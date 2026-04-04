---
title: Platform-Specific Companion Files
description: Platform-variant companion files organize provider-specific instructions alongside platform-agnostic skills
type: adr
category: architecture
tags:
    - architecture
    - skills
    - providers
status: accepted
created: 2026-03-01
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0002 Skills Companion Files.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [GeminiAgents.md, CodexAgents.md]
---

# Platform-Specific Companion Files

## Context and Problem Statement

The VersionControl skill needs to teach both GitHub and GitLab workflows — different CLIs (`gh` vs `glab`), different branch protection models, different CI systems (Actions vs GitLab CI). With companion files adopted ([ARCH-0002](ARCH-0002 Skills Companion Files.md)), a specific convention is needed for how skills organize platform-variant companions so the pattern is replicable across all skills.

## Decision Drivers

- GitHub and GitLab have different CLIs (`gh` vs `glab`), different APIs, and different CI systems
- One skill should handle both — duplicating into separate skills means duplicating shared logic
- An AI working with GitLab shouldn't load GitHub-specific instructions
- Any skill author must know exactly how to add a platform companion: file naming, `@` reference, directory placement

## Considered Options

1. **Inline platform sections** — `## GitHub` and `## GitLab` headings inside SKILL.md, always loaded regardless of relevance
2. **Platform companion files** — `GitHub.md` and `GitLab.md` alongside SKILL.md, referenced via `@`, loaded selectively
3. **Platform-specific skills** — separate VersionControl-GitHub and VersionControl-GitLab skills, clean but duplicated core logic

## Decision Outcome

Chosen option: **Platform companion files**. Each platform gets its own companion file (e.g., `GitHub.md`, `GitLab.md`) inside the skill directory. SKILL.md contains the platform-agnostic workflow and references companions via `@`. The AI loads only the relevant companion based on the user's environment.

### Consequences

- [+] Core skill stays platform-agnostic — shared logic written once
- [+] Platform companions independently maintainable and testable
- [+] Pattern scales to any number of platforms without bloating the core skill
- [-] Skill directories grow with each platform — discoverability depends on consistent naming
