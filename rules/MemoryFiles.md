Reusable knowledge (conventions, corrections, pitfalls) graduates to a rule in the owning module's `rules/` directory, where it gets version-controlled, installed to every provider's rules tree, and stays visible across harnesses. A convention that lives only in one harness's auto-memory counts as unrecorded. If no module clearly owns it, use forge-steering.

Harness auto-memory (Claude Code's `~/.claude/projects/<project>/memory/`, Codex/Gemini/opencode equivalents) is a supplementary layer for session continuity, user context, and project state. It is never the system of record.
