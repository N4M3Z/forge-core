---
title: "Fixture-Based Canary Testing"
description: "Validators test against real fixture files in valid/ and invalid/ directories to prove they catch errors"
type: adr
category: process
tags:
    - testing
    - validation
    - fixtures
status: accepted
created: 2026-04-05
updated: 2026-04-05
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0010 Unified Module Validation.md"
responsible:
    - "@N4M3Z"
accountable:
    - "@N4M3Z"
consulted: []
informed: []
upstream:
    - "https://github.com/json-schema-org/JSON-Schema-Test-Suite"
---

# Fixture-Based Canary Testing

## Context and Problem Statement

Validators can regress silently — a broken validator that accepts everything still produces exit 0 in CI. Unit tests verify individual check functions, but nothing proves the full pipeline (file read, frontmatter extraction, schema validation) catches real errors. A council review found that forge-core's entire quality gate was untested end-to-end.

## Decision Drivers

- A validator that accepts everything is as broken as one that rejects everything
- Adding a test case should require adding a file, not writing code
- The pattern should work for any validator (ADR, mdschema, skill frontmatter)

## Considered Options

1. **`valid/` + `invalid/` directories** — fixtures organized by expected result, runner globs and asserts based on parent directory
2. **Inline annotation manifest** — JSON file with `"valid": true/false` per fixture (JSON Schema Test Suite pattern)
3. **Filename prefix** — `pass-` and `fail-` prefixes, flat directory

## Decision Outcome

Chosen option: **`valid/` + `invalid/` directories**, because the directory name is the assertion and the layout is self-documenting without reading any manifest or convention docs.

### Consequences

- [+] Adding a canary test is creating a file in the right directory
- [+] Directory listing shows test coverage at a glance
- [-] Two directories per validator instead of one flat directory

## Related Decisions

- [CORE-0010](CORE-0010 Unified Module Validation.md) — the validation chain these fixtures test

## Links

- [JSON Schema Test Suite](https://github.com/json-schema-org/JSON-Schema-Test-Suite) — canonical validator testing pattern
- [markdownlint fixtures](https://github.com/DavidAnson/markdownlint) — valid/invalid directory convention
- [bats-core](https://bats-core.readthedocs.io/) — upgrade path for structured TAP output
