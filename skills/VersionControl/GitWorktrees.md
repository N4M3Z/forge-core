## Git Worktrees

Isolated workspaces sharing a single repo — work on multiple branches in parallel without switching.

### jj-colocated repos: this skill does not apply

If `.jj/` exists at repo root, do NOT use git worktrees — `git worktree add` mutates refs behind jj's back, and jj's auto-snapshot does not cover trees it doesn't own. Check first:

```sh
[ -d "$(git rev-parse --show-toplevel)/.jj" ] && echo "jj-colocated: use jj workspaces"
```

The replacement is `jj workspace add ../repo-<name>` (shared store/history/op-log, isolated working copy per agent); clean up with `jj workspace forget <name>`. EnterWorktree is blocked in these repos by a settings hook, and worktree-isolated subagents are equally off-limits. Mechanics live in the forge-dev JujutsuToolkit skill; commit/push discipline in VersionControl/Jujutsu.md.

### Directory selection priority

1. **Use an existing `.worktrees/` or `worktrees/` directory** if either is present at repo root. If both exist, prefer `.worktrees/`.
2. **Respect CLAUDE.md preference** if it documents a worktree location (`grep -i "worktree.*director" CLAUDE.md`).
3. **Ask the user** only when neither of the above applies — offer `.worktrees/` (project-local, hidden) or `~/.config/worktrees/<project>/` (global).

### Safety verification

For project-local directories, confirm the directory is gitignored before creating a worktree — otherwise worktree contents get staged:

```sh
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

If not ignored, add it to `.gitignore` and commit that change before proceeding. Global directories (outside the repo) need no verification.

### Create and prepare

```sh
project=$(basename "$(git rev-parse --show-toplevel)")
path=".worktrees/$BRANCH_NAME"          # or a resolved global path
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

After the worktree exists, auto-detect and run project setup so the new tree matches the parent:

```sh
[ -f package.json ]     && npm install
[ -f Cargo.toml ]       && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f pyproject.toml ]   && poetry install
[ -f go.mod ]           && go mod download
```

Run the project's test suite once to establish a clean baseline. If tests fail, stop and report — don't proceed on a broken baseline.

### Session-scoped worktrees

Worktrees created by agent tooling (EnterWorktree, worktree-isolated subagents) live under `~/worktrees/<repo>/<name>/` at a **detached HEAD** — no branch points at them, so nothing reminds anyone they exist. Exit with `ExitWorktree(action: "remove")` once the work lands; if the session ends any other way, only the orphan sweep below catches them.

### Cleanup

Removing the worktree is part of landing the work — a merge is not complete while its worktree still exists. When work is merged or abandoned:

```sh
git worktree remove <path>
git worktree list    # verify nothing lingers
```

Never delete a worktree directory manually — always use `git worktree remove` so the repo's worktree list stays consistent.

Before finishing any task that used worktrees, sweep for orphans: for every linked worktree in `git worktree list`, if its tree is clean and its HEAD is already in the mainline (`git merge-base --is-ancestor <sha> <mainline>`), remove it.

### Red flags

- Creating a worktree without checking the directory is gitignored — contents leak into the parent repo's status
- Skipping the baseline test run — can't distinguish new bugs from pre-existing breakage
- Deleting worktree directories with `rm -rf` instead of `git worktree remove` — leaves dangling references in `.git/worktrees/`
- Ending a session with a merged worktree still attached — detached-HEAD session worktrees accumulate silently under `~/worktrees/` because no branch names them
- Hardcoding setup commands without detecting the project type — breaks on unfamiliar stacks

---

*Git worktree content adapted from [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) (MIT) under EUPL-1.2.*
