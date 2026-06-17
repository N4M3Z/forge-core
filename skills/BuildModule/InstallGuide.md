# Installation Guide Validation

The Documentation section checks that INSTALL.md exists. This companion validates its content — does it actually guide an AI agent through installation on all supported platforms?

Reference standard: [Mintlify install.md](https://github.com/mintlify/install-md), template at [forge-cli templates/init/INSTALL.md](https://github.com/N4M3Z/forge-cli/blob/main/templates/init/INSTALL.md).

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

Report `SCAFFOLD: full validation deferred`, check only:

| Check           | Pass criteria                                     |
|-----------------|---------------------------------------------------|
| Summary         | H1 title with a blockquote summary directly below |
| Planned section | `## Planned` heading has content below it         |

## Standard

All checks required:

| Check       | Pass criteria                                                        |
|-------------|----------------------------------------------------------------------|
| Summary     | H1 title with a blockquote summary directly below                    |
| Autonomy    | Opening prose instructs the agent to execute the steps autonomously  |
| OBJECTIVE   | `## OBJECTIVE` heading with a one-sentence goal                      |
| DONE WHEN   | `## DONE WHEN` heading with a measurable success condition           |
| TODO        | `## TODO` heading with a checklist of 3-7 items                      |
| Steps       | Step headings with shell commands in fenced code blocks              |
| EXECUTE NOW | Closing line starts with `EXECUTE NOW` and restates DONE WHEN        |

## Full

Standard checks plus build tooling:

| Check             | Pass criteria                                                 |
|-------------------|---------------------------------------------------------------|
| Build step        | Steps include a build command (`cargo build` or equivalent)   |
| Platform coverage | Steps cover each OS in `platforms:` (or all three if absent)  |

## Status Levels

- **FAIL** — required check missing (heading absent)
- **WARN** — heading present but content insufficient
- **PASS** — all checks pass for the detected tier
