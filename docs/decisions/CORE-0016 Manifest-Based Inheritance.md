---
status: Accepted
date: 2026-03-09
responsible: ["N4M3Z"]
accountable: ["N4M3Z"]
consulted: ["DeveloperCouncil"]
informed: []
promoted: ["PublishPrompts"]
tags: [manifest, inheritance, drift-detection, provenance]
---

# Manifest-Based Prompt Inheritance

## Context and Problem Statement

Derived repos inherit rules, skills, and agents from forge modules via forge-cli deployment. There was no mechanism to track what's been customized vs. pristine, making it impossible to propagate upstream changes without manually diffing files. Skills and agents used a flat-list manifest for orphan cleanup, while rules had no manifest at all.

## Decision Drivers

- Need to detect drift between installed content and upstream sources
- Need to propagate upstream changes to pristine files automatically
- Need 3-way merge support for adapted files (manifest SHA as merge-base)
- Avoid maintaining two manifest formats with different YAML shapes

## Considered Options

1. Separate formats — flat list for skills, SHA map for rules/agents
2. Unified SHA map for all three artifact types
3. External provenance database

## Decision Outcome

Chosen option: **Unified SHA map**, because it gives all artifact types drift detection with a single format, eliminates the flat-list/SHA-map collision risk on `.manifest`, and the flat list is a degenerate case (orphan cleanup only needs keys, not values).

### Format

```yaml
forge-core:
    GitConventions.md: 8f4ca9a50b03d3043a53d0007965a5dcf182bb236cea5f27...
    KeepChangelog.md: 1de3b2a8c0681396c7bd76be217f688958f44cf4a186c52c...
```

For rules and agents, the SHA is the body hash of the source `.md` file (frontmatter stripped via `body_sha256`). For skills, it's the body hash of `SKILL.md`. State is computed at scan time, never stored:

- Installed body SHA matches manifest SHA → pristine
- Installed body SHA differs → adapted
- Upstream source SHA differs from manifest → upstream updated (sync available)

### Consequences

- [+] All three artifact types have drift detection and provenance tracking
- [+] Single manifest format simplifies tooling and documentation
- [+] Install binaries write manifests; companion script is read-only reporter
- [-] Shell `body_sha()` and Rust `body_sha256()` must produce identical hashes

### Pristine File Pattern

A file is **pristine** when its body hash (frontmatter stripped) matches the upstream source exactly. Derived repos should maximize pristine files to minimize sync burden. Strategies:

- **Go pristine**: remove unnecessary frontmatter (`paths:` scoping) when the rule works without it
- **Promote upstream**: fix the upstream rule to be universally correct, eliminating the downstream adaptation
- **Split into companion**: keep the upstream file pristine, add a separate companion file with derived-specific content (e.g., `ForgeADR.md` alongside a pristine `SKILL.md`)
- **Rename to own**: when content is a complete rewrite, rename to break the false inheritance link (e.g., a derived repo's GitLab conventions in its own file rather than adapting `GitConventions.md`)

The goal is zero adapted files in the drift report. Adapted files require manual review on every upstream change; pristine files auto-update.

## More Information

- Validated against chezmoi (file-level override) and PAI v4.0 (SYSTEM/USER split)
- [CORE-0013 Platform-Specific Companion Files](0013%20Platform-Specific%20Companion%20Files.md): skills use companion files for derived-specific content
- [CORE-0012 Rules as Shared Ecosystem Conventions](0012 Rules as Shared Ecosystem Conventions.md): rules are module-delivered, installed by `forge install`
- PublishPrompts skill provides Drift, Sync, Adopt, Promote, Setup subskills for the full lifecycle
