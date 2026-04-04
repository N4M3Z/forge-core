---
title: ADR Template Choice
description: Adopts structured-madr as the ADR template with custom extensions for RACI, accountability, and upstream provenance tracking
type: adr
category: process
tags:
    - adr
    - process
    - structured-madr
status: accepted
created: 2026-02-19
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0004 Adopt Architecture Decision Records.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# ADR Template Choice

## Context and Problem Statement

Having adopted ADRs ([CORE-0004](CORE-0004 Adopt Architecture Decision Records.md)), we need a concrete template format. Established formats exist — Nygard's original ADR, full MADR 4.0, Y-Statements, and structured-madr — each with different tradeoffs between brevity, machine-readability, and tooling support. ADR frontmatter must be machine-readable and validatable in CI.

## Decision Drivers

- Frontmatter must be machine-readable and validatable via JSON Schema in CI
- Considered options must be recorded — Nygard's original omits them entirely
- RACI-style accountability tracking is valuable for team decisions
- Template must scale from quick records (20 lines) to thorough analyses (100+ lines)

## Considered Options

1. **Nygard ADR** — Context, Decision, Status, Consequences. Minimal but no options enumeration, no frontmatter schema, no accountability tracking
2. **Full MADR 4.0** — Context, Decision Drivers, Considered Options with per-option Pros/Cons, Decision Outcome with Confirmation, More Information, RACI frontmatter. Thorough but heavy, no JSON Schema validation
3. **Y-Statements** — everything in one sentence. Forces conciseness but sentences become unwieldy for complex decisions
4. **MADR light** — MADR 4.0 minus per-option Pros/Cons and Confirmation, plus custom frontmatter (tags, RACI fields)
5. **structured-madr** — extends MADR with machine-readable YAML frontmatter (`title`, `description`, `type`, `category`, `tags`, `created`, `updated`, `author`, `project`, `technologies`, `audience`, `related`). [JSON Schema](https://github.com/zircote/structured-madr/blob/main/schemas/structured-madr.schema.json) + [GitHub Action](https://github.com/zircote/structured-madr) validator. Risk assessment sections for options. Audit trail

## Decision Outcome

Chosen option: **structured-madr with custom extensions**.

Use [structured-madr](https://github.com/zircote/structured-madr) as the base, validated by its JSON Schema in CI. Extend with custom fields for RACI accountability and upstream provenance tracking. See [CORE-0007](CORE-0007 Forge MADR Extensions.md) for the `x-forge-` namespace.

### structured-madr frontmatter

```yaml
---
title: "Use PostgreSQL for Primary Storage"
description: "Decision to adopt PostgreSQL as the primary database"
type: adr
category: architecture
tags:
    - database
    - postgresql
status: accepted
created: 2025-01-15
updated: 2025-01-20
author: Architecture Team
project: my-application
technologies:
    - postgresql
    - rust
audience:
    - developers
    - architects
related:
    - adr_0001.md
---
```

### Custom extensions

structured-madr recommends `x-` prefix for custom fields. The `x-forge-` namespace is documented in [CORE-0007](CORE-0007 Forge MADR Extensions.md). The base extensions used across all repos:

| Canonical           | Short form     | Type     | Purpose                                          |
| ------------------- | -------------- | -------- | ------------------------------------------------ |
| `x-responsible`     | `responsible`  | string[] | RACI: who does the work                          |
| `x-accountable`     | `accountable`  | string[] | RACI: who owns the outcome                       |
| `x-consulted`       | `consulted`    | string[] | RACI: whose input is sought                      |
| `x-informed`        | `informed`     | string[] | RACI: who is notified of the outcome             |
| `x-upstream`        | `upstream`     | string   | Provenance URL for adapted ADRs                  |

Short forms are used in practice for readability.

Body sections follow structured-madr: Context (with Background and Current Limitations), Decision Drivers (Primary/Secondary), Considered Options (with Risk Assessment), Decision, Consequences (Positive/Negative/Neutral), Related Decisions, Links, More Information, Audit.

Nygard short template kept at `templates/adr.md` for minimal records.

### Consequences

- [+] Machine-readable frontmatter validated by JSON Schema in CI
- [+] Structured options with risk assessment surface tradeoffs explicitly
- [+] Full RACI scales from solo projects to team decisions
- [+] `upstream` field tracks provenance and promoted rules
- [-] Heavier template than MADR light — more sections to fill
- [-] Custom extensions require extended schema for validation

## More Information

- [structured-madr](https://github.com/zircote/structured-madr) — upstream schema and GitHub Action validator
- [structured-madr JSON Schema](https://github.com/zircote/structured-madr/blob/main/schemas/structured-madr.schema.json) — frontmatter validation schema
- [MADR](https://adr.github.io/madr/) — original format this derives from
- [MADR Template Primer](https://www.ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html) — Olaf Zimmermann's walkthrough
- Nygard short template at `templates/adr.md` for minimal records
- Upstream template at `templates/structured-madr.md`, schema at `templates/structured-madr.schema.json`
- [CORE-0007](CORE-0007 Forge MADR Extensions.md) — `x-forge-` namespace for the forge ecosystem
