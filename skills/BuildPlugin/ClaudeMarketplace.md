## Marketplace Registration

Add a module to a Claude Code plugin marketplace for distribution via the CLI and Cowork (the web-based plugin management UI for organizations).

### How Marketplaces Work

A marketplace is a GitHub repo with `.claude-plugin/marketplace.json` at the root. Users add it with `/plugin marketplace add owner/repo`, then install individual plugins from it.

**Claude Code CLI** supports all source types — remote URLs, GitHub shorthand, npm packages, and local paths. It fetches the plugin and caches it locally.

**Cowork** (organizational plugin management) clones the marketplace repo with plain `git clone`. It does not run `--recursive` or resolve remote source URLs. Only plugins physically present as directories inside the marketplace repo are visible to Cowork. Submodules resolve to empty directories and fail silently.

### Cowork Hook Limitation

Cowork silently drops all plugin hooks. The CLI is spawned with `--setting-sources user`, which excludes plugin-scoped hook discovery ([GitHub #27398][ISSUE]). All hook types (command, prompt, agent) are affected, and no error is surfaced. Skills, agents, and MCP servers work in Cowork.

Any behavior that must work in Cowork cannot rely on hooks. Ship it as a rule (always loaded) or a skill (user-invoked) instead.

[ISSUE]: https://github.com/anthropics/claude-code/issues/27398

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

Auto-discovered directories, the `rules/` gap, and the SessionStart `additionalContext` workaround are covered by [ClaudePlugin.md](ClaudePlugin.md).

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
