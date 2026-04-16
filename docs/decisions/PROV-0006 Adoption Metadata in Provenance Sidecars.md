---
title: "Adoption Metadata in Provenance Sidecars"
description: "Adoption reuses PROV-0003 with a distinct buildType; transform skills applied during adoption appear as SLSA resolvedDependencies, not local fields"
type: adr
category: architecture
tags:
    - provenance
    - adoption
    - schema
status: accepted
created: 2026-04-16
updated: 2026-04-16
author: "@N4M3Z"
project: forge-core
related:
    - "PROV-0003 Provenance Tracking.md"
    - "ARCH-0012 Community Adoption Strategy.md"
    - "ARCH-0013 Markdown-First Adoption Mechanism.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Adoption Metadata in Provenance Sidecars

## Context and Problem Statement

[ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md) decides that adopted community skills produce working `SKILL.md` artifacts and that each transform (debrand, minimize, rescope, align, extract) is itself a skill invoked as a build step. Each adoption therefore has two kinds of inputs: the upstream source being transformed, and the transform skills that touched it. Phase 2 of the strategy ([ARCH-0012](ARCH-0012 Community Adoption Strategy.md)) depends on this metadata being queryable across the corpus.

[PROV-0003](PROV-0003 Provenance Tracking.md) already specifies `.provenance/<Name>.yaml` sidecars in [SLSA v1.0][SLSA] format for assembly builds. The question is how adoption fits into that schema — whether it needs local-forge fields under `externalParameters`, or whether SLSA's native `resolvedDependencies` already models the build composition exactly right.

## Decision Drivers

- [SLSA v1.0][SLSA]'s `resolvedDependencies` is designed to record every input that produced the artifact, including tooling — a transform skill applied during adoption is precisely an input in the SLSA sense
- Recording transform skills as dependencies pins them by SHA, which means Phase 2 evals can answer "which version of `/MinimizePrompt` was applied to this adoption" without any forge-local schema
- Duplicating the same data into a forge-local `transforms_applied` array would be redundant with `resolvedDependencies` and create two places to update
- Git diffs and commit messages remain the lossless record of exactly what changed and why; structured dependency entries complement them, do not replace them

## Considered Options

1. **Reuse PROV-0003 unchanged, distinguish by `buildType` only, record transform skills as `resolvedDependencies`** — SLSA-native; transform versions pinned automatically; no forge-local schema.
2. **Extend under `externalParameters` with a forge-local `transforms_applied` array** — categorization is queryable, but duplicates what `resolvedDependencies` already captures once transforms become skills.
3. **Parallel sidecar** — `.adoption/<Name>.yaml` separate from PROV-0003. Two sidecars per artifact; no benefit.
4. **Frontmatter carries everything** — machine-queryable via YAML parsing but assembly strips it at deploy, and it fights the CanonSidecar rule.

## Decision Outcome

Chosen option: **reuse PROV-0003 unchanged, distinguish by `buildType`, record transform skills as `resolvedDependencies`.**

Because [ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md) defines each transform as a skill, the SLSA dependency model fits natively. Every transform skill applied to an adoption appears alongside the upstream source in `resolvedDependencies`, each pinned by SHA. No local-forge fields are needed; no parallel sidecar; no duplicate structures.

### Schema

```yaml
predicate:
    buildDefinition:
        buildType: https://forge-cli/adopt/v1
        externalParameters:
            upstream_url: https://github.com/davila7/claude-code-templates/...
        resolvedDependencies:
            - name: upstream
              uri: https://github.com/davila7/claude-code-templates/blob/<sha>/cli-tool/components/skills/security/security-best-practices/SKILL.md
              digest:
                  sha256: <upstream-sha>
            - name: DebrandPrompt
              uri: forge-core/skills/DebrandPrompt/SKILL.md
              digest:
                  sha256: <DebrandPrompt-sha>
            - name: MinimizePrompt
              uri: forge-core/skills/MinimizePrompt/SKILL.md
              digest:
                  sha256: <MinimizePrompt-sha>
            - name: RescopePrompt
              uri: forge-core/skills/RescopePrompt/SKILL.md
              digest:
                  sha256: <RescopePrompt-sha>
        runDetails:
            builder:
                id: forge-cli
                version:
                    forge: 0.1.0
            metadata:
                startedOn: "2026-04-16T10:00:00Z"
```

