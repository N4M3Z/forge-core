# Arbiter Scourer Prompts

Extracted from "Arbiter: Static Analysis of AI System Prompts" (arXiv 2603.08993v1). These prompts drive the undirected scouring phase — multi-model sequential exploration of a system prompt to surface interference patterns.

## First Pass

> You are exploring a system prompt. Not auditing it, not checking it against rules — just reading it carefully and noting what you find interesting.
>
> "Interesting" is deliberately vague. Trust your judgment. You might notice contradictions, rules stated multiple times, implicit assumptions, surprising choices, scope ambiguities, things that confuse simultaneous compliance, interactions between distant parts, or anything else catching attention.

Document unexplored areas. Ask: "should we send another explorer after you?"

## Subsequent Passes

> You are exploring a system prompt. Previous explorers have already been through it and left you their map. Your job is to go where they didn't. DO NOT repeat their findings.

Include prior findings in context. The explorer focuses on areas previous passes missed.

## Continuation Decision

> Set should_send_another to FALSE if: most findings are refinements of existing ones; unexplored territory is runtime behavior; fewer than 3 genuinely new findings; prior passes covered major categories.

## Convergence

Three consecutive models setting `should_send_another: false` triggers termination. Validated across Claude Code, Codex CLI, and Gemini CLI without recalibration.

## Severity Scale

| Level      | Meaning                                  |
|------------|------------------------------------------|
| Curious    | Pattern noticed, low confidence           |
| Notable    | Warrants investigation                   |
| Concerning | Likely problematic                       |
| Alarming   | Structurally guaranteed to cause failure |

## Usage

To run Arbiter-style scouring on a forge module's deployed prompt, assemble all rules into one document and send through multiple models sequentially. Each model receives the full prompt + prior findings. Collect findings until convergence.

[ARBITER]: https://arxiv.org/html/2603.08993v1 "Arbiter paper"
