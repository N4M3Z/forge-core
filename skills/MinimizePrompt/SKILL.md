---
name: MinimizePrompt
description: "Remove motivational, marketing, and filler prose from a prompt-shaped document while preserving directive content. USE WHEN adopting a community skill, authoring a skill or rule that feels bloated, or auditing an existing artifact for token waste. Applies MVPR principles."
version: 0.1.0
allowed-tools: Read, Edit, Write
---

# MinimizePrompt

Cut motivational, marketing, and emphasis-inflated prose from prompt-shaped documents. Preserve the directive content and the facts that make the artifact work.

Aligned with [MVPR-0001](docs/decisions/MVPR-0001 Minimum Viable Prompt.md) and [MVPR-0002](docs/decisions/MVPR-0002 Prompt Minimalization Metrics.md). Referenced by [ForgeAdopt](../ForgeAdopt/SKILL.md) as the `minimize` transform.

## What to remove

| Pattern                   | Example                                                                |
| ------------------------- | ---------------------------------------------------------------------- |
| Motivational framing      | "Don't hold back", "Claude is capable of extraordinary work"           |
| Emphasis inflation        | CAPS-LOCKED warnings, repeated `**CRITICAL**` or `**IMPORTANT**`       |
| Marketing superlatives    | "Production-ready", "Best-in-class", "Complete toolkit"                |
| Filler transitions        | "First of all", "It's worth noting", "As previously mentioned"         |
| Tautology                 | "Use good practices" without defining good practices                   |
| Duplicate summaries       | Opening paragraph repeats the description; closing repeats the opening |
| Decorative checkmarks     | ✅-bulleted feature lists that restate workflow content                 |

## What to preserve

- Workflow steps and decision points
- Anti-patterns with concrete examples ("avoid X because Y")
- Tables, code blocks, and command examples
- Constraints and hard rules
- Frontmatter fields that affect routing — `description`, `allowed-tools`, `name`, `version`

## Red flags that a section should stay

A section earns its tokens if it does at least one of:

- Cites a specific source, rule, benchmark, or prior decision
- Names a concrete anti-pattern with a reason
- Is referenced by another section in the same document
- Carries a command, regex, schema, or structured data
- Encodes a decision that cannot be reconstructed from names alone

If none of the above applies, the section is a candidate for removal.

## Procedure

1. Read the document end-to-end once before cutting.
2. Identify the load-bearing sections — workflow, constraints, examples, tables. These are immune.
3. Sweep the remaining prose for the patterns in "What to remove." Cut per-pattern, not per-paragraph.
4. After each sweep, re-read. If a sentence no longer makes sense without a neighbor, the cut was too aggressive.
5. Measure the delta. A healthy minimization on a community prompt cuts 20-40% of tokens. More than 50% suggests content loss, not just filler loss.

## Constraints

- Never remove content that names a specific failure mode
- Never collapse a table or code block into prose
- Preserve anti-pattern lists even if worded emphatically — the emphasis is directive signal, not filler
- Keep one concrete example per abstract principle; cut additional restatements
- Do not rewrite in a different voice; remove, do not paraphrase
