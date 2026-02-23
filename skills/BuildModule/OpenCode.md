# OpenCode

Generate and maintain `AGENTS.md` for OpenCode compatibility.

## Generate

Run `opencode init` inside the module directory. This creates `AGENTS.md` with project instructions derived from the codebase.

```bash
opencode init
```

OpenCode will not overwrite an existing `AGENTS.md`. It also falls back to reading `CLAUDE.md` if `AGENTS.md` is absent (disableable via env var).

## Update

To regenerate after changes, rename the existing file first, then diff:

```bash
command mv AGENTS.md AGENTS.md.bak
opencode init
diff AGENTS.md.bak AGENTS.md
```

Review the diff. Keep manual additions from `.bak` that the generator missed. Remove the `.bak` when satisfied.

## Configuration

OpenCode uses `opencode.json` (JSON/JSONC) at project root or `~/.config/opencode/opencode.json` global. Supports an `instructions` array with glob patterns for additional instruction files.

## Agent Configuration

Two formats:
1. **JSON** — in `opencode.json` under `"agent"` key
2. **Markdown** — YAML-frontmatter files in `.opencode/agents/` or `~/.config/opencode/agents/`

Built-in agents: Build, Plan (primary), General, Explore (subagents).

## Skill Support

OpenCode follows the [Agent Skills](https://agentskills.io) standard. Skills live in `.opencode/skills/`, and it also searches `.claude/skills/` and `.agents/skills/`. Forge's `install-skills` binary handles deployment.

## Event Mapping

| Forge Event | OpenCode Event | Behavior |
|-------------|----------------|----------|
| `SessionStart` | `session.created` | TUI toast (cannot inject into system prompt) |
| `Stop` | `session.idle` | Warning toast only (cannot block exit) |
| `PreCompact` | `experimental.session.compacting` | Context injection via `output.context.push()` |
| `PreToolUse` | No equivalent | Skills-only in OpenCode |

Modules with lifecycle hooks need a TypeScript plugin adapter at `.opencode/plugins/<module>.ts`. See `Core/docs/OpenCodeModuleCompatibility.md` for the adapter template.
