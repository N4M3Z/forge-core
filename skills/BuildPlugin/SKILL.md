---
name: BuildPlugin
version: 0.1.0
description: "Create, validate, and publish Claude Code plugins from forge modules. USE WHEN create plugin, validate plugin, publish plugin, marketplace, plugin.json, cowork plugin."
argument-hint: "[create|validate|marketplace] [module-path]"
---

# BuildPlugin

Create, validate, and publish forge modules as Claude Code plugins. Covers plugin.json creation, marketplace registration, and Cowork deployment.

## Workflow Routing

| Workflow      | Trigger                                        | Reference            |
| ------------- | ---------------------------------------------- | -------------------- |
| **Create**    | "create plugin", "add plugin.json"             | Instructions below   |
| **Validate**  | "validate plugin", "check marketplace readiness" | Instructions below |
| **Marketplace** | "add to marketplace", "publish to cowork"    | @ClaudeMarketplace   |
| **Structure** | "plugin layout", "auto-discovery", "bin PATH", "plugin env vars" | @ClaudePlugin |

## Create plugin.json

1. Read `module.yaml` for name, version, description.
2. Generate `.claude-plugin/plugin.json`:

```json
{
    "name": "module-name",
    "version": "0.1.0",
    "description": "From module.yaml",
    "author": {"name": "Author"},
    "license": "EUPL-1.2",
    "repository": "https://github.com/owner/repo",
    "keywords": [],
    "skills": ["../skills"]
}
```

3. Add `"hooks": "./hooks/hooks.json"` only if the module has hooks.
4. Version in plugin.json must match module.yaml exactly.

## Validate

Check these in order. Stop on first failure.

| Check               | Pass criteria                                                |
| ------------------- | ------------------------------------------------------------ |
| plugin.json exists  | `.claude-plugin/plugin.json` present and valid JSON          |
| name                | Lowercase kebab-case (Cowork enforces strictly)              |
| version             | Valid semver, matches module.yaml                            |
| description         | Non-empty string                                             |
| author              | Object with `name` field                                     |
| license             | SPDX identifier present                                      |
| repository          | URL string present                                           |
| keywords            | Non-empty array                                              |
| README.md           | Exists, not empty                                            |
| LICENSE             | Exists                                                       |
| INSTALL.md          | Follows install.md standard (OBJECTIVE, DONE WHEN, TODO)     |
| CLAUDE.md           | Exists                                                       |
| Skills              | Each has SKILL.md with name/description/version frontmatter  |
| Skill YAML          | Each has SKILL.yaml with sources field                       |

Report:

```
Section              Status
──────────────────────────────
plugin.json          PASS / FAIL
module.yaml          PASS / FAIL
Documentation        PASS / FAIL
Skills               PASS / FAIL
──────────────────────────────
Verdict: READY / NOT READY
```

## Constraints

- Never publish a module that fails validation

## Sources

- <https://code.claude.com/docs/en/plugin-marketplaces>
- <https://support.claude.com/en/articles/13837433-manage-cowork-plugins-for-your-organization>
