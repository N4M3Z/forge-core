---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: []
tags: [architecture, config, skills]
---

# ENV Vars in Markdown Instructions

## Context and Problem Statement

Markdown instructions (skills, agents, rules) need to reference configurable values — file paths, directory locations, tool names, feature flags. These instructions execute at read time with no compilation step. Configuration must be resolvable by both the AI reading the prose and the shell commands embedded in it.

## Decision Drivers

- Hardcoded paths break across environments — almost universally worse than any alternative
- Configuration must be discoverable inside the instruction itself
- Shell commands and AI prose need the same values from the same source
- No compilation step for configuration — ENV vars resolve at runtime, even when deployment assembles companion files

## Considered Options

1. **Placeholder syntax** — `{{VAR}}` tokens replaced at install time, requires a build step and loses the original template
2. **ENV vars referenced inline** — instructions reference `$FORGE_ADR_PREFIX` or document the env var name, resolved at runtime by the AI or shell

## Decision Outcome

Chosen option: **ENV vars referenced inline**. Skills and rules reference environment variables by name. The AI reads the variable name and resolves it from the environment. Shell commands use `$VAR` syntax directly. No build step, no placeholder replacement — configuration resolves at runtime regardless of how the file was assembled.

### Consequences

- [+] Shell commands and AI instructions share the same configuration mechanism
- [+] Values overridable per environment by setting ENV vars
- [-] ENV vars must be populated before the instruction is useful — requires a config loading layer
