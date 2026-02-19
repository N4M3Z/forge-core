---
name: BuildSkill
description: "Create and validate skills for forge modules. USE WHEN create skill, new skill, write skill, validate skill, check skill, skill structure, skill conventions."
---

# BuildSkill

Create and validate skills following forge conventions. Skills are markdown files (SKILL.md) with YAML frontmatter that teach AI coding tools new capabilities.

## Workflow Routing

| Workflow | Trigger | Section |
|----------|---------|---------|
| **Create** | "create a skill", "new skill", "write a skill" | [Create Workflow](#create-workflow) |
| **Validate** | "validate skill", "check skill structure" | [Validate Workflow](#validate-workflow) |

## Skill Conventions

### SKILL.md Structure

Every skill is a single `SKILL.md` file with YAML frontmatter:

```yaml
---
name: SkillName
description: What it does. USE WHEN trigger phrase one, trigger phrase two, or trigger phrase three.
---
```

**Frontmatter rules:**
- `name:` -- PascalCase for multi-word (e.g., `VaultOperations`, `DailyPlan`), natural casing for single words (e.g., `Log`, `Draft`, `Init`)
- `description:` -- single line, under 1024 characters, includes `USE WHEN` with intent-based triggers joined by commas/OR
- Optional: `argument-hint:` for skills invoked with `/SkillName <args>` (e.g., `"[natural language description]"`)
- Optional: `version:` for versioned skills
- No separate `triggers:` or `workflows:` arrays in YAML

### Body Structure

```markdown
# SkillName

Brief description of what the skill does.

## Instructions (or ## Usage)

Step-by-step procedure. Use numbered steps for sequential operations.

### Step 1: Description
[What to do]

### Step 2: Description
[What to do]

## Constraints

- Boundary conditions and rules
- What NOT to do
```

**For skills with multiple workflows:** Use `## Workflow Routing` table in the body linking to sections within the same file. Keep everything in one SKILL.md unless it exceeds ~200 lines.

### Where Skills Live

| Location | Purpose |
|----------|---------|
| `skills/SkillName/` | Module skills (shipped with a module) |
| User vault workspace | Personal/experimental skills |

All parent directories must be registered in `plugin.json` under the `skills` array for Claude Code discovery. Other providers (Gemini, Codex, OpenCode) use `make install` from the module's Makefile.

### Naming Conventions

| Component | Convention | Examples |
|-----------|-----------|----------|
| Skill directory | PascalCase | `BuildSkill`, `DailyPlan`, `VaultOperations` |
| Single-word skill | Natural case | `Log`, `Draft`, `Init`, `Update` |
| SKILL.md | Always `SKILL.md` | -- |

### CLI Tool Integration

When a skill wraps a CLI tool (Rust binary, shell script), include:

1. **Tool location** -- where the binary lives
2. **Usage examples** -- concrete `bash` blocks showing invocation
3. **Intent-to-flag mapping** -- table translating natural language to CLI flags
4. **Output format** -- what the tool returns (JSONL, plain text, etc.)

### Canon + Sidecar Pattern

Module skills use two files side by side:

| File | Purpose | Managed by |
|------|---------|------------|
| `SKILL.md` | **Canon** -- frontmatter (`name:`, `description:`) + skill body | Claude / AI |
| `SKILL.yaml` | **Sidecar** -- Obsidian metadata (`title:`, `aliases:`, `tags:`, etc.) | Obsidian Linter |

**Why separate files?** Obsidian's Linter reformats frontmatter on save -- it adds `title:`, reorders keys, and may strip unrecognized fields like `name:`. Separating prevents cross-contamination.

### Multi-Provider Routing

Module skills that deploy to multiple providers (Claude, Gemini, Codex) must declare provider support in SKILL.yaml:

```yaml
providers:
  claude:
    enabled: true
  gemini:
    enabled: true
  codex:
    enabled: true
```

`install-skills` reads this block to selectively install skills per runtime. Skills using Claude-only features (TeamCreate, agent teams) should note runtime differences.

---

## Create Workflow

### Step 1: Understand the request

Determine:
1. What does this skill do?
2. What should trigger it? (intent phrases for `USE WHEN`)
3. Does it wrap a CLI tool, or is it purely procedural?
4. Which module should it live in?

If the user hasn't specified, ask using AskUserQuestion.

### Step 2: Write the SKILL.md

Follow the structure from [Skill Conventions](#skill-conventions) above.

**Checklist while writing:**
- [ ] Frontmatter has `name:` and `description:` with `USE WHEN`
- [ ] Description is single-line, under 1024 characters
- [ ] Body starts with `# SkillName` heading
- [ ] Clear step-by-step instructions (numbered steps for sequential operations)
- [ ] If wrapping a CLI tool: usage examples, intent-to-flag mapping, output format
- [ ] Constraints section with boundary conditions
- [ ] No unnecessary complexity -- minimum needed for the task
- [ ] If module skill: SKILL.yaml sidecar with `providers:` block

### Step 3: Create the skill directory and file

```bash
mkdir -p skills/SkillName
```

Write the SKILL.md using the Write tool.

### Step 4: Register

For Claude Code: ensure the skill's parent directory is listed in `plugin.json` under `skills`.

For other providers: run `make install` from the module's Makefile.

### Step 5: Verify

1. Test invocation: does the description trigger correctly?
2. Review: does the procedure work end-to-end?

---

## Validate Workflow

### Step 1: Read the target skill

Read the SKILL.md file.

### Step 2: Check frontmatter

- [ ] `name:` present and uses correct casing
- [ ] `description:` is single-line with `USE WHEN` clause
- [ ] `description:` is under 1024 characters
- [ ] No deprecated fields (`triggers:`, `workflows:` arrays)
- [ ] Optional fields (`argument-hint:`, `version:`) are correctly formatted

### Step 3: Check body structure

- [ ] Starts with `# SkillName` heading (matches `name:` frontmatter)
- [ ] Has clear instructions (numbered steps, usage section, or workflow routing)
- [ ] If multiple workflows: `## Workflow Routing` table present
- [ ] Constraints or rules section for boundary conditions
- [ ] No unnecessary sections or boilerplate

### Step 4: Check CLI tool integration (if applicable)

- [ ] Tool path is documented
- [ ] Usage examples with `bash` blocks
- [ ] Intent-to-flag mapping table (if tool has flags)
- [ ] Output format described

### Step 5: Report

**COMPLIANT** -- all checks pass.

**NON-COMPLIANT** -- list failures with specific fixes. Offer to fix automatically.

---

## Constraints

- Every skill MUST have `name:` and `description:` in frontmatter
- Description MUST include `USE WHEN` trigger phrases
- PascalCase for multi-word skill names, natural case for single words
- Skill directory name must match the `name:` field
- Prefer one SKILL.md per skill -- split only when exceeding ~200 lines
