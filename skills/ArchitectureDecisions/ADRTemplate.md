# ADR Template Reference

Adapted from MADR (https://adr.github.io/madr/) for the forge ecosystem. Target 20-60 lines per ADR.

## Config Keys

All configurable via `defaults.yaml` deep merge. Override in `config.yaml` or via forge-obsidian.

| Key                  | Default                    | Purpose                                       |
|----------------------|----------------------------|-----------------------------------------------|
| `adr.prefix`         | `date`                     | Filename prefix mode: `date` or `number`      |
| `adr.directory`      | `docs/decisions`           | Where ADRs live relative to module root       |
| `adr.template`       | `templates/adr.md`         | Short template — most decisions               |
| `adr.full_template`  | `templates/madr.md`        | Full MADR 4.0 — complex multi-stakeholder     |
| `adr.schema`         | `docs/decisions/.mdschema` | Path to the validation schema                 |

## Prefix Modes

| Mode     | Pattern                        | Example                              |
|----------|--------------------------------|--------------------------------------|
| `date`   | `YYYY-MM-DD-kebab-title.md`   | `2026-03-02-hybrid-adr-placement.md` |
| `number` | `NNNN-kebab-title.md`         | `0001-hybrid-adr-placement.md`       |

Date is the default — self-documenting, matches journal naming, no sequence tracking. Same-day ADRs disambiguated by title. Number mode follows the MADR standard for compact cross-references (`ADR-0003`).

No existing ADR tool (npryce/adr-tools, meza/adr-tools, MADR) offers configurable prefix — all hardcode sequential numbering. This is a forge convention.

## Frontmatter

| Field    | Required | Values                                                          |
|----------|----------|-----------------------------------------------------------------|
| `status` | Yes      | `Proposed`, `Accepted`, `Deprecated`, `Superseded: by <ref>`   |
| `date`   | Yes      | `YYYY-MM-DD` — creation date, not modification date            |

## Sections

**Context** (required) — Problem statement. What forced a decision? What are the constraints? 3-6 sentences.

**Considered Options** (optional but expected) — Alternatives examined. Even if one option was obvious, listing others proves due diligence. Minimum two options for significant decisions.

**Decision** (required) — Lead with the chosen option in bold. Follow with rationale. One paragraph; more means Context is doing too little work.

**Consequences** (optional) — Notable tradeoffs. Bullet format. Omit if there are no meaningful consequences to document.
