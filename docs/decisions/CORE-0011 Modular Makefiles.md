---
status: "Superseded by forge-cli"
date: 2026-02-21
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: [MakefileFirst.md]
tags: [architecture, build]
---

# Modular Makefiles

> Superseded by forge-cli. Modules now call the `forge` binary directly instead of including shared Makefile fragments.

## Context and Problem Statement

Each module had its own ~200-line Makefile implementing install, verify, lint, and test targets. The logic was largely identical across modules — install skills to provider directories, run mdschema checks, shellcheck scripts. Bug fixes and improvements had to be replicated manually to every module.

## Decision Drivers

- Identical build logic across modules must be maintained in one place
- Modules must remain independently buildable (`make install` from any module root)
- New modules should inherit build capabilities without copying boilerplate

## Considered Options

1. **Per-module standalone Makefiles** — each module owns its full build logic, no shared dependency but high duplication
2. **Shared Makefile fragments via `include`** — forge-lib provides `mk/*.mk` fragments that modules include, centralizing common targets
3. **Build script (shell or Rust)** — single binary replaces Make entirely

## Decision Outcome

Chosen option: **Shared Makefile fragments via `include`**. forge-lib provides `mk/common.mk`, `mk/skills/install.mk`, `mk/lint.mk` and others. Modules include them and override only what differs. A ~200-line Makefile reduces to ~20 lines of includes and module-specific targets.

### Consequences

- [+] Bug fixes and improvements propagate to all modules by updating the forge-lib submodule
- [+] New modules get install/lint/test for free with a few includes
- [-] Modules depend on forge-lib submodule being initialized and up to date
- [-] Make include debugging is opaque — errors point to fragment line numbers, not the consuming Makefile
