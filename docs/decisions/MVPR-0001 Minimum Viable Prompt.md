---
title: Minimum Viable Prompt
description: Each model receives only the instructions it needs, nothing more
type: adr
category: architecture
tags:
    - architecture
    - prompts
status: accepted
created: 2026-03-15
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0002 Skills Companion Files.md"
    - "ARCH-0005 Platform-Specific Companion Files.md"
    - "PROV-0004 Reference Links for Prompt Provenance.md"
    - "PROV-0005 Qualifier Directories for Model Targeting.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Minimum Viable Prompt

## Context

Every deployed rule consumes context window tokens. Research confirms prompt bloat degrades output quality, not just cost. Models improve with each release — instructions essential for earlier models become redundant as capabilities are baked into training. ADRs ARCH-0002 and ARCH-0005 address token efficiency for skills via companion files. PROV-0005 enables deploying different rule content per model via qualifier directories. What's missing is the guiding principle: each model should receive only the instructions it needs, nothing more.

## Considered Options

1. **Ship everything** — every model gets every rule. Simple but wastes tokens and degrades output quality as the rule set grows.
2. **Per-model rule sets** — maintain separate rule lists per model. Precise but creates N copies to maintain, drifts silently.
3. **Minimum viable prompt with targeting** — one rule set, deploy-time filtering via frontmatter targets and qualifier directories. Each model gets only what it needs.

## Decision

A **minimum viable prompt** is the smallest instruction set that produces the desired behavior for a given model. Every instruction above that threshold is wasted tokens. Every instruction below it is a behavioral gap.

This principle drives three mechanisms:

- **Frontmatter targets** (PROV-0005) — skip entire rules for models that don't need them
- **Qualifier directories** (PROV-0005) — deploy different content per model when the instruction needs to be different, not absent
- **Provenance stripping** (PROV-0004) — remove source citations from deployed files so only instruction text consumes tokens

The goal is not rule deletion but **rule targeting** — a rule essential for Haiku but redundant for Opus should deploy to Haiku only, not be removed from the ecosystem.

## Consequences

- Positive: each model gets a right-sized prompt, not a bloated universal one
- Positive: token cost decreases per model as redundant rules are targeted
- Positive: output quality improves as prompt noise decreases
- Tradeoff: maintaining per-model targeting requires ongoing validation via static scan and behavioral ablation
