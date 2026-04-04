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

Plugin entries require `name`, `description`, and `source`:

```json
{
    "name": "plugin-name",
    "description": "One-line description",
    "source": {
        "type": "url",
        "url": "https://github.com/owner/repo.git"
    }
}
```

Source `type` field uses `"type"`, not `"source"`. Source types: `url` (git URL), `github` (owner/repo shorthand), `git-subdir`, `npm`, relative path.

## Cowork Constraints

- Marketplace repo **must be private** — Cowork rejects public repos ([support article][1])
- Plugin names must be **lowercase kebab-case** — Cowork enforces this strictly
- The Cowork GitHub App must be installed on the repo
- Sync fires on PR merge to default branch, or manually on demand

## Reserved Names

Cannot use: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`, or names impersonating Anthropic.

## Plugin Requirements

Each plugin repo needs `.claude-plugin/plugin.json`:

| Field         | Required | Example                                       |
| ------------- | -------- | --------------------------------------------- |
| `name`        | yes      | `"forge-finance"`                             |
| `version`     | yes      | `"0.1.0"`                                     |
| `description` | yes      | `"Tax law rules and filing workflows"`        |
| `author`      | yes      | `{"name": "Author Name"}`                     |
| `license`     | no       | `"EUPL-1.2"`                                  |
| `repository`  | no       | `"https://github.com/owner/repo"`             |
| `keywords`    | no       | `["tax", "finance"]`                          |
| `skills`      | if any   | `["../skills"]`                               |
| `hooks`       | if any   | `"./hooks/hooks.json"`                        |

With `strict: false` on the marketplace entry, the plugin repo does not need its own `plugin.json` — the marketplace entry defines the full plugin surface.