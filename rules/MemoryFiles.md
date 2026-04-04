Never store learnings, feedback, or conventions in Claude Code's auto-memory (`~/.claude/projects/.../memory/`). All reusable knowledge belongs in the relevant module's `rules/` directory where it gets version-controlled, installed to `.claude/rules/`, and shared across sessions.

Auto-memory is ephemeral, invisible to other tools, and truncated at 200 lines. Module rules are the source of truth. When you learn something that should persist (a correction, a convention, a pitfall), write a rule file in the owning module. If no module clearly owns it, use forge-steering.
