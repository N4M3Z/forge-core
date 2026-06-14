# Claude Code Agent Deployment

How forge agents deploy to Claude Code. Following [ArtifactComposition](../../rules/ArtifactComposition.md), the `forge install` command transforms source agents into Claude Code format.

## Deployed Format

Deployment passes agent frontmatter through unchanged: the deployed file carries `name` and `description`. `model` and `tools` stay in `defaults.yaml` and are never written into the agent file. Provenance is recorded in a `.provenance/` sidecar directory next to the deployed agents.

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
