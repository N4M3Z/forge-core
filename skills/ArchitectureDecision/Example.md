---
title: Hybrid ADR Placement
description: Root for ecosystem-spanning decisions, per-module for internal decisions
type: adr
category: process
tags:
    - adr
    - process
status: accepted
created: 2026-03-02
updated: 2026-03-02
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Hybrid docs/decisions/ placement for forge ADRs

## Context

The forge ecosystem spans a root repo and independently clonable modules. Decisions range from ecosystem-wide conventions to module-internal choices. A single centralized directory conflates these scopes; purely per-module scatters ecosystem conventions across repositories.

## Considered Options

- Centralized root only — all ADRs in one place, modules link by reference
- Per-module only — each module owns its decisions, no root directory
- Hybrid — root for ecosystem-spanning, per-module for internal

## Decision

Chosen option: **Hybrid**, because it matches the existing layering model. Modules are independently deployable, so module-internal rationale belongs with the module. Ecosystem-spanning decisions belong at root where all modules can reference them. Numbering is per-scope — root and modules count independently.

## Consequences

- Scope is self-documenting from file location — `Modules/forge-tlp/docs/decisions/` vs `docs/decisions/` signals the audience
- No global sequence; cross-scope references use relative paths rather than bare numbers
