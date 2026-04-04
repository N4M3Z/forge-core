---
name: PromptAnalysis
version: 0.1.0
description: "Validate and minimize prompts — provenance, targeting, staleness, redundancy, ablation testing, perplexity scoring. USE WHEN audit rules, check provenance, minimize prompts, prompt cleanup, validate targeting, find redundant rules, prompt audit, prompt analysis, stale rules."
---
Analyze rules, skills, and agents for minimum viable prompt compliance (CORE-0021). Each concern is a subskill with its own detection patterns and output format.

## Subskill Routing

| Keyword                          | Subskill        | What it does                              |
|----------------------------------|-----------------|-------------------------------------------|
| "scan", "audit", "check", "all" | Scan            | Run all subskills on a module             |
| "provenance", "sources", "refs"  | @Provenance.md  | Check external source citations           |
| "target", "targeting", "provider"| @Targeting.md   | Check model/provider targeting correctness|
| "stale", "staleness", "deprecated"| @Staleness.md  | Check for outdated references             |
| "cleanup", "minimize", "fix"    | Cleanup         | Scan + auto-fix with confirmation         |
| single file path                 | Single          | Full analysis of one file with all subskills|

### External Tool Subskills

| Keyword                      | Subskill               | Requires                                  |
|------------------------------|------------------------|--------------------------------------------|
| "deep", "test", "ablation"  | @PromptFoo.md          | `npm install -g promptfoo` + API keys     |
| "compress", "perplexity"    | @LLMLingua.md          | `pip install llmlingua`                   |
| "benchmark", "capability"   | @ArtificialAnalysis.md | API key from artificialanalysis.ai        |

## Scan Mode

Run all static subskills (Provenance + Targeting + Staleness) on every rule in a module:

```
/PromptAnalysis scan Modules/forge-core/rules
```

Scan collects results from each subskill and presents a unified report grouped by status. No API calls, no model queries — purely static.

## Single File Mode

All subskills on one file:

```
/PromptAnalysis Modules/forge-core/rules/NoHeredoc.md
```

Shows full content with inline annotations, current targeting, qualifier variants, and a recommendation.

## Cleanup Mode

Scan + apply safe structural fixes with confirmation:

```
/PromptAnalysis cleanup Modules/forge-core/rules
```

For each fixable issue, present via AskUserQuestion. Only structural fixes (add targets, move to qualifier dir). Never delete rules or change content.

## Output Format

Follow @Output.md for the ASCII dashboard layout, card types, optional gauges, and batch decision flow.