---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: [SkillNaming.md]
tags: [architecture, skills, agents, rules]
---

# Skills, Agents, and Rules

## Context and Problem Statement

The system needs a way to package AI capabilities, specialist personas, and behavioral constraints. These three concerns are distinct — a capability (how to create an ADR), a persona (a security architect reviewing code), and a constraint (never edit deployed copies) serve different purposes and have different lifecycles. Claude Code provides native support for all three as markdown files in `.claude/` directories.

## Decision Drivers

- Claude Code's extension model already separates skills (`.claude/skills/`), agents (`.claude/agents/`), and rules (`.claude/rules/`) — aligning with it means zero adaptation cost
- Each artifact type must have a clear routing signal — "what kind of thing is this?"
- Artifacts must be independently deployable — a rule change shouldn't require redeploying skills
- Other providers (Gemini, Codex, OpenCode) have analogous but differently-named mechanisms

## Considered Options

1. **Single "instruction" type** — everything is a markdown file with a type tag, unified but ambiguous routing
2. **Two types: skills and config** — skills for capabilities, config for everything else, conflates personas with constraints
3. **Three types: skills, agents, rules** — skills teach capabilities, agents define specialist personas, rules enforce constraints

## Decision Outcome

Chosen option: **Three types**, aligning with Claude Code's native extension model. Skills (`skills/*/SKILL.md`) are invocable capabilities with workflows and steps. Agents (`agents/*.md`) are specialist personas with expertise, focus areas, and tool access. Rules (`rules/*.md`) are behavioral constraints loaded automatically — always-on guardrails that don't need invocation.

### Consequences

- [+] Clear routing — "I need to do X" → skill, "I need expertise in Y" → agent, "always do Z" → rule
- [+] Independent deployment — rules update without touching skills or agents
- [+] Each type has its own directory, naming convention, and mdschema
- [-] Borderline cases exist — some content could be a skill or a rule depending on framing

## More Information

- [Claude Code skills](https://docs.claude.com/en/docs/claude-code/slash-commands) — skills, agents, rules in `.claude/`
- [Claude Code agents](https://docs.claude.com/en/docs/claude-code/sub-agents) — custom subagent definitions
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) — custom tools in `.gemini/`
- [Codex](https://github.com/openai/codex) — instructions in `.codex/`
- [OpenCode](https://opencode.ai) — rules in `.opencode/`