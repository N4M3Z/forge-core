---
title: Markdown as System Language
description: All instructions, skills, agents, and rules are authored as markdown with YAML frontmatter
type: adr
category: architecture
tags:
    - architecture
    - markdown
status: accepted
created: 2026-02-19
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [MarkdownFirst.md]
---
# Markdown as System Language

## Context and Problem Statement

The system needs a universal format for skills, agents, rules, documentation, journal templates, and configuration. This format must be readable by humans, consumable by AI tools across providers, and authorable without specialized tooling. It also needs to integrate with PKM tools (like Obsidian) where content is first-class.

## Decision Drivers

- Multi-provider portability — no vendor lock-in to one AI tool's plugin format
- Zero runtime dependencies — any tool that reads files can consume the content
- Authors must iterate by editing prose, not debugging code
- Content must work in Obsidian vaults, GitHub rendering, and AI tool contexts simultaneously

## Considered Options

1. **Code templates** — executable scripts with placeholder substitution, requires a runtime per provider and per artifact type
2. **JSON/YAML definitions** — structured data with typed fields, machine-readable but hard to author and review
3. **Markdown with YAML frontmatter** — prose body for instructions, frontmatter for metadata, validated by mdschema

## Decision Outcome

Chosen option: **Markdown with YAML frontmatter**. Everything is markdown — skills, agents, rules, ADRs, journal templates, documentation. YAML frontmatter carries machine-readable metadata while the body remains free-form instruction or content. The same file works in a git repo, an Obsidian vault, and an AI tool's context window.

### Consequences

- [+] Zero dependencies — any AI tool that reads files can consume the content
- [+] Authors iterate by editing prose, not debugging code or schemas
- [+] Same files render in Obsidian, GitHub, and AI tool contexts without conversion
- [-] No compile-time validation of content logic — structural checks rely on mdschema, semantic correctness requires review
