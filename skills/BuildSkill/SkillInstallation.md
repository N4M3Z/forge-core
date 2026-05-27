# Skill Installation (INSTALL.md)

## When to include

A per-skill INSTALL.md is required when the skill needs user actions the plugin system cannot automate:

- Creating a user-config file (`~/.config/forge/<artifact>.{ext}`)
- Authenticating with an external service (API tokens, OAuth flows)
- Installing a tool unique to that skill (not a module-wide shared prerequisite)

Skills that work after `make install` or plugin add need no INSTALL.md. Hooks auto-discovered via `hooks/hooks.json` need no INSTALL.md.

## What does NOT belong in per-skill INSTALL.md

- **Shared prerequisites** (gitleaks, yq, jq) belong in the module-level INSTALL.md at the repo root
- **Hook wiring** belongs in `hooks/hooks.json` (auto-discovered by the plugin system)
- **Behavioral guidance** belongs in SKILL.md

## Shape

Same Mintlify standard as the repo-level INSTALL.md. Required elements: H1 title, blockquote summary, conversational opening, OBJECTIVE, DONE WHEN (measurable), TODO checklist, Steps with shell commands, EXECUTE NOW closing.

Template at `templates/init/INSTALL.md` in [forge-cli][TEMPLATE].

## Boundary

| Content type | Lives in |
|---|---|
| "When committing, follow these rules" | SKILL.md |
| "Run this command to set up the skill" | INSTALL.md |
| "Install gitleaks" (used by multiple skills) | Module INSTALL.md |
| Hook script that fires on PreToolUse | `hooks/` + `hooks.json` |

## Related

- [InstallInstructions](../../rules/InstallInstructions.md) — the rule establishing this convention
- [UserConfigSchema](UserConfigSchema.md) — when the config file uses the autoMode-mirror pattern

[TEMPLATE]: https://github.com/N4M3Z/forge-cli/blob/main/templates/init/INSTALL.md
