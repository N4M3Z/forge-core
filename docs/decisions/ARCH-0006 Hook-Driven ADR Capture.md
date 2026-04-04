---
title: Hook-Driven ADR Capture
description: PreCompact and SessionStart hooks prompt for ADR capture before context is lost
type: adr
category: architecture
tags:
    - architecture
    - adr
    - hooks
status: accepted
created: 2026-03-07
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0004 Adopt Architecture Decision Records.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Hook-Driven ADR Capture

## Context and Problem Statement

ADRs require authoring discipline ([CORE-0004](CORE-0004 Adopt Architecture Decision Records.md)). Architectural decisions happen naturally during sessions — technology choices, pattern adoptions, convention changes — but they're rarely written down in the moment. After context compaction or session end, the reasoning that led to decisions is compressed away or lost entirely.

## Decision Drivers

- Decisions made during sessions must survive context compaction
- Manual ADR creation after the fact relies on remembering what was decided and why
- The capture prompt must fire at the right moments — after compaction and on session resume
- The module must work both as a dispatch module (via `hooks/<Event>.sh`) and as a standalone Claude Code plugin (via `hooks.json`)

## Considered Options

1. **Manual capture only** — rely on authors to invoke the ArchitectureDecisions skill when they recognize a decision was made
2. **PreCompact hook** — prompt for ADR capture before context is compressed, catching decisions while they're still in the window
3. **SessionStart hook on compact/resume** — prompt after compaction or session continuation, when the summary is available but details are about to be lost
4. **Both PreCompact and SessionStart** — belt and suspenders

## Decision Outcome

Chosen option: **Both PreCompact and SessionStart**. PreCompact fires before compression, warning about uncaptured decisions while full context is available. SessionStart fires on `compact` and `resume` sources, prompting the ArchitectureDecisions skill to extract decisions from the compacted summary. Dual-mode support: `hooks/<Event>.sh` for dispatch, `hooks.json` with matchers for standalone plugin use.

### Consequences

- [+] Two capture opportunities — before and after compaction
- [+] Works in both dispatch and standalone plugin modes
- [+] Configurable via `yaml env` — prompt text and behavior adjustable per module
- [-] The prompt is advisory, not enforcing — the AI may not act on it in a busy session
