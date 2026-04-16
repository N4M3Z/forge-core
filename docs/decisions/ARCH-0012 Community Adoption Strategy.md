---
title: "Community Adoption Strategy"
description: "Forge adopts a small, selective set of community skills under explicit scope, excluding rules and agents, with productization deferred until the pattern proves out"
type: adr
category: architecture
tags:
    - architecture
    - adoption
    - strategy
    - curation
status: accepted
created: 2026-04-16
updated: 2026-04-16
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0001 Skills Agents and Rules.md"
    - "MVPR-0001 Minimum Viable Prompt.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Community Adoption Strategy

## Context and Problem Statement

Third-party catalogs like [aitmpl.com][AITMPL] (backed by [davila7/claude-code-templates][CCT]) ship ~1000 artifacts with no editorial gating, no schema enforcement, and no blocking CI. Research of the top-installed skills found that only 10-25% pass basic quality checks after transform, install counts correlate with category naming rather than utility (npm-hit counters, not unique adopters), and no competitor occupies the schema-validated, provenance-tracked, adversarially-reviewed quality tier.

Forge needs a strategy that decides what to adopt, how much, under what rules, and what to explicitly not build. Without this ADR, each adoption becomes an ad-hoc judgment call, and productization infrastructure risks being built speculatively before any adoption is done.

The adoption *mechanism* is captured in [ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md); the provenance *schema* in [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md). This ADR is strategic: it defines scope, inclusion rules, exclusion rules, and the deferred work.

## Decision Drivers

- Catalog volume is a losing category against npm-distributed community aggregators; coherence per skill is the defensible axis
- Context budget is a first-class constraint ([MVPR-0001](MVPR-0001 Minimum Viable Prompt.md)) — every always-loaded token is paid every turn, forever
- Research showed top-installed community skills are heavily biased toward interchangeable "senior-X" role prompts and first-party Anthropic wrappers; genuine novelty is rare
- Forge is maintainer infrastructure for the author and their clients, not a product in a growth race — audience-of-one eliminates the forcing function that would justify heavy productization scaffolding
- Skills abstract patterns; patterns emerge from practice, so any tooling built before multiple adoptions have happened will encode assumed taste rather than observed behavior

## Considered Options

1. **Transform-Only Import** — every upstream candidate runs through an automated multi-metric gate and transform pipeline, landing as forge-authored content. High machinery cost before first adoption.
2. **Tier-Gated Passthrough** — three tiers (quarantine/community/trusted) with distinct gates. Three-times the maintenance surface; skills rot in quarantine.
3. **Verified Marketplace** — forge publishes signed attestations on community skills via aitmpl and similar. Dependent on upstream PR acceptance (82 open PRs against a solo maintainer — ~70% vanity probability).
4. **Selective Extraction** — hand-port only the 5-10% of upstream genuinely worth carrying. No automated ingest. Minimal machinery. Honest about scale.
5. **Differentiated Fork** — fork the upstream, strip to the passing subset, publish as a minified catalog. Fork-sync burden one maintainer cannot sustain.
6. **MCP Runtime Proxy** — expose community skills on demand via an MCP server with budget-gated runtime injection. Elegant but MCP support is uneven across providers and adds latency per invocation.

## Decision Outcome

Chosen option: **Selective Extraction**. Forge adopts a small, bounded set of community skills under explicit rules, with every other option deferred or deleted.

### Strategic scope

- **Target volume**: 3-5 hand-adoptions in the initial phase. Not 10, not 30 — selective means selective.
- **Selection criterion**: only skills the maintainer will actually invoke. Adopting skills that won't be run is theater; quality judgment requires exercise, not catalog coverage.
- **Rate of adoption**: bounded by hand, not by pipeline. Weeks-to-months per skill, not hours.

### Inclusion rules

