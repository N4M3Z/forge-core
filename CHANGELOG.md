# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- `skills/DesignPrinciples/SKILL.md` — canonical cross-cutting design canon (durable foundations, WCAG-anchored hard checks, advisory non-failing thresholds), `disable-model-invocation` so it serves as a reference the other design skills cite rather than an invocable skill
- `skills/DesignDashboard/SKILL.md` — data-UI design discipline (density, state completeness, chart-to-data-shape matching, progressive disclosure) for dashboards, admin panels, and analytics views, distinct from `DesignFrontend`'s aesthetic scope
- `skills/BashConventions/` + `BashPatterns.md` companion — Bash pitfalls (BSD vs GNU, `set -euo pipefail` traps, subprocess env) relocated from forge-dev
- `skills/VersionControl/GitWorktrees.md` — companion covering parallel feature work via `git worktree`, with SLSA provenance (adapted from [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) MIT under EUPL-1.2)
- `VersionControl` now serves as the canonical home for git conventions and platform-specific repo governance (absorbing the retired forge-dev `Git` skill). forge-dev's `GitHub` skill remains distinct — it covers CI, Actions, releases, and operational `gh` workflows

### Changed

- `skills/DesignFrontend/SKILL.md` — USE WHEN tightened to marketing/landing/brand-aesthetic surfaces; dashboards and analytics UI now route to `DesignDashboard`. Carries a foundations digest and cites the `DesignPrinciples` canon.
- `skills/AdoptArtifact/SKILL.md` — removed the 3–5 initial cap and the skills-only restriction; agents are now eligible for adoption
- `skills/ForgeAdopt/` renamed to `skills/AdoptArtifact/` for brand-neutral naming
- `skills/RefinePrompt/` consolidates the former Prompt cluster (`AlignPrompt`, `DebrandPrompt`, `ExtractPrompt`, `MinimizePrompt`, `RescopePrompt`, `AdaptPrompts`) into one skill with six companions. Adoption sidecars collapse the per-transform `resolvedDependencies` entries to a single `RefinePrompt` SHA pin.
- CORE-0010 amended — validation is now fully handled by `forge validate .`; there are no module-specific validators.
- `make test` removed. `make validate` is the single entry point.

### Removed

- `scripts/validate-adr.py` — superseded by `forge validate .`, which runs both mdschema and JSON Schema (`templates/forge-adr.json`) against every ADR. The wrapper script and its self-tests are redundant. `templates/forge-adr.json` is kept; forge-cli reads it.

## [0.5.0] - 2026-04-04

### Added

- ADR renumbering with prefix-based sections (CORE, ARCH, PROV, MVPR)
- structured-madr frontmatter adoption with forge extensions (CORE-0005, CORE-0007)
- forge-adr template and JSON schema for ADR validation
- `scripts/validate-adr.py` with type, const, format, and pattern enforcement
- GitHub Actions CI workflow (`validate.yaml`)
- Git pre-commit hooks with hash-verified validate.sh fallback
- GitHub push protection for secret scanning
- Strict mdschema coverage for root, rules, skills, and ADRs
- HtmlPlayground skill
- BuildPlugin skill companion (ClaudeMarketplace absorbed from rule)

### Changed

- Migrated from forge-lib submodule to forge-cli external binary
- Adopted Mintlify install.md standard for INSTALL.md
- Retired VERIFY.md (DONE WHEN in INSTALL.md replaces it)
- README rewritten with artifact types, install pattern, and contributing section
- ARCHITECTURE.md updated with user/ overlay pattern and skill subdirectory flattening
- CLAUDE.md regenerated with current architecture and conventions
- History squashed to clean commits

[Unreleased]: https://github.com/N4M3Z/forge-core/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/N4M3Z/forge-core/releases/tag/v0.5.0
