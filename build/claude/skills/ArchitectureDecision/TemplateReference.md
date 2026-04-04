# ADR Template Reference

Three template tiers, from minimal to full:

| Template                       | Schema                           | When to use                             |
| ------------------------------ | -------------------------------- | --------------------------------------- |
| `templates/adr.md`             | —                                | Minimal Nygard records (10-20 lines)    |
| `templates/madr.md`            | —                                | MADR light for standard decisions       |
| `templates/structured-madr.md` | `templates/structured-madr.json` | Upstream structured-madr (shared repos) |
| `templates/forge-adr.md`       | `templates/forge-adr.json`       | Forge ecosystem ADRs (RACI + upstream)  |

## Config

| Env var             | YAML key             | Default                    | Purpose                                  |
| ------------------- | -------------------- | -------------------------- | ---------------------------------------- |
| `$ADR_PREFIX`       | `adr.prefix`         | `number`                   | Filename prefix mode: `number` or `date` |
| `$ADR_DIRECTORY`    | `adr.directory`      | `docs/decisions`           | ADR directory relative to module root    |
| `$ADR_TEMPLATE`     | `adr.template`       | `templates/forge-adr.md`   | Default template for new ADRs            |
| `$ADR_SCHEMA`       | `adr.schema`         | `templates/forge-adr.json` | JSON schema for frontmatter validation   |
| `$ADR_MDSCHEMA`     | `adr.mdschema`       | `docs/decisions/.mdschema` | Markdown structural schema               |

## Filename Convention

Read `$ADR_PREFIX` (default: `number`):
- `number`: `NNNN Title Name.md` — next available four-digit number
- `date`: `YYYY-MM-DD Title Name.md` — today's date at creation

Prefixes are per-scope. Root and module directories count independently.

## Frontmatter (forge-adr)

| Field         | Required | Type         | Description                                         |
| ------------- | -------- | ------------ | --------------------------------------------------- |
| `title`       | yes      | string       | Short descriptive title                             |
| `description` | yes      | string       | One-sentence summary                                |
| `type`        | yes      | string       | Always `adr`                                        |
| `category`    | yes      | string       | architecture, process, governance, security, etc.   |
| `tags`        | yes      | string array | Keywords for search                                 |
| `status`      | yes      | string       | proposed, accepted, deprecated, superseded          |
| `created`     | yes      | string       | YYYY-MM-DD creation date                            |
| `updated`     | yes      | string       | YYYY-MM-DD last modification                        |
| `author`      | yes      | string       | GitHub handle (e.g., `@N4M3Z`)                      |
| `project`     | yes      | string       | Repository name                                     |
| `related`     | no       | string array | Filenames of related ADRs                           |
| `responsible` | no       | string array | RACI: who does the work                             |
| `accountable` | no       | string array | RACI: who approves the decision                     |
| `consulted`   | no       | string array | RACI: whose input is sought                         |
| `informed`    | no       | string array | RACI: who is notified                               |
| `upstream`    | no       | string array | Rules promoted from this ADR, or provenance sources |

## Sections

**Context and Problem Statement** (required) — What forced a decision? What are the constraints? 3-6 sentences.

**Decision Drivers** (optional) — Forces or concerns influencing the choice. Bullet list.

**Considered Options** (required) — Numbered list of alternatives examined. Minimum two for significant decisions.

**Decision Outcome** (required) — Lead with `Chosen option: **Option X**, because [rationale]`. One paragraph.

**Consequences** (subsection of Decision Outcome) — Notable tradeoffs. `[+]` / `[-]` markers. Omit if no meaningful consequences.

**Related Decisions** (optional) — Links to related ADRs with relationship description.

**Links** (optional) — Prior art, specs, discussions.
