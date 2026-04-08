# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

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
