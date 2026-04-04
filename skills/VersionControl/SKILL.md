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
