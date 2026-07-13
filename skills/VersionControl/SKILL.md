---
name: VersionControl
version: 0.3.0
description: "Git best practices: conventional commits, staging, push policy, pre-commit checks, repo governance, plus Jujutsu (jj) colocated repos (commit and push discipline, push-batched signing, secret scans relocated to pre-push). USE WHEN committing, pushing, creating PRs, branch protection, rulesets, CODEOWNERS, pre-commit hooks, blocking known-dangerous strings, or working in a jj / jujutsu / colocated repo."
---

# VersionControl

Git conventions and repo governance. Commit discipline, staging hygiene, and platform-specific branch protection.

## Commit Messages

Use conventional commit prefixes. Message should explain **why**, not what.

| Prefix       | Use when                                |
|--------------|-----------------------------------------|
| `feat:`      | New feature or capability               |
| `fix:`       | Bug fix                                 |
| `refactor:`  | Restructuring without behaviour change  |
| `docs:`      | Documentation only                      |
| `chore:`     | Maintenance (deps, configs, CI)         |
| `test:`      | Adding or fixing tests                  |

Keep the first line under 72 characters. Add a blank line and body for context when the change is non-obvious.

AI agents set the commit author to their own identity with model id (`Claude Fable 5 (claude-fable-5)`); additional contributors on the same commit get `Co-Authored-By` trailers in the same format, solo commits none. See [GitConventions](../../rules/GitConventions.md).

## Staging

- Stage specific files by name; never use `git add -A` or `git add .`
- Commit with a pathspec (`git commit -- <path>...`), never a bare `git commit`. A bare commit snapshots the **entire index**, so any work already staged in the repo — the user's in-flight changes — is swept into your commit under your message. Pathspec-commit lands only the files you name. When unsure what is staged, run `git diff --cached --stat` first and confirm it shows only your files.
- Never commit files that contain secrets (`.env`, credentials, API keys)
- Stage and pause for the user to self-review before the commit lands. See [StageForReview](../../rules/StageForReview.md) for the rule, [StagedReview](../StagedReview/SKILL.md) for the review workflow with `tuicr` / `revdiff` / `git diff --cached`.

## Jujutsu (jj) repositories

jj is the default working VCS where the repo is colocated. The routing principle: agents work in jj changes (auto-snapshotted, describable, abandonable, op-log-recoverable); a git commit is the human-boundary artifact, materialized when work crosses to people (push, PR, review). A commit is not a useful working artifact for an agent, so reserve an explicit `git commit` for landing a large, coherent chunk of work, and let jj carry the routine working-copy churn otherwise. The same routing governs parallelism: jj workspaces for agents in jj repos, git worktrees only in git-only repos.

When the repo is colocated with jj (`.jj/` at the root), there is no staging area and the commit and push workflow differs: the working copy is a commit, signing is batched at push, and git hooks (including the checks below) do not fire. See [Jujutsu.md](Jujutsu.md) for the jj commit and push discipline and how the secret scans relocate to pre-push.

## Pre-commit Checks

Two stacked checks protect against leaking PII or secrets into git history. Both must pass before a commit lands.

**Layer 1 — gitleaks.** Categorical scanner for API tokens, private keys, connection strings. Fires via the repo's `.githooks/pre-commit` for user-typed commits. See [SecretScan](../SecretScan/SKILL.md) for `.gitleaks.toml` and baseline workflow.

**Layer 2 — safety-net.** A user-curated regex list at `~/.config/forge/safety-net` (per the [UserConfig](../../rules/UserConfig.md) rule) catches everything gitleaks misses: deprecated emails, personal phones, internal hostnames, legacy handles. The `safety-net` Claude Code hook (`hooks/safety-net.sh`, auto-discovered via `hooks.json`) intercepts AI-initiated `git commit` calls, walks staged blobs, and emits a block decision on any match. CI runs the same regex check as second-line defense.

### Which layer owns what

| Pattern type                                | Layer      | Why                                            |
| ------------------------------------------- | ---------- | ---------------------------------------------- |
| API keys, tokens, private key blocks        | gitleaks   | Categorical rules updated by the community     |
| Credentials in `.env` or config files       | gitleaks   | Pattern-based detection                        |
| User-specific identifiers (emails, phones)  | safety-net | Only you know what's dangerous for you         |
| Deprecated addresses, legacy handles        | safety-net | Not in any public rule database                |

