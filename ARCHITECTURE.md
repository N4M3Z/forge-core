# Forge Architecture

## What forge-core does

Skills for creating and validating **artifacts** — structured markdown units that get deployed to AI providers. Each artifact type maps to how the AI loads it:

- **Rules** — always in context. Small files, one concern each. The filename is the label you see when debugging.
- **Skills** — lazy loaded on invocation. Description always visible, full body loaded on demand.
- **Agents** — persona definitions for off-session delegation.

forge-core defines the conventions. [forge-cli](https://github.com/N4M3Z/forge-cli) enforces them — assembling artifacts for each provider, tracking provenance, and detecting drift.

### Skill Directory Structure

Each skill directory contains a required `SKILL.md` and optional companions. Subdirectories organize overlays (`user/`), model qualifiers (`claude-opus-4/`), and support files (`scripts/`, `Templates/`):

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
| [BuildPlugin](skills/BuildPlugin/SKILL.md)       | Plugins  | Create, validate, and publish Claude Code plugins               |

Utility skills handle operational concerns:

| Skill                                                              | What it covers                                                     |
|--------------------------------------------------------------------|--------------------------------------------------------------------|
| [ArchitectureDecision](skills/ArchitectureDecision/SKILL.md)       | Find, read, create, validate, and capture Architecture Decision Records |
| [VersionControl](skills/VersionControl/SKILL.md)                   | Git conventions, repo governance (GitHub rulesets, GitLab branches) |
| [MarkdownLint](skills/MarkdownLint/SKILL.md)                       | Formatting, backtick references, heading hierarchy                 |
| [MarkdownSchema](skills/MarkdownSchema/SKILL.md)                   | .mdschema creation, derivation, and validation                     |
| [SettingsMaintenance](skills/SettingsMaintenance/SKILL.md)          | AI tool settings audit — permissions, plugins, hooks               |
| [SystemCheck](skills/SystemCheck/SKILL.md)                          | Ecosystem staleness — binary freshness, version drift              |
| [RTK](skills/RTK/SKILL.md)                                         | Token-optimized CLI proxy setup and reference                      |
| [PublishPrompts](skills/PublishPrompts/SKILL.md)                    | Provenance tracking and sync for inherited rules, skills, agents   |
| [AdaptPrompts](skills/AdaptPrompts/SKILL.md)                       | Adapt generic rules for independent repos                          |
| [PromptAnalysis](skills/PromptAnalysis/SKILL.md)                   | Validate and minimize prompts — staleness, redundancy, ablation    |
| [HtmlPlayground](skills/HtmlPlayground/SKILL.md)                   | Generate single-file HTML demos comparing techniques               |

Skills that need to stay focused can offload reference material into **companion files** loaded via `@` references (e.g., `@ClaudeSkill.md`). Companions live in the skill root — see [Skill Directory Structure](#skill-directory-structure).

## Rule Assembly Pipeline

Rules can have **provider-specific variants** and **external provenance**. The install binary assembles them into clean deployed files with zero metadata overhead.

### Walkthrough: `AgentTeams.md` for Codex

**Step 1:** Source files

```
rules/
    AgentTeams.md                    ← base
    codex/AgentTeams.md              ← codex variant
    gemini/AgentTeams.md             ← gemini variant
```

**Base** (`rules/AgentTeams.md`):
```markdown
Council skills MUST use agent teams. Always TeamCreate
before spawning any agents.

Never use bare Agent calls for council specialists. [1]

[1]: https://docs.anthropic.com/en/docs/claude-code/sub-agents
```

**Codex variant** (`rules/codex/AgentTeams.md`):
```markdown
Codex CLI does not support agent teams. Council skills
use sequential Agent calls without `team_name`:

1. For each specialist, use Agent tool with `subagent_type`.
2. Present findings, ask user for input.
3. Spawn new Agent per specialist with prior transcript.
4. Repeat for all rounds, then synthesize.
```

No frontmatter, no `mode:` -- default is replace.

**Step 2:** install-rules resolves the variant

```
install-rules rules/ --provider codex --dst .codex/rules/

    resolve_variant("rules/", "AgentTeams.md", "codex", "")
        check rules/user/AgentTeams.md          → not found
        check rules/codex/AgentTeams.md         → FOUND ← wins
```

**Step 3:** Assembly and stripping

```ascii
Base body                          Variant body
┌────────────────────────────┐     ┌────────────────────────────┐
│ Council skills MUST use    │     │ Codex CLI does not support │
│ agent teams. Always        │     │ agent teams. Council skills│
│ TeamCreate before          │     │ use sequential Agent calls │
│ spawning any agents.       │     │ without `team_name`:       │
│                            │     │                            │
│ Never use bare Agent       │     │ 1. For each specialist ... │
│ calls for council          │     │ 2. Present findings ...    │
│ specialists. [1]           │     │ 3. Spawn new Agent ...     │
│                            │     │ 4. Repeat for all rounds   │
│ [1]: https://docs...       │     └────────────────────────────┘
└────────────────────────────┘               │
         │                          mode: replace (default)
         │ source_sha = sha256(     ─────────┘
         │   base body)                      │
         │ = a3f8c2...                       ▼
         │                         ┌────────────────────────────┐
         │                         │ Codex CLI does not support │
         │                         │ agent teams. Council skills│
         │                         │ use sequential Agent calls │
         │                         │ without `team_name`:       │
         │                         │                            │
         │                         │ 1. For each specialist ... │
         │                         │ 2. Present findings ...    │
         │                         │ 3. Spawn new Agent ...     │
         │                         │ 4. Repeat for all rounds   │
         │                         └────────────────────────────┘
         │                                   │
         │                          deployed_sha = sha256(
         │                            assembled output)
         │                          = b7d1e4...
         │                                   │
         ▼                                   ▼
```

The variant body replaces the base entirely. No frontmatter in the variant, so nothing to strip. The base's wiki-refs (`[1]`) are extracted for provenance but don't appear in the output (the variant doesn't contain them).

**Step 4:** Three files written to `.codex/rules/`

**Deployed file** (`AgentTeams.md`) -- clean, zero metadata:
```
Codex CLI does not support agent teams. Council skills
use sequential Agent calls without `team_name`:

1. For each specialist, use Agent tool with `subagent_type`.
2. Present findings, ask user for input.
3. Spawn new Agent per specialist with prior transcript.
4. Repeat for all rounds, then synthesize.
```

**Provenance** (`AgentTeams.prov.yaml`) -- W3C PROV, generated:
```yaml
entity:
    name: AgentTeams.md
    sha256: b7d1e4...

wasDerivedFrom:
    - uri: rules/AgentTeams.md
      sha256: a3f8c2...
    - uri: rules/codex/AgentTeams.md
      sha256: c9e2f1...

wasGeneratedBy:
    builder: install-rules@0.6.0
    time: "2026-03-15T01:00:00Z"
    provider: codex

sources:
    - https://docs.anthropic.com/en/docs/claude-code/sub-agents
```

**Manifest** (`.manifest`) -- integrity:
```yaml
forge-core:
    AgentTeams.md:
        digest:
            source: a3f8c2...
            deployed: b7d1e4...
```

`source` is the SHA of the base body (tracks git drift). `deployed` is the SHA of the assembled output on disk (tracks tampering). When no variant is used, both are equal.

**What happens for each provider**

```ascii
Source (rules/)                                        Deploy targets
┌──────────────────────────┐
│ AgentTeams.md     (base) │───┐
├──────────────────────────┤   │    ┌─────────────┐    .claude/rules/
│ codex/AgentTeams.md      │───┼───▶│ resolve     │───▶ AgentTeams.md  (base content)
├──────────────────────────┤   │    │ variant     │
│ gemini/AgentTeams.md     │───┘    │ strip + SHA │    .codex/rules/
└──────────────────────────┘        │ prov + mfst │───▶ AgentTeams.md  (codex variant)
                                    └─────────────┘
                                                       .gemini/rules/
                                                   ───▶ AgentTeams.md  (gemini variant)
```

| Provider | Variant resolved | Content deployed |
|----------|-----------------|------------------|
| claude   | none            | base             |
| codex    | `codex/`        | codex variant    |
| gemini   | `gemini/`       | gemini variant   |

### Resolution Precedence

Qualifier directories are named after providers or models from `defaults.yaml`. Resolution checks in order (first match wins):

```
rules/user/{file}                ← personal override (gitignored)
rules/{provider}/{model}/{file}  ← exact model (e.g., claude/opus4.5/)
rules/{provider}/{file}          ← provider (e.g., codex/)
rules/{file}                     ← base (fallback)
```

### Frontmatter Targets

Rules that apply to some providers but not others declare `targets:` in frontmatter. Stripped at deploy -- zero tokens in the deployed file.

```yaml
---
targets: [claude, codex]
---
Always prefix shell commands with `rtk`...
```

This rule deploys to Claude and Codex, skipped for Gemini. The `targets:` field also documents intent -- if qualifier directories are lost, frontmatter records which providers the rule was meant for.

See [ADR 0018](docs/decisions/CORE-0018 Qualifier Directories for Model Targeting.md).

### Variant Merge Modes

Variant files default to **replace** (swap entire base content). For partial overrides, declare `mode:` in variant frontmatter:

`replace` -- variant body replaces base entirely (default)
`append` -- variant body concatenated after base body
`prepend` -- variant body concatenated before base body

### Provenance

Source files cite external authorities using GFM reference links:

```markdown
Always parameterize SQL queries [1].

[1]: https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html
```

At deploy time, `[N]` markers and the `[N]:` reference block are stripped from the deployed file. The extracted URLs flow into the `.prov.yaml` `sources:` array. See [ADR 0017](docs/decisions/CORE-0017 GFM Reference Links for Prompt Provenance.md) and [ADR 0020](docs/decisions/CORE-0020 W3C PROV Provenance Records.md).

### Output Summary

Each deployed rule produces three artifacts:

| File | Purpose | Contents |
|------|---------|----------|
| `Rule.md` | Deployed instruction | Clean markdown, zero metadata |
| `Rule.prov.yaml` | Provenance record | W3C PROV: what was derived from what, by which builder, citing which sources |
| `.manifest` | Integrity | `digest: { source: sha, deployed: sha }` per module per file |

`source` SHA tracks git drift (did the source change since install?). `deployed` SHA tracks tampering (did the deployed file change since install?). See [ADR 0019](docs/decisions/CORE-0019 Dual SHA Manifest.md).

## Prompt Validation

The PromptProvenance skill validates rules, skills, and agents for targeting correctness, redundancy, and provenance quality. It runs in two modes: **scan** (static analysis) and **deep** (behavioral testing via PromptFoo ablation).

### Scan Mode (Static Analysis)

Scans all rules in a module and flags issues without calling any AI model:

```ascii
rules/*.md                           PromptProvenance scan
┌──────────────────────┐
│ UseRTK.md            │──┐
│ ShellAliases.md      │──┤          ┌─────────────────────┐
│ AgentTeams.md        │──┼─────────▶│ check provenance    │──▶ 0 refs: add sources
│ NoHeredoc.md         │──┤          │ check targets       │──▶ provider-specific: needs targets:
│ SanitizeData.md      │──┘          │ check conflicts     │──▶ scope overlap with rule X
│                      │             │ check staleness     │──▶ references deprecated model ID
│ codex/AgentTeams.md  │             │ estimate redundancy │──▶ likely redundant for Opus 4.6
│ gemini/AgentTeams.md │             └─────────────────────┘
└──────────────────────┘                      │
                                              ▼
                                        Scan Report
                                    ┌──────────────────┐
                                    │ 27 rules scanned │
                                    │ 23 OK            │
                                    │ 2 split needed   │
                                    │ 1 likely redundant│
                                    │ 1 missing sources │
                                    └──────────────────┘
```

| Check | Method | What it catches |
|-------|--------|-----------------|
| Missing provenance | No `[N]:` wiki-refs in source | Rules without external source citations |
| Missing targets | Provider-specific content without `targets:` | Rules that should be filtered per provider |
| Needs qualifier split | References provider-specific tools/APIs | Rules that need variant directories |
| Conflict detection | Scope overlap analysis (Arbiter-style) | Two rules that contradict each other |
| Staleness | Regex for deprecated model IDs, removed APIs | Rules referencing outdated content |
| Redundancy estimate | Model self-assessment (weak signal) | Rules the model already follows natively |

### Deep Mode (Behavioral Testing)

When scan flags a rule as "likely redundant," deep mode confirms via PromptFoo ablation. It generates test cases where the rule should matter, runs with/without the rule against each target model, and compares pass rates:

```ascii
NoHeredoc.md                    PromptFoo ablation
(flagged by scan)
                           ┌─────────────────────────┐
  system prompt            │ Test: "create a file     │    Opus 4.6
  WITH rule    ────────────│  with 3 lines"           │──▶ uses Write tool ✓
                           │                          │
  system prompt            │ Assert: must NOT use     │    Opus 4.6
  WITHOUT rule ────────────│  heredoc syntax          │──▶ uses Write tool ✓
                           └─────────────────────────┘
                                      │
                                      ▼
                           Both pass = rule is REDUNDANT
                           for Opus 4.6 (safe to skip)
```

Deep mode is optional, expensive (API calls per rule per model), and reserved for ambiguous cases. Scan mode handles the 90% case statically.

### Provenance Lifecycle

The full lifecycle from authoring to validation:

```ascii
Author                 Install                    Validate
──────                 ───────                    ────────

Write rule     ──▶    strip frontmatter   ──▶    scan for issues
add [1]: refs         strip refs                 check targeting
add targets:          resolve variant             check provenance
                      compute SHA                 estimate redundancy
                      gen .prov.yaml              flag conflicts
                      update .manifest            recommend splits
                           │                           │
                           ▼                           ▼
                      deployed .md              scan report
                      (token-clean)             (actionable findings)
```

See [CORE-0022](docs/decisions/CORE-0022 Prompt Minimalization.md).

## Prompt Inheritance

Derived repos inherit rules, skills, and agents from forge modules. Each installed file has a **provenance state** tracked via SHA manifest:

| State                | Meaning                                               | Sync behavior          |
|----------------------|-------------------------------------------------------|------------------------|
| **pristine**         | Digest `source` matches upstream, `deployed` matches disk | Safe to auto-update    |
| **adapted**          | Digest differs from upstream                          | Requires manual review |
| **local**            | Not from any upstream module                          | Not tracked            |
| **upstream updated** | Upstream source changed since last install            | Sync available         |

Install binaries write `.manifest` files with dual SHA digest maps. The `publish-prompts.sh` companion script reads these manifests and reports drift.

### Keeping files pristine

Adapted files are maintenance debt -- every upstream change needs manual review. Strategies to stay pristine:

- Use qualifier directories for provider-specific content instead of adapting the base
- Fix upstream rules to be universally correct instead of adapting downstream
- Split into companion files: keep upstream `SKILL.md` pristine, add a derived-specific companion with local extensions
- Rename complete rewrites to break false inheritance (own file, own name, not tracked against upstream)

See [ADR 0016](docs/decisions/CORE-0016 Manifest-Based Inheritance.md) for the full decision record.

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
- Skill directories use subdirectories for `user/` overlays, model qualifiers, and support files — companion `.md` files live at the root alongside `SKILL.md`
- Agent names are PascalCase, unique across all vaults
- `defaults.yaml` is the single source of truth for the skill roster
- Skills require structural decomposition (main skill + companion files) when complexity warrants it

## References

[1]: https://docs.anthropic.com/en/docs/claude-code/skills "Claude Code Skills"
[2]: https://docs.anthropic.com/en/docs/claude-code/sub-agents "Claude Code Sub-agents"
[3]: https://docs.anthropic.com/en/docs/claude-code/hooks "Claude Code Hooks"
[4]: skills/BuildModule/SKILL.md "Forge Module Convention"
