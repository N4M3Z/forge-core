---
name: OptimizeContext
version: 0.1.0
description: "Evaluate the currently loaded memory, rules, and skills against the running model's baseline and offload instructions the model already follows unprompted into model qualifier directories. USE WHEN optimize context, trim my context, simplify memory, trim loaded rules, model already knows this, is this rule still needed, rules the model no longer needs, what can we remove now that the model is smarter, offload rules, context bloat. For static provenance or staleness scans and ablation testing use PromptAnalysis instead."
---

# OptimizeContext

Models improve under the instruction set: guidance written for one model version becomes dead weight for the next. This skill makes the running model evaluate its own loaded context item by item, then routes instructions it no longer needs into qualifier directories ([PROV-0005][PROV5]) so weaker or older models keep them. Rules are the priority target because they load into every session ([Claude Code memory docs][CCDOCS]); skill bodies cost nothing until invoked.

## Workflow

### Step 1: Establish the baseline

Record the running model ID from the session environment (for example `claude-fable-5`). Strip harness decorations such as effort markers (`[1m]`); they are not part of the model name, and qualifier directories are named with the exact model ID, so it must be precise. That model is the evaluation baseline. Offload destinations are named for the models that still need an instruction, usually the previous flagship, never for the current model.

The session baseline applies only to content the session model executes: rules, memory, skill bodies. Agents are evaluated against their own pinned model (the `model:` tier in agent frontmatter or `defaults.yaml`), never the session model. An agent pinned to a fast tier still needs scaffolding the session model does not.

### Step 2: Inventory the loaded context

Collect what is actually in context this session:

- User memory: `~/.claude/CLAUDE.md` plus its `@` imports
- User rules: `~/.claude/rules/*.md`
- Project memory and rules: `CLAUDE.md`, `.claude/rules/`
- Skill roster: every loaded `description:` field; bodies only when already invoked
- Auto-memory `MEMORY.md`: conventions found here are relocation candidates to module rules, not offload candidates

Map every deployed file to its source module before proposing changes (search the modules' `rules/` and `skills/` trees for the same filename). Deployed `.claude/` trees are install targets; edits land in the source module only.

### Step 3: Self-assess each item

The test is behavioral, not cognitive: "If this instruction were absent, would my default output already satisfy it?" Understanding an instruction is not the same as complying with it unprompted. Probe honestly: draft the unprompted behavior, compare it against the instruction, then score confidence.

Separate the two instruction kinds first:

| Kind       | Example                                                         | Eligible for offload?                               |
| ---------- | --------------------------------------------------------------- | --------------------------------------------------- |
| Capability | "read the file before editing", workarounds for a failure mode | Yes, when the failure mode is gone                  |
| Preference | naming conventions, formatting, locale, security policy         | Never: preferences cannot be inferred, only slimmed |

### Step 4: Classify

| Verdict  | Criteria                                                     | Action                                                                              |
| -------- | ------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| Offload  | Compensates for a weakness the current model no longer shows | Copy full text into the qualifier directory of every model still in use, drop base |
| Slim     | Preference still binding, explanatory scaffolding redundant  | Base keeps the one-line form, full version moves to the qualifier directory         |
| Keep     | Behavior would drift without it                              | None                                                                                 |
| Escalate | Confidence is not high                                       | PromptAnalysis deep mode (ablation) before any action                                |

Self-assessment is a weak signal ([MVPR-0002][MVPR2]): only high-confidence verdicts become proposals.

### Step 5: Confirm each move

Present every proposal individually via AskUserQuestion with options Offload / Slim / Keep. Offer outright deletion only when the content is wrong or stale, and label it as deletion.

### Step 6: Apply and redeploy

Apply approved edits in the source module, run `forge assemble` and confirm each offloaded file resolves into `build/<provider>/` before any base file is dropped, then run `make install` and verify the deployed tree with `forge drift build/claude ~/.claude`.

## Offload Mechanics

Per [PROV-0005][PROV5], the same filename in a qualifier directory overrides the base, with resolution precedence `user/` > `provider/model/` > `provider/` > base:

```
rules/
    VerboseGuard.md                            # base, slimmed or removed
    claude/claude-opus-4-6/VerboseGuard.md     # full text for the model that still needs it
```

Valid qualifier names are the provider names plus the exact model IDs listed in the forge models config (`config/models.yaml`), not entries in the module's `defaults.yaml`. Assembler support currently lags the canon: provider-level qualifiers work for rules and agents, model-level directories are not yet resolved, and skill directories accept no qualifiers at all. Offloaded model-level files are therefore canon-compliant parking that activates when the assembler catches up; for skills, slim the body in place or use `targets:` frontmatter instead. A file the assembler does not resolve disappears from deployment silently, which is why Step 6 verifies `build/<provider>/` before dropping a base.

## Red Flags

| Thought                                | Reality                                                                        |
| -------------------------------------- | ------------------------------------------------------------------------------ |
| "I obviously know this, remove it"     | Knowing is not complying. Test the unprompted behavior, not the comprehension. |
| "This preference is self-evident"      | Preferences are user choices, not capabilities. Slim them, never remove them.  |
| "Just delete the redundant rule"       | Deletion loses it for weaker models and other providers. Offload first.        |
| "Edit ~/.claude/rules directly"        | Deployed files are install targets. Edit the source module and reinstall.      |
| "Batch all removals into one approval" | One proposal, one question. Bulk approval hides individual regressions.        |
| "Trim the agent, the session model is smart" | Agents run on their pinned model. Evaluate against their `model:` tier, not the session baseline. |

## Constraints

- The evaluator is the model that benefits from a smaller context: counter the bias with behavioral probes and a high-confidence bar, never "seems obvious"
- Preference and policy rules are exempt from capability-based removal
- Medium or low confidence escalates to PromptAnalysis ablation; no action on weak signals
- Every content move preserves the full text somewhere (qualifier directory or `user/`)
- No base file is dropped until `forge assemble` proves the replacement resolves into `build/<provider>/`
- Edits land in source modules only; deployed trees are regenerated by `make install`

[PROV5]: ../../docs/decisions/PROV-0005%20Qualifier%20Directories%20for%20Model%20Targeting.md
[MVPR2]: ../../docs/decisions/MVPR-0002%20Prompt%20Minimalization%20Metrics.md
[CCDOCS]: https://code.claude.com/docs/en/memory
