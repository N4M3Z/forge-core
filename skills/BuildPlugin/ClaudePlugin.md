Claude Code plugin structure and auto-discovery conventions ([plugins reference][CCPLUGINS], [creating plugins][CCCREATE]).

Auto-discovered directories from a plugin:

| Directory        | Loaded when                            |
| ---------------- | -------------------------------------- |
| `skills/`        | User invokes or Claude matches         |
| `agents/`        | User selects or Claude delegates       |
| `hooks/`         | Event fires (SessionStart, PreToolUse) |
| `commands/`      | Legacy name for skills                 |
| `output-styles/` | Output formatting                      |
| `.mcp.json`      | MCP server definitions                 |
| `.lsp.json`      | LSP server definitions                 |
| `settings.json`  | Default agent settings                 |

Not discovered: `rules/`, `CLAUDE.md`, `memory/`. These only load from project-level (`.claude/`) and user-level (`~/.claude/`) paths.

`bin/` is flat: files directly inside are added to the Bash tool's PATH ([plugins reference][CCPLUGINS]). No subdirectory recursion. Use extensionless names with shebangs and `chmod +x`.

Environment variables available in hook commands and subprocesses:

| Variable                 | Scope                                            |
| ------------------------ | ------------------------------------------------ |
| `${CLAUDE_PLUGIN_ROOT}`  | Plugin installation directory (reset on updates) |
| `${CLAUDE_PLUGIN_DATA}`  | Persistent data directory surviving updates       |

To deliver always-on domain knowledge from a plugin, use a SessionStart hook that emits rule content as `additionalContext`:

```json
{"hookSpecificOutput":{"additionalContext":"rule content here"}}
```

Manifest at `.claude-plugin/plugin.json`: `name` (kebab-case) is the only required field.

[CCPLUGINS]: https://code.claude.com/docs/en/plugins-reference
[CCCREATE]: https://code.claude.com/docs/en/plugins
