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

**First pass — scan for user-correction signals.** Re-read the conversation specifically looking for: user messages containing "no", "don't", "actually", "wait", "stop", "that's wrong"; follow-up questions that reveal you missed something ("did you X?", "is it still Y?"); user edits or rewrites of your output; requests that imply a prior step should have been done differently. These are the highest-value learnings — they encode behaviors the user actively wants changed. Surface them first.

**Second pass — walk the scan checklist below.** Walk through each category and list concrete findings before filtering.

### Scan Checklist

1. **Corrections made** — wrong assumptions that were fixed, approaches rejected by the user, things that didn't work the first time
2. **Tool behaviors learned** — CLI flags, API quirks, platform constraints, output format surprises, command interactions (e.g., one command cleaning another's output)
3. **Packaging and deployment** — build pipelines, release workflows, distribution patterns, CI/CD discoveries
4. **Cross-tool interactions** — when tool A's output feeds tool B, ordering dependencies, cleanup side effects
5. **Patterns discovered** — reusable conventions, architectural decisions, workflow improvements
6. **Process improvements** — better ways to approach tasks discovered during work

For each finding, apply the reusability test: will this come up again in a different session? If no, skip it. If uncertain, include it: a skipped learning is lost, an extra proposal can be rejected.

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

## Source vs Deployed; Local vs Upstream

LearnFrom always edits source files in the module root (`rules/`, `skills/`, `agents/`). Never edit deployed copies under `.claude/`, `.codex/`, `.gemini/`, or `.opencode/` — those are `forge install` outputs that get overwritten on every sync.

Start with the source artifact relevant to the current workload, then check its provenance record (`.provenance/<file>.yaml` sidecar). If `resolvedDependencies` lists an upstream module (forge-core, forge-dev, etc.), the artifact is inherited content. Propose the change upstream; the local copy refreshes via `forge install` after the upstream merges. Edit the local copy directly only when the change is genuinely repo-specific (project-only convention, local override).

Skipping this check creates drift: a local edit to inherited content silently shadows future upstream improvements, and a local edit to a deployed copy is overwritten on the next sync.

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
- Edit source artifacts in the module root, never deployed copies under `.claude/`, `.codex/`, `.gemini/`, or `.opencode/`
- For inherited artifacts (provenance sidecar lists an upstream module), propose the change upstream first; touch the local copy only for repo-specific overrides
- A learning shorter than ~3 sentences belongs in an existing file as an appended paragraph
- Keep rules concise (max 120 words per section per the rules `.mdschema`)
- New rules follow the `.mdschema` in `rules/` if present
- Prefer over-proposing to under-proposing: a skipped learning is permanently lost, an extra proposal costs one "Skip" click
- Session-specific fixes are not rules, but tool behaviors and packaging patterns often are
- Validate against the target directory's `.mdschema` before writing
