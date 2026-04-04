# Output Format

Use markdown with visual indicators that render cleanly in Claude Code's terminal. Group by status, lead with the verdict, make actionable items obvious.

## Dashboard Layout

```markdown
# PromptAnalysis: forge-core

**28 rules** scanned — 4 need attention, 24 clean

---

## Needs Attention

### AuthorInModules.md

> targets: all | refs: 0

- **[!] Targeting** — references ".claude/" but no `targets:` field
  - fix: add `targets: [claude]`
- [i] Provenance — no external sources cited

### NoHeredoc.md

> targets: all | refs: 0

- [i] Provenance — no external sources cited
- **[!] Redundancy** — PromptFoo: with 17% / without 17% = **REDUNDANT**
  - LLMLingua: `[======    ] 51%` compressible
  - fix: narrow targets or archive

---

## Clean

| Rule                    | Targets          | Refs | Notes              |
|-------------------------|------------------|------|--------------------|
| UseRTK.md               | claude, codex    | 0    |                    |
| ShellAliases.md         | claude, codex    | 0    |                    |
| MarkdownConventions.md  | all              | 0    |                    |
| GitConventions.md       | all              | 0    |                    |
| ...                     | ...              | ...  |                    |
```

## Indicators

Use these markers consistently:

- **[!]** bold = actionable finding with a fix available
- [i] plain = informational observation, no automatic fix
- **[x]** bold = error, must fix (stale reference, contradiction)

## Severity Rendering

Actionable findings use **bold** so they stand out at a glance. Info findings are plain. Errors use **bold** with `[x]`.

## Gauges

LLMLingua compression as an inline bar:
```
[======    ] 51% compressible
```

PromptFoo ablation as a comparison:
```
with: 50% / without: 17% = NEEDED (+33%)
with: 17% / without: 17% = REDUNDANT
```

## Batch Decision Flow

After displaying the dashboard, collect all actionable findings into one AskUserQuestion with multiSelect. Each option is one fix:

```
1. AuthorInModules.md — add targets: [claude]
2. NoHeredoc.md — narrow targets to [claude/haiku]
3. ContextualNaming.md — add targets: [claude]
```

For each accepted fix:

| Action          | What to do                                                   |
|-----------------|--------------------------------------------------------------|
| add targets     | Prepend `---\ntargets: [providers]\n---\n` to the rule file  |
| create variant  | Create qualifier directory + copy the rule as starting point |
| archive         | Move rule to an archive directory (never delete)             |

Report what was changed after applying.
