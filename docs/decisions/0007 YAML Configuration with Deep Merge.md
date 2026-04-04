---
status: Accepted
date: 2026-02-19
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: []
tags: [architecture, config]
---

# YAML Configuration with Deep Merge

## Context and Problem Statement

ENV vars in markdown instructions ([0006](0006 ENV Vars in Markdown Instructions.md)) need a source. Each module has configurable values — paths, feature flags, skill rosters — that differ between default and user-specific setups. The configuration system must support committed defaults, user overrides, and ENV var export without requiring users to manage shell profiles.

## Decision Drivers

- Defaults must be committed and version-controlled — the module works out of the box
- User overrides must be gitignored — personal paths and preferences don't pollute the repo
- Override granularity must be per-field, not per-file — users change one path, not copy the entire config
- ENV variable export must be automatic — general-purpose tools like `yq` can read individual values, but exporting an entire config subtree as prefixed ENV vars requires a multi-step pipeline

## Considered Options

1. **Flat ENV files** — `.env` with `KEY=VALUE` pairs, no nesting, no merge, no defaults mechanism
2. **JSON config** — structured, mergeable, but painful to author by hand and no comment support
3. **YAML with deep merge** — `defaults.yaml` (committed) merged with `config.yaml` (gitignored), recursive merge so users override only the fields they need

## Decision Outcome

Chosen option: **YAML with deep merge**. Each module ships `defaults.yaml` with the full schema and sensible defaults. Users create `config.yaml` (gitignored) with only the fields they want to override. forge-lib's `yaml env` command exports the merged result as ENV vars with a configurable prefix (`FORGE_ADR_PREFIX`, `FORGE_ADR_DIRECTORY`, etc.).

### Consequences

- [+] Module works out of the box with zero user configuration
- [+] Users override one field without knowing the full schema
- [+] `yaml env` bridges config to ENV vars consumed by skills and shell commands
- [-] Deep merge semantics can be surprising — array replacement vs append, null vs missing
