# Installation Guide Validation

The Documentation section checks that INSTALL.md exists. This companion validates its content — does it actually guide an AI agent through installation on all supported platforms?

Reference standard: [forge-learn INSTALL.md](https://github.com/N4M3Z/forge-learn/blob/main/INSTALL.md).

## Per-Platform Reference

Platform-specific prerequisites, build commands, and notes for each supported OS:

- @macOSPlatform.md
- @WindowsPlatform.md
- @LinuxPlatform.md

When writing or validating an INSTALL.md, ensure the module covers each platform appropriate to its `platforms:` field (or all three if absent).

## Tier Detection

Check in order:

1. INSTALL.md contains a `## Planned` heading → **Scaffold** (placeholder module)
2. `Cargo.toml` exists at module root → **Full** (Rust module, needs build tooling)
3. Otherwise → **Standard** (skills-only, no compilation)

**Skip Windows checks** if `module.yaml` has `platforms:` without `windows` (e.g., forge-apple is `platforms: [macos]`).

## Scaffold

Report `SCAFFOLD — full validation deferred`, check only:

| Check | Pass criteria |
|-------|---------------|
| AI notice | First blockquote mentions "AI agents" |
| Planned section | `## Planned` heading has content below it |

## Standard

All checks required:

| Check | Pass criteria |
|-------|---------------|
| AI notice | First blockquote mentions "AI agents" |
| Requirements | `## Requirements` heading with numbered items |
| Build / Deploy | Heading matching `## .*(Build\|Deploy).*` with a code block |
| Platforms | `## Platforms` heading (optional — required for Full tier) |
| Configuration | `## Configuration` heading (optional) |

## Full

Standard checks plus cross-platform support:

| Check | Pass criteria |
|-------|---------------|
| POSIX section | Code block with `bash` or `sh` fence under Build heading |
| PowerShell fallback | `powershell` code block or heading containing "PowerShell" / "Windows" |
| PowerShell content | PowerShell blocks contain `.exe` or `cargo build` (not POSIX pasted in) |
| Platforms | `## Platforms` heading with Windows mentioned in the section body |

## Status Levels

- **FAIL** — required check missing (heading absent)
- **WARN** — heading present but content insufficient
- **PASS** — all checks pass for the detected tier
