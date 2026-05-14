---
name: RefinePrompt
description: "Apply targeted transforms to prompt-shaped documents: align conventions, debrand vendor references, minimize filler, rescope tool grants, extract bulk reference, adapt for downstream repos. USE WHEN refining an adopted skill, polishing an authored skill/rule/agent, removing rot, or porting prompts across repos."
version: 0.1.0
allowed-tools: Read, Edit, Write, Grep
argument-hint: "[target file or repo]"
---

# RefinePrompt

Six transforms for refining a prompt-shaped document. Apply each independently or in sequence; each is also composable by [AdoptArtifact](../AdoptArtifact/SKILL.md) during community-skill adoption.

## Decide what to apply

| Transform | Apply when                                                                   |
| --------- | ---------------------------------------------------------------------------- |
| Align     | Indent, fence tags, heading depth, frontmatter, or table alignment is off    |
| Debrand   | Hardcoded vendor names or external-service dependencies bias the artifact    |
| Minimize  | Motivational, marketing, or filler prose; emphasis inflation                 |
| Rescope   | `allowed-tools: '*'` or unnecessarily broad grants                            |
| Extract   | SKILL.md body has bulk reference material that does not need to be loaded    |
| Adapt     | Porting prompts from this repo to a downstream/consumer repo                  |

## Transforms

@Align.md

@Debrand.md

@Minimize.md

@Rescope.md

@Extract.md

@Adapt.md

## Cross-cutting constraints

- Never rewrite content to change meaning. Refine structure, remove rot, narrow scope; do not paraphrase.
- Preserve anti-pattern lists, concrete examples, command/regex/schema blocks, and runtime-critical frontmatter (`name`, `description`, `version`, `allowed-tools`, `argument-hint`, `hooks`).
- Recompute the artifact's SHA-256 after every transform and sync it to the provenance sidecar if one exists. The sidecar's `subject.digest.sha256` must match the current file content.
- When in doubt, preserve and flag for human review rather than transform silently.
