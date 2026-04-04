Claude Code plugin marketplace conventions for Cowork and CLI distribution.

## Marketplace Repository

The marketplace manifest lives at `.claude-plugin/marketplace.json` in the repo root. Required fields:

```json
{
    "name": "marketplace-name",
    "owner": { "name": "github-username" },
    "plugins": []
}
```

Plugin entries require `name`, `description`, and `source`. For subtree-embedded plugins, `source` is a relative path:

```json
{
    "name": "Forge Finance",
    "description": "One-line description",
    "source": "./forge-finance"
}
```

Plugin names use title case in `marketplace.json` ("Forge Finance"). Directory names use kebab-case (`forge-finance`).

Remote source types are also supported: `{"type": "url", "url": "https://..."}`, `{"source": "github", "repo": "owner/repo"}`, `git-subdir`, `npm`.

## Cowork Constraints

- Cowork clones marketplace repos with plain `git clone` (no `--recursive`) — plugin files must be physically present, not submodules
- Plugins are embedded as `git subtree` directories at the repo root
- The Cowork GitHub App must be installed on the repo
- Sync fires on PR merge to default branch, or manually on demand

## Plugin Auto-Discovery

Claude Code auto-discovers these directories from a plugin:

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

**Not discovered: `rules/`, `CLAUDE.md`, `memory/`.** These only load from project-level (`.claude/`) and user-level (`~/.claude/`) paths. See PluginContextInjection rule for the workaround.

## Reserved Names

Cannot use: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`, or names impersonating Anthropic.

## Plugin Requirements

Each plugin needs `.claude-plugin/plugin.json`:

| Field         | Required | Example                                |
| ------------- | -------- | -------------------------------------- |
| `name`        | yes      | `"Forge Finance"`                      |
| `version`     | yes      | `"0.1.0"`                              |
| `description` | yes      | `"Tax law rules and filing workflows"` |
| `author`      | yes      | `{"name": "Author Name"}`             |
| `license`     | no       | `"EUPL-1.2"`                           |
| `repository`  | no       | `"https://github.com/owner/repo"`      |
| `keywords`    | no       | `["tax", "finance"]`                   |
| `skills`      | if any   | `["./skills"]`                         |
| `agents`      | if any   | `["./agents"]`                         |
| `hooks`       | if any   | `"./hooks/hooks.json"`                 |

[1]: https://support.claude.com/en/articles/13837433-manage-cowork-plugins-for-your-organization
[2]: https://code.claude.com/docs/en/plugin-marketplaces
[3]: https://code.claude.com/docs/en/plugins-reference
