# Install

> **For AI agents**: This guide covers installation of forge-core. Follow the steps for your deployment mode.

## Requirements

1. **Git** with submodule support
2. **Rust toolchain** — `cargo` for building forge-lib binaries
3. **shellcheck** (recommended) — `brew install shellcheck` for shell script linting

## Build and Deploy

**As a submodule** — already included. Deploy skills with `make install`.

**Standalone** — clone with submodules:

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-core.git
```

Or if already cloned:

```bash
git submodule update --init
```

This checks out [forge-lib](https://github.com/N4M3Z/forge-lib) into `lib/`, providing shared utilities for skill deployment.

Deploy skills:

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

Verify the installation:

```bash
make verify
```

Skills require a session restart to be discovered.

## Configuration

`defaults.yaml` ships with the skill roster, keyed by provider:

```yaml
skills:
    claude:
        BuildSkill:
        BuildAgent:
        BuildModule:
        # ... more skills
    gemini:
        BuildSkill:
        # ...
```

Create `config.yaml` (gitignored) to override — same structure, only the fields you want to change.

## Updating

```bash
git pull --recurse-submodules    # update module + forge-lib
make clean                      # remove old skills
make install                    # reinstall everything
```
