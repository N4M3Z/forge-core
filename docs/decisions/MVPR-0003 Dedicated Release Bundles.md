---
title: Dedicated Release Bundles
description: Pre-built per-provider release archives for zero-build installation
type: adr
category: architecture
tags:
    - architecture
    - deployment
status: proposed
created: 2026-03-16
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Provider-Specific Release Bundles

## Context

Currently `make install` builds everything locally — reads source, resolves qualifier variants, strips frontmatter and refs, writes clean files. Users must clone the repo and run the build. There's no way to distribute pre-built, ready-to-use instruction sets. As the ecosystem grows, new users should be able to download a versioned bundle and extract it into `.claude/rules/` without building from source.

## Considered Options

- **Provider-specific bundles** — one release per provider (`forge-core-claude-v0.6.0.tar.gz`) with pre-assembled rules/skills/agents
- **Universal bundle + manifest** — all source files + qualifier dirs, consumer runs `make install` locally
- **Both tiers** — pre-built for quick install, source for customization

## Decision

Chosen option: **provider-specific bundles**. Each release produces one archive per configured provider containing fully assembled, stripped, token-clean files ready to extract into the provider's directory.

```
releases/
    forge-core-claude-v0.6.0.tar.gz
    forge-core-codex-v0.6.0.tar.gz
    forge-core-gemini-v0.6.0.tar.gz
    forge-core-opencode-v0.6.0.tar.gz
```

Each bundle contains:

```
forge-core-claude-v0.6.0/
    rules/
        AgentTeams.md              # assembled, stripped, token-clean
        UseRTK.md
        ...
    skills/
        PromptAnalysis/
            SKILL.md
            ...
    agents/
        ...
    .manifest                      # deployment record for integrity verification
    VERSION                        # module version + build metadata
```

### Build

`make release` runs `forge install` per provider into a staging directory, then archives:

```makefile
release:
    @for provider in claude codex gemini opencode; do \
        dst="releases/$(MODULE)-$$provider-v$(VERSION)"; \
        forge install --provider $$provider --dst $$dst/; \
        tar -czf "$$dst.tar.gz" -C releases "$(MODULE)-$$provider-v$(VERSION)"; \
    done
```

### Install from release

```bash
tar -xzf forge-core-claude-v0.6.0.tar.gz -C ~/.claude/
# or for project-level:
tar -xzf forge-core-claude-v0.6.0.tar.gz -C .claude/
```

### Verification

The `.manifest` inside the bundle allows integrity verification after extraction. Provenance sidecars (`.yaml`, generated during assembly) provide full lineage per file. Future: forge-audit signs the bundle with SSH key (SLSA Level 2).

## Consequences

- Positive: zero-build install path for new users
- Positive: versioned, reproducible deployments
- Positive: each provider gets only the content it needs (minimum viable prompt)
- Positive: `.manifest` and provenance sidecars travel with the bundle for integrity and audit
- Tradeoff: releases must be rebuilt on every source change
- Tradeoff: `user/` qualifier overrides can't be included (they're personal and gitignored)