- Skills only. The adoption surface is the skills artifact class; rules and agents are excluded from community intake.
- Upstream source must be licensable (MIT, Apache, EUPL, or equivalent) and pinnable to a commit SHA — no floating branches.
- The skill must measurably improve on or fill a gap that existing forge skills do not cover.

### Exclusion rules

- **Rules never flow through community adoption.** Rules are always-loaded and token-taxed on every turn; their identity-shaping effect makes them unsuitable for external authorship.
- **Agents never flow through community adoption.** Agents are persona-heavy; a community agent would dilute forge's voice.
- **Adopted skill names must not collide with first-party names.** Adoption lineage is a provenance property, not a directory property; two skills with the same name cannot coexist. Collisions are resolved by renaming the adoption or rejecting it.
- Skills that duplicate a forge-authored skill without demonstrable delta are rejected, regardless of upstream install count.

### Deferred / deleted work

- **Automated ingest pipeline** (Strategy 1): deferred until hand-adoptions have surfaced a stable enough pattern that encoding it in code is worth the cost. Not before Phase 3.
- **Publishing pipeline and verified-marketplace submissions** (Strategy 3): deleted from the current plan. If productization becomes interesting, a new ADR captures it from the artifacts accumulated — not speculatively built now.
- **Rejection log**: not shipped in v1. If the absence of rejection records bites during Phase 2 evaluation, add a `.rejected/` log then. Don't build for hypothetical survivorship bias concerns now.
- **External-adopter recruitment**: not pursued in v1. Forge is personal and professional curation; the forcing function of external users is deliberately absent.

### Phases of execution

1. **Hand-adopt** 3-5 candidate skills via the mechanism in [ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md). Each adoption produces an artifact plus provenance sidecar, placed in whichever existing module is the most natural domain home.
2. **Derive evals** from the accumulated corpus — glob the provenance sidecars across `Modules/`, observe what transforms actually happened, what manual effort each adoption cost, what commit messages captured as rationale.
3. **Decide on Phase 3** only after Phase 2 yields a rubric. If the evals do not produce consistent, generalizable criteria, the algorithmic `forge rate` CLI is not built. The strategy ends at Phase 2.

### Acknowledged risks, not mitigated

- **Audience-of-one eliminates the forcing function.** Personal curation with no external adopters drifts toward "maintainer didn't hit friction this week." Accepted — the output serves the maintainer's stack, not a market.
- **Evals reflect maintainer taste.** A corpus of 3-5 adoptions by one curator is introspection, not research. If Phase 3's CLI ever ships, its description must name this limitation explicitly.
- **Selective extraction has low velocity.** Days-to-weeks per adoption, not hours. Accepted; this is a feature of the strategy, not a cost to minimize.

### Consequences

- [+] No productization infrastructure is built speculatively; every component ships only after its need is demonstrated through practice
- [+] The scope is small enough that scope creep is visible — any drift toward "adopt this too because it's popular" violates the stated selection criterion
- [+] Rules and agents exclusion preserves forge's always-loaded coherence and voice; community intake cannot erode them
- [-] Forge will appear small next to aitmpl-class catalogs; external discovery of forge's adopted skills is not a goal
- [-] The maintainer carries 100% of the judgment load; no process redundancy, no external reviewers; bus factor of one for adoption decisions

## Related Decisions

- [ARCH-0001](ARCH-0001 Skills Agents and Rules.md) — the three-artifact model; this ADR restricts community intake to skills only
- [ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md) — the mechanism implementing this strategy
- [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md) — the schema capturing adoption lineage and transform history
- [MVPR-0001](MVPR-0001 Minimum Viable Prompt.md) — the context-budget principle driving selective adoption over volume

## Links

- [aitmpl.com][AITMPL] — the reference community catalog driving this decision
- [davila7/claude-code-templates][CCT] — upstream repository and npm distribution

[AITMPL]: https://www.aitmpl.com/ "Claude Code Templates catalog"
[CCT]: https://github.com/davila7/claude-code-templates "Upstream repository"
