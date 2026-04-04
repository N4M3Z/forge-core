---
status: Accepted
date: 2026-03-23
---

# Provenance Tracking

## Context

When source files are transformed during assembly (frontmatter stripped, variants merged, refs removed), the deployed file no longer matches the source. Debugging "where did this deployed rule come from?" requires tracing the assembly chain. The manifest (CORE-0019) tracks deployment integrity but not lineage. Auditors need to verify that a security-critical instruction (e.g., a CVE-driven guardrail) was included in the deployed prompt.

## Considered Options

1. **in-toto/SLSA attestation** — industry standard for supply chain provenance, JSON-native, cosign/Sigstore tooling
2. **SPDX 3.0 Build Profile** — SBOM-oriented, designed for component inventory and build provenance
3. **W3C PROV-inspired YAML** — custom format using PROV vocabulary

## Decision

Chosen option: **in-toto/SLSA v1.0**, serialized as YAML. in-toto is the industry standard for build provenance, purpose-built for tracking "these inputs were transformed into this output by this builder." SLSA builds on in-toto with a structured `buildDefinition` that captures resolved dependencies with per-file digests.

Provenance is a **build record** — it answers "what sources produced this built file?" Each assembled file in `build/` gets a `.yaml` sidecar containing the SLSA statement. Sidecars stay in `build/` and are never deployed to the target.

Source-level staleness detection reads provenance sidecars to compare recorded source hashes against current source files. Deployment-level staleness is handled separately by `.manifest` at the target (see CORE-0019).

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

## Consequences

- Positive: industry standard — cosign/Sigstore tooling for verification
- Positive: compact — one self-contained statement per output file
- Positive: source hashes enable source-level staleness detection
- Positive: YAML serialization consistent with ecosystem
- Positive: sidecars stay in build/ — no context pollution at target
- Tradeoff: in-toto envelope adds structural overhead vs flat hashes
