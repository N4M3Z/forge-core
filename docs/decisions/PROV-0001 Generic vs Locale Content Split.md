---
title: Generic vs Locale Content Split
description: Locale subdirectories for jurisdiction-specific module content
type: adr
category: architecture
tags:
    - architecture
    - locale
status: accepted
created: 2026-03-29
updated: 2026-04-04
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: ["DeveloperCouncil"]
informed: []
upstream: []
---

# Generic vs Locale Content Split

## Context and Problem Statement

Modules serving a specific jurisdiction (tax, legal, compliance) need a way to separate generic content from jurisdiction-specific content without polluting filenames with locale suffixes.

## Decision Drivers

- Filenames should describe content, not repeat the module's jurisdiction
- The install tooling deploys nested directories recursively
- Claude Code loads rules recursively from `.claude/rules/`
- Adding a second jurisdiction should not require renaming existing files
- Locale tags use IETF BCP 47 format: `{language}-{REGION}` (`en-CZ`, `cs-CZ`, `de-AT`)

## Considered Options

1. Locale subdirectories (`rules/cs-CZ/`, `skills/cs-CZ/`, generic at root)
2. Assembly-time locale injection (overlay system)
3. Country as provider dimension in defaults.yaml
4. Flat structure with locale in frontmatter metadata
5. Separate modules per country

## Decision Outcome

Chosen option: **Option 1 (locale subdirectories)**, because it requires zero tooling changes, preserves flat discovery for generic content, and the subdirectory IS the namespace.

### Consequences

- [+] Generic content at root, jurisdiction content in `{kind}/{locale}/` (e.g. `rules/cs-CZ/`)
- [+] Adding a jurisdiction means adding a subdirectory
- [+] The install tooling handles nested directories for rules, skills, and agents

## More Information

The install tooling's `collect_files_recursive` and `copy_directory_recursive` handle nested directories. Claude Code recursively loads from `.claude/rules/{locale}/`.
