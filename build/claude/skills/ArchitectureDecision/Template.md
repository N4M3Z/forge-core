# ADR Template Reference

MADR light format adapted from [MADR](https://adr.github.io/madr/) for the forge ecosystem. Target 20-60 lines per ADR.

## Config Keys

All configurable via `defaults.yaml` deep merge. Override in `config.yaml`. At runtime, use env vars set by `yaml env`:

| Key                  | Env var (after `yaml env`) | Default                    | Purpose                                       |
|----------------------|----------------------------|----------------------------|-----------------------------------------------|
| `adr.prefix`         | `FORGE_ADR_PREFIX`         | `number`                   | Filename prefix mode: `date` or `number`      |
| `adr.directory`      | `FORGE_ADR_DIRECTORY`      | `docs/decisions`           | Where ADRs live relative to module root       |
| `adr.template`       | `FORGE_ADR_TEMPLATE`       | `templates/madr.md`        | Default MADR light template                   |
| `adr.full_template`  | `FORGE_ADR_FULL_TEMPLATE`  | `templates/adr.md`         | Nygard short template — minimal decisions     |
| `adr.schema`         | `FORGE_ADR_SCHEMA`         | `docs/decisions/.mdschema` | Path to the validation schema                 |

## Filename Convention

`NNNN Title Name.md` — four-digit number, dot separator, human-readable title with spaces.

| Mode     | Pattern                 | Example                                   |
|----------|-------------------------|-------------------------------------------|
| `number` | `NNNN Title Name.md`    | `0001 Adopt Architecture Decision Records.md` |
| `date`   | `YYYY-MM-DD Title Name.md`   | `2026-03-02.Hybrid ADR Placement.md`      |

Number mode is the default — compact cross-references (`ADR-0001`), matches existing forge-dev and forge-journals conventions.

## Frontmatter

| Field         | Required | Values                                                          |
|---------------|----------|-----------------------------------------------------------------|
| `status`      | Yes      | `Proposed`, `Accepted`, `Deprecated`, `Superseded: by <ref>`   |
| `date`        | Yes      | `YYYY-MM-DD` — creation date, not modification date            |
| `responsible` | Yes      | People who did the work (RACI: R)                              |
| `accountable` | Yes      | People who own the outcome (RACI: A)                           |
| `consulted`   | No       | People asked for input before deciding (RACI: C)               |
| `informed`    | No       | People notified after the decision was made (RACI: I)          |
| `promoted`    | No       | Rules that codify this decision (e.g., `[Licensing]`)          |
| `tags`        | No       | Topic classification and search                                |

## Sections

**Context and Problem Statement** (required) — What forced a decision? What are the constraints? 3-6 sentences.

**Decision Drivers** (optional) — Forces or concerns influencing the choice. Bullet list.

**Considered Options** (required) — Numbered list of alternatives examined. Minimum two for significant decisions.

**Decision Outcome** (required) — Lead with `Chosen option: **Option X**, because [rationale]`. One paragraph.

**Consequences** (subsection of Decision Outcome) — Notable tradeoffs. `[+]` / `[-]` markers. Omit if no meaningful consequences.

**More Information** (optional) — Links, references, prior art, related ADRs.
