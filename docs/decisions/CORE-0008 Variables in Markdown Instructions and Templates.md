---
title: Variables in Markdown Instructions and Templates
description: Runtime ENV vars for instructions, ${VARIABLE} with envsubst for templates, %% comments for inline guidance
type: adr
category: architecture
tags:
    - architecture
    - config
    - skills
    - templates
status: accepted
created: 2026-02-19
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0003 YAML Frontmatter for Machine Readability.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [PlaintextTemplateVariables.md]
---

# Variables in Markdown Instructions and Templates

## Context and Problem Statement

Markdown instructions (skills, agents, rules) need to reference configurable values — file paths, directory locations, tool names, feature flags. Templates need placeholder values that get filled at creation time. Both must be resolvable by shell tools and readable by AI.

Three placeholder patterns had emerged organically: inline descriptions ("Title — a short noun phrase"), `{{VARIABLE}}` ([Obsidian Templater][1] syntax), and `{VARIABLE}` (structured-madr convention). None of these are shell-resolvable.

## Decision Drivers

- Hardcoded paths break across environments
- Shell commands and AI prose need the same values from the same source
- Templates should be instantiable with `envsubst` — no custom parsers
- Placeholder names should be self-documenting
- Obsidian Templater has its own `{{VARIABLE}}` pattern that cannot change — coexistence is required

## Considered Options

1. **`{{VARIABLE}}`** — Obsidian Templater syntax. Works inside Obsidian but not resolvable by shell tools. Collides with Templater when files are opened in the vault.
2. **`{VARIABLE}`** — structured-madr convention. Not standard shell syntax, requires custom string replacement.
3. **`${VARIABLE}` with `%%` comments** — standard shell parameter expansion, resolvable by `envsubst`. Obsidian `%%` comments provide inline documentation hidden in preview mode.

## Decision Outcome

Two complementary patterns for two contexts:

**Runtime instructions** — skills and rules reference `$VARIABLE` environment variables by name. The AI reads the variable name and resolves it from the environment. Shell commands use `$VAR` syntax directly. No build step, no placeholder replacement — configuration resolves at runtime.

**Templates** — plaintext templates use `${VARIABLE}` placeholders, instantiable with `envsubst < template.md > output.md`. Variable names are UPPER_SNAKE_CASE and self-documenting. End-of-line `%%` comments describe what each variable should contain, with enum choices separated by `|`:

```markdown
status: ${STATUS}                          %% proposed | accepted | deprecated | superseded %%
- [+] ${POSITIVE}                          %% positive outcome — what improves %%
```

Obsidian Templater templates continue using `{{VARIABLE}}`. The two patterns do not mix within a single file.

### Consequences

- [+] Shell commands and AI instructions share the same configuration mechanism
- [+] Templates are instantiable with `envsubst` — zero custom tooling
- [+] `%%` comments are invisible in Obsidian preview but visible in source — guidance without noise
- [-] ENV vars must be populated before the instruction is useful — requires a config loading layer
- [-] Two coexisting patterns (`${VAR}` and `{{VAR}}`) — mitigated by the rule that they never mix in one file

[1]: https://silentvoid13.github.io/Templater/
