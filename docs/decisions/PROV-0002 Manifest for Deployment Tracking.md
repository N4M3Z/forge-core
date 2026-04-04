---
title: Manifest for Deployment Tracking
description: Nested manifest tracks drift and deployment integrity for installed content
type: adr
category: manifest
tags:
    - manifest
    - inheritance
    - drift-detection
    - deployment
status: accepted
created: 2026-03-09
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "ARCH-0005 Platform-Specific Companion Files.md"
    - "ARCH-0004 Rules as Shared Ecosystem Conventions.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: ["DeveloperCouncil"]
informed: []
upstream: [PublishPrompts.md, DeployManifest.md]
---

# Manifest for Deployment Tracking

## Context and Problem Statement

Derived repos inherit rules, skills, and agents from upstream modules via the install tooling. Without tracking, there is no way to detect drift from upstream and no way to know if a deployed file was modified post-install.

## Decision Drivers

- Need to detect drift between installed content and upstream sources
- Need to detect post-install modifications in provider directories
- Prune must be source-aware — only remove files from the current module, not other modules sharing the target

## Considered Options

1. **Flat manifest** — `{path: fingerprint}` per deployed file, no structure
2. **Nested manifest** — mirrors deployed directory tree, each leaf has `fingerprint`
3. **External tracking database** — centralized tracking outside the filesystem

## Decision Outcome

Chosen option: **Nested manifest**. A single `.manifest` dotfile per provider directory (e.g., `.claude/.manifest`) tracks deployment integrity. Provenance tracking extends this format with provenance paths.

### Manifest Format

The manifest mirrors the deployed directory structure. Files are leaf keys with `fingerprint`:

```yaml
rules:
    CurrencyFormatting.md:
        fingerprint: abc123...
    cz:
        PersonalTaxIncome.md:
            fingerprint: def456...

agents:
    GameMaster.md:
        fingerprint: 1e1a469e...

skills:
    SessionPrep:
        SKILL.md:
            fingerprint: 789ghi...
    ArchitectureDecision:
        SKILL.md:
            fingerprint: aaa111...
        ProjectADR.md:
            fingerprint: bbb222...
```

### Staleness Detection

| Target vs manifest | Build vs manifest | Status    | Action              |
| ------------------ | ----------------- | --------- | ------------------- |
| matches            | matches           | Unchanged | skip                |
| matches            | differs           | Stale     | copy (safe)         |
| differs            | —                 | Modified  | skip (or `--force`) |
| not in manifest    | —                 | New       | copy                |

For inheritance drift, body fingerprint (frontmatter stripped via `body_sha256`) is compared against the upstream source:

- Installed body fingerprint matches upstream → pristine
- Installed body fingerprint differs → adapted
- Upstream source fingerprint differs from last install → upstream updated (sync available)

### Source-Aware Prune

Only prune files where the source module matches the current module. Safe for shared targets where multiple modules deploy to the same provider directory.

### Pristine File Pattern

A file is **pristine** when its body fingerprint matches the upstream source exactly. Strategies to maximize pristine files:

- **Go pristine**: remove unnecessary frontmatter when the rule works without it
- **Promote upstream**: fix the upstream rule to be universally correct
- **Split into companion**: keep the upstream file pristine, add a separate companion with derived-specific content
- **Rename to own**: when content is a complete rewrite, break the false inheritance link

### Consequences

- [+] Single manifest format for deployment and inheritance tracking
- [+] Nested structure mirrors the filesystem — human-readable at a glance
- [+] Source-aware prune prevents cross-module damage in shared targets
- [-] Shell `body_sha()` and Rust `body_sha256()` must produce identical fingerprints
- [-] Manifest corruption means full reinstall (acceptable risk)

## More Information

- [ARCH-0005](ARCH-0005 Platform-Specific Companion Files.md): skills use companion files for derived-specific content
- [ARCH-0004](ARCH-0004 Rules as Shared Ecosystem Conventions.md): rules are module-delivered, installed by `make install`
- Provenance tracking extends the manifest with provenance paths and SLSA sidecars
- PublishPrompts skill provides Drift, Sync, Adopt, Promote, Setup subskills
