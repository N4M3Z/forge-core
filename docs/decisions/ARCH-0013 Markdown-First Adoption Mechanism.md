---
title: "Markdown-First Adoption Mechanism"
description: "Community skills are adopted through a workflow skill composing per-transform skills as build steps, producing first-class markdown artifacts in their natural domain location"
type: adr
category: architecture
tags:
    - architecture
    - adoption
    - skills
    - mechanism
status: accepted
created: 2026-04-16
updated: 2026-04-16
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0001 Skills Agents and Rules.md"
    - "ARCH-0002 Skills Companion Files.md"
    - "ARCH-0012 Community Adoption Strategy.md"
    - "PROV-0006 Adoption Metadata in Provenance Sidecars.md"
    - "CORE-0001 Markdown as System Language.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Markdown-First Adoption Mechanism

## Context and Problem Statement

[ARCH-0012](ARCH-0012 Community Adoption Strategy.md) fixed the strategic decision: selective extraction of 3-5 community skills. This ADR decides the mechanism — the concrete primitive the maintainer uses to perform an adoption, how transforms compose, and where the output lives.

The temptation is to scaffold a `forge adopt` CLI with gates, transforms, and an ingest pipeline before a single adoption has been performed. That encodes assumed taste before the taste exists. The mechanism decision holds the line on authoring conventions while the adoption practice is still too young to compile.

## Decision Drivers

- [CORE-0001](CORE-0001 Markdown as System Language.md) — markdown is the system language; skills, rules, agents, ADRs are all authored as markdown, making "build a markdown skill" the lowest-friction move
- Skills abstract patterns; with zero adoptions done, any CLI schema would be a guess, not a codification
- Adopted skills belong with their domain peers, not segregated by source — a security skill sits next to other security content regardless of who wrote it originally
- Transforms like debranding, minimizeing, and rescoping are themselves reusable patterns that apply beyond adoption — forge's own skills could be debranded, and any prompt-shaped content can be shrunk — so they deserve to be skills in their own right, not hardcoded verbs
- Cowork drops plugin hooks silently; a skill-based mechanism survives the Cowork runtime without ceremony

## Considered Options

1. **CLI-first** — ship `forge adopt <url>` as a subcommand from day one with transforms encoded as internal functions. Pattern-guessing before evidence.
2. **Single monolithic workflow skill** — `/ForgeAdopt` as a standard skill with all transform logic embedded in its body. Simple but bundles unrelated concerns (debranding a vendor reference vs minimizeing pep-talk prose).
3. **Workflow skill composing per-transform skills as build steps** — `/ForgeAdopt` as the orchestrator; each transform (`/DebrandPrompt`, `/MinimizePrompt`, `/RescopePrompt`, `/AlignPrompt`, `/ExtractPrompt`) is a separate skill invoked as a build step. Transforms become reusable outside adoption and each pins independently in provenance.

## Decision Outcome

Chosen option: **workflow skill composing per-transform skills as build steps.**

`/ForgeAdopt` is a standard skill at `skills/ForgeAdopt/SKILL.md`, following the existing skill `.mdschema` ([ARCH-0001](ARCH-0001 Skills Agents and Rules.md), [ARCH-0002](ARCH-0002 Skills Companion Files.md)). It orchestrates a sequence of per-transform skills, each of which is a first-class skill usable independently of adoption.

### Input

A single upstream URL. The skill fetches the upstream content (via `WebFetch`, `gh api`, or an upstream-specific CLI against a scratch directory — whichever is cheapest for the source), records the commit SHA, reads the source, and makes the transform decisions inline.

Sources are identified by URL, not hardcoded. When a second catalog appears, the skill handles it the same way.

### Output

Every successful adoption produces two files placed in whatever domain home fits best:

