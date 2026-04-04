---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: []
tags: [adr, process, obsidian]
---

# MADR Template Choice

## Context and Problem Statement

Having adopted ADRs ([0002](0002 Adopt Architecture Decision Records.md)), we need a concrete template format. Three established formats exist — Nygard's original ADR, full MADR 4.0, and Y-Statements — each with different tradeoffs between brevity and thoroughness. Additionally, ADRs need to work inside Obsidian vaults where frontmatter, tags, and wikilinks are first-class citizens.

## Decision Drivers

- Template must be fast to write — most decisions don't warrant 8+ sections
- Considered options must be recorded — Nygard's original omits them entirely
- Frontmatter must be Obsidian-compatible — tags, properties, graph integration
- RACI-style accountability tracking is valuable for team decisions
- YAML sidecars may accompany ADRs when managed by PKM tools

## Considered Options

1. **Nygard ADR** — Context, Decision, Status, Consequences. Minimal but no options enumeration, no accountability tracking
2. **Full MADR 4.0** — Context, Decision Drivers, Considered Options with per-option Pros/Cons, Decision Outcome with Confirmation, More Information, RACI frontmatter. Thorough but heavy
3. **Y-Statements** — everything in one sentence. Forces conciseness but sentences become unwieldy for complex decisions
4. **MADR light** — MADR 4.0 minus per-option Pros/Cons and Confirmation, plus Obsidian-native frontmatter (tags, RACI fields)

## Decision Outcome

Chosen option: **MADR light**. Uses MADR 4.0's minimal template (Context and Problem Statement, Considered Options, Decision Outcome are mandatory; Decision Drivers, Consequences, More Information are optional). Extends frontmatter with full RACI (`responsible`/`accountable`/`consulted`/`informed` instead of MADR's collapsed `decision-makers`), `tags` for topic classification and search, and `promoted` to track decisions codified as rules. Consequences use `[+]`/`[-]` markers from MADR's own pros/cons notation.

### Consequences

- [+] Fast to write — 20-60 lines covers most decisions
- [+] Considered options always recorded — prevents "we didn't think about alternatives" gaps
- [+] Full RACI scales from solo projects (just `responsible`) to team decisions with clear accountability
- [+] `promoted` field links decisions to the rules that enforce them
- [-] RACI fields and `promoted` are extensions beyond MADR 4.0 — MADR tooling will ignore them

## More Information

- [MADR](https://adr.github.io/madr/) — upstream format this derives from
- [MADR Template Primer](https://www.ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html) — Olaf Zimmermann's walkthrough of MADR 4.0
- Nygard short template kept at `templates/adr.md` as an alternative for minimal records
- Future direction: OMADR (Obsidian MADR) — wikilinks for cross-references, YAML sidecars for PKM-managed metadata
