# Forge Architecture

## Problem

[forge-core](https://github.com/N4M3Z/forge-core) is a development platform for your own AI ecosystem. The skills in this repository help AI coding tools create and validate **artifacts** that follow your conventions.

An **artifact** is any structured unit that gets deployed to AI providers: a skill [1], an agent [2], a hook [3], or a module [4]. Each artifact type has its own associated building and validation skills that covers its conventions. The package also ships utility skills like RTK that solve common development problems directly.

### Skill Directory Structure

Each skill directory is flat — no nested subdirectories:

```
skills/BuildSkill/
    SKILL.md            # Canon — AI instructions (required)
    SKILL.yaml          # Sidecar — provider routing, metadata (required)
    ClaudeSkill.md      # Companion — reference material loaded via @
```

| File | Role | When to add |
|------|------|-------------|
| `SKILL.md` | Entry point. Frontmatter (`name`, `description`, `version`) + instructions | Always |
| `SKILL.yaml` | Provider routing, deployment metadata, sources | Always |
| Companion `.md` | Reference material, examples, domain-specific patterns | When SKILL.md needs to stay focused |

Companion files are loaded via `@` references in SKILL.md:

```markdown
@ClaudeSkill.md
```

This injects the companion's content at load time. Use companions to keep the main skill focused on flow and routing while offloading detailed reference material. Context files live in the skill root, never in subdirectories.

## Data Flow

### Idea to Artifact

```ascii
Authoring environment       forge-core module           Provider directories
┌───────────────┐           ┌──────────────────┐        ┌──────────────────┐
│               │           │                  │        │ .claude/skills/  │
│ Draft/edit    │──promote─▶│ skills/          │─make──▶│ .gemini/skills/  │
│ artifact      │           │   SKILL.md       │install │ .codex/skills/   │
│               │◀──draft───│   SKILL.yaml     │        │ .opencode/skills/│
│               │           │                  │        │                  │
└───────────────┘           └──────────────────┘        └──────────────────┘
     author                      source of truth              consumers
```

Artifacts are authored in a local environment, promoted to the module, and subsequently deployed to provider directories via `make install` to provide functionality at runtime. Authoring can happen directly in the module or via an external tool (e.g., Obsidian with [forge-obsidian](https://github.com/N4M3Z/forge-obsidian) using the `/Draft` and `/Promote` workflows).

### External Collaboration

```ascii
Contributor              Module                       Maintainer
┌──────────────┐         ┌──────────────────┐        ┌──────────────────┐
│ Fork + PR    │───PR───▶│ Review + Merge   │──note─▶│ Backward ref     │
└──────────────┘         └──────────────────┘        └──────────────────┘
```

External contributions land directly in the module via pull request (GitHub, GitLab, or any git repository remote). After merge, the maintainer should create a backward reference note linking to the PR.

## Build Skills

Providers discover skills by matching the `description` field against user requests — only frontmatter is loaded at session start, with full instructions pulled in on activation. This makes the `description` field (and its `USE WHEN` keywords) the primary routing mechanism.

Each Build skill targets one artifact type:

| Skill                                            | Artifact | What it covers                                                  |
|--------------------------------------------------|----------|-----------------------------------------------------------------|
| [BuildSkill](skills/BuildSkill/SKILL.md)         | Skills   | SKILL.md structure, frontmatter, SKILL.yaml sidecar, conventions |
| [BuildAgent](skills/BuildAgent/SKILL.md)         | Agents   | Agent markdown, frontmatter fields, deployment across providers |
| [BuildModule](skills/BuildModule/SKILL.md)       | Modules  | Directory layout, config convention, three-layer architecture   |
| [BuildHook](skills/BuildHook/SKILL.md)           | Hooks    | Hook registration, event handling, platform-specific wiring     |

Utility skills handle operational concerns:

| Skill                                                    | What it covers                                                     |
|----------------------------------------------------------|--------------------------------------------------------------------|
| [VersionControl](skills/VersionControl/SKILL.md)         | Git conventions, repo governance (GitHub rulesets, GitLab branches) |
| [MarkdownLint](skills/MarkdownLint/SKILL.md)             | Formatting, backtick references, heading hierarchy                 |
| [MarkdownSchema](skills/MarkdownSchema/SKILL.md)         | .mdschema creation, derivation, and validation                     |
| [SettingsMaintenance](skills/SettingsMaintenance/SKILL.md) | AI tool settings audit — permissions, plugins, hooks               |
| [SystemCheck](skills/SystemCheck/SKILL.md)               | Ecosystem staleness — binary freshness, version drift              |
| [RTK](skills/RTK/SKILL.md)                               | Token-optimized CLI proxy setup and reference                      |

Skills that need to stay focused can offload reference material into **companion files** loaded via `@` references (e.g., `@ClaudeSkill.md`). Companions live in the skill root — see [Skill Directory Structure](#skill-directory-structure).

## Separation of Concerns

Artifacts separate into canon and sidecar:

| | Canon | Sidecar |
|---|---|---|
| **Files** | `SKILL.md`, agent `.md` | `SKILL.yaml`, agent sidecar |
| **Contains** | AI-consumed content | Provider/platform metadata |
| **Consumer** | AI providers | Build tooling, Obsidian |

Two independent justifications:

- **Noise reduction** — provider metadata is unnecessary tokens for AI consumers
- **Separation of concerns** — each file has one owner, one consumer, one change cadence

This is a design principle, not an accommodation for any tool's behavior.

## Deploying artifacts

During `make install`, `install-skills` merges sidecar fields into canon for providers that need them. For Claude and Codex, sidecar fields are appended to the SKILL.md frontmatter — canon fields always take precedence:

```ascii
SKILL.md (canon)                  SKILL.yaml (sidecar)
┌─────────────────────┐           ┌─────────────────────────────┐
│ ---                 │           │ claude:                     │
│ name: BuildSkill    │           │   argument-hint: "[task]"   │
│ description: "..."  │           │                             │
│ version: "1.0.0"    │           │ sources:                    │
│ ---                 │           │   - https://code.claude.com │
│                     │           └─────────────────────────────┘
│ (AI instructions)   │                       │
└─────────────────────┘                       │
          │                                   │
          └──────────┐  ┌────────────────────┘
                     ▼  ▼
              install-skills
              (merge_claude_fields)
                     │
            ┌────────┴────────┐
            │ Canon fields    │  name, description, version
            │ kept as-is      │  (sidecar cannot override)
            │                 │
            │ Sidecar fields  │  argument-hint appended
            │ appended        │  (only if not already present)
            └────────┬────────┘
                     │
                     ▼
        .claude/skills/BuildSkill/SKILL.md
        ┌─────────────────────────────┐
        │ ---                         │
        │ name: BuildSkill            │  ← from canon
        │ description: "..."          │  ← from canon
        │ version: "1.0.0"            │  ← from canon
        │ argument-hint: "[task]"     │  ← from sidecar
        │ ---                         │
        │                             │
        │ (AI instructions)           │
        └─────────────────────────────┘
```

All providers use the same SKILL.md format. Claude and Codex deploy via file copy; Gemini installs via its own CLI (`gemini skills install`). The sidecar fields are merged at install time — the deployed artifact is self-contained.

## Conventions

- **Skill directories**: PascalCase (`BuildSkill`, `BuildAgent`)
- **Agent names**: PascalCase, unique across all vaults (`CouncilDeveloper`, `SecurityArchitect`)
- **Skill files**: `SKILL.md` + `SKILL.yaml` (uppercase, always this exact name)
- **Companion files**: PascalCase with descriptive suffix reflecting role (`ClaudeSkill.md`, `ClaudeAgent.md`, `CodexProvider.md`, `LinuxPlatform.md`)

## Enforcement

Rules and conventions are enforced at two levels:

- **Hooks** enforce mandatory rules at runtime (validation hooks block violations before they land). Use hooks wherever possible.
- **Markdown** (Build skills) documents all conventions so they can be followed manually or by any AI provider, even without hooks installed.

Both exist. Hooks are preferred for anything that can be automated. Markdown covers everything, including what hooks enforce.

## Invariants

- Every skill directory contains both `SKILL.md` (canon) and `SKILL.yaml` (sidecar)
- `SKILL.md` frontmatter contains only provider-neutral fields: `name`, `description`, `version`. Provider-specific fields (e.g., `argument-hint` for Claude) belong in the sidecar
- `SKILL.yaml` never duplicates fields from `SKILL.md`
- Skill directories are flat — companion files live in the root, no subdirectories
- Agent names are PascalCase, unique across all vaults
- `defaults.yaml` is the single source of truth for the skill roster
- Skills require structural decomposition (main skill + companion files) when complexity warrants it

## References

[1]: https://docs.anthropic.com/en/docs/claude-code/skills "Claude Code Skills"
[2]: https://docs.anthropic.com/en/docs/claude-code/sub-agents "Claude Code Sub-agents"
[3]: https://docs.anthropic.com/en/docs/claude-code/hooks "Claude Code Hooks"
[4]: skills/BuildModule/SKILL.md "Forge Module Convention"
