---
name: SettingsMaintenance
version: 0.1.0
description: "Audit and clean AI coding tool settings — permissions, plugins, hooks, cross-layer conflicts. USE WHEN review permissions, clean settings, audit config, plugin conflicts, hook audit, settings cruft."
---

# SettingsMaintenance

Audit and clean AI coding tool settings files. Covers permission entries, plugin configuration, hook wiring, and cross-layer conflicts.

## Settings Architecture

AI coding tools layer settings across multiple files. Claude Code uses 4 files with inheritance:

| Layer          | File                              | Committed       | Scope                                           |
|----------------|-----------------------------------|-----------------|--------------------------------------------------|
| Global shared  | `~/.claude/settings.json`         | No (personal)   | All projects                                     |
| Global local   | `~/.claude/settings.local.json`   | No (personal)   | All projects, overrides global shared            |
| Project shared | `.claude/settings.json`           | Yes (git)       | This project, shared with collaborators          |
| Project local  | `.claude/settings.local.json`     | No (gitignored) | This project, personal overrides                 |

Precedence (highest wins): project local > project shared > global local > global shared.

At the global level, both files are personal — the `settings.json` / `settings.local.json` split is redundant. The local file is designed for project-level use where `settings.json` is committed and `settings.local.json` holds personal overrides.

## Workflow Routing

| Subskill          | Trigger                                                    | Content                |
|-------------------|------------------------------------------------------------|------------------------|
| ClaudePermissions | "permissions", "allowed commands", "settings cruft"        | @ClaudePermissions.md  |
| ClaudePlugins     | "plugins", "plugin conflicts", "disable plugins"           | @ClaudePlugins.md      |
| ClaudeHooks       | "hooks", "hook config", "dispatch"                         | @ClaudeHooks.md        |
| ClaudeBaseline    | "baseline", "global settings", "user scope", "bootstrap"   | @ClaudeBaseline.md     |
| GeminiSettings    | "gemini settings", "audit gemini"                          | @GeminiSettings.md     |
| Full audit        | "full audit", "review settings", "clean everything"        | All of the above       |

## Common Procedure

All subskills follow this 6-phase workflow:

1. **Scope** — Determine which settings layers to audit. Default: all 4 files that exist. User can narrow to "just global" or "just project".
2. **Inventory** — Read each file. Count entries by category. Present a summary table with totals.
3. **Audit** — Run the subskill's checks against the inventory. Collect findings.
4. **Report** — Present findings grouped by category. Each finding: ID, category, severity (remove/consolidate/flag), entry, reason.
5. **Apply** — On user approval, edit files. Apply changes per-category so user can approve/reject each group independently. Use targeted Edit tool calls for reviewable diffs.
6. **Verify** — `jq . <file> > /dev/null` for JSON validity. Count before/after entries. Spot-check that critical tools remain permitted.

## Cross-Layer Checks

Run these regardless of which subskill is active:

| Check                              | What to look for                                                                          |
|------------------------------------|-------------------------------------------------------------------------------------------|
| **Env var duplication**            | Same key+value in both global and project `settings.json` — project inherits from global  |
| **Permission scattering**          | Same entry in both `settings.json` and `settings.local.json` at the same level            |
| **Plugin enable/disable conflict** | Global disables a plugin but project re-enables it (or vice versa)                        |
| **Redundant local file**           | At global level, `settings.local.json` entries that already exist in `settings.json`      |

## Auto mode policy

`permissions.defaultMode: "auto"` routes every tool call through an AI classifier that blocks anything irreversible, destructive, or aimed outside the trusted environment. Configure that classifier with the `autoMode` block, whose entries are prose natural-language rules, not tool patterns:

- `autoMode.environment`: trusted infrastructure (repos, buckets, domains, local services)
- `autoMode.soft_deny`: destructive actions, blocked unless the user's explicit, specific intent clears them
- `autoMode.hard_deny`: unconditional boundaries, intent and allow exceptions do not apply
- `autoMode.allow`: exceptions to soft blocks

Precedence: hard_deny > soft_deny > allow > explicit intent. Include the literal `"$defaults"` in any list to keep built-in rules. The classifier also reads CLAUDE.md. Validate with `claude auto-mode config` and `claude auto-mode critique`.

This is the soft, AI-judged layer; the hard layer is `permissions.deny` (before the classifier, unoverridable) and command-guard hooks. `permissions.allow`/`deny`/`ask` use structured `Tool(specifier)` syntax, not prose.

## Sources

- <https://docs.anthropic.com/en/docs/claude-code>
