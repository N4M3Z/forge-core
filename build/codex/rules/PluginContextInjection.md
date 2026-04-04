Claude Code plugins cannot ship `rules/` or `CLAUDE.md` — those only load from project-level (`.claude/rules/`) and user-level (`~/.claude/rules/`) paths. Plugins auto-discover `skills/`, `agents/`, `hooks/`, `commands/`, `output-styles/`, `.mcp.json`, `.lsp.json`, and `settings.json`.

To deliver always-on domain knowledge (equivalent to rules) from a plugin, use a `SessionStart` hook that reads rule files and emits them as `additionalContext`:

```json
{"hookSpecificOutput":{"additionalContext":"rule content here"}}
```

The hook script reads `${CLAUDE_PLUGIN_ROOT}/rules/*.md`, JSON-escapes the content, and prints the JSON object to stdout. This is the pattern used by superpowers, explanatory-output-style, and other plugins that ship behavioral conventions.

Skills and agents are on-demand (loaded when invoked). Only SessionStart hooks inject content unconditionally into every session.