# Verification Guide Validation

The Documentation section checks that VERIFY.md exists. This companion validates its content — does it actually confirm the module works after installation?

Reference standard: [forge-learn VERIFY.md](https://github.com/N4M3Z/forge-learn/blob/main/VERIFY.md).

## Tier Detection

Same tier as INSTALL.md (Scaffold / Standard / Full). See @InstallGuide.md for detection logic.

## Scaffold

| Check | Pass criteria |
|-------|---------------|
| AI notice | First line is blockquote or paragraph mentioning "AI agents" |
| Health check | Has at least one check with a bash code block |

## Standard

| Check | Pass criteria |
|-------|---------------|
| AI notice | First line is blockquote or paragraph mentioning "AI agents" |
| Health check | `## Health check` heading with quick verification commands |
| Structure validation | `## Structure validation` heading verifying expected files (optional) |
| Success criteria | `## Success criteria` heading summarizing pass/fail |

## Full

Standard checks plus:

| Check | Pass criteria |
|-------|---------------|
| Health check | Includes binary availability checks (`--version` / `--help`) |
| Functionality tests | `## Functionality tests` heading with at least one functional test |
| Test suite | `cargo test` command with expected test count |

## Status Levels

- **FAIL** — required check missing (heading absent)
- **WARN** — heading present but content insufficient
- **PASS** — all checks pass for the detected tier
