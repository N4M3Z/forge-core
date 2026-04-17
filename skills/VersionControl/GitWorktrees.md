## Git Worktrees

Isolated workspaces sharing a single repo — work on multiple branches in parallel without switching.

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

### Cleanup

When work is merged or abandoned:

```sh
git worktree remove .worktrees/<branch>
git worktree list
```

Never delete a worktree directory manually — always use `git worktree remove` so the repo's worktree list stays consistent.

### Red flags

- Creating a worktree without checking the directory is gitignored — contents leak into the parent repo's status
- Skipping the baseline test run — can't distinguish new bugs from pre-existing breakage
- Deleting worktree directories with `rm -rf` instead of `git worktree remove` — leaves dangling references in `.git/worktrees/`
- Hardcoding setup commands without detecting the project type — breaks on unfamiliar stacks

---

*Git worktree content adapted from [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) (MIT) under EUPL-1.2.*
