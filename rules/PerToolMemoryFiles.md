Each AI tool's memory file at the repo root (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.codex/AGENTS.md`, etc.) is self-contained. Do not collapse them into a single canonical file or import one from another via `@path`, symlinks, or build-step generation.

Tool-specific guidance (plan mode, hook syntax, import directives, context-window limits) belongs only in that tool's file. Shared content (project structure, build commands) appearing in multiple files is the accepted cost of tool isolation.

Reasoning: [ARCH-0014 Per-Tool Memory Files](../docs/decisions/ARCH-0014 Per-Tool Memory Files.md).
