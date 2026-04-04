# forge-core

## Description

Module-building skills and operational tools for the forge ecosystem. Skills for creating and validating artifacts -- [skills][1], [agents][2], [hooks][3], and [modules][4] -- plus operational utilities for markdown linting, settings auditing, and version control conventions.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the structural overview and design principles. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to create skills and contribute.

[1]: https://docs.anthropic.com/en/docs/claude-code/skills "Claude Code Skills"
[2]: https://docs.anthropic.com/en/docs/claude-code/sub-agents "Claude Code Sub-agents"
[3]: https://docs.anthropic.com/en/docs/claude-code/hooks "Claude Code Hooks"
[4]: skills/BuildModule/SKILL.md "Forge Module Convention"

## Compatibility

Skills install for Claude Code, Gemini CLI, Codex, and OpenCode:

```bash
make install                      # all providers
make install-skills-claude        # Claude Code only
make install-skills-gemini        # Gemini CLI only
SCOPE=user make install           # install to ~/.claude/skills/ (global)
SCOPE=workspace make install      # install to ./.claude/skills/ (project-local)
```

## Getting started

See [INSTALL.md](INSTALL.md) for detailed setup instructions.

```bash
git clone https://github.com/N4M3Z/forge-core.git
cd forge-core
make install
```

## Usage

| Skill                                                                  | Artifact | What it does                                                                                |
|------------------------------------------------------------------------|----------|---------------------------------------------------------------------------------------------|
| [**BuildSkill**](skills/BuildSkill/SKILL.md)                           | Skills   | Create and validate skill definitions (SKILL.md structure, frontmatter, conventions)        |
| [**BuildAgent**](skills/BuildAgent/SKILL.md)                           | Agents   | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment) |
| [**BuildModule**](skills/BuildModule/SKILL.md)                         | Modules  | Design and validate modules (directory layout, config convention, three-layer architecture)  |
| [**BuildHook**](skills/BuildHook/SKILL.md)                             | Hooks    | Hook registration, event handling, platform-specific wiring                                 |
| [**ArchitectureDecision**](skills/ArchitectureDecision/SKILL.md)       | --       | Find, read, create, validate, and capture Architecture Decision Records                     |
| [**VersionControl**](skills/VersionControl/SKILL.md)                   | --       | Git conventions, repo governance (GitHub rulesets, GitLab branches, CODEOWNERS)              |
| [**MarkdownLint**](skills/MarkdownLint/SKILL.md)                       | --       | Format and lint markdown -- backtick code references, fix bare URLs, heading hierarchy      |
| [**MarkdownSchema**](skills/MarkdownSchema/SKILL.md)                   | --       | Create, derive, and validate .mdschema files for markdown documents                         |
| [**SettingsMaintenance**](skills/SettingsMaintenance/SKILL.md)          | --       | Audit and clean AI tool settings -- permissions, plugins, hooks, cross-layer conflicts      |
| [**SystemCheck**](skills/SystemCheck/SKILL.md)                         | --       | Ecosystem staleness -- binary freshness, version drift, submodule pointers                  |
| [**AdaptPrompts**](skills/AdaptPrompts/SKILL.md)                       | --       | Adapt generic rules for independent repos -- strip branding, scope, preserve overrides      |
| [**RTK**](skills/RTK/SKILL.md)                                         | --       | Token-optimized CLI proxy (60-90% savings)                                                  |

## Requirements

| Dependency                                         | Required    | Purpose                                          |
|----------------------------------------------------|-------------|--------------------------------------------------|
| [forge](https://github.com/N4M3Z/forge-cli)       | Yes         | Module validation and skill deployment            |
| shellcheck                                         | Recommended | Shell script linting (`brew install shellcheck`) |

## License

EUPL 1.2 -- see [LICENSE](LICENSE).
