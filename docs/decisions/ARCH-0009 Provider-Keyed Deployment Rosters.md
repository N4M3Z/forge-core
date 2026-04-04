---
title: Provider-Keyed Deployment Rosters
description: Each provider's artifact roster is a single YAML key, readable at a glance
type: adr
category: architecture
tags:
    - architecture
    - config
    - providers
status: accepted
created: 2026-02-20
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

# Provider-Keyed Deployment Rosters

## Context and Problem Statement

With multi-provider support adopted ([ARCH-0008](ARCH-0008 Multi-Provider Support.md)), YAML config files need to express which artifacts (skills, agents, rules) deploy to which provider. A flat list leaves this mapping implicit. The question is how to structure provider-to-artifact mappings in `defaults.yaml` so they're readable, editable, and queryable.

## Decision Drivers

- "What does Claude get?" should be answerable by reading one YAML key
- Adding or removing an artifact from one provider should be a config change, not a code change
- Provider-specific overrides (naming, path conventions) need a natural home

## Considered Options

1. **Flat list with per-artifact `providers` field** — each entry declares its targets, requires scanning everything to answer "what does provider X get?"
2. **Provider-keyed top-level structure** — each provider key lists its artifacts, readable at a glance
3. **Separate config files per provider** — one YAML per provider, clean separation but scattered config

## Decision Outcome

Chosen option: **Provider-keyed top-level structure**. Each provider's roster is a single YAML key. The install system reads the key matching the current platform and deploys only those artifacts. Currently skills are routed this way; agents and rules will follow the same pattern.

### Consequences

- [+] Adding or removing an artifact from one provider is a single-line YAML edit
- [+] Provider-specific overrides live alongside the roster
- [-] Artifacts shared across all providers appear in multiple keys — duplication is the cost of per-provider clarity
