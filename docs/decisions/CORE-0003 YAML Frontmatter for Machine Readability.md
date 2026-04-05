---
title: YAML Frontmatter for Machine Readability
description: All markdown files carry YAML frontmatter as the metadata format, aligned with Obsidian Properties, Claude Code, and static site generators
type: adr
category: architecture
tags:
    - architecture
    - markdown
    - frontmatter
    - yaml
status: accepted
created: 2026-03-30
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0001 Markdown as System Language.md"
    - "CORE-0002 Metadata Inside Files.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [ObsidianFrontmatter.md]
---

# YAML Frontmatter for Machine Readability

## Context and Problem Statement

[CORE-0002](CORE-0002 Metadata Inside Files.md) established that metadata belongs inside the file it describes. This ADR selects the specific format: YAML frontmatter.

The broader ecosystem has converged on YAML frontmatter as the standard metadata layer for markdown files:

- [**Claude Code**][CC] reads YAML frontmatter in `CLAUDE.md` and skill files to understand file purpose, version, and configuration without parsing the full body ([docs][CC-DOCS]).
- [**Obsidian**][OBS] adopted YAML frontmatter as the basis for its [Properties][OBS-PROPS] system — the native UI for viewing, editing, and querying file metadata. The [Dataview][DATAVIEW] and Tasks plugins query frontmatter fields for dynamic views.
- **Static site generators** ([Jekyll][JEKYLL], [Hugo][HUGO], Astro, Eleventy) all use YAML frontmatter as the standard metadata format for content files.
- **GitHub** renders YAML frontmatter as a formatted table at the top of markdown files in the web UI.

This is not a project-specific convention — it is the de facto standard for markdown metadata across the tools this ecosystem depends on.

## Decision Drivers

- [Obsidian][OBS] Properties requires YAML frontmatter — no frontmatter means no queryable metadata in the vault
- [Claude Code][CC] parses frontmatter to understand skill definitions, agent configurations, and rule files
- Schema validation via `mdschema` requires typed fields that can be checked by CI
- Structured-madr adoption depends on a rich frontmatter convention
- Every major markdown tool already expects YAML frontmatter — adopting it costs nothing and enables everything

## Considered Options

1. **TOML frontmatter** — delimited by `+++`. Used by [Hugo][HUGO] as an alternative. Less readable than YAML for nested structures, and [Obsidian][OBS] does not support it natively.
2. **JSON frontmatter** — delimited by `{` / `}`. Valid in some static site generators but hostile to human authoring, no [Obsidian][OBS] support, and poor readability for lists and nested values.
3. **YAML frontmatter** — delimited by `---` at the top of the file. Universally supported by markdown renderers, [Obsidian][OBS], [Claude Code][CC], GitHub, and static site generators.

## Decision Outcome

All markdown files carry YAML frontmatter delimited by `---`. Frontmatter holds machine-readable metadata; the prose body holds human-readable instructions. The same file works in a git repo, an [Obsidian][OBS] vault, and an AI tool's context window without conversion.

Frontmatter properties must be flat — [Obsidian][OBS]'s Properties panel cannot display nested YAML. Use strings or lists of strings only, never nested objects. YAML values containing `:` must be quoted.

This decision precedes the MADR template choice because frontmatter is the mechanism; structured-madr is the schema that standardizes which fields appear in ADR frontmatter specifically.

### Consequences

- **Positive:** Every file is queryable by [Dataview][DATAVIEW], validatable by `mdschema`, and parseable by AI tools without custom logic
- **Positive:** Aligns with the dominant ecosystem convention — no migration cost, no custom tooling
- **Positive:** Metadata travels with the file across systems, tools, and repos
- **Negative:** Authors must maintain frontmatter alongside prose — stale metadata is a risk mitigated by CI validation and [Obsidian][OBS]'s Properties UI

[CC]: https://claude.ai/code
[CC-DOCS]: https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview
[OBS-PROPS]: https://help.obsidian.md/properties
[OBS]: https://obsidian.md/
[DATAVIEW]: https://blacksmithgu.github.io/obsidian-dataview/
[JEKYLL]: https://jekyllrb.com/docs/front-matter/
[HUGO]: https://gohugo.io/content-management/front-matter/
