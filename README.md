# forge-core

## Description

Module-building skills and operational tools for your AI ecosystem. Skills for creating and validating [skills][1], [agents][2], [hooks][3], and [modules][4] — plus ADR management, markdown linting, settings auditing, and version control conventions.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the structural overview. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

## Compatibility

Deploys to Claude Code, Gemini CLI, Codex, and OpenCode:

```sh
make install                      # all providers
SCOPE=user make install           # ~/.claude/skills/ (global)
SCOPE=workspace make install      # ./.claude/skills/ (project-local)
```

## Installation

Have your AI resolve the install instructions:

```sh
curl -s https://raw.githubusercontent.com/N4M3Z/forge-core/main/INSTALL.md | claude
```

Or manually:

```sh
git clone https://github.com/N4M3Z/forge-core.git
cd forge-core
make install    # requires forge-cli (https://github.com/N4M3Z/forge-cli)
```

`make install` deploys skills to all providers and activates git pre-commit hooks. See [INSTALL.md](INSTALL.md) for the full agent-executable setup.

## Usage

Skills teach AI coding tools new capabilities. Invoke them with `/SkillName` in Claude Code, or reference them in prompts for other providers. Rules enforce behavioral conventions automatically.

| Skill                                                            | What it does                                                    |
| ---------------------------------------------------------------- | --------------------------------------------------------------- |
| [**BuildSkill**](skills/BuildSkill/SKILL.md)                     | Create and validate skill definitions                           |
| [**BuildAgent**](skills/BuildAgent/SKILL.md)                     | Scaffold, validate, and audit agent definitions                 |
| [**BuildModule**](skills/BuildModule/SKILL.md)                   | Design and validate forge modules                               |
| [**BuildHook**](skills/BuildHook/SKILL.md)                       | Hook registration, event handling, platform wiring              |
| [**BuildPlugin**](skills/BuildPlugin/SKILL.md)                   | Create, validate, and publish Claude Code plugins               |
| [**ArchitectureDecision**](skills/ArchitectureDecision/SKILL.md) | Find, create, validate, and capture ADRs with schema validation |
| [**VersionControl**](skills/VersionControl/SKILL.md)             | Git conventions, repo governance, CODEOWNERS                    |
| [**MarkdownLint**](skills/MarkdownLint/SKILL.md)                 | Format and lint markdown documents                              |
| [**MarkdownSchema**](skills/MarkdownSchema/SKILL.md)             | Create, derive, and validate .mdschema files                    |
| [**PublishPrompts**](skills/PublishPrompts/SKILL.md)              | Provenance tracking and sync for inherited content              |
| [**AdaptPrompts**](skills/AdaptPrompts/SKILL.md)                 | Adapt generic rules for independent repos                       |
| [**PromptAnalysis**](skills/PromptAnalysis/SKILL.md)             | Validate and minimize prompts                                   |
| [**SettingsMaintenance**](skills/SettingsMaintenance/SKILL.md)    | Audit and clean AI tool settings                                |
| [**SystemCheck**](skills/SystemCheck/SKILL.md)                   | Ecosystem staleness and version drift checks                    |
| [**RTK**](skills/RTK/SKILL.md)                                   | Token-optimized CLI proxy                                       |

### ADR Prefix Sections

Architecture Decision Records document the why behind structural choices. Each prefix section numbers independently:

| Prefix | Scope                    | Example                                      |
| ------ | ------------------------ | -------------------------------------------- |
| `CORE` | Markdown and scaffolding | `CORE-0001 Markdown as System Language`      |
| `ARCH` | Ecosystem architecture   | `ARCH-0001 Skills Agents and Rules`          |
| `PROV` | Manifest and provenance  | `PROV-0002 Manifest for Deployment Tracking` |
| `MVPR` | Prompt optimization      | `MVPR-0001 Minimum Viable Prompt`            |

ADRs use [structured-madr][5] frontmatter with forge extensions. Validate with `python3 bin/validate-adr.py templates/forge-adr.json docs/decisions/`.

## Requirements

| Dependency                                       | Required    | Purpose                          |
| ------------------------------------------------ | ----------- | -------------------------------- |
| [forge-cli](https://github.com/N4M3Z/forge-cli) | Yes         | Module validation and deployment |
| python3                                          | Yes         | ADR frontmatter validation       |
| shellcheck                                       | Recommended | Shell script linting             |
| ruff                                             | Recommended | Python linting                   |

## License

[EUPL-1.2](LICENSE)

[1]: https://docs.anthropic.com/en/docs/claude-code/skills
[2]: https://docs.anthropic.com/en/docs/claude-code/sub-agents
[3]: https://docs.anthropic.com/en/docs/claude-code/hooks
[4]: skills/BuildModule/SKILL.md
[5]: https://github.com/zircote/structured-madr
