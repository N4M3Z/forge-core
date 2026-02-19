# forge-core

Module-building skills for the forge ecosystem. Teaches your AI coding tool to create skills, build agents, and architect modules.

## Skills

| Skill | What it does |
|-------|-------------|
| **BuildSkill** | Create and validate skill definitions (SKILL.md structure, frontmatter, conventions) |
| **BuildAgent** | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment) |
| **BuildModule** | Design and validate forge modules (directory layout, config convention, three-layer architecture) |

## Ecosystem

| Module | Purpose |
|--------|---------|
| **forge-core** | Authoring skills -- teaches your AI to build with forge |
| **[forge-lib](https://github.com/N4M3Z/forge-lib)** | Deployment utilities -- Rust binaries for installing agents and skills across providers |
| **[forge-council](https://github.com/N4M3Z/forge-council)** | Specialist agents -- 13 agents organized into structured multi-round debates |

## Install

See [INSTALL.md](INSTALL.md) for detailed setup instructions.

Quick start:

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

## License

MIT
