# AGENTS.md -- forge-core

> Module-building skills for the forge ecosystem. Provides skill creation,
> agent scaffolding, and module architecture guidance. Multi-provider
> support: Claude Code, Gemini CLI, Codex, OpenCode.

## Build / Install / Verify

```bash
make install          # deploy skills to all providers
make verify           # check skills deployed across all providers
make test             # validate-module convention checks
make lint             # shellcheck all scripts
make clean            # remove installed skills
```

No plugin installation needed for standalone use -- skills are deployed
directly to provider directories by the Makefile.

## Project Structure

```
skills/
  BuildSkill/
    SKILL.md              # Skill creation and validation instructions
    SKILL.yaml            # Deployment metadata and provider routing
    ClaudeSkill.md        # Claude Code @ reference patterns for skills
  BuildAgent/
    SKILL.md              # Agent scaffolding, validation, and audit
    SKILL.yaml            # Deployment metadata and provider routing
    ClaudeAgent.md        # Claude Code @ reference patterns for agents
  BuildModule/
    SKILL.md              # Module architecture and validation
    SKILL.yaml            # Deployment metadata and provider routing
lib/                      # git submodule -> forge-lib (Rust binaries)
.claude-plugin/
  plugin.json             # Claude Code plugin manifest
defaults.yaml             # Skill roster
config.yaml               # User overrides (gitignored)
module.yaml               # Module metadata (name, version)
Makefile                  # Multi-provider install, verify, test, clean
```

## Skills

| Skill | Purpose |
|-------|---------|
| **BuildSkill** | Create and validate skill definitions (SKILL.md + SKILL.yaml structure, frontmatter, conventions) |
| **BuildAgent** | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment config) |
| **BuildModule** | Design and validate forge modules (directory layout, config convention, three-layer architecture) |

### Skill File Convention

Each skill directory contains:
- `SKILL.md` -- AI instructions with YAML frontmatter (name, description, version)
- `SKILL.yaml` -- deployment metadata (name, description, argument-hint, provider routing)
- Optional companion `.md` files for provider-specific content

## Consuming as Submodule

```bash
git submodule add https://github.com/N4M3Z/forge-core.git modules/forge-core
```

Skills are installed via `make install` in the module directory. Each skill
auto-deploys to Claude Code, Gemini CLI, Codex, and OpenCode based on the
`providers:` section in its `SKILL.yaml`.

### Makefile Integration

```makefile
install-forge-core:
	@$(MAKE) -C modules/forge-core install SCOPE=$(SCOPE)
```

## Ecosystem

| Module | Purpose |
|--------|---------|
| **forge-core** | Authoring skills -- teaches your AI to build with forge |
| **[forge-lib](https://github.com/N4M3Z/forge-lib)** | Deployment utilities -- Rust binaries for installing agents and skills |
| **[forge-council](https://github.com/N4M3Z/forge-council)** | Specialist agents -- 13 agents organized into structured multi-round debates |

## Development Conventions

- **Skill naming**: PascalCase directories (`BuildSkill/`), matching `name:` in SKILL.yaml
- **Config override**: `config.yaml` (gitignored) overrides `defaults.yaml`
- **forge-lib**: Consumed as git submodule at `lib/`, provides `install-skills` and `validate-module`

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope.

Types: `feat`, `fix`, `docs`
