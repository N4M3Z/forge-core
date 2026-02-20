# forge-core

Development platform for the forge ecosystem. Skills for creating and validating forge artifacts — skills, agents, hooks, and modules — plus utilities like RTK.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the structural overview and design principles. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to create skills and contribute.

## Skills

| Skill | Artifact | What it does |
|-------|----------|-------------|
| [**BuildSkill**](skills/BuildSkill/SKILL.md) | Skills | Create and validate skill definitions (SKILL.md structure, frontmatter, conventions) |
| [**BuildAgent**](skills/BuildAgent/SKILL.md) | Agents | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment) |
| [**BuildModule**](skills/BuildModule/SKILL.md) | Modules | Design and validate forge modules (directory layout, config convention, three-layer architecture) |
| [**BuildHook**](skills/BuildHook/SKILL.md) | Hooks | Hook registration, event handling, platform-specific wiring |
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
