---
title: "Per-Tool Memory Files"
description: "Each AI tool's primary memory file (CLAUDE.md, AGENTS.md, GEMINI.md) stays self-contained, not imported or generated from a shared canonical source"
type: adr
category: architecture
tags:
    - architecture
    - documentation
    - cross-tool
status: accepted
created: 2026-04-23
updated: 2026-04-23
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0008 Multi-Provider Support.md"
    - "ARCH-0001 Skills Agents and Rules.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Per-Tool Memory Files

## Context and Problem Statement

Modules host content for several AI tools (Claude Code, Codex, Gemini, OpenCode). Each tool reads its own primary memory file from the repo root: Claude Code reads `CLAUDE.md`, Codex reads `AGENTS.md` ([agents.md][AGENTSMD]), Gemini reads `GEMINI.md`. Claude Code's memory documentation states explicitly: *"Claude Code reads `CLAUDE.md`, not `AGENTS.md`"* ([Claude memory docs][CCMEM]), and recommends importing `AGENTS.md` from `CLAUDE.md` if both must share content.

Two approaches present themselves: keep one canonical file (e.g., `AGENTS.md`) and have all others import or symlink to it, or keep one file per tool with deliberate isolation. The question is whether convergence or divergence is the more sustainable default as the tool roster grows.

## Decision Drivers

- Each tool has its own quirks: load order, comment syntax, import directives (`@path` for Claude Code, none for Codex), context-window limits (Claude Code recommends under 200 lines; Codex has no documented limit), hook system, plugin model. Guidance optimal for one tool can be wrong for another.
- New tool integrations should be additive, not refactors of existing files.
- A single canonical file invites tool-specific guidance to leak into shared content. Once that happens, the other tool's behavior becomes unpredictable.
- Multi-provider support ([ARCH-0008](ARCH-0008 Multi-Provider Support.md)) already establishes per-provider artifact isolation for skills and agents. Memory files follow the same logic.

## Considered Options

1. **Single canonical source with per-tool imports** — `AGENTS.md` is canonical, `CLAUDE.md` contains `@AGENTS.md`, `GEMINI.md` symlinks. One source of truth, automatic sync.
2. **Per-tool files, deliberately separate** — `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` each maintained independently. Some duplication, no cross-tool coupling.
3. **Generated per-tool files from a canonical source** — a build step renders per-tool variants from a master document with provider-specific sections.

## Decision Outcome

Chosen option: **per-tool files, deliberately separate**. Each tool's primary memory file lives at the repo root, owned by that tool, and is internally complete. Authors do not import or symlink between them. Some content (project structure, build commands) appears in multiple files; this is the accepted cost of tool isolation.

When a new tool integration arrives (e.g., Codex creates its own `AGENTS.md` with Codex-specific quirks), existing files are not touched. When a tool-specific behavior is documented, it lands only in that tool's file.

### Consequences

- [+] Tool quirks stay isolated. A Claude Code plan-mode instruction in `CLAUDE.md` cannot accidentally apply to Codex.
- [+] New tool integrations are additive, not refactors.
- [+] Each file can be tuned for its tool's loading model — `CLAUDE.md` benefits from being concise per the [Claude memory docs][CCMEM]; `AGENTS.md` has no such limit.
- [-] Shared content (project structure, build commands, conventions) is duplicated across files and can drift.
- [-] No automated mechanism to flag drift; relies on periodic audits.

### Mitigations

- Periodic doc reviews catch material drift between files.
- The companion rule [IsolateHarnessMemory][RULE] gives an always-loaded directive against merging or cross-importing these files.
- Content that genuinely belongs in one place (deployment internals, ADR index, FAQ) lives in `docs/` or `ARCHITECTURE.md`, not in tool memory files.

## Related Decisions

- [ARCH-0008](ARCH-0008 Multi-Provider Support.md) — establishes per-provider artifact isolation for skills and agents
- [ARCH-0001](ARCH-0001 Skills Agents and Rules.md) — defines the artifact classes that load alongside memory files

[AGENTSMD]: https://agents.md "AGENTS.md cross-tool standard"
[CCMEM]: https://code.claude.com/docs/en/memory "Claude Code memory documentation"
[RULE]: ../../rules/IsolateHarnessMemory.md
