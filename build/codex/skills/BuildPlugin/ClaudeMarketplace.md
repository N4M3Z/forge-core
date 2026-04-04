## Marketplace Registration

Add a module to a Claude Code plugin marketplace for Cowork distribution.

### Prerequisites

- Module passes BuildPlugin validation
- Module has a public GitHub repo (for plugin source)
- Marketplace repo is **private** (Cowork requirement)
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

4. Verify the name is not reserved (ClaudeMarketplace rule).

5. Commit and push. Cowork syncs on merge to default branch.

### Source types

| Type        | When to use                                    | Example                                          |
| ----------- | ---------------------------------------------- | ------------------------------------------------ |
| `url`       | Plugin has its own repo                        | `"url": "https://github.com/owner/repo.git"`    |
| `github`    | Shorthand for GitHub repos                     | `"owner": "N4M3Z", "repo": "forge-finance"`     |
| `git-subdir`| Plugin is a subdirectory of a monorepo         | `"url": "...", "directory": "plugins/my-plugin"` |
| `npm`       | Plugin published to npm                        | `"package": "@scope/plugin-name"`                |

For forge modules with their own repos, use `url` with the `.git` suffix.

### Verify sync

After pushing, trigger sync in Cowork: Settings > Plugins > Sync marketplace. The plugin should appear in the available plugins list.

If sync fails:
- Confirm marketplace repo is **private** (not public)
- Confirm plugin names are lowercase kebab-case
- Confirm source URLs are accessible
- Confirm `.claude-plugin/marketplace.json` is valid JSON