- `skills/<Name>/SKILL.md` — a working skill. Same schema as any other skill. Invocable, testable, deployable. Carries `upstream: <url>` in frontmatter as a human-facing pointer — no SHA (see [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md)).
- `skills/<Name>/.provenance/SKILL.yaml` — the SLSA sidecar. Each transform skill applied appears as a `resolvedDependencies` entry with its pinned digest; the upstream source is another entry. See [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md) for the schema.

Choosing the destination is part of the adoption decision. In a project with multiple scopes (modules, subtrees, plugins), the skill goes where its domain already lives; in a single-scope project, there is only one `skills/` directory and the question does not arise. If no existing home is a natural fit, the adoption is deferred — creating new structure just to house one imported skill is over-engineering. The commit that lands the adoption captures the placement reasoning in its message.

Companion files (where upstream content is better extracted than inlined) follow [ARCH-0002](ARCH-0002 Skills Companion Files.md) — same `@` include conventions as any skill.

### Transform skills (build steps)

Each transform is a standalone skill with its own `SKILL.md`, invocable directly on any prompt-shaped content and composable by `/ForgeAdopt` during adoption. Initial vocabulary:

- **`/DebrandPrompt`** — remove hardcoded vendor references; replace with category-level variables where the instruction generalizes
- **`/MinimizePrompt`** — collapse motivational / marketing / filler prose while preserving directive content
- **`/RescopePrompt`** — add or tighten `allowed-tools` frontmatter to the narrowest set the skill actually uses
- **`/AlignPrompt`** — fix indentation, fence language tags, heading depth, and other convention mismatches
- **`/ExtractPrompt`** — move bulk reference material into `@`-included companion files so the always-loaded content stays lean

v1 note: these transform skills may not all exist at the first adoption. `/ForgeAdopt` v1 can embed transform logic inline while the vocabulary stabilizes; as a transform proves recurring, it extracts into its own skill and subsequent adoptions record it in `resolvedDependencies`. The schema in [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md) supports both modes transparently.

### What the mechanism does NOT do

- No multi-metric gate is enforced in v1. The maintainer's judgment decides what ships. Gates ship later if Phase 2 evals produce a rubric worth encoding.
- No automated submission to upstream catalogs. The skill's output is local artifacts; anything downstream of the repository is out of scope.
- No parallel batch adoption. The skill runs once per invocation, produces one adoption, and stops. Serial by design.
- No cache of upstream content. Every adoption fetches fresh; caching is a premature optimization while only 3-5 adoptions are planned.

### Consequences

- [+] Transforms are testable and evolvable independently; each transform skill can be invoked outside adoption (e.g., to debrand a forge-authored skill that accumulated branding over time)
- [+] The build pipeline is explicit in provenance — every adopted skill records exactly which transform skill versions touched it, pinned by SHA
- [+] Reuses existing primitives — skill schema, provenance sidecars, domain-scoped `skills/` directories, `@` companion includes — without inventing new structures
- [+] Adopted skills integrate naturally with their domain; there is no visual "community vs first-party" split in the deployed tree
- [-] The transform-skill vocabulary must be authored and maintained; each adds a small surface. Accepted — extraction is demand-driven, not speculative
- [-] The maintainer must decide placement per adoption; the skill cannot default a destination, so judgment is required at every invocation. Accepted — the placement decision is part of the value

## Related Decisions

- [ARCH-0012](ARCH-0012 Community Adoption Strategy.md) — the strategic decision this mechanism implements
- [ARCH-0001](ARCH-0001 Skills Agents and Rules.md) — the skill artifact class `/ForgeAdopt` and its transform skills belong to
- [ARCH-0002](ARCH-0002 Skills Companion Files.md) — companion-file conventions used by `/ExtractPrompt` and adopted skills with extracted content
- [PROV-0006](PROV-0006 Adoption Metadata in Provenance Sidecars.md) — the sidecar schema that records transform skills as build dependencies
- [CORE-0001](CORE-0001 Markdown as System Language.md) — the underlying principle that makes skill-first natural
