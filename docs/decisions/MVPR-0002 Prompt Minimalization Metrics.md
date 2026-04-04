---
title: Prompt Minimalization Metrics
description: Static scan plus behavioral ablation for prompt relevance validation
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
    - "MVPR-0001 Minimum Viable Prompt.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Prompt Minimalization

## Context and Problem Statement

The minimum viable prompt principle (MVPR-0001) requires knowing which rules each model needs. Manual curation doesn't scale — models update frequently and the rule set grows with each module. No existing tool validates prompt relevance per model (confirmed gap across PromptFoo, Langfuse, and academic tools). Arbiter research found 95% of prompt conflicts are statically detectable.

## Considered Options

- **Manual curation** — periodically review rules by hand
- **Static analysis only** — scan for conflicts, staleness, targeting gaps. Fast, free, catches structural issues. Cannot detect behavioral redundancy.
- **Behavioral ablation only** — PromptFoo with/without each rule per model. Accurate but slow and expensive for every rule.
- **Static scan + behavioral confirmation** — static for the 90% case, ablation on demand for flagged rules.

## Decision Outcome

Chosen option: **static scan + behavioral confirmation on demand**, implemented as the PromptProvenance skill.

**Scan mode** (static, no API calls):

| Check | Method |
|-------|--------|
| Missing provenance | No `[N]:` wiki-refs in source |
| Missing targets | Provider-specific content without `targets:` |
| Qualifier split needed | References provider-specific tools/APIs |
| Scope conflicts | Overlap analysis between rules (Arbiter-style) |
| Staleness | Regex for deprecated model IDs, removed APIs |
| Redundancy estimate | Model self-assessment with confidence score |

**Deep mode** (PromptFoo ablation, on demand): generates test cases for flagged rules, runs with/without per model, compares pass rates. Equal pass rates confirm redundancy. Recommends adding `targets:` to skip the rule for capable models.

## Consequences

- Positive: structural issues caught without API cost
- Positive: behavioral confirmation available for ambiguous cases
- Positive: actionable output (add targets, split to qualifier dir, archive, add sources)
- Tradeoff: deep mode requires PromptFoo and API keys
- Tradeoff: scan mode redundancy estimates are weak signals

## More Information

- [Arbiter: Static Analysis of AI System Prompts](https://arxiv.org/html/2603.08993v1) — 95% static detectability finding
- [PromptFoo](https://www.promptfoo.dev/) — behavioral ablation testing
- [LLMLingua](https://www.llmlingua.com/) — perplexity-based compression (weak signal for redundancy)
- Vault research: Resources/Research/Arbiter Prompt Analysis
