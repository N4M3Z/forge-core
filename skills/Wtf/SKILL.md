---
name: Wtf
description: "Reactive correction and root-cause fix. USE WHEN something went wrong, user is frustrated, demands a correction, says wtf, what the hell, why did you, that's wrong, this is broken, no not that, stop. Executes the immediate fix, then hunts the upstream artifact that caused it and creates a corrective change."
version: 0.1.0
---

# Wtf

Fix first, then find and fix what caused it. Two phases, no pause between them.

## Phase 1: Immediate Fix

The user is frustrated, possibly confused. Do not assume they know the exact fix, and do not blindly execute a vague correction.

1. **Brief investigation** (under 30 seconds): re-read the last few exchanges, identify what went wrong and the likely cause. One sentence of context, no lengthy analysis.
2. **Offer correction options** via AskUserQuestion: present 2-3 concrete fixes based on what you found. Each option should describe the specific change, not abstract categories. Include "I'll explain what happened first" as a fallback option.
3. **Execute** the chosen fix. No debate, no "are you sure" follow-up. If the user typed a clear correction ("no, do X instead"), skip the AskUserQuestion and execute directly.

Confirm the fix in one sentence, then proceed directly to Phase 2.

## Phase 2: Root-Cause Search

The wrong behavior came from somewhere. Find the artifact that taught it, permitted it, or failed to prevent it.

### Narrowing heuristic

Use the mistake type to focus the search:

| Mistake type                          | Start looking at                                      |
| ------------------------------------- | ----------------------------------------------------- |
| Did something completely unexpected   | Hooks (may silently inject context), conflicting rules, agent definition with surprising defaults |
| Blanketly ignored explicit instructions | Session compaction dropped context; a rule contradicted the instruction; a skill workflow overrode the user's approach |
| Ignored explicit instruction          | Re-read the user's exact words; check if a rule or skill overrode them |
| Wrong file location, path, or format  | Rules about paths, naming, directory conventions       |
| Wrong tone, phrasing, or prose style  | Rules about writing, memory about user preferences     |
| Wrong tool, command, or flag          | Skills, settings, CLAUDE.md                            |
| Repeated past mistake                 | Memory (stale entry reinforcing the wrong pattern)     |
| Wrong default or assumption           | Agent definitions, CLAUDE.md, code defaults            |
| Overstepped scope or permission       | Settings, rules about confirmation, agent constraints  |

### Search order

Walk these in order, stop at the first hit that explains the behavior:

1. **Rules** (`~/.claude/rules/`, project `.claude/rules/`) — missing rule that would have prevented this, or existing rule with wrong guidance
2. **Memory** (`~/.claude/projects/*/memory/`) — stale or incorrect memory entry that informed a bad decision
3. **Agents** (`~/.claude/agents/`, project `.claude/agents/`) — agent definition with wrong instructions, missing constraints, or bad defaults
4. **Skills** (`~/.claude/skills/`) — skill body that gave bad instructions or missed a case
5. **Settings** (`~/.claude/settings.json`, `.claude/settings.json`) — wrong permission, missing config
6. **Hooks** (`settings.json` hooks, module `hooks/`) — a PreToolUse or PostToolUse hook silently injecting or blocking context. Check `hookSpecificOutput.additionalContext` for invisible context injection.
7. **CLAUDE.md** (project or user) — missing or misleading instruction
8. **Current context** — information available in the conversation that was ignored, misread, or not acted on (user messages, tool output, prior findings)
9. **Code** — implementation bug, wrong default, missing guard

For each candidate artifact, state what it says (or fails to say) and how that led to the wrong behavior. Present findings inline, not as a separate report.

### When the root cause is "nothing"

If no artifact exists that covers this case, that itself is the finding. Propose whether a new rule is warranted based on severity: a one-off annoyance does not need a rule; a mistake that would repeat in any similar session does.

## Phase 3: Corrective Change

Based on the root cause:

| Root cause                        | Action                                                     |
| --------------------------------- | ---------------------------------------------------------- |
| Missing rule                      | Create the rule in the owning module's `rules/` directory  |
| Wrong rule                        | Edit it in the source module, not the deployed copy        |
| Stale memory                      | Update or delete the memory entry                          |
| Wrong agent                       | Fix the agent definition                                   |
| Wrong skill                       | Fix the skill body                                         |
| Wrong setting                     | Fix the setting, explain why                               |
| Missing instruction in CLAUDE.md  | Add it                                                     |
| Ignored context                   | Save a feedback memory so it persists across sessions      |
| Code bug                          | Fix the code                                               |

### Calibrating the response

Not every correction deserves the same weight:

- **First occurrence, low stakes**: feedback memory is enough. The memory persists across sessions and guides future behavior without adding a permanent rule.
- **Second occurrence, or high stakes** (data loss, security, wrong external action): a rule is warranted. Write it in the owning module's `rules/` directory.
- **Pattern across sessions**: a rule plus a skill update if the skill's workflow permitted the mistake.
- **Structural gap** (no artifact type covers this case): propose a new skill or agent, but only if the gap is real. Most gaps are just missing rules.

Stage the corrective change. If the change is in a git-tracked module, offer to commit and PR. If it's a deployed-only file (`~/.claude/rules/` without a source module), note that the user should move it to the owning module.

## Constraints

- Never skip Phase 2. The user invoked this skill because the same class of mistake should not happen again. A fix without a corrective change is half the job.
- The corrective change describes current behavior, not the history of the mistake (per StartFresh).
- Read the artifact before editing. The root-cause search produces a hypothesis; verify it by reading the actual file before modifying.
- One corrective change per invocation. If the search surfaces multiple issues, fix the one that caused this specific mistake. File the rest as observations, not edits.
