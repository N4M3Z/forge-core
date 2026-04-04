## Marketplace Registration

Add a module to a Claude Code plugin marketplace for Cowork distribution.

### Prerequisites

- Module passes BuildPlugin validation
- Module has a public GitHub repo (for plugin source)
- Marketplace repo is **private** ([Cowork requirement][1])
- Cowork GitHub App installed on the marketplace repo

### Add to marketplace

1. Read the marketplace registry at `.claude-plugin/marketplace.json` in the marketplace repo.

2. Append a new entry to the `plugins` array:

```json
{
    "name": "plugin-name",
    "description": "One-line description from plugin.json",
    "source": {
        "type": "url",
        "url": "https://github.com/owner/repo.git"
    }
}
```

3. Verify no duplicate names in the plugins array.

4. Verify the name is not reserved (see Reserved Names below).

5. Commit and push. Cowork syncs on merge to default branch.

### Source types

| Type         | When to use                            | Example                                           |
| ------------ | -------------------------------------- | ------------------------------------------------- |
| `url`        | Plugin has its own repo                | `"url": "https://github.com/owner/repo.git"`     |
| `github`     | Shorthand for GitHub repos             | `"owner": "N4M3Z", "repo": "forge-finance"`      |
| `git-subdir` | Plugin is a subdirectory of a monorepo | `"url": "...", "directory": "plugins/my-plugin"`  |
| `npm`        | Plugin published to npm                | `"package": "@scope/plugin-name"`                 |

### Plugin auto-discovery

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

Not discovered: `rules/`, `CLAUDE.md`, `memory/`. These only load from project-level (`.claude/`) and user-level (`~/.claude/`) paths.

### Plugin requirements

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

### Reserved names

Cannot use: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`, or names impersonating Anthropic.

### Verify sync

After pushing, trigger sync in Cowork: Settings > Plugins > Sync marketplace. The plugin should appear in the available plugins list.

If sync fails:
- Confirm marketplace repo is **private** (not public)
- Confirm plugin names are lowercase kebab-case
- Confirm source URLs are accessible
- Confirm `.claude-plugin/marketplace.json` is valid JSON

[1]: https://support.claude.com/en/articles/13837433-manage-cowork-plugins-for-your-organization
[2]: https://code.claude.com/docs/en/plugin-marketplaces
[3]: https://code.claude.com/docs/en/plugins-reference
