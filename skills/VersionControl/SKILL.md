---
name: VersionControl
version: 0.2.0
description: "Git best practices — conventional commits, staging, push policy, pre-commit gates, repo governance. USE WHEN committing, pushing, creating PRs, branch protection, rulesets, CODEOWNERS, pre-commit hooks, blocking known-dangerous strings."
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

- Stage specific files by name; never use `git add -A` or `git add .`
- Never commit files that contain secrets (`.env`, credentials, API keys)
- Stage and pause for the user to self-review before the commit lands. See [StageForReview](../../rules/StageForReview.md) for the rule, [StagedReview](../StagedReview/SKILL.md) for the review workflow with `tuicr` / `revdiff` / `git diff --cached`.

## Pre-commit Gates

Every repo runs two stacked gates: gitleaks (categorical, pattern-based) and a known-dangerous-strings grep (specific, user-curated). gitleaks alone misses anything that doesn't match its built-in rules — legacy email addresses, retired internal hostnames, an old phone number — because those look like ordinary text. The user knows them; encode that knowledge in the hook.

### Layer 1: gitleaks

See the [SecretScan](../SecretScan/SKILL.md) skill for install, `.gitleaks.toml`, and baseline workflow. This is the categorical layer — API tokens, private keys, connection strings.

### Layer 2: known-dangerous strings

Maintain a per-user list of literal strings that must never enter any repo. Typical entries:

- Deprecated email addresses (`@protonmail.com`, `@me.com`, old company addresses)
- Retired internal hostnames or IPs
- Personal phone numbers in any format
- Legacy handles or usernames you no longer want indexed

Keep the list at `~/.config/git/danger-strings` (plain text, one regex per line, `#` comments allowed). Manage it alongside dotfiles so the same list deploys to every machine.

```text
# ~/.config/git/danger-strings — extended regex, one per line
@protonmail\.(com|ch)
@me\.com
\b\+420[\s-]?\d{3}[\s-]?\d{3}[\s-]?\d{3}\b
oldhost\.internal\.example
```

Install one hook in `~/.config/git/hooks/pre-commit` and point every clone at the shared hooks directory:

```sh
git config --global core.hooksPath ~/.config/git/hooks
```

The hook (POSIX, exit 1 on hit):

```sh
#!/bin/sh
set -e
list="${HOME}/.config/git/danger-strings"
[ -r "$list" ] || exit 0
staged=$(git diff --cached --name-only --diff-filter=ACMR)
[ -z "$staged" ] && exit 0
patterns=$(grep -Ev '^\s*(#|$)' "$list" | paste -sd '|' -)
[ -z "$patterns" ] && exit 0
if printf '%s\n' "$staged" | xargs -I{} git show ":{}" 2>/dev/null | grep -E "$patterns"; then
    echo "pre-commit: known-dangerous string in staged content — fix or update danger-strings list" >&2
    exit 1
fi
```

`grep` over `git show ":path"` (the staged blob), not the working tree, so a partial `git add -p` is checked at the actual byte content about to be committed.

CI runs the same two gates as the second line of defense: a workflow step that reads the same `danger-strings` file (committed to the dotfiles repo, fetched in CI) and fails the build if the diff against the base branch contains a hit. See [SecretScan](../SecretScan/SKILL.md) for the gitleaks CI integration.

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

For parallel feature work in a single clone, use git worktrees instead of stashing or switching.

@GitWorktrees.md

## Sources

- <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets>
- <https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners>
- <https://docs.gitlab.com/user/project/protected_branches/>
