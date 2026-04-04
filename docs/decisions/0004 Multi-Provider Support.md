---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: [PlatformAgnostic.md]
tags: [architecture, providers]
---

# Multi-Provider Support

## Context and Problem Statement

AI coding tools are evolving rapidly — Claude Code, Gemini CLI, Codex, OpenCode each have different extension mechanisms, directory conventions, and capability sets. Building skills and modules for a single provider risks lock-in and limits reach. But supporting multiple providers introduces complexity in installation, testing, and content authoring.

## Decision Drivers

- No vendor lock-in — switching or adding providers should not require rewriting skills
- Skills are markdown prose ([0001](0001 Markdown as System Language.md)) — the content is portable, only deployment differs
- Each provider has its own directory convention (`.claude/`, `.gemini/`, `.codex/`, `.opencode/`)
- Provider capabilities diverge — agent teams, hooks, and tool availability vary

## Considered Options

1. **Claude Code only** — simplest path, deepest integration, but locks the ecosystem to one vendor
2. **Lowest common denominator** — only use features available in all providers, limits what's possible
3. **Multi-provider with platform-specific companions** — shared core skills deployed to all, with companion files and rules for platform-specific behavior

## Decision Outcome

Chosen option: **Multi-provider with platform-specific companions**. Skills are authored once as markdown and deployed to each provider's directory by the install system. Platform differences (agent invocation, hook mechanisms, directory layout) are handled by companion files and platform-specific rules rather than degrading the core experience.

### Consequences

- [+] Skills authored once, deployed everywhere — no per-provider rewrites
- [+] Platform-specific companions capture provider quirks without polluting core skills
- [-] Install tooling must understand each provider's conventions
- [-] Testing matrix grows with each new provider
- [-] Some features (agent teams, hooks) are only available on specific platforms

## More Information

- [Claude Code](https://docs.claude.com/en/docs/claude-code) — skills, agents, rules in `.claude/`
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) — custom tools in `.gemini/`
- [Codex](https://github.com/openai/codex) — instructions in `.codex/`
- [OpenCode](https://opencode.ai) — rules in `.opencode/`
