---
name: VersionControl
version: 0.1.0
description: "Git best practices — conventional commits, staging, push policy, repo governance. USE WHEN committing, pushing, creating PRs, branch protection, rulesets, CODEOWNERS."
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

**Never** add `Co-Authored-By` trailers unless the user explicitly asks.

## Staging

- Stage specific files by name — never use `git add -A` or `git add .`
- Review `git diff --staged` before committing
- Never commit files that contain secrets (`.env`, credentials, API keys)

## Push Policy

- Never force-push (`--force`, `--force-with-lease`) unless the user explicitly asks
- Never skip hooks (`--no-verify`) unless the user explicitly asks
- Do not push unless the user asks — committing and pushing are separate actions

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
