# forge-core

Module-building skills and operational tools for the forge ecosystem. Skills for creating and validating artifacts -- [skills][1], [agents][2], [hooks][3], and [modules][4] -- plus operational utilities for markdown linting, session management, and permissions auditing.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the structural overview and design principles. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to create skills and contribute.

[1]: https://docs.anthropic.com/en/docs/claude-code/skills "Claude Code Skills"
[2]: https://docs.anthropic.com/en/docs/claude-code/sub-agents "Claude Code Sub-agents"
[3]: https://docs.anthropic.com/en/docs/claude-code/hooks "Claude Code Hooks"
[4]: skills/BuildModule/SKILL.md "Forge Module Convention"

## Skills

| Skill | Artifact | What it does |
|-------|----------|-------------|
| [**BuildSkill**](skills/BuildSkill/SKILL.md) | Skills | Create and validate skill definitions (SKILL.md structure, frontmatter, conventions) |
| [**BuildAgent**](skills/BuildAgent/SKILL.md) | Agents | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment) |
| [**BuildModule**](skills/BuildModule/SKILL.md) | Modules | Design and validate modules (directory layout, config convention, three-layer architecture) |
| [**BuildHook**](skills/BuildHook/SKILL.md) | Hooks | Hook registration, event handling, platform-specific wiring |
| [**MarkdownLint**](skills/MarkdownLint/SKILL.md) | — | Format and lint markdown — backtick code references, fix bare URLs, heading hierarchy |
| [**Sessions**](skills/Sessions/SKILL.md) | — | Claude Code session search, resume, and index repair |
| [**Permissions**](skills/Permissions/SKILL.md) | — | Audit and clean Claude Code permissions in settings.local.json |
| [**RTK**](skills/RTK/SKILL.md) | — | Token-optimized CLI proxy (60-90% savings) |

## Install

See [INSTALL.md](INSTALL.md) for detailed setup instructions.

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-core.git
cd forge-core
make install
```

## Multi-Provider Support

Skills install for Claude Code, Gemini CLI, Codex, and OpenCode:

```bash
make install                      # all providers
make install-skills-claude        # Claude Code only
make install-skills-gemini        # Gemini CLI only
SCOPE=user make install           # install to ~/.claude/skills/ (global)
SCOPE=workspace make install      # install to ./.claude/skills/ (project-local)
```

## Ecosystem

| Module | Purpose |
|--------|---------|
| **forge-core** | Authoring skills — teaches your AI to build with forge |
| **[forge-lib](https://github.com/N4M3Z/forge-lib)** | Deployment utilities — Rust binaries for installing agents and skills across providers |
| **[forge-council](https://github.com/N4M3Z/forge-council)** | Specialist agents — 13 agents organized into structured multi-round debates |

## License

MIT — see [LICENSE](LICENSE).
