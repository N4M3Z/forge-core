---
title: mdschema for Structural Validation
description: YAML schema files declaring frontmatter and heading constraints for structured markdown validation
type: adr
category: architecture
tags:
    - architecture
    - validation
    - markdown
status: accepted
created: 2026-02-21
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0001 Markdown as System Language.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: [MarkdownSchema.md]
---

# mdschema for Structural Validation

## Context and Problem Statement

With markdown as the system language ([CORE-0001](CORE-0001 Markdown as System Language.md)), structured files (skills, ADRs, journal templates) can silently omit required frontmatter fields, skip heading levels, or violate conventions. There is no equivalent of JSON Schema for markdown files. Validation must be automatable in CI and `make lint`.

## Decision Drivers

- Schema should travel with the content — no out-of-band documentation about what fields are required
- Same mechanism must work for skills, ADRs, journal templates, and any structured markdown
- Must integrate with existing build tooling (`make lint`, CI pipelines)

## Considered Options

1. **Manual checklist in build skills** — instructions tell authors what to include, no enforcement
2. **Custom Rust validator with hardcoded rules** — fast but couples validation logic to code, every new file type needs new code
3. **`.mdschema` files** — YAML files declaring frontmatter fields and heading constraints, checked by a generic validator

## Decision Outcome

Chosen option: **`.mdschema` files**. Each directory carries its own schema declaring required frontmatter, heading hierarchy (`no_skip_levels`), and max depth. Both `make verify` and the standalone `mdschema` CLI consume them.

### Consequences

- [+] Schema travels with the content — discoverable without external documentation
- [+] Same mechanism works across all structured markdown in the ecosystem
- [+] Generic validator means new file types need zero new code — just a schema file
- [-] Covers structure only — semantic correctness (does the content actually work?) requires review
