---
title: Skills Companion Files
description: Sidecar YAML files carry metadata the canonical skill file should not express
type: adr
category: architecture
tags:
    - architecture
    - skills
status: accepted
created: 2026-02-22
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [CanonSidecar.md]
---

# Skills Companion Files

## Context and Problem Statement

As skills grew in scope, SKILL.md files became long and mixed concerns — platform-specific instructions, reference material, examples, and templates all in one file. This bloated context windows (AI tools pay per token) and made maintenance harder. Updating Claude-specific guidance meant editing a file that also contained Gemini instructions.

## Decision Drivers

- Context window efficiency — unused platform instructions are wasted tokens
- Separation of concerns — platform-specific, reference, and example content should be isolatable
- Skills must remain self-contained — no dependencies beyond the skill directory
- Both Claude Code and PAI use `@` file includes for skill composition

## Considered Options

1. **Monolithic SKILL.md** — everything in one file, simple but bloated
2. **Companion files with `@` includes** — SKILL.md references topic-specific files (ClaudeSkill.md, ADRTemplate.md) via `@FileName.md`, loaded on demand
3. **Separate skills per concern** — one skill per platform or topic, maximum separation but content duplication

## Decision Outcome

Chosen option: **Companion files with `@` includes**, following the pattern established by PAI's skill system where SYSTEM and USER layers compose via file references. SKILL.md stays focused on the core workflow. Platform-specific instructions, reference material, and examples live in companion `.md` files referenced via `@FileName.md`. The install system resolves includes at deploy time.

### Consequences

- [+] Core skill stays concise — companions loaded only when relevant
- [+] Platform-specific content updated independently without touching the main skill
- [+] Same pattern works for reference material, examples, and templates
- [+] `@` includes are optional — Claude Code autodiscovers files in skill directories — but explicit references provide composition control over which companion loads when


## More Information

- [PAI Skills System](https://danielmiessler.com/blog/personal-ai-infrastructure) — Daniel Miessler's Personal AI Infrastructure, where the companion file pattern originates
- [Extend Claude with skills](https://docs.claude.com/en/docs/claude-code/slash-commands) — Claude Code's native `@` include support
