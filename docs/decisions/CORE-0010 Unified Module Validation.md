---
title: "Unified Module Validation"
description: "Delegate CI and pre-commit validation to forge-cli's shared validate.sh script"
type: adr
category: process
tags:
    - validation
    - ci
    - pre-commit
status: accepted
created: 2026-04-02
updated: 2026-04-02
author: "N4M3Z"
project: forge-core
related: []
responsible: ["N4M3Z"]
accountable: ["N4M3Z"]
consulted: []
informed: []
upstream: ["forge-cli CLI-0008"]
---

# Unified Module Validation

## Context and Problem Statement

forge-core's CI pipeline and pre-commit hook implement validation logic inline — ADR frontmatter checks, shellcheck, clippy, ruff, tsc. Every forge module that needs CI copies and adapts this logic. The checks drift between modules. forge-cli now provides `forge validate` as a compiled binary and `bin/validate.sh` as a standalone script. The inline implementations in forge-core are redundant.

## Decision Drivers

- Validation logic must be identical across CI, pre-commit, and local development
- forge-cli defines what a valid module looks like — modules should not reimplement the checks
- CI must work without compiling forge-cli (no Rust toolchain requirement for the validator itself)

## Considered Options

1. **Keep inline CI/pre-commit** — each module maintains its own validation scripts
2. **Delegate to forge-cli binary** — CI compiles and runs `forge validate .`
3. **Delegate to forge-cli script** — modules commit a local copy of `bin/validate.sh` from forge-cli

## Decision Outcome

Chosen option: **delegate to forge-cli script**, because it provides identical checks everywhere without requiring the compiled binary in CI.

forge-core replaces its custom `.github/workflows/ci.yaml` steps and `.githooks/pre-commit` logic with forge-cli's `bin/validate.sh`. The CI template from `forge-cli/templates/ci.yaml` handles toolchain setup.

**Pre-commit hook:**

```sh
#!/usr/bin/env bash
set -euo pipefail

if command -v forge >/dev/null 2>&1; then
    forge validate .
else
    bash bin/validate.sh
fi
```

**Migration path:**
1. Copy `bin/validate.sh` from forge-cli
2. Replace `.github/workflows/ci.yaml` with forge-cli's `templates/ci.yaml`
3. Simplify `.githooks/pre-commit` to the pattern above
4. Remove `bin/validate-adr.py` once its checks are absorbed into `validate.sh`

### Consequences

- [+] Single source of truth for validation logic (forge-cli)
- [+] New checks added to forge-cli automatically reach all modules on next copy
- [+] Drift detection warns when the local copy is stale
- [-] forge-core loses the ability to add module-specific validation without contributing upstream
- [-] `bin/validate-adr.py` retirement requires ADR checks to be reimplemented in `validate.sh`

## Related Decisions

- [CLI-0008](https://github.com/N4M3Z/forge-cli/blob/main/docs/decisions/CLI-0008%20Validation%20Script%20Distribution.md) — forge-cli's distribution model for the validation script
