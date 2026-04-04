---
title: Forge MADR Extensions
description: Documents the x-forge- extension pattern for structured-madr frontmatter, adding RACI, provenance, and promotion fields
type: adr
category: process
tags:
    - adr
    - process
    - structured-madr
    - extensions
status: accepted
created: 2026-03-30
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0005 ADR Template Choice.md"
    - "CORE-0003 YAML Frontmatter for Machine Readability.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Forge MADR Extensions

## Context and Problem Statement

[CORE-0005](CORE-0005 ADR Template Choice.md) adopts [structured-madr][1] as the ADR template. The upstream schema covers universal ADR fields (title, description, type, category, tags, status, created, updated, author, project, related). But the forge ecosystem needs additional fields for RACI accountability, rule promotion tracking, and cross-repo provenance.

The [structured-madr schema][1] allows additional properties prefixed with `x-`, providing a sanctioned extension mechanism.

## Decision Drivers

- RACI fields (responsible, accountable, consulted, informed) track decision ownership across teams
- `promoted` tracks which rules were extracted from a decision
- `upstream` and `sources` track cross-repo provenance and external references
- Extensions must not break upstream schema validation

## Decision Outcome

Forge ADRs use `x-forge-` prefixed extension fields alongside [structured-madr][1] required fields. For brevity, the short form (without prefix) is the canonical name in forge repos. Both forms are valid in the schema.

### Extension Fields

| Short form    | Compliant form         | Type         | Purpose                                                          |
| ------------- | ---------------------- | ------------ | ---------------------------------------------------------------- |
| `responsible` | `x-forge-responsible`  | string array | RACI: who does the work                                          |
| `accountable` | `x-forge-accountable`  | string array | RACI: who approves the decision                                  |
| `consulted`   | `x-forge-consulted`    | string array | RACI: whose input is sought                                      |
| `informed`    | `x-forge-informed`     | string array | RACI: who is notified of the outcome                             |
| `upstream`    | `x-forge-upstream`     | string array | Rules or artifacts promoted from this ADR, or provenance sources |

### Three Tiers

1. **structured-madr** — upstream schema, shared repos. Required fields only: title, description, type, category, tags, status, created, updated, author, project.
2. **forge-adr** — forge ecosystem fork. Adds RACI and upstream. Used in forge-core and downstream modules.
3. **Obsidian derivation** — future tier for vault-specific fields (aliases, icon, image, cssclasses, project.*). Not yet standardized.

### Consequences

- **Positive:** ADRs carry full accountability and provenance metadata
- **Positive:** Extensions use the sanctioned `x-` mechanism — upstream schema validation passes
- **Negative:** Forge ADRs have more frontmatter fields than upstream [structured-madr][1] — mitigated by all extension fields being optional

[1]: https://github.com/zircote/structured-madr
