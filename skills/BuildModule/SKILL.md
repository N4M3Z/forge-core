---
name: BuildModule
version: 0.1.0
description: "Design, build, and validate forge modules. USE WHEN create module, new module, scaffold module, validate module, check module, audit module, module structure, module conventions, module architecture."
---

# BuildModule

Guide for creating robust forge modules. Focuses on the three-layer concern architecture and ensures modules are portable across AI coding tools. Modules follow the [Agent Skills](https://agentskills.io) standard for cross-provider compatibility.

## Module Structure

Every forge module follows this standard layout:

```
module-name/
    module.yaml         Metadata and event registration
    defaults.yaml       Default configuration (committed)
    config.yaml         User overrides (gitignored)
    agents/             Agent markdown files
    skills/             SKILL.md files for AI capabilities
    hooks/              Bash scripts triggered by events
    bin/                Entry points or build scripts
    src/                Source code (typically Rust)
    .claude-plugin/     Claude Code plugin manifest
    Makefile            install/validate/clean targets delegating to forge
    CLAUDE.md           Project instructions for Claude Code (generated)
    AGENTS.md           Project overview for Codex/OpenCode (generated)
    GEMINI.md           Project context for Gemini CLI (generated)
    README.md           Human-facing documentation
    INSTALL.md          Agent-executable installation guide
```

Not all directories are required. A skills-only module (no hooks, no Rust) only needs: `skills/`, `module.yaml`, `defaults.yaml`, `.claude-plugin/plugin.json`, `Makefile`.

## Core Mandates

1. **Config Convention**: Ship `defaults.yaml` (committed) with reasonable defaults + `config.yaml` (gitignored override). Users create `config.yaml` only when they need overrides. Loader falls back: `config.yaml` > `defaults.yaml` > compiled `Default` impl. Never commit user-specific paths.

2. **Separation of Concerns**: Keep parsing logic "pure" (no I/O) in library modules. Let binaries handle the environment and file reads.

3. **Lazy Compilation**: Use `bin/_build.sh` to compile binaries on first hook invocation, ensuring low overhead.

4. **Validation Driven**: Ship an `INSTALL.md` following the [Mintlify install.md](https://github.com/mintlify/install-md) standard. Its DONE WHEN section embeds a measurable success condition so an AI agent can confirm the module is functional without manual intervention.

## Three-Layer Architecture

Every module addresses one or more of these concerns:

| Layer         | Question                               | Examples                                                    |
|---------------|----------------------------------------|-------------------------------------------------------------|
| **Identity**  | Does it store user-specific knowledge? | forge-avatar (goals, preferences, beliefs)                  |
| **Behaviour** | Does it change how the AI responds?    | forge-steering (rules), forge-tlp (access control)          |
| **Knowledge** | Does it provide new tools or skills?   | forge-council (specialists), forge-core (build skills)      |

Don't mix layers. Rules go in behaviour modules. Skills go in knowledge modules. User data goes in identity modules.

## module.yaml

```yaml
name: forge-example
version: 0.1.0
description: One-line description of what this module does.
events: []
platforms: []
```

`events: []` means no hooks. For hook-using modules, list the events:
```yaml
events: [SessionStart, PreToolUse, Stop]
```

`platforms: []` means all platforms (default). For platform-restricted modules:
```yaml
platforms: [macos]  # skip Windows/Linux checks in INSTALL.md validation
```

## defaults.yaml

```yaml
# Module-specific configuration.
# Override: create config.yaml (gitignored) with only the fields you want to change.

skills:
    claude:
        SkillName:
    gemini:
        SkillName:
    codex:
        SkillName:
    opencode:
        SkillName:

agents:
    AgentName:
        model: fast
        tools: Read, Grep, Glob

providers:
    claude:
        models:
            fast: [claude-sonnet-4-6]
            strong: [claude-opus-4-6]
    gemini:
        models:
            fast: [gemini-2.0-flash]
            strong: [gemini-2.5-pro]
    codex:
        models:
            fast: [gpt-5.3-codex]
            strong: [gpt-5.4]
    opencode:
        models:
            fast: [claude-sonnet-4-6]
            strong: [claude-opus-4-6]
```

The `skills:` section uses provider-keyed allowlists. `forge install` reads this to decide which skills deploy to which provider. Skills omitted from a provider's list are skipped. This allows Claude-only skills (e.g., those using agent teams) to be excluded from Gemini/Codex without per-skill configuration.

**Critical**: The `providers:` section drives agent deployment. `forge install` reads provider keys from this section to determine target directories. A provider missing from `providers:` means agents will NOT deploy there, even if the `agents:` section is correct.

## plugin.json

```json
{
    "name": "forge-example",
    "version": "0.1.0",
    "description": "Module description.",
    "author": {"name": "Author Name"},
    "skills": ["./skills"]
}
```

Add `"hooks": "./hooks/hooks.json"` only if the module has hooks.

## Makefile Pattern

All module build, install, test, and lint logic runs through Makefiles. No standalone shell scripts that duplicate or bypass Make targets; they become invisible, untested, and unmaintainable.

Modules ship a minimal Makefile (~20 lines, not 200) that activates git hooks and delegates to the `forge` CLI:

```makefile
FORGE ?= forge

.PHONY: help install validate clean

install:
	git config core.hooksPath .githooks
	$(FORGE) install --target ~

validate:
	@bash .githooks/pre-commit

clean:
	rm -rf build/
```

`forge install` reads `defaults.yaml` directly to decide what deploys where, so the Makefile needs no agent or skill roster variables.

## Provider Documentation

Every module ships platform-specific instruction files at its root:

| File        | Platform        | Generate                       | Reference              |
|-------------|-----------------|--------------------------------|------------------------|
| `CLAUDE.md` | Claude Code     | `claude` (manual or `/init`)   | --                     |
| `AGENTS.md` | Codex, OpenCode | `codex init` / `opencode init` | @CodexProvider.md, @OpenCodeProvider.md |
| `GEMINI.md` | Gemini CLI      | `gemini init`                  | @GeminiProvider.md                      |

Generate these files by running each platform's CLI init command inside the module directory. The CLI analyzes the codebase and produces platform-appropriate instructions. To update an existing file, rename it to `.bak`, re-run init, and diff.

Generate them after the module structure is complete and before first commit.

## Session Capture

Once the module is a git repository — and before substantial agent work begins — enable [Entire](https://github.com/entireio/cli) so every coding session is checkpointed onto a commit-anchored branch from the start. Match `--agent` to the tool in use (`claude-code`, `codex`, `gemini`, `opencode`, and others):

```bash
entire enable --agent <agent> --skip-push-sessions --local --telemetry=false
```

`--skip-push-sessions` keeps the transcript branch local-only, which is mandatory for a public module: a default enable would publish the verbatim session transcript on `git push`. `--local` writes gitignored settings. See the SessionContinuity skill (forge-dev) for the resume, rewind, and review workflows.

## Validation Flow

1. **Unit Tests**: `cargo test` (or equivalent) for Rust modules
2. **Module Conventions**: `forge validate` checks structure
3. **Pre-commit Gate**: `make validate` runs `.githooks/pre-commit`
4. **Binary Availability**: Check binaries respond to `--help` or `--version`

## Validate

@ModuleStructure.md

## Constraints

- ALL CAPS filenames = system-provided (SYSTEM.md, CONVENTIONS.md). Title Case = user-authored.
- `config.yaml` is always gitignored at every level
- The `forge` CLI provides install, validate, and assembly operations
- Modules must work standalone -- no dependency on a parent monorepo

## Sources

- <https://github.com/anthropics/claude-code/blob/main/plugins/README.md>
- <https://code.claude.com/docs/en/skills>
