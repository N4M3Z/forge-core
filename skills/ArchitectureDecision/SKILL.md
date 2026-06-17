---
name: ArchitectureDecision
version: 0.3.0
description: "Find, read, create, validate, and capture Architecture Decision Records. USE WHEN ADR lookup, architecture decision, project context, decision history, create ADR, new ADR, validate ADR, capture ADRs, decisions directory, or editing any ADR file."
paths:
    - "docs/decisions/*.md"
argument-hint: "[topic to search | 'list' | 'create: <title>' | 'validate' | 'capture']"
---

# Architecture Decisions

Find, read, create, validate, and capture Architecture Decision Records (ADRs). ADRs document significant decisions with context, alternatives, and rationale. Rules enforce; ADRs explain the why.

## Requirements

ADRs live in `docs/decisions/`. We use [structured-madr][MADR] with custom extensions for RACI accountability and provenance tracking (`templates/forge-adr.md`, validated by `templates/forge-adr.json`).

Required frontmatter: `title`, `description`, `type`, `category`, `tags`, `status`, `created`, `updated`, `author`, `project`, `responsible`, `accountable`, `consulted`, `informed`, `upstream`. Status values are lowercase: `proposed`, `accepted`, `deprecated`, `superseded`.

Before proposing architectural changes or challenging existing patterns, check the project's ADRs via this skill. Do not contradict an accepted ADR without explicitly acknowledging it and proposing a superseding record.

After writing an ADR with body-level links to other ADRs, backfill those references into the `related:` frontmatter field. Body links are for human navigation; `related:` is for machine-readable cross-referencing.

When modifying code in an area governed by an ADR, re-read the ADR and verify it still describes reality. Drift between ADR claims and actual behavior is a docs bug — fix the ADR (or the code) before layering new behavior on top.

[MADR]: https://github.com/zircote/structured-madr

@user/ForgeADR.md

@TemplateReference.md

@SchemaValidation.md

@user/ContextKeeper.md

## ADR Conventions

### Placement

| Scope              | Location                          | When to use                          |
| ------------------ | --------------------------------- | ------------------------------------ |
| Ecosystem-spanning | `$ADR_DIRECTORY` at project root  | Decisions affecting multiple modules |
| Module-internal    | `$ADR_DIRECTORY` within a module  | Decisions scoped to one module       |

### Status Values

| Status       | Meaning                                      |
| ------------ | -------------------------------------------- |
| `proposed`   | Under discussion, not yet decided            |
| `accepted`   | Decision in effect                           |
| `deprecated` | No longer recommended, not replaced          |
| `superseded` | Replaced by a newer ADR — link the successor |

Never modify an accepted ADR's decision text. To revise, create a new ADR and mark the old one superseded.

---

## Find Workflow

1. Search `$ADR_DIRECTORY` (default `docs/decisions/`). If not found, search fallbacks:

    - `doc/adr/`
    - `docs/adr/`
    - `**/adr/`

    Use Glob to find markdown files with numbered or dated prefixes. Exclude template files.

2. Present an index table:

    ```markdown
    | #    | Title                               | Status   | Date       |
    | ---- | ----------------------------------- | -------- | ---------- |
    | 0001 | Adopt Architecture Decision Records | accepted | 2026-03-02 |
    ```

3. When asked about a specific topic, search ADR titles and content for relevant keywords. Read and summarize matching ADRs with: Context, Decision, Consequences, Status.

---

## Create Workflow

1. Determine scope: ecosystem-spanning (root `$ADR_DIRECTORY`) or module-internal? If the user hasn't specified, ask.

2. If the ADR directory does not exist, scaffold it: create the directory and copy `$ADR_MDSCHEMA` if one exists in the project's templates.

3. Scan existing ADRs and assign the next available number.

4. Gather content from the user or conversation context: title (short noun phrase), context (what prompted this?), options considered, decision (what was chosen and why?), consequences (optional tradeoffs).

5. Check for overlap first. Read every existing ADR in the target directory (titles AND bodies, not just filenames). For each existing ADR, evaluate the relationship:
    - **Subset**: already covered — tell the user which ADR covers it. Do not create.
    - **Extension**: adds a new dimension — suggest amending the existing ADR.
    - **Contradiction**: reverses an existing decision — create with `accepted`, mark old `superseded`.
    - **Complementary**: genuinely different ground — proceed, add cross-references.

6. Use the `$ADR_TEMPLATE` (default `templates/forge-adr.md`). Fill in all frontmatter fields and body sections. Write to the ADR directory.

7. Set status to `proposed` unless the decision is already confirmed — then set `accepted`.

8. Run the Validate workflow on the new file.

---

## Validate Workflow

1. If a file path was provided, validate that file. Otherwise, ask which ADR to validate or validate the entire ADR directory.

2. Run frontmatter schema validation against `$ADR_SCHEMA` (default `templates/forge-adr.json`). Use the first available tool:

    a. `structured-madr` local checkout at `~/Data/Developer/zircote/structured-madr`:
    ```sh
    INPUT_PATH=$ADR_DIRECTORY INPUT_SCHEMA=$ADR_SCHEMA npm run validate --prefix ~/Data/Developer/zircote/structured-madr
    ```

    b. `check-jsonschema`:
    ```sh
    check-jsonschema --schemafile $ADR_SCHEMA $ADR_DIRECTORY/*.md
    ```

3. Check structural compliance if `$ADR_MDSCHEMA` exists in the ADR directory.

4. Check content rules:
    - Filename matches `$ADR_PREFIX` pattern (number or date)
    - All required frontmatter fields present (title, description, type, category, tags, status, created, updated, author, project)
    - `status` is one of: proposed, accepted, deprecated, superseded
    - `created` and `updated` are YYYY-MM-DD format
    - `## Context and Problem Statement` is present and non-empty
    - `## Decision Outcome` or `## Decision` is present and non-empty
    - If status is superseded: the successor filename is referenced

5. Report COMPLIANT (all checks pass) or NON-COMPLIANT (list failures with fixes, offer to fix automatically).

---

## Capture Workflow

Triggered post-compaction or by the user asking to capture decisions from the current session.

1. Review the current conversation context for architectural decisions. Look for: technology choices, pattern adoptions, convention changes, structural refactors, trade-off evaluations with explicit reasoning.

2. For each identified decision, run the Create workflow. Set status to `accepted` if the decision was confirmed during the session, `proposed` if it was discussed but not finalized.

3. If no architectural decisions are found, report that and exit.

---

## Constraints

- `$ADR_DIRECTORY` must contain `$ADR_MDSCHEMA` when it exists — scaffold it if missing
- Status must be set at creation — never leave it blank
- Always search multiple common locations before concluding no ADRs exist
- Include links to related ADRs when decisions are connected
- An ADR records the decision and its rationale, not implementation status. No transient or current-state prose ("currently", "we just enabled it on N repos", "verified on this repo", session counts, dates of execution). State the decision in the timeless present. Session status, verification results, and what-was-done-today belong in journals, commit messages, or the backlog — never the ADR.

## Sources

- <https://adr.github.io/>
- <https://adr.github.io/madr/>
