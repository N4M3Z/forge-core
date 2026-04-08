# forge-core

## Description

A build system for AI instructions. Treats prompts the way software engineering treats source code: authored in version-controlled markdown, validated by schemas, assembled per target, deployed with provenance records.

Three artifact types map to how [Claude Code][CC] loads instructions:

- **[Rules][CC-RULES]** — small instruction files, always in context. One file, one behavior. When something goes wrong, the filename tells you which rule caused it.
- **[Skills][CC-SKILLS]** — lazy-loaded capabilities. The AI reads the description at session start but loads full instructions only when invoked.
- **[Agents][CC-AGENTS]** — markdown files that define a persona and role for agent delegation.

This is not a plugin system. Plugins are deployed artifacts for end users (one-click install via [Cowork][COWORK]). forge is what happens before that: authoring, validating, assembling, and tracking instructions across teams, models, and providers.

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
| [**HtmlPlayground**](skills/HtmlPlayground/SKILL.md)             | Generate single-file HTML demos comparing techniques            |

### ADR Prefix Sections

Architecture Decision Records document the why behind structural choices. Each prefix section numbers independently:

| Prefix | Scope                    | Example                                      |
| ------ | ------------------------ | -------------------------------------------- |
| `CORE` | Markdown and scaffolding | `CORE-0001 Markdown as System Language`      |
| `ARCH` | Ecosystem architecture   | `ARCH-0001 Skills Agents and Rules`          |
| `PROV` | Manifest and provenance  | `PROV-0002 Manifest for Deployment Tracking` |
| `MVPR` | Prompt optimization      | `MVPR-0001 Minimum Viable Prompt`            |

ADRs use [structured-madr][MADR] frontmatter with forge extensions. Validate with `scripts/validate-adr.py templates/forge-adr.json docs/decisions/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, skill authoring conventions, and PR process.

## Requirements

| Dependency                                       | Required    | Purpose                          |
| ------------------------------------------------ | ----------- | -------------------------------- |
| [forge-cli](https://github.com/N4M3Z/forge-cli) | Yes         | Module validation and deployment |
| python3                                          | Yes         | ADR frontmatter validation       |
| shellcheck                                       | Recommended | Shell script linting             |
| ruff                                             | Recommended | Python linting                   |

## License

[EUPL-1.2](LICENSE)

[CC]: https://code.claude.com/docs/en/overview
[CC-RULES]: https://code.claude.com/docs/en/memory
[CC-SKILLS]: https://code.claude.com/docs/en/skills
[CC-AGENTS]: https://code.claude.com/docs/en/sub-agents
[COWORK]: https://support.claude.com/en/articles/13837433-manage-cowork-plugins-for-your-organization
[MADR]: https://github.com/zircote/structured-madr
