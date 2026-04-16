---
name: AlignPrompt
description: "Fix indentation, fence language tags, heading depth, and frontmatter fields to match forge conventions. USE WHEN an adopted community skill or any prompt-shaped document fails a forge convention check (indent, fence, heading, schema)."
version: 0.1.0
allowed-tools: Read, Edit, Write
---

# AlignPrompt

Bring a prompt-shaped document into forge convention without changing its meaning. Referenced by [ForgeAdopt](../ForgeAdopt/SKILL.md) as the `align` transform.

## What to fix

| Axis              | Forge convention                                                               |
| ----------------- | ------------------------------------------------------------------------------ |
| Indentation       | Four spaces. No tabs. Applies to markdown, YAML, TOML, JSON, code blocks.      |
| Fence tags        | Every fenced code block carries a language tag. Use `sh`, not `bash`.          |
| Heading depth     | Max depth 3. No skipped levels (no H1 to H3 without H2 between).               |
| Heading style     | One H1 per document, matching the skill name in PascalCase.                    |
| Frontmatter keys  | `name`, `description`, `version`. Strip upstream fields forge does not use.    |
| Skill name        | PascalCase, two words, scope plus focus (for example `SecurityBestPractices`). |
| Table alignment   | Pipes line up vertically; pad cells with spaces to the widest column.          |
| Trailing newline  | Every text file ends with a single `\n`.                                       |
| Wikilinks / paths | Spaces literal, not URL-encoded.                                               |

## What to preserve

- The skill's actual instructions and workflow
- Body structure and section order unless a heading level is wrong
- Code block contents; only fix the fence tag, never the code inside
- Emphasis and voice, except where convention conflicts

## Procedure

1. Read the full document.
2. Fix frontmatter first — it gates downstream checks.
3. Walk the heading tree, flagging any skip or over-deep section.
4. Sweep indentation; convert tabs to four spaces.
5. Sweep fences; ensure every one has a language tag.
6. Align tables column by column.
7. Re-read; the content meaning must be unchanged.

## Constraints

- Never rewrite content to fix alignment — only fix structure
- If an upstream skill legitimately needs H4 or H5, flag it as a content issue, do not silently demote
- Do not remove frontmatter fields the skill relies on for runtime behavior (`argument-hint`, `allowed-tools`, `hooks`)
- If the H1 title does not match the skill name, rename the file or rewrite the H1 — do not leave them divergent