### Field semantics

All structural fields are [SLSA v1.0][SLSA] standards-defined:

- **`buildType: https://forge-cli/adopt/v1`** — declares this is an adoption build. Distinguishes from assembly (`https://forge-cli/assemble/v1`). Phase 2 evals filter on this value.
- **`externalParameters.upstream_url`** — convenience denormalization of the upstream dependency's URI for direct queryability without array traversal. `externalParameters` is SLSA's standards-sanctioned extension point; the schema is defined by `buildType`.
- **`resolvedDependencies`** — every input that produced the artifact:
    - `upstream` entry pins the source being transformed (URL + SHA).
    - One entry per transform skill applied, pinned by its own `SKILL.md` SHA. The `uri` uses a module-relative path of the form `<module>/skills/<Name>/SKILL.md` so readers can resolve the dependency directly against the repository tree.
- **`runDetails.metadata.startedOn`** — ISO-8601 timestamp of the adoption.

### The v1 mode: inline transforms

Before individual transform skills exist, `/ForgeAdopt` performs the transforms inline. In that mode, `resolvedDependencies` contains only the upstream entry; the fact that `buildType: https://forge-cli/adopt/v1` records an adoption and the diff shows what changed is sufficient. As transforms extract into skills ([ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md)), subsequent adoptions grow their dependency lists naturally. The schema supports both phases without change.

### Where transform detail and rationale live

The git diff between the adopted artifact and the upstream at the pinned SHA is the authoritative record of what changed. The commit message carries the prose reasoning — what was preserved, what was cut, why the destination was chosen, any non-obvious decisions. The sidecar's structured `resolvedDependencies` answers "which transform skills at what versions"; the diff answers "what text moved"; the commit answers "why." Three sources, no duplication.

### Frontmatter contract for adopted skills

The `SKILL.md` frontmatter gains exactly one field beyond the standard skill schema:

- **`upstream`** (string, URL) — the permalink to the upstream source. No SHA suffix; the SHA lives in the sidecar's `resolvedDependencies`.

All other adoption metadata is sidecar-only or git-native.

### Consequences

- [+] Pure SLSA: every structural concept used here is defined by the spec; no forge-local schema invention
- [+] Transform skills are pinned by SHA in every adoption that used them — Phase 2 can answer "which version of `/MinimizePrompt` was applied" without inspecting forge's tooling version
- [+] One source of truth per axis: structured dependencies in the sidecar, exact changes in the diff, prose rationale in the commit
- [+] Extending from inline transforms to per-skill transforms requires zero schema change — `resolvedDependencies` just grows entries
- [+] Assembly continues to strip frontmatter at deploy; adopted skills cost the same runtime tokens as any other skill
- [-] A reader of the bare `SKILL.md` sees only `upstream:` and must open the sidecar for the dependency chain or run `git log` for rationale — mitigated by the fact that the adoption story is usually not what the reader needs when invoking the skill
- [-] Cross-adoption queries ("how many adoptions applied `/MinimizePrompt`?") require YAML parsing of the `resolvedDependencies` arrays — straightforward but not a single-field scan

## Related Decisions

- [PROV-0003](PROV-0003 Provenance Tracking.md) — the base schema this ADR declares sufficient for adoption
- [ARCH-0012](ARCH-0012 Community Adoption Strategy.md) — the strategy requiring Phase 2 eval queries across adopted skills
- [ARCH-0013](ARCH-0013 Markdown-First Adoption Mechanism.md) — the mechanism producing the sidecars this ADR shapes; defines each transform as a skill

## Links

- [SLSA v1.0 Provenance][SLSA] — the upstream specification whose `resolvedDependencies` field natively models transform skills as build inputs
- [in-toto Statement][INTOTO] — the envelope format that carries the SLSA predicate

[SLSA]: https://slsa.dev/provenance/v1 "SLSA Provenance v1.0"
[INTOTO]: https://github.com/in-toto/attestation/blob/main/spec/v1/statement.md "in-toto Statement v1"
