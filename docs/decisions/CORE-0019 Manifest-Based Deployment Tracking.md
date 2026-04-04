---
status: Accepted
date: 2026-03-23
---

# Manifest-Based Deployment Tracking

## Context

Installing skills, agents, and rules to provider directories is a multi-step process. Without tracking what was deployed, subsequent installs cannot detect user-modified files (edited post-install) or unchanged files (skip for performance).

## Considered Options

- **Flat deployment record** — `{path: {sha256: hash}}` per deployed file, lives at the target
- **Named fields** — `source_sha` + `deployed_sha` as separate top-level fields
- **Separate manifest files** — one for source, one for deployed

## Decision

Chosen option: **flat deployment record**. The manifest is a deployment record, not a build artifact. It lives at the target as a `.manifest` dotfile — one per provider directory. Assembly does not produce it; copy creates it after deploying files.

```yaml
rules/AgentTeams.md:
    sha256: e3b0c44298fc1c149afbf4c8996fb924...
rules/CodeStyle.md:
    sha256: 1234567890abcdef1234567890abcdef...
skills/SessionPrep/SKILL.md:
    sha256: b3c67018a9f2e1d4c5b6a7f8e9d0c1b2...
```

Each entry maps a deployed file path (relative to the provider directory) to the SHA-256 hash of the content that was deployed.

### Staleness detection

On subsequent installs, copy reads `.manifest` from the target and compares:

| Target hash vs `.manifest` | Build hash vs `.manifest` | Status    | Action              |
| -------------------------- | ------------------------- | --------- | ------------------- |
| matches                    | matches                   | Unchanged | skip                |
| matches                    | differs                   | Stale     | copy (safe)         |
| differs                    | —                         | Modified  | skip (or `--force`) |
| not in `.manifest`         | —                         | New       | copy                |

Source-level staleness (has the source changed since last build?) is detected by comparing provenance sidecars against current source files. See CORE-0020.

## Consequences

- Positive: simple format — just `{path: {sha256: hash}}`, human-readable
- Positive: lives at the target — survives `build/` cleanup
- Positive: per-provider — each target directory tracks its own deployments
- Positive: no spec overhead — this is not an attestation, just a cache
- Tradeoff: manifest corruption means full reinstall (acceptable risk)
