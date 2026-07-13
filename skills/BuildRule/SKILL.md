---
name: BuildRule
version: 0.1.0
description: "Create, validate, or place behavioral rules in forge modules. USE WHEN create rule, new rule, write rule, capture rule, add a rule, graduate a correction or convention to a rule, validate rule, rule conventions, where does this rule belong, or the user runs /Rule."
---

# BuildRule

Author, place, and validate the small always-in-context instruction files that steer every session. A rule is the durable form of a correction: when the user says "always do X" or "never do Y again", it becomes a rule, not a memory.

## Rule Conventions

### Shape

A rule is a single `.md` file in the owning module's `rules/` directory. One file, one behavior — when something goes wrong, the filename names the rule that caused it. The only valid subdirectories are locale (`rules/cs-CZ/`), harness and model qualifiers (`rules/claude/`, `rules/claude/claude-opus-4-6/`), and gitignored `user/` overrides; resolution precedence is in PROV-0005.

### Naming

PascalCase, scope + focus, self-explanatory in English: `PreferTrash`, `VerifyClaims`, `NoEmDash`. No spaces, hyphens, or opaque acronyms. The filename is the rule's identity in every error report.

### Frontmatter

Optional. When present: `name`, `version`, `description`, `targets` (harness filter), `mode` (`replace` | `append` | `prepend`, qualifier variants only). Assembly strips frontmatter at deploy — never put load-bearing content there.

### Body

Concise, actionable prose stating the current truth (PresentTense; no backstory). A wrong/right example pair beats three paragraphs of explanation. No headings needed; max depth 3 if used. Cite sources for factual claims (CiteSources).

**Every word costs tokens on every interaction** — rules are always in context. If the model already does it unprompted, the rule belongs in a model qualifier directory or nowhere (see OptimizeContext). If it needs more than ~20 lines, it is probably a skill, not a rule.

### Placement

Rules are authored in the owning module's `rules/`, never directly in `~/.claude/` (AuthorInModules — deployed files get overwritten on install). Route by subject: version-control behavior → the module owning VersionControl; vault conventions → forge-obsidian; no clear owner → forge-steering. Prefer folding a new constraint into an existing rule on the same subject over creating a near-duplicate file (LessIsMore).

## Create Workflow

1. **Distill the behavior** — one sentence stating what must (or must never) happen, generalized beyond the incident that prompted it. Include the why only when the rule is not self-evident.
2. **Find the owner** — `grep -l <topic> */rules/*.md` across modules; extend an existing rule if one covers the subject.
3. **Write the file** following the conventions above.
4. **Deploy** — `make install` from the module (or mirror the edit into the deployed `~/.claude/rules/` copy for immediate effect in the current session).
5. **Land it** — commit in the module repo per its VCS flow; rules ride normal PRs.

## Validate Workflow

- [ ] Single `.md` file in `rules/` (or a valid qualifier subdirectory)
- [ ] PascalCase filename naming the behavior
- [ ] One behavior; no bundled unrelated constraints
- [ ] Body is present-tense instruction, no narration of what changed
- [ ] Short enough to justify its permanent token cost
- [ ] Not a duplicate — no existing rule covers the same subject
- [ ] Factual claims carry sources

Report **COMPLIANT** or **NON-COMPLIANT** with specific fixes.
