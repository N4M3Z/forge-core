# forge-core — Installation

> **For AI agents**: This guide covers installation of forge-core. Follow the steps for your deployment mode.

## As part of forge-dev (submodule)

Already included as a submodule. Deploy skills with:

```bash
make install
```

## Standalone (Claude Code plugin)

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-core.git
```

Or if already cloned:

```bash
git submodule update --init
```

This checks out [forge-lib](https://github.com/N4M3Z/forge-lib) into `lib/`, providing shared utilities for skill deployment.

### 2. Deploy skills

```bash
make install
```

By default, this installs skills into the local project directory for use in the current workspace (`SCOPE=workspace`):

- Skills: `.claude/skills/`, `.gemini/skills/`, `.codex/skills/`, `.opencode/skills/`

To install globally for your user (available in all projects):

```bash
make install SCOPE=user
```

This installs skills to `~/.claude/skills/`, `~/.gemini/skills/`, `~/.codex/skills/`, and `~/.opencode/skills/`.

Use `SCOPE=all` to target both workspace and user home directories.

The Makefile automatically initializes the `lib/` submodule on first run if `Cargo.toml` is not found.

Provider-specific skill installs:

```bash
make install-skills-claude    # ./.claude/skills/ (SCOPE=workspace) or ~/.claude/skills/ (SCOPE=user|all)
make install-skills-gemini    # via gemini CLI (skipped if CLI not installed)
make install-skills-codex     # ./.codex/skills/ (SCOPE=workspace) or ~/.codex/skills/ (SCOPE=user|all)
make install-skills-opencode  # ./.opencode/skills/ with kebab-case names (SCOPE=workspace|user|all)
```

### 3. Verification

```bash
make verify
```

Skills require a session restart to be discovered.

## What gets installed

| Skill | What it does |
|-------|-------------|
| **BuildSkill** | Create and validate skill definitions (SKILL.md structure, frontmatter, conventions) |
| **BuildAgent** | Scaffold, validate, and audit agent markdown files (frontmatter, body structure, deployment) |
| **BuildModule** | Design and validate forge modules (directory layout, config convention, three-layer architecture) |

No compiled binaries needed at runtime — forge-core is pure markdown skills. Skills are markdown files deployed by scope across `.claude/`, `.gemini/`, `.codex/` (workspace) and/or `~/` equivalents (user/all). Skills are additionally deployed to `.opencode/skills/` with kebab-case names.

## Configuration

### defaults.yaml

Ships with the skill roster:

```yaml
skills:
    - BuildSkill
    - BuildAgent
    - BuildModule
```

### Module config override

Create `config.yaml` (gitignored) to override:

```yaml
# Example: disable a skill
skills:
    - BuildSkill
    - BuildAgent
```

## Updating

```bash
git pull --recurse-submodules    # update module + forge-lib
make clean                      # remove old skills
make install                    # reinstall everything
```

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| forge-lib | Yes (standalone) | Shared skill deployment utilities |
| Rust toolchain | Yes (standalone) | Building forge-lib binaries (`cargo build`) |
| shellcheck | Recommended | `brew install shellcheck` — shell script linting |

forge-lib must be compiled from source. The Makefile handles building automatically on first `make install`.

> **Note (forge-dev only):** When running as a submodule of forge-dev, forge-lib is provided by the parent project via `FORGE_LIB` env var — the module's own `lib/` submodule is not used.
