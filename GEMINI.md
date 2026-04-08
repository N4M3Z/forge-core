# GEMINI.md

## Project Overview

**forge-core** is a build system for AI instructions, treating prompts with the same rigor as software source code. It manages three primary artifact types that map to how AI agents (like Claude Code, Gemini CLI, and Codex) load instructions:

-   **Rules (`rules/`)**: Small, always-in-context behavioral instructions. Each file represents a single concern.
-   **Skills (`skills/`)**: Lazy-loaded capabilities defined by a `SKILL.md` (instructions) and `SKILL.yaml` (metadata sidecar).
-   **Agents (`agents/`)**: Markdown-defined personas and roles for delegation.

The project emphasizes **Provenance**, **Validation** (via `.mdschema`), and **Architecture Decision Records (ADRs)** to maintain a high-quality, auditable instruction set across multiple AI providers.

### Core Technologies
-   **Markdown**: The primary system language for all instructions.
-   **YAML Frontmatter**: Used for machine-readable metadata within markdown files.
-   **Python**: Used for ADR and schema validation scripts.
-   **Make**: Standardized build and deployment orchestration.
-   **forge-cli**: External dependency required for module validation and assembly.

---

## Building and Running

The project uses a `Makefile` to manage the lifecycle of AI instruction artifacts.

### Key Commands

-   **`make install`**: Assembles and deploys all rules, skills, and agents to provider-specific directories (`.claude/`, `.gemini/`, `.codex/`, `.opencode/`). This also activates git pre-commit hooks.
    -   `SCOPE=user make install`: Deploys to global user directories (e.g., `~/.claude/skills/`).
    -   `SCOPE=workspace make install`: Deploys to project-local directories.
-   **`make validate`**: Performs structural validation of the module, ensuring all files adhere to naming and schema conventions.
-   **`make test`**: Runs the full validation suite plus self-tests for the ADR validator.
-   **`make clean`**: Removes generated provider directories and build artifacts.

### ADR Validation
To validate a specific Architecture Decision Record:
```sh
scripts/validate-adr.py templates/forge-adr.json "docs/decisions/CORE-0001 Markdown as System Language.md"
```

---

## Development Conventions

### Artifact Structure

#### 1. Skills (`skills/SkillName/`)
-   **`SKILL.md` (Canon)**: Contains the AI-facing instructions. Must include YAML frontmatter with `name`, `version`, and `description` (using the `USE WHEN` trigger pattern).
-   **`SKILL.yaml` (Sidecar)**: Contains provider-specific metadata (e.g., `argument-hint` for Claude) and external `sources`.
-   **Naming**: Use `PascalCase` for multi-word skills (e.g., `BuildSkill`) and natural casing for single words (e.g., `Log`).

#### 2. Rules (`rules/`)
-   Concise, actionable prose in flat `.md` files.
-   Assembly strips optional frontmatter for a zero-token overhead deployment.
-   One file per behavior to simplify debugging.

#### 3. Agents (`agents/`)
-   Persona definitions in markdown format.
-   Names must be `PascalCase` and unique across the ecosystem.

### Architecture Decision Records (ADRs)
ADRs are stored in `docs/decisions/` and follow specific prefix sections:
-   **`CORE-`**: Markdown and scaffolding.
-   **`ARCH-`**: Ecosystem architecture.
-   **`PROV-`**: Manifest and provenance.
-   **`MVPR-`**: Prompt optimization.

Each section numbers independently (e.g., `CORE-0001`).

### General Practices
-   **Markdown First**: All documentation and instructions must be valid markdown, checked against sibling `.mdschema` files.
-   **Conventional Commits**: Use `type: description` format (e.g., `feat: add BuildPlugin skill`). Supported types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.
-   **Provenance**: Cite external sources using GFM reference links. These are extracted during build into `.prov.yaml` records.
-   **Separation of Concerns**: Keep AI instructions (Canon) separate from tool metadata (Sidecar).
