---
title: Provenance Tracking
description: in-toto/SLSA provenance sidecars deployed alongside content, linked from the manifest
type: adr
category: architecture
tags:
    - architecture
    - provenance
status: accepted
created: 2026-03-23
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "PROV-0002 Manifest for Deployment Tracking.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Provenance Tracking

## Context and Problem Statement

When source files are transformed during assembly (frontmatter stripped, variants merged, refs removed), the deployed file no longer matches the source. Debugging "where did this deployed rule come from?" requires tracing the assembly chain. The manifest ([PROV-0002](PROV-0002 Manifest for Deployment Tracking.md)) tracks deployment integrity but not lineage. This ADR extends the manifest with provenance paths and deploys SLSA sidecars alongside content.

## Considered Options

1. **in-toto/SLSA attestation** — industry standard for supply chain provenance, JSON-native, cosign/Sigstore tooling
2. **SPDX 3.0 Build Profile** — SBOM-oriented, designed for component inventory and build provenance
3. **W3C PROV-inspired YAML** — custom format using PROV vocabulary

## Decision Outcome

Chosen option: **in-toto/SLSA v1.0**, serialized as YAML. in-toto is the industry standard for build provenance, purpose-built for tracking "these inputs were transformed into this output by this builder."

### Provenance Directory Layout

Every directory that has content files gets its own `.provenance/` sibling. The provenance file is always one `../.provenance/<filename>.yaml` away from the content it describes. Claude Code ignores dotdirectories.

```
.claude/
    agents/
        GameMaster.md
        .provenance/
            GameMaster.yaml
    rules/
        CurrencyFormatting.md
        .provenance/
            CurrencyFormatting.yaml
        cz/
            PersonalTaxIncome.md
            .provenance/
                PersonalTaxIncome.yaml
    skills/
        SessionPrep/
            SKILL.md
            .provenance/
                SKILL.yaml
```

### Manifest Extension

The manifest from [PROV-0002](PROV-0002 Manifest for Deployment Tracking.md) gains a `provenance` field linking each deployed file to its sidecar:

```yaml
rules:
    CurrencyFormatting.md:
        fingerprint: abc123...
        provenance: .provenance/CurrencyFormatting.yaml
    cz:
        PersonalTaxIncome.md:
            fingerprint: def456...
            provenance: .provenance/PersonalTaxIncome.yaml
```

The `provenance` path is relative to the content directory. To read the full SLSA chain for any deployed file, join the provider target base with the provenance path.

### Sidecar Format

Each provenance sidecar is an in-toto/SLSA v1.0 statement:

```yaml
provenance:
    _type: https://in-toto.io/Statement/v1
    subject:
        - name: claude/rules/AgentTeams.md
          digest:
              sha256: def456...
    predicateType: https://slsa.dev/provenance/v1
    predicate:
        buildDefinition:
            buildType: https://forge-cli/assemble/v1
            resolvedDependencies:
                - uri: rules/AgentTeams.md
                  digest:
                      sha256: abc123...
                - uri: rules/user/AgentTeams.md
                  digest:
                      sha256: 789ghi...
        runDetails:
            builder:
                id: forge-cli
                version:
                    forge: 0.1.0
            metadata:
                startedOn: "2026-03-23T10:00:00Z"
```

Source-level staleness detection reads provenance sidecars to compare recorded source fingerprints against current source files. This enables source-aware prune — only remove files where the source module matches the current module.

## Consequences

- [+] Industry standard — cosign/Sigstore tooling for verification
- [+] Sidecars deploy alongside content — provenance travels with the files
- [+] Source fingerprints enable source-aware prune in shared targets
- [+] YAML serialization consistent with ecosystem
- [-] in-toto envelope adds structural overhead vs flat fingerprints
