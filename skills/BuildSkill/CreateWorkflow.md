## Step 1: Understand the request

Determine:
1. What does this skill do?
2. What should trigger it? (intent phrases for `USE WHEN`)
3. Does it wrap a CLI tool, or is it purely procedural?
4. Which module should it live in?

If the user hasn't specified, ask using AskUserQuestion.

## Step 2: Write the SKILL.md

Follow the structure from [SkillStructure.md](SkillStructure.md).

**Checklist while writing:**
- [ ] Frontmatter has `name:` and `description:` with `USE WHEN`
- [ ] Description is single-line, under 1024 characters
- [ ] Body starts with `# SkillName` heading
- [ ] Clear step-by-step instructions (numbered steps for sequential operations)
- [ ] If wrapping a CLI tool: usage examples, intent-to-flag mapping, output format (see [CliToolIntegration.md](CliToolIntegration.md))
- [ ] Constraints section with boundary conditions
- [ ] No unnecessary complexity — minimum needed for the task
- [ ] Skill listed in module's `defaults.yaml` under each target provider (see [MultiProviderRouting.md](MultiProviderRouting.md))
- [ ] If locale-specific (e.g., Czech tax): description mixes English action phrases ("record transaction", "validate balance") with backticked native terms (`účetní deník`, `bilance`). Avoid diacritic-stripped czenglish (`podvojne ucetnictvi`) — matches neither natural English nor natural Czech queries

## Step 3: Create the skill directory and file

```sh
mkdir -p skills/SkillName
```

Write the SKILL.md using the Write tool.

## Step 4: Register

For Claude Code: ensure the skill's parent directory is listed in `plugin.json` under `skills`.

For other providers: run `make install` from the module's Makefile.

## Step 5: Verify

1. Test invocation: does the description trigger correctly?
2. Review: does the procedure work end-to-end?
3. Dispatch the **SkillReviewer** agent on the new `SKILL.md` (and any companion files). It catches trigger weaknesses, czenglish descriptions, broken cross-references, body bloat, and convention drift that self-review misses. Apply confirmed fixes before declaring done.

## Step 6: Pressure test

Apply TDD to the skill itself — write a scenario where the skill should apply but might be rationalized away, then verify it holds.

1. **Write a pressure scenario** — describe a situation where someone would think "this skill doesn't apply here" but it actually does. Example for a debugging skill: "The fix seems obvious, I'll just change it."
2. **Test the trigger** — does the description match this scenario? Would the AI load this skill?
3. **Test the procedure** — does following the skill's steps produce the right outcome in this scenario?
4. **Tighten** — if the skill would be bypassed, improve the description's USE WHEN triggers or add entries to the Red Flags table.
