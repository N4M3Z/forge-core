A skill is a directory under `skills/` containing `SKILL.md` as the entrypoint ([Claude Code docs][CCDOCS]).

`SKILL.md` carries YAML frontmatter (`name`, `description`, `version`, `sources`, and optionally `argument-hint`, `allowed-tools`, `model`, `effort`, `context`, `hooks`, `paths`, `shell`) plus the workflow body. Companion files (templates, examples, reference material) live alongside. Skills are lazy-loaded: `SKILL.md` is only injected into context when the user invokes the skill or the AI matches the description. Companion files are loaded on demand when the AI decides it needs them during execution.

## Forge additions beyond the native spec

| File          | Purpose                                        |
| ------------- | ---------------------------------------------- |
| `user/`       | Qualifier directory, flattened at assembly     |
| `@` includes  | Companion file references, resolved by forge    |

**`@` includes vs plain references**: use `@File.md` only for companions that should be auto-injected alongside SKILL.md on every invocation. For optional or variant companions (e.g. a multi-mode skill where only one mode is loaded per run), use plain filename references like `` `File.md` `` and let the AI load on demand. Over-use of `@` wastes tokens on unused companions.

## SKILL.md frontmatter

```yaml
---
name: SkillName
version: 0.1.0
description: What it does. USE WHEN trigger phrase one, trigger phrase two, or trigger phrase three.
sources:
    - https://upstream.example/docs
---
```

**Frontmatter rules:**
- `name:` — PascalCase for multi-word (`VaultOperations`, `DailyPlan`), natural casing for single words (`Log`, `Draft`, `Init`)
- `version:` — semantic version (required for module skills, optional for personal/vault skills)
- `description:` — single line, under 1024 characters, includes `USE WHEN` with intent-based triggers joined by commas/OR
- `sources:` — list of upstream documentation URLs the skill references (optional but recommended for module skills)
- Optional: `argument-hint:` for skills invoked with `/SkillName <args>` (e.g., `"[natural language description]"`)
- No separate `triggers:` or `workflows:` arrays in YAML

## Body structure

```markdown
# SkillName

Brief description of what the skill does.

## Instructions (or ## Usage)

Step-by-step procedure. Use plain numbered lists for sequential operations.

1. First action
2. Second action
3. Third action

## Constraints

- Boundary conditions and rules
- What NOT to do
```

**Instruction format**: Use plain numbered lists (1, 2, 3) — not labeled steps (`### Step 1:`, `### Phase 2:`, `### Step M1:`). Headings within Instructions are for separating modes or major sections, not for individual steps.

**For skills with multiple workflows:** use a `## Workflow Routing` table pointing at companion files. Keep SKILL.md focused on flow and routing, not static data. Extract reference material (schema templates, configuration examples, lookup tables) into companion files.

## Where skills live

| Location             | Purpose                               |
| -------------------- | ------------------------------------- |
| `skills/SkillName/`  | Module skills (shipped with a module) |
| User vault workspace | Personal/experimental skills          |

All parent directories must be registered in `plugin.json` under the `skills` array for Claude Code discovery. Other providers (Gemini, Codex, OpenCode) use `make install` from the module's Makefile.

## Naming conventions

| Component         | Convention        | Examples                                      |
| ----------------- | ----------------- | --------------------------------------------- |
| Skill directory   | PascalCase        | `BuildSkill`, `DailyPlan`, `VaultOperations`  |
| Single-word skill | Natural case      | `Log`, `Draft`, `Init`, `Update`              |
| SKILL.md          | Always `SKILL.md` | —                                             |

**Naming around variants**: when a skill could plausibly spawn siblings (e.g. `StyleCzech` may want `Fantasy`, `Scifi`, `Noir`), don't bake the variant into the skill name. Name the skill for its stable scope and push variants into companion files (`Fantasy.md`, `Scifi.md`). Prefer `StyleCzech` with `Fantasy.md` over `StyleCzechFantasy`. Apply this only when variants are plausible — a truly single-purpose skill stays named for its purpose.

[CCDOCS]: https://code.claude.com/docs/en/skills
