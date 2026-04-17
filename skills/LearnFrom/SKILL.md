---
name: LearnFrom
description: "Extract session learnings and apply them as updates to rules, skills, and agents. USE WHEN session produced reusable patterns, corrections, or conventions worth capturing."
version: 0.1.0
---

# LearnFrom

Extract reusable learnings from the current session and apply them as updates to rules, skills, and agents in the current repo.

## Workflow Routing

| Workflow     | Trigger                                          | Section                          |
| ------------ | ------------------------------------------------ | -------------------------------- |
| **Analyze**  | "learn from this session", "extract learnings"   | [Analyze](#analyze-the-session)  |
| **Targeted** | "add a rule for X", "update the agent to note Y" | [Apply Changes](#apply-changes)  |

## Analyze the Session

Review the current conversation and identify:

1. **Patterns discovered** — reusable conventions, architectural decisions, workflow improvements
2. **Corrections made** — wrong assumptions that were fixed, pitfalls encountered
3. **Tool behaviors learned** — CLI flags, API quirks, platform constraints
4. **Process improvements** — better ways to do things discovered during work

For each item, apply the reusability test: will I encounter this again? If no, skip it.

## Scan Existing Artifacts FIRST

Before drafting any proposal, list every file in `rules/`, `skills/`, and `agents/` of the target module. For each candidate learning, search by topic for an existing artifact that already touches the same area. The default outcome is a one-line edit to an existing file, NOT a new file.

Concrete signals you should be editing not creating:
- Topic overlap: existing rule covers the same domain (git, bash, markdown, ADRs)
- Adjacent guidance: existing skill mentions the same tool or workflow
- Sibling concept: existing rule covers the inverse or a related case

Only create a new file when the learning is genuinely orthogonal to everything that exists. If you find yourself writing a rule shorter than ~3 sentences, it almost certainly belongs as a paragraph in an existing file.

Determine the target artifact. The categorization decision matters — rules cost tokens every session; skills cost tokens only when invoked.

| Learning type              | Target           | Example                                      |
| -------------------------- | ---------------- | -------------------------------------------- |
| Always-relevant constraint | `rules/`         | "every text file ends with newline"          |
| Task-specific guidance     | `skills/*/SKILL.md` with `paths:` | "shell scripting pitfalls — auto-trigger on `**/*.sh`" |
| Skill workflow improvement | `skills/*/`      | "add note about tool limitation"             |
| Agent instruction update   | `agents/`        | "add guidance about deployment scope"        |
| Existing file refinement   | edit in place     | "add RACI to required frontmatter list"      |

If the guidance only matters when working on certain files (shell scripts, Python, Markdown), make it a skill with `paths:` frontmatter so it auto-triggers on relevant file edits — don't put it in `rules/` where it loads on every session regardless of relevance.

## Draft Proposals

For each identified learning, draft a concrete proposal in this priority order:

1. **Append to existing rule** — one paragraph added to an in-topic file
2. **Append to existing skill body** — for skill-scoped guidance
3. **Edit existing agent instructions** — for agent-specific behavior
4. **New rule or skill** — only when no existing artifact fits

Show the existing-file scan result alongside each proposal so the user can see what was considered and rejected.

Rules must fire on a concrete trigger. Abstract principles ("be careful with X") don't change behavior; concrete signals do ("when you're about to write Y, check Z"). Iterate the wording with the user — first drafts are usually too abstract OR too tied to one specific case. Filename should match the final framing — rename if the concept shifts during iteration.

## Interactive Review

Present proposals in batches via AskUserQuestion (4 questions max per call).

For each proposal, show the target file and proposed change with a `preview` field carrying the literal content that would be written. Options: "Capture", "Adjust", "Skip".

For "Adjust": ask what to change, then re-present.

After the first batch, dig deeper before declaring done. Most sessions have 2-3 obvious learnings and several non-obvious ones surfaced only by re-scanning corrections, pushback, and stuck moments. Ask yourself "what else did the user have to correct?" before stopping.

## Apply Changes

For each confirmed proposal:

- **New rules**: write to `rules/` using the Write tool
- **Updates**: use the Edit tool on the target file
- **New skills/agents**: write to `skills/` or `agents/` using the Write tool

After writing, verify the file exists and has correct content.

## Summary

List what was captured: rules created or updated, skills updated, agents updated, items skipped.

## Constraints

- Scan existing `rules/`, `skills/`, and `agents/` BEFORE drafting — a new file is the last resort, not the first instinct
- A learning shorter than ~3 sentences belongs in an existing file as an appended paragraph
- Keep rules concise (max 120 words per section per the rules `.mdschema`)
- New rules follow the `.mdschema` in `rules/` if present
- Apply the reusability filter strictly — session-specific fixes are not rules
- Validate against the target directory's `.mdschema` before writing