When in doubt, add to safety-net. gitleaks rules evolve upstream; safety-net patterns are yours to control.

### When a check blocks

1. Read the block reason (match count, config path)
2. Inspect the staged diff to find the offending lines
3. Fix the content, re-stage, and retry
4. If it's a false positive (test fixture, inert example), update `~/.config/forge/safety-net` to exclude the pattern or add the file to `.gitleaks.toml` allowlist. Never bypass with `--no-verify`.

### Relationship to ForensicAgent

Safety-net is the **deterministic prevention layer** (regex, runs on every commit, no AI). [ForensicAgent](../../agents/ForensicAgent.md) is the **AI-driven detection layer** (prose rules from `~/.config/forge/forensic.yaml`, runs on demand or during audits). The hook reads `safety-net`; the agent reads `forensic.yaml`. They complement each other but never share config files.

After a ForensicAgent scan surfaces a new leaked pattern, add it to `~/.config/forge/safety-net` so the hook prevents recurrence.

See [INSTALL.md](INSTALL.md) for config-file setup and verification.

### Validation chain

Single validation path: `make validate` → `.githooks/pre-commit`; CI runs the same checks via [prek](https://github.com/j178/prek). Never duplicate validation logic across Makefile recipes, CI workflow steps, and hook scripts. Without prek, fall back to `forge validate` or the hash-verified validate.sh download.

## Session checkpointing (Entire)

Repos with Entire enabled install git hooks via `core.hooksPath` that inject a session trailer on commit and ship session logs on push. They run alongside the secret scans on normal `git commit` / `git push`, so keep the gitleaks `pre-commit` hook in the same hooks directory Entire points at, or it stops firing. Capture itself runs off Claude Code hooks, not git, so it is VCS-agnostic. Under jj the git hooks do not fire; see [Jujutsu.md](Jujutsu.md).

## Push Policy

- Never force-push unless the user explicitly asks. When force-pushing is sanctioned, default to `--force-with-lease` not `--force` — lease fails fast if the remote moved since your last fetch, and safety-net plugins allow lease while blocking raw force
- Never skip hooks (`--no-verify`) unless the user explicitly asks
- Do not push unless the user asks — committing and pushing are separate actions

## History Rewrite

When squashing, reordering, or rebuilding a linear history, `git read-tree -u --reset <sha>` is the cleanest primitive — it snaps the index and working tree to any commit's tree state without running a merge or rebase. Build the new history by iterating target commits:

```sh
git branch backup-pre-squash            # always create a safety branch first
git checkout --orphan squashed-tmp
git read-tree -u --reset <end-of-group-1-sha>
git commit -m "<new message 1>"
git read-tree -u --reset <end-of-group-2-sha>
git commit -m "<new message 2>"
# repeat for each group, then swap branches
git branch -f main squashed-tmp
git switch main
git branch -d squashed-tmp
git push --force-with-lease origin main
```

Respect commit chronology when grouping. Squashing by theme fails when commits are interleaved across themes — the end-of-group tree snapshot inherits every earlier commit's content, so a commit titled "Rust rules" also carries whatever unrelated work preceded it. Group along the chronological spine and name commits by the actual content in each tree snapshot.

Before any destructive rewrite, create a backup branch (`git branch backup-pre-<op>`). Costs nothing, preserves the old tip for recovery, and lets you diff the rewritten history against the original to confirm content parity before force-pushing.

## Restructuring directories

Converting a tracked directory to a submodule, extracting a subtree into its own repo, or otherwise removing and re-cloning a directory destroys its GITIGNORED files. Tracked content is restorable from a commit, a `git bundle`, or a re-clone; `.env`, secrets, `.venv`, and local config live in no commit, no bundle, and no stash, so the `rm -rf` the surgery requires erases them permanently. A `git bundle --all` recovery point does NOT cover them — only a filesystem snapshot does.

Back up the directory before touching the tree (`cp -a <dir> <scratch>`), restore the gitignored files into the new submodule or repo afterward, and confirm the critical secrets (`.env`, tokens) survived before calling the restructure done. The deny rules that stop the AI from reading `.env` also stop it from verifying the restore, so the human confirms.

A jj-colocated repo cannot create the conversion: jj ignores submodules, so snapshotting a dir-turned-submodule records file deletions, not a gitlink. Commit the `git submodule add` through git, then `jj git import` — jj holds the imported gitlinks cleanly even though it cannot author them.

The conversion is invisible in the filesystem: a submodule mount is byte-identical to the directory it replaced (same files, same paths), and nested mounts still appear at every location. Confirm it landed with `git submodule status` and `file <dir>/.git` (a submodule's `.git` is a file, not a directory), never by eyeballing the tree — the payoff is one source repo behind identical-looking mounts, not a visibly different layout. State this up front, or the operator who sees an unchanged tree concludes it failed.

Draw the mount-vs-source line explicitly, or the operator reads the in-tree dirs as stale copies to delete. The in-tree dirs are the live submodule working copies; the source repos are the remote (or the local bares standing in for it), which sit OUTSIDE the super-repo. Deleting an in-tree mount only forces a `git submodule update` to restore it — the dirs staying put is correct, not leftover cleanup.

Point the submodules at the real remote (GitHub/GitLab) as part of the conversion, not after. Local bares standing in for that remote are scaffolding: use RELATIVE URLs (`../<bares>/<name>.git`), never absolute filesystem paths, which pin the super-repo to one machine and path so it clones nowhere else. A super-repo whose submodules resolve only to local absolute-path bares carries no component history of its own and is not standalone-cloneable, which reads to the operator as "where is the canonical repo?". Once the components are pushed to the host and `.gitmodules` re-pointed there, the local bares are disposable.

## Pull Requests

- Title under 70 characters — details go in the body
- Body format: `## Summary` (1-3 bullets) + `## Test plan` (checklist)
- Create from a feature branch, never directly from main

## Post-Merge Branch Cleanup

After a PR merges, delete the local and remote branch — feature branches accumulate fast and squash-merges leave them behind.

Squash-merge changes the commit hash, so `git branch -d` refuses with "not fully merged." Verify state via the platform first, then force-delete:

```sh
# Verify merge state per branch (gh / glab)
gh pr list --head feat/my-branch --state all --limit 1

# Local — squash-merged branches need -D
git branch -D feat/my-branch

# Remote — separate operation
git push origin --delete feat/my-branch
```

If the [safety-net][SAFETY] plugin is installed, `git branch -D` is blocked from AI agents (force-delete bypasses the merge check). Hand the command back to the user to run in their own terminal — write out the exact command in a shell block and ask them to execute it. Same applies for `git push origin --delete` if the safety net is configured to block remote-destructive operations.

[SAFETY]: https://github.com/kenryu42/claude-code-safety-net

For local branches whose remote was deleted but the local copy lingers, use `git fetch --prune` then the `commit-commands:clean_gone` skill (or `git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D`).

Use `git switch <branch>` rather than `git checkout <branch>` — checkout's positional args parse ambiguously and trip safety nets.

## Repo Governance

Platform-specific branch protection, rulesets, and code ownership.

| Platform | CLI    | Companion  | Detect by                     |
|----------|--------|------------|-------------------------------|
| GitHub   | `gh`   | @GitHub.md | `github.com` in remote origin |
| GitLab   | `glab` | @GitLab.md | `gitlab.com` in remote origin |

Auto-detect from the remote origin URL. If ambiguous, ask the user.

### Principles

- Prefer rulesets over legacy branch protection (GitHub) — rulesets are more granular and support bypass actors
- Document governance in the repo itself (CODEOWNERS, branch rules) not just in external settings
- Always read current rules before modifying — audit first, change second

## Commit Signing

GPG with the YubiKey OpenPGP slot and `pinentry-mac` is the preferred path on macOS. SSH with FIDO2 hardware keys (`sk-ssh-ed25519`) is the alternative; on macOS it needs a wrapper around Apple's bundled `ssh-agent`.

@CommitSigning.md

## Parallel Work

In git-only repos, use git worktrees for parallel feature work instead of stashing or switching. In jj-colocated repos, git worktrees do not apply; use jj workspaces (the companion's carve-out has the details).

@GitWorktrees.md

## Sources

- <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets>
- <https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners>
- <https://docs.gitlab.com/user/project/protected_branches/>
