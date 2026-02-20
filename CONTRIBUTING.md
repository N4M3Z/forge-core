# Contributing to forge-core

Start with [ARCHITECTURE.md](ARCHITECTURE.md) for the structural overview — it defines artifacts, canon+sidecar, and the invariants. This guide covers how to work with the module.

## How Ideas Become Artifacts

```
                Internal (vault author)                    External (contributor)
                ┌─────────────────────┐                    ┌──────────────────┐
                │  Idea / draft       │                    │  Fork + branch   │
                │  in authoring env   │                    │                  │
                └────────┬────────────┘                    └────────┬─────────┘
                         │                                          │
                    /Promote                                     git push
                         │                                          │
                         ▼                                          ▼
                ┌─────────────────────────────────────────────────────────────┐
                │                     forge-core module                       │
                │                                                             │
                │  skills/YourSkill/                                          │
                │      SKILL.md       ← canon (AI instructions)              │
                │      SKILL.yaml     ← sidecar (provider routing)           │
                └────────────────────────────┬────────────────────────────────┘
                                             │
                                        make install
                                             │
                     ┌───────────────┬───────┴───────┬───────────────┐
                     ▼               ▼               ▼               ▼
              .claude/skills/  .gemini/skills/  .codex/skills/  .opencode/skills/
```

Internal authors use `/Promote` to copy from their authoring environment (e.g., Obsidian vault) into the module. External contributors fork, make changes, and open a PR. Both paths converge at the module — the single source of truth. `make install` deploys to all providers.

## Getting Started

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-core.git
cd forge-core
make install    # deploy skills to all providers
make verify     # confirm deployment
make test       # validate conventions (runs validate-module from forge-lib)
make lint       # shellcheck all scripts
```

Prerequisites:
- Rust toolchain (for building [forge-lib](https://github.com/N4M3Z/forge-lib) binaries)
- `shellcheck` (`brew install shellcheck`) for linting
- At least one AI provider CLI (Claude Code, Gemini CLI, Codex, or OpenCode)

## Creating a Skill

Each skill lives in its own directory under `skills/` with two required files:

```
skills/YourSkill/
    SKILL.md        # Canon — provider-neutral AI instructions
    SKILL.yaml      # Sidecar — provider routing and metadata
```

### SKILL.md (canon)

Provider-neutral frontmatter + AI instructions in the body:

```yaml
---
name: YourSkill
description: "What this skill does. USE WHEN trigger keywords."
version: "1.0.0"
---

Your AI instructions here.
```

The `description` field drives skill discovery — providers match it against user requests. Use `USE WHEN` to list trigger keywords explicitly.

Provider-specific fields (e.g., `argument-hint` for Claude) go in the sidecar, not here.

### SKILL.yaml (sidecar)

Provider routing and deployment metadata. Consumed by build tooling, not by the AI directly:

```yaml
sources:
    - https://example.com/reference
```

Canon fields (`name`, `description`, `version`) live in SKILL.md only — never duplicate them here. See [Canon + Sidecar](ARCHITECTURE.md#canon--sidecar) for why.

### Companion Files

When SKILL.md needs to stay focused, split reference material into companion files loaded via `@`:

```markdown
@ClaudeSkill.md
```

The companion lives in the same directory. The `@` reference injects its content at load time. Use companions for domain-specific patterns, examples, or templates that would clutter the main instructions. Keep them in the skill root — no subdirectories.

### Deploy and Validate

```bash
make install    # deploy to providers
make verify     # confirm installed
make test       # check conventions
```

## Hook Authoring

Hooks and markdown serve different roles:

| | Hooks | Markdown (Build skills) |
|---|---|---|
| **When** | Every matching event, unconditionally | When AI loads the skill |
| **Purpose** | Enforce mandatory rules | Document all conventions |
| **Failure mode** | Block the action | Advisory only |

Use hooks wherever a convention can be automated. Validation logic lives in [forge-lib](https://github.com/N4M3Z/forge-lib) (`validate-module`, `validate-skill` binaries). Hook registration is platform-specific — each provider has its own mechanism for wiring hooks to events.

## Validation

`validate-module` runs five test suites:

| Suite | What it checks |
|-------|---------------|
| Module Structure | `module.yaml` exists with name/version/description, `plugin.json` valid |
| Agent Frontmatter | Agent files match roster, required fields present |
| Defaults Consistency | Config files are well-formed |
| Skill Integrity | SKILL.md + SKILL.yaml present, required fields, structure |
| Deploy Parity | Deployed files match source |

Run it:

```bash
make test                     # via Makefile
validate-module .             # directly
validate-module . --verbose   # detailed output
```

## Contributing via PR

External contributions land directly in the module:

1. Fork the repository
2. Create a branch for your change
3. Make your changes following the conventions above
4. Run `make test && make lint` to validate
5. Open a PR against `main`

After merge, a backward reference note is created in the maintainer's Obsidian vault linking to the PR. This keeps the vault reconstructible without adding process overhead to the PR workflow.

## Internal Authoring (Draft/Promote)

For vault-native development:

1. Author the skill in `Orchestration/Skills/` in your Obsidian vault
2. Iterate with the AI in the vault context (Obsidian-visible, Linter-managed)
3. When ready, run `/Promote` to copy to the target module (strips vault metadata, produces clean SKILL.md + SKILL.yaml)
4. The vault retains the working copy; the module gets the released version

To pull a module skill back into the vault for editing: `/Draft`.

## Conventions

### Structural Requirements

Skills should be structurally decomposed when complexity warrants it. Rather than enforcing a line count, the convention is:

- **Main skill** (SKILL.md): Entry point, high-level flow, gate checks
- **Companion files** (`@` references): Domain-specific reference material, examples, templates
- **Sidecar** (SKILL.yaml): Provider routing, never duplicates canon fields

If a skill's SKILL.md becomes difficult to follow as a single document, split it. See [Skill Directory Structure](ARCHITECTURE.md#skill-directory-structure) and [Naming Conventions](ARCHITECTURE.md#naming-conventions).

### Git

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope.

Types: `feat`, `fix`, `docs`
