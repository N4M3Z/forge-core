---
name: MarkdownConventions
version: 0.1.0
description: "Markdown authoring and linting conventions for forge — fence tags, table alignment, link paths, reference-style labels, README language switchers, and the Linting workflow. USE WHEN editing any markdown file, or invoking lint."
paths:
    - "**/*.md"
argument-hint: "[path to markdown file]"
---

# MarkdownConventions

Hub for forge's markdown conventions and the linting workflow. Each companion below holds one convention; Claude reads the relevant companion when the current task calls for it.

## Workflow

For a full lint pass on a file: see [Linting.md](Linting.md). That workflow reads the file, applies all conventions below, and writes the corrected version after confirmation.

## Conventions

- [MarkdownCodeFence.md](MarkdownCodeFence.md) — every fenced code block has a language tag; prefer `sh` over `bash`
- [TableAlignment.md](TableAlignment.md) — tables must have column-aligned pipes
- [MarkdownLinks.md](MarkdownLinks.md) — use literal spaces in link paths, never `%20`
- [MarkdownReflinks.md](MarkdownReflinks.md) — reference-style link labels use mnemonic abbreviations, not numbers
- [SourceCitations.md](SourceCitations.md) — cite origins for factual data points (numbers, dates, limits)
- [ReadmeLanguageSwitcher.md](ReadmeLanguageSwitcher.md) — multilingual README switcher pattern

## Constraints

- Never modify YAML frontmatter content during a lint pass
- Never modify content inside fenced code blocks or inline code
- Preserve Obsidian-specific syntax (wikilinks, embeds, callouts, `%% %%` comments, dataview blocks)
