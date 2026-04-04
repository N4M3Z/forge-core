---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: [ArchitectureDecisionRecords.md]
tags: [adr, process]
---

# Adopt Architecture Decision Records

## Context and Problem Statement

Conversations, meetings, email threads, instant messages, commit messages, tribal knowledge — decisions get made everywhere, but none of these are structured or durable. As systems grow, the rationale behind structural choices becomes harder to recover. Both humans and LLMs working with systems lose the "why" behind how things were built, leading to proposals that unknowingly contradict prior decisions.

## Decision Drivers

- Accepted decisions must not be silently contradicted — violations should be visible
- Decision history needs to live outside git commits, which don't transfer across repos or tools
- AI sessions compress away reasoning during context compaction — decisions must survive that

## Considered Options

1. **Commit messages only** — decisions live in git history, discoverable via `git log --grep` but buried in noise, no structured format, no status lifecycle
2. **Inline documentation sections** — add a "Decisions" section to project docs, keeps context close but bloats files and has no schema enforcement
3. **ADR files in docs/decisions/** — dedicated markdown files per decision with frontmatter (status, date), validated by mdschema, numbered filenames for cross-referencing

## Decision Outcome

Chosen option: **ADR files in docs/decisions/**. They separate decision records from operational documentation, support a status lifecycle (Proposed → Accepted → Superseded), and can be validated structurally via mdschema. The markdown format integrates naturally into PKM tools (like Obsidian) and enables automated capture pipelines (hooks that prompt for ADR extraction after context compaction).

### Consequences

- [+] Decisions discoverable by listing a single directory
- [+] Status field prevents accidental contradiction of accepted decisions
- [+] Markdown format links into Obsidian vaults and other PKMs without conversion
- [-] Requires authoring discipline — automated capture hooks mitigate this

## More Information

- [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) — Michael Nygard's original 2011 post
- [MADR](https://adr.github.io/madr/) — Markdown Architectural Decision Records
- [Y-Statements](https://medium.com/olzzio/y-statements-10eb07b5a177) — single-sentence format, considered and rejected for readability