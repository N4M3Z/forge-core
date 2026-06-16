---
title: Model Baseline Context Evaluation
description: The running model self-assesses loaded context against its own baseline, with verification rails and qualifier-directory parking
type: adr
category: architecture
tags:
    - architecture
    - prompts
status: accepted
created: 2026-06-12
updated: 2026-06-12
author: "@N4M3Z"
project: forge-core
related:
    - "MVPR-0001 Minimum Viable Prompt.md"
    - "MVPR-0002 Prompt Minimalization Metrics.md"
    - "PROV-0005 Qualifier Directories for Model Targeting.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Model Baseline Context Evaluation

## Context and Problem Statement

Always-on instructions accumulate for the weakest model that ever needed them. As frontier models internalize behaviors through training and harness prompts (read-before-assert, verify-before-done, scope discipline), the rules written to compensate become permanent token cost with no behavioral effect, and nothing in the toolchain distinguishes "still steering" from "internalized." MVPR-0001 demands a minimum viable prompt per model; MVPR-0002 supplies static scans and on-demand ablation. Neither answers the operational question a new flagship raises: which loaded instructions can this model drop, and where does the dropped content go so weaker models keep it?

## Considered Options

- **Manual curation per model release** — re-read every rule by hand; does not scale and has no test
- **Static scan only** — MVPR-0002 scan mode; catches structure, staleness, and conflicts but cannot measure whether the running model needs an instruction
- **Ablation for everything** — PromptFoo with/without per rule per model; accurate but slow and expensive as a default path
- **Baseline self-assessment with verification rails** — the running model evaluates its own loaded context, bounded by rails that counter its bias

## Decision Outcome

Chosen option: **baseline self-assessment with verification rails**, implemented as the OptimizeContext skill.

The running model applies a behavioral test to each loaded instruction: "if this instruction were absent, would my unprompted output already satisfy it?" Knowing is not complying; the test is on behavior, not comprehension. Content divides into three kinds with different verdict spaces:

| Kind                | Test                                            | Verdicts                              |
| ------------------- | ----------------------------------------------- | ------------------------------------- |
| Capability steering | behavioral test against the session baseline    | offload, keep                         |
| Preference, policy  | user choices no model can infer                 | slim, stale-fix, keep (never removed) |
| Knowledge reference | does this belong in always-on context at all?   | relocate to a lazy skill, stale-fix, keep |

The rails are part of the decision, not implementation detail:

- **Nothing is destroyed by capability reasoning.** Offload parks the full text in model qualifier directories ([PROV-0005](PROV-0005 Qualifier Directories for Model Targeting.md)) for the models that still need it; deletion requires the content to be wrong or stale, and explicit confirmation.
- **The evaluator is biased toward a smaller context.** Verdicts below high confidence escalate to ablation ([MVPR-0002](MVPR-0002 Prompt Minimalization Metrics.md)) instead of acting; every duplication or staleness claim is verified against the repository before application; every proposal is confirmed individually by the user.
- **Agents are evaluated against their pinned model tier, never the session model.** A fast-tier agent still needs scaffolding the session model does not.
- **Rules are evaluated first.** They cost tokens in every session; skill bodies are lazy and are trimmed only for dead weight, while their reference and policy content is protected.
- **Knowledge migrates down the loading ladder.** Reference material found in always-on rules relocates into the owning skill, loading only when the skill fires.

## Consequences

- Positive: context shrinks as models improve instead of growing monotonically
- Positive: older models keep their full instruction sets through qualifier parking
- Positive: reference content moves from always-on rules to lazy skills, sharpening the rules/skills split
- Tradeoff: self-assessment is a weak signal; the confidence bar and ablation escalation are load-bearing, not optional
- Tradeoff: the evaluation recurs at every model generation; it is an operating practice, not a one-time cleanup
