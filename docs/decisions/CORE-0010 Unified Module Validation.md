---
title: "Unified Module Validation"
description: "Single validation path via prek, pre-commit hook fallback, and make validate delegation"
type: adr
category: process
tags:
    - validation
    - ci
    - pre-commit
status: accepted
created: 2026-04-02
updated: 2026-04-17
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0011 Verified Remote Execution.md"
    - "CORE-0012 Fixture-Based Canary Testing.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Unified Module Validation

## Context and Problem Statement

Validation logic must be identical across CI, pre-commit, and local development. Modules should not reimplement checks — forge-cli defines what a valid module looks like via `forge validate .` and the shared `.pre-commit-config.yaml` hook configuration.

## Decision Drivers

- Single validation path — never duplicate logic across Makefile, CI, and hook scripts
- CI must work without the forge binary (portable fallback)
- Forge-cli handles all validation — no module-specific validator scripts required

## Considered Options

1. **Inline CI/pre-commit** — each module maintains its own validation scripts
2. **prek as primary runner** — declarative hook config, CI action, local pre-commit
3. **Delegate to validate.sh** — hash-verified remote script download

## Decision Outcome

Chosen option: **prek as primary runner**, with hash-verified validate.sh as fallback for environments without prek.

The validation architecture has two tiers:

**Primary (prek):** `.pre-commit-config.yaml` declares all checks — shellcheck, gitleaks, semgrep, `forge validate`. CI runs `j178/prek-action@v2`. Local pre-commit runs via `prek run`.

**Fallback (hash-verified):** `.githooks/pre-commit` tries `forge validate .` first. If the binary isn't installed, it downloads `validate.sh` from forge-cli with SHA-256 verification per [CORE-0011](CORE-0011 Verified Remote Execution.md). `make validate` delegates to this hook.

ADR frontmatter validation is performed by `forge validate .` directly against `templates/forge-adr.json`; no module-specific validator is required. Canary fixtures under `tests/fixtures/` ([CORE-0012](CORE-0012 Fixture-Based Canary Testing.md)) prove that forge-cli catches the failure modes the previous custom wrapper caught.

### Consequences

- [+] Single source of truth — prek config is the canonical check list
- [+] CI and local dev run identical checks
- [+] No module-specific validator to maintain alongside forge-cli
- [-] Two validation tiers to maintain (prek config + pre-commit fallback)

## Related Decisions

- [CORE-0011](CORE-0011 Verified Remote Execution.md) — hash verification for the fallback path
- [CORE-0012](CORE-0012 Fixture-Based Canary Testing.md) — canary fixtures that prove the validator catches errors
