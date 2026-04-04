---
title: Qualifier Directories for Model Targeting
description: Directory-based model variant selection and frontmatter targeting for provider-specific rule content
type: adr
category: architecture
tags:
    - architecture
    - targeting
status: accepted
created: 2026-03-15
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Qualifier Directories for Model Targeting

## Context

Some rules need different content per AI provider or model — extra guardrails for weaker models, different tool names per provider, provider-specific workarounds. The directory tree must express both "deploy this only to provider X" (include/exclude) and "deploy different content to provider X" (variant override). No AI coding tool implements directory-based model variant selection (confirmed gap across Cursor, Continue.dev, GitHub Copilot, AGENTS.md).

## Considered Options

- **Qualifier directories** — `rules/claude/opus4.5/Rule.md` overrides the base `rules/Rule.md`
- **Frontmatter targets** — `targets: [claude]` for include/exclude filtering
- **Config-driven** — `defaults.yaml` enumerates which rules deploy to which providers
- **Filename convention** — `Rule.claude.md` suffix-based variants

## Decision

Chosen option: **qualifier directories + frontmatter targets**, because they solve different problems and compose cleanly.

**Qualifier directories** handle content variants. Same filename in a subdirectory named after a provider or model overrides the base. Resolution precedence: `user/` > `provider/model/` > `provider/` > base. Valid qualifier names come from `defaults.yaml` providers config; `user/` is always valid (gitignored, personal overrides).

```
rules/
  AgentTeams.md                  # base — all providers
  codex/AgentTeams.md            # codex-specific (no team support)
  gemini/AgentTeams.md           # gemini-specific (no Agent tool)
  user/AgentTeams.md             # personal override
```

**Frontmatter targets** handle include/exclude. A rule that applies to some providers but not others declares `targets:` in frontmatter, stripped at deploy. This also serves as a reconstructibility record — if qualifier directories are lost, the frontmatter documents which providers the rule was meant for.

```yaml
---
targets: [claude, codex]
---
```

Absent `targets:` deploys everywhere (backward compatible).

Variant files can declare merge mode: `mode: replace` (default), `mode: append`, `mode: prepend`. Frontmatter stripped at deploy.

## Consequences

- Positive: first tool to ship model-level targeting on rule files
- Positive: `targets:` frontmatter enables directory reconstruction if the tree is lost
- Positive: backward compatible — rules without frontmatter or qualifier dirs deploy as before
- Tradeoff: qualifier directories add depth to the rules tree
