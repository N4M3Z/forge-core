---
name: ResearchTopic
version: 0.1.0
description: "Decompose a research question into sub-queries, spawn parallel WebResearcher agents per angle, synthesize findings with citations and explicit confidence. USE WHEN the user asks to research, investigate, look online, look up, dig into, find sources, gather evidence, or survey what's known about a topic. Single-pass; for multi-round adversarial research use ResearchCouncil in forge-council."
---

# ResearchTopic

Single-pass parallel web research. Decompose, fan out, synthesize. The goal is a structured answer with citations and explicit confidence levels, returned in one cycle.

For multi-perspective research where specialists challenge each other across rounds, use [ResearchCouncil](https://github.com/N4M3Z/forge-council/blob/main/skills/ResearchCouncil/SKILL.md).

## Step 1: Decompose

Break the research question into 3-5 sub-queries covering different angles. Examples:

| Original                                       | Sub-queries                                                                                                       |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| "best practices for tool X"                    | Official docs · GitHub issues + discussions · YouTube/Twitter creators using it · Reddit threads · Alternatives  |
| "is library X production-ready"                 | Maintainer activity · Open critical issues · Production case studies · Recent security advisories                |
| "landscape for AI code review tools"           | Vendor offerings · Open-source TUI · Editor plugins · IDE-native features · Recent benchmarks                    |

Decomposition is the highest-leverage step — a sloppy query becomes a confused report. Name the angles before spawning.

## Step 2: Spawn parallel WebResearcher agents

For each sub-query, spawn a `WebResearcher` via the Task tool **in a single message** so they run in parallel. Each prompt includes the sub-question, brief context of the parent goal, an explicit ask for citations + confidence level, and a cap (~300 words per agent).

## Step 3: Synthesize

Combine the agent reports into one structured output. Don't paste raw reports — synthesize:

```markdown
## Research: <topic>

### Summary
One paragraph covering the load-bearing findings.

### Findings
1. **<finding>** — confidence: established | likely | uncertain. <One-sentence justification.> [source][1]
2. ...

### Conflicts
Where sources disagree, flag the disagreement and which side has more credibility.

### Gaps
What couldn't be determined; what would need primary-source access.

### What this means for you
(Only if the research was triggered by a decision question.) Concrete next steps.

### Sources
[1]: <url> "title"
```

## Red Flags

| Thought                                              | Reality                                                                                                              |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| "I'll just search directly without spawning agents"   | Parallel fan-out is why this skill exists; in-context serial searches eat the context window.                         |
| "Top search results are good enough"                  | Vendor blogs, AI-summary spam, out-of-date posts rank well. Evaluate authority + recency.                             |
| "If only one source says X, drop it"                  | Often the most valuable signal. Flag as low-confidence, don't drop.                                                  |
| "Skip Conflicts if all sources agree"                 | Agreement is itself a finding — write "all sources concur on X" explicitly.                                          |
