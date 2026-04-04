# Claude Code Agent Deployment

How forge agents deploy to Claude Code. The `install-agents` binary transforms source agents into Claude Code format.

## Deployed Format

Source (`agents/SecurityArchitect.md`):
```yaml
---
name: SecurityArchitect
description: "Security policy architect — threat modeling..."
version: 0.3.0
---
```

Deployed (`~/.claude/agents/SecurityArchitect.md`):
```yaml
---
name: SecurityArchitect
description: Security policy architect — threat modeling...
model: sonnet
tools: Read, Grep, Glob, Bash, WebSearch
---
# synced-from: SecurityArchitect.md
```

The binary resolves `model` and `tools` from `defaults.yaml` and adds the `# synced-from:` provenance header.

## Model Resolution

defaults.yaml semantic tiers map to Claude model IDs:

| Tier | Claude model |
|------|-------------|
| fast | claude-sonnet-4-6 |
| strong | claude-opus-4-6 |

## Claude Code Tool Names

Available tools for `claude.tools` / defaults.yaml `tools`:

| Tool | Access |
|------|--------|
| Read, Grep, Glob | Read-only search and file access |
| Bash | Shell command execution |
| Write, Edit | File creation and modification |
| WebSearch, WebFetch | Internet access |
| Task | Subagent spawning |
| AskUserQuestion | User interaction |

Restrict tools to the minimum needed. Read-only agents (Architect, Designer) should not get Write/Edit/Bash.

## @ File References

Agents deployed to `~/.claude/agents/` can include companion files via `@` references. Resolution is relative to the agent file's directory.

## Discovery

Claude Code discovers agents from `~/.claude/agents/`. The `--scope` flag controls deployment:

| Scope | Destination |
|-------|-------------|
| workspace | `./.claude/agents/` (project-local) |
| user | `~/.claude/agents/` (global) |
| all | Both |
