# Module Structure Validation

Run this checklist against any forge module to audit compliance. Report pass/fail per section.

Invoke: `/BuildModule validate path/to/module`

## 1. Structure

| Check                                 | Pass criteria                                                     |
|---------------------------------------|-------------------------------------------------------------------|
| `module.yaml` exists                  | Has `name`, `version`, `description`                              |
| `.claude-plugin/plugin.json` exists   | Has `name`, `version`, `description`, `skills`                    |
| Version match                         | `module.yaml` version == `plugin.json` version                    |
| `Makefile` exists                     | Has `install`, `verify`, `test`, `lint`, `check`, `clean` targets |
| `lib/` submodule                      | Points to forge-lib, not pinned to ancient commit                 |
| `defaults.yaml`                       | Exists if module has configurable behaviour                       |
| `LICENSE` exists                      | EUPL-1.2 license file present at module root                     |
| `docs/decisions/` (if present)        | Contains `.mdschema`; template path set in `defaults.yaml`        |

## 2. Documentation

| Check                             | Pass criteria                                                                        |
|-----------------------------------|--------------------------------------------------------------------------------------|
| `README.md`                       | Exists, not empty, has `## License` section                                          |
| `INSTALL.md`                      | Exists, starts with `> **For AI agents**: This guide covers installation of [module].` |
| `VERIFY.md`                       | Exists, starts with `> **For AI agents**: Complete this checklist after installation.`  |
| `CLAUDE.md`                       | Exists (Claude Code project instructions)                                            |
| `AGENTS.md`                       | Exists (Codex/OpenCode project overview)                                             |
| `GEMINI.md`                       | Exists (Gemini CLI project context)                                                  |
| `.github/copilot-instructions.md` | Exists (Copilot project context)                                                     |

## 3. Skills

For each directory in `skills/`:

| Check              | Pass criteria                                                                 |
|--------------------|-------------------------------------------------------------------------------|
| `SKILL.md` exists  | Has YAML frontmatter with `name`, `version`, `description`                    |
| `SKILL.yaml` exists | Has `sources:` field (no `name:` or `description:` -- those live in SKILL.md) |
| Name match         | `SKILL.md` frontmatter `name` matches directory name                          |
| USE WHEN           | `description` contains "USE WHEN" trigger phrases                             |

Directory-level validation (if `skills/` has files):

| Check               | Pass criteria                                              |
|----------------------|------------------------------------------------------------|
| `.mdschema` exists   | `skills/.mdschema` present for structural validation       |
| Schema content       | Validates frontmatter fields: `name`, `description`, `version` |

## 4. Agents

For each `.md` file in `agents/`:

| Check               | Pass criteria                                                          |
|----------------------|------------------------------------------------------------------------|
| Frontmatter          | Has `name`, `version`, `description`                                   |
| PascalCase name      | `name` matches filename without extension                              |
| USE WHEN             | `description` contains "USE WHEN" trigger phrases                      |
| Body structure       | Has `## Role`, `## Instructions`, `## Constraints` headings           |
| Constraints clause   | Constraints include honesty clause and SendMessage clause              |

Directory-level validation (if `agents/` has files):

| Check               | Pass criteria                                              |
|----------------------|------------------------------------------------------------|
| `.mdschema` exists   | `agents/.mdschema` present for structural validation       |
| Schema content       | Validates frontmatter fields: `name`, `description`, `version` |

## 5. Shell Scripts

For each `.sh` file (excluding `target/` and `lib/`):

| Check              | Pass criteria                                                   |
|--------------------|-----------------------------------------------------------------|
| Strict mode        | `set -euo pipefail` present                                     |
| Alias safety       | Uses `command` prefix for `cd`, `cp`, `mv`, `rm` -- never bare |
| No `builtin`       | `command` works for everything, `builtin` causes problems       |

## 6. Versions

| Check                      | Pass criteria                                  |
|----------------------------|------------------------------------------------|
| module.yaml == plugin.json | Version strings match exactly                  |
| Cargo.toml (if Rust)       | Note version -- may differ from module version |

## 7. Configuration

| Check                         | Pass criteria                                                                                                 |
|-------------------------------|---------------------------------------------------------------------------------------------------------------|
| `config.yaml` in `.gitignore` | User overrides never committed                                                                                |
| Provider dirs in `.gitignore` | Pattern: `.claude/agents/*`, `.claude/skills/*`, etc. for all 4 providers                                     |
| .gitkeep exclusions           | Each provider dir has `.gitkeep` excluded from ignore (`!.claude/agents/.gitkeep`)                            |
| `.codex/config.toml` ignored  | Generated by `install-agents` for Codex provider                                                              |
| No committed provider dirs    | `.claude/`, `.gemini/`, `.codex/`, `.opencode/` are generated by `make install` -- only .gitkeep files tracked |

## 8. Roster Consistency

Cross-check directory contents against `defaults.yaml` registration:

| Check                           | Pass criteria                                                            |
|---------------------------------|--------------------------------------------------------------------------|
| Skills registered               | Every directory in `skills/` appears under `skills:` in `defaults.yaml`  |
| Agents registered               | Every file in `agents/` appears under `agents:` in `defaults.yaml`       |
| No phantom skills               | No `defaults.yaml` skill entries without a matching `skills/` directory   |
| No phantom agents               | No `defaults.yaml` agent entries without a matching `agents/` file        |

## 9. Makefile Consistency

Cross-check Makefile targets against directory structure:

| Check                          | Pass criteria                                                                  |
|--------------------------------|--------------------------------------------------------------------------------|
| Agent plumbing (if `agents/`)  | Makefile declares `AGENT_SRC`, includes `agents/install.mk` + `agents/verify.mk` |
| Skill plumbing (if `skills/`)  | Makefile declares `SKILL_SRC`, includes `skills/install.mk` + `skills/verify.mk` |
| install target                 | Includes `install-agents` if `agents/` exists                                  |
| clean target                   | Includes `clean-agents` if `agents/` exists                                    |
| verify target                  | Includes `verify-agents` if `agents/` exists                                   |
| check target                   | Tests for `agents/` directory and `install-agents` binary if `agents/` exists  |

## 10. Installation Guide

@InstallGuide.md

## 11. Verification Guide

@VerifyGuide.md

## 12. Report

Output a summary table:

```
Section              Status
─────────────────────────────────
Structure            PASS / FAIL (N issues)
Documentation        PASS / FAIL (N issues)
Skills               PASS / FAIL (N issues)
Agents               PASS / FAIL (N issues)
Shell                PASS / FAIL (N issues)
Versions             PASS / FAIL (N issues)
Configuration        PASS / FAIL (N issues)
Roster Consistency   PASS / FAIL (N issues)
Makefile Consistency PASS / FAIL (N issues)
Installation Guide   PASS / WARN (N) / FAIL (N)  [tier: Full|Standard|Scaffold]
Verification Guide   PASS / WARN (N) / FAIL (N)  [tier: Full|Standard|Scaffold]
```

List specific failures with file paths and remediation hints.
