---
name: GuardRails
description: "Safety guardrails: runtime overrides for AI-safety plugin blocks, and per-language security review for python, javascript/typescript, and go. USE WHEN a safety plugin blocks a command, sandbox blocked, git reset --hard blocked, rm -rf blocked, workaround for a blocked command, safety plugin configuration, security review, secure-by-default coding, vulnerability report."
version: 0.2.0
allowed-tools: Read, Grep, Glob, Write, Edit
---

# GuardRails

Two related disciplines under one roof: making sure execution doesn't go wrong at runtime, and making sure code doesn't ship with foreseeable vulnerabilities. Read the relevant companion based on the current need.

## Companions

- [DestructiveCommandGuard.md](DestructiveCommandGuard.md) — reference for [dcg](https://github.com/Dicklesworthstone/destructive_command_guard): rules, workarounds, when not to disable.
- [SecurityReview.md](SecurityReview.md) — per-language security review (python, javascript/typescript, go); secure-by-default coding, passive detection, full vulnerability reports.

Future safety plugins land as sibling companions following the same shape: overview, what they catch, workarounds, configuration, when not to disable.

## Routing

| Trigger                                                       | Read                                |
| ------------------------------------------------------------- | ----------------------------------- |
| A command just got blocked with a safety-plugin error         | The plugin's companion (`DestructiveCommandGuard.md` and similar) |
| Configuring a safety plugin for the first time                | The plugin's companion              |
| Considering whether to disable or override a rule             | The plugin's § When not to disable  |
| User requests a security review of code                       | `SecurityReview.md`                 |
| Starting a new project, want secure-by-default coding         | `SecurityReview.md`                 |
| Producing a vulnerability report                              | `SecurityReview.md`                 |

## Cross-cutting constraints

- Never disable a safety plugin to push a blocked command through.
- Never retry a blocked command with cosmetic variations to slip past the regex.
- When a block catches a genuine mistake, thank the guardrail and pick the safer path.
- For irrecoverable operations (force-push to main, drop production table, unbounded `rm`), prefer hand-off to the user over attempting the command yourself.
- Security review triggers only on explicit security-review requests, never on generic code review or debugging.
