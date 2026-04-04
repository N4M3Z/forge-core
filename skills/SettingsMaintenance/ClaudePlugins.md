# ClaudePlugins

Audit plugin configuration across Claude Code settings files. Each enabled plugin injects its skill descriptions into every session turn, consuming tokens regardless of whether the plugin is used.

## Procedure

1. Read `enabledPlugins` from every settings file where it appears
2. Build a table: plugin name, global state, project state, effective state
3. Run the checks below
4. Present findings with estimated token impact

## Checks

| Check | What to look for |
|-------|-----------------|
| **Global/project conflict** | Global sets `false` but project sets `true` (or vice versa). Flag whether this is intentional override or accidental. Common cause: plugin installed globally, then project config was created from a template that enables everything. |
| **Irrelevant to project** | Plugin doesn't match the project's tech stack. Examples: `stripe` in a non-payment repo, `gitlab` in a GitHub project, `atlassian` when no Jira/Confluence is used. |
| **Duplicate enablement** | Same plugin set to `true` at both global and project level. The project entry is redundant — plugins inherit from global. |
| **Disabled but present** | Plugin explicitly set to `false`. Verify intent: is this an intentional disable (keep it) or a leftover from uninstallation (remove the key)? Explicit `false` entries prevent future global enablement from taking effect, which may or may not be desired. |

## Token Impact

Every enabled plugin adds its full skill roster to the system prompt on every turn. Rough estimates:

| Plugin type | Skill count | Context overhead |
|-------------|-------------|-----------------|
| Small (1-3 skills) | 1-3 | ~200-500 tokens/turn |
| Medium (4-8 skills) | 4-8 | ~500-1500 tokens/turn |
| Large (10+ skills) | 10+ | ~1500-3000 tokens/turn |

With 16 enabled plugins, overhead can reach 10,000+ tokens/turn before any user interaction. Disabling unused plugins is a direct cost reduction.

## Guidelines

- Recommend disabling plugins that don't match the project context
- Preserve explicit `false` entries when the user wants to prevent global inheritance
- Flag conflicts between layers but let the user decide intent
- Count enabled plugins before and after
