# GEMINI.md

This file provides instructional context for the Gemini AI agent when working with the **forge-core** codebase.

## Project Overview

**forge-core** is the module-building toolkit for the Forge ecosystem. It provides skills that teach AI coding tools to create skills, scaffold agents, and architect modules.

### Core Responsibilities
- **Skill Creation:** Guiding the creation and validation of SKILL.md + SKILL.yaml definitions.
- **Agent Scaffolding:** Generating agent markdown files with correct frontmatter, body structure, and deployment configuration.
- **Module Architecture:** Designing and validating forge modules with the three-layer concern architecture.

## Building and Testing

The project uses a `Makefile` to manage skill deployment and validation.

### Key Commands
- `make install`: Deploys skills to all providers (Claude, Gemini, Codex, OpenCode).
- `make verify`: Verifies skills are deployed across all providers.
- `make test`: Runs `validate-module` convention checks.
- `make lint`: Runs `shellcheck` on all shell scripts.
- `make clean`: Removes installed skills from all provider directories.

## Skills

| Skill | Responsibilities |
| :--- | :--- |
| `BuildSkill` | SKILL.md structure, frontmatter conventions, SKILL.yaml deployment metadata, validation. |
| `BuildAgent` | Agent frontmatter (name, description, version), body structure (Role, Expertise, Instructions, Constraints), deployment config. |
| `BuildModule` | Directory layout, module.yaml, defaults.yaml, config convention, Makefile pattern, three-layer architecture. |

## Skill File Convention

Each skill directory contains:
- `SKILL.md` — AI instructions with YAML frontmatter (name, description, version).
- `SKILL.yaml` — Deployment metadata (name, description, argument-hint, provider routing).
- Optional companion `.md` files referenced via `@` includes (Claude Code specific).

## Submodule Integration

Forge modules consume `forge-core` for its authoring skills. Install via:

```bash
git submodule add https://github.com/N4M3Z/forge-core.git modules/forge-core
cd modules/forge-core && make install SCOPE=workspace
```

### Makefile Integration Example
```makefile
install-forge-core:
	@$(MAKE) -C modules/forge-core install SCOPE=$(SCOPE)
```

## Configuration

- `defaults.yaml`: Skill roster (committed).
- `config.yaml`: User overrides (gitignored), same structure as defaults.
- `module.yaml`: Module metadata (name, version, description).

## Development Conventions

- **Skill naming**: PascalCase directories matching `name:` in SKILL.yaml.
- **Provider routing**: `providers:` block in SKILL.yaml controls which platforms receive the skill.
- **forge-lib**: Git submodule at `lib/`, provides `install-skills` and `validate-module` Rust binaries.
