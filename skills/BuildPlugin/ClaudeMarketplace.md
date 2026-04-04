## Marketplace Registration

Add a module to a Claude Code plugin marketplace for distribution via the CLI and Cowork (the web-based plugin management UI for organizations).

### How Marketplaces Work

A marketplace is a GitHub repo with `.claude-plugin/marketplace.json` at the root. Users add it with `/plugin marketplace add owner/repo`, then install individual plugins from it.

**Claude Code CLI** supports all source types — remote URLs, GitHub shorthand, npm packages, and local paths. It fetches the plugin and caches it locally.

**Cowork** (organizational plugin management) clones the marketplace repo with plain `git clone`. It does not run `--recursive` or resolve remote source URLs. Only plugins physically present as directories inside the marketplace repo are visible to Cowork. Submodules resolve to empty directories and fail silently.

### Prerequisites

- Module passes BuildPlugin validation
- Module has a public GitHub repo
- Cowork GitHub App installed on the marketplace repo (for Cowork distribution)

### Embedding Plugins for Cowork

Use `git subtree` to embed the plugin's files directly in the marketplace repo:

```sh
git subtree add --prefix=<directory-name> <repo-url> main --squash
```

Then add an entry to `.claude-plugin/marketplace.json` with a relative path:

```json
{
    "name": "Plugin Name",
    "description": "One-line description from plugin.json",
    "source": "./<directory-name>"
}
```

Plugin names use title case in `marketplace.json`. Directory names use kebab-case.

To pull upstream changes later:

```sh
git subtree pull --prefix=<directory-name> <repo-url> main --squash
```

### Remote Sources (CLI Only)

These source types work in the Claude Code CLI but are not visible to Cowork:

| Type         | Example                                          |
| ------------ | ------------------------------------------------ |
| `url`        | `{"type": "url", "url": "https://...git"}`      |
| `github`     | `{"source": "github", "repo": "owner/repo"}`    |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "directory": "path"}` |
| `npm`        | `{"source": "npm", "package": "@scope/name"}`   |

### Plugin Auto-Discovery

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

### Plugin Requirements

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

### Reserved Names

Cannot use: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`, or names impersonating Anthropic.

### Verify Sync

After pushing, trigger sync in Cowork: Settings > Plugins > Sync marketplace. The plugin should appear in the available plugins list.

[1]: https://support.claude.com/en/articles/13837433-manage-cowork-plugins-for-your-organization
[2]: https://code.claude.com/docs/en/plugin-marketplaces
[3]: https://code.claude.com/docs/en/plugins-reference
