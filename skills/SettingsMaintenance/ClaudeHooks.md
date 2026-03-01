# ClaudeHooks

Audit hook configuration across Claude Code settings files. Hooks run shell commands in response to events — misconfiguration causes double-dispatch, silent failures, or wasted execution.

## Procedure

1. Read `hooks` from global `settings.json` and project `settings.json`
2. Build a table: event name, handler source (global/project/plugin), command, matcher
3. Run the checks below
4. Present findings with severity

## Available Events

Claude Code supports these hook events:

| Event               | Timing                       | Output mode                      |
|---------------------|------------------------------|----------------------------------|
| `SessionStart`      | Session begins               | Concatenate (output shown to AI) |
| `PreToolUse`        | Before tool execution        | Gate (exit 2 blocks the tool)    |
| `PostToolUse`       | After tool execution         | Passive (output discarded)       |
| `Stop`              | AI stops generating          | Gate (exit 2 blocks stop)        |
| `PreCompact`        | Before context compaction    | Concatenate (output shown to AI) |
| `UserPromptSubmit`  | User submits a prompt        | Passive                          |
| `SubagentStop`      | Subagent finishes            | Passive                          |
| `SessionEnd`        | Session ends                 | Passive                          |
| `Notification`      | Notification fired           | Passive                          |

## Checks

| Check                        | What to look for                                                                                                                                                                                                                                      |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Double dispatch**          | Same event handled at both global and project level calling the same binary (possibly via different paths). Common: global `dispatch SessionStart` + project `dispatch SessionStart` → modules run twice per session start.                            |
| **Stale commands**           | Hook command references a binary that doesn't exist at the specified path. Verify with `command -v <binary>` or `test -x <path>`.                                                                                                                     |
| **Empty matcher**            | `"matcher": ""` matches all tools. Verify this is intentional vs a missing value. Compare with `"matcher": "*"` (explicit match-all) and `"matcher": "Bash"` (tool-specific).                                                                         |
| **Missing events**           | Compare registered events against the available events list. Flag events with no handlers if the project expects coverage (e.g., no Stop hook means no exit gate).                                                                                     |
| **Handler ordering**         | Multiple handlers on the same event execute in array order. Verify the order makes sense (e.g., RTK rewrite should run before dispatch for PreToolUse).                                                                                               |
| **Plugin vs settings hooks** | Hooks can come from `settings.json` AND from plugin `hooks.json` files. Both fire for the same event. Flag potential overlap between project settings hooks and the plugin entry point (`Core/hooks/hooks.json` or `.claude-plugin/plugin.json`). |

## Hook Layers

Hooks can be registered at three levels:

| Source             | File                              | When active            |
|--------------------|-----------------------------------|------------------------|
| Global settings    | `~/.claude/settings.json` hooks   | Always                 |
| Project settings   | `.claude/settings.json` hooks     | In this project        |
| Plugin             | `hooks.json` via plugin manifest  | When plugin is loaded  |

All three fire for the same event. Order: global settings first, then project settings, then plugins (but verify — this may change across Claude Code versions).

## Guidelines

- Double dispatch is the most common issue — same binary invoked via two paths
- Empty matchers are usually intentional for catch-all hooks (dispatch, c0ntextkeeper)
- Tool-specific matchers (`"matcher": "Bash"`) should be verified against the tool name they intend to match
- Stale commands cause silent failures — hooks fail but don't block the session
