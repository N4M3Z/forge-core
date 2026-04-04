---
name: ArchitectureDecisions
version: 0.1.0
description: "Find, read, create, validate, and capture Architecture Decision Records. USE WHEN ADR lookup, architecture decision, project context, decision history, create ADR, new ADR, validate ADR, capture ADRs, decisions directory."
---

# Architecture Decisions

Find, read, create, validate, and capture Architecture Decision Records (ADRs). ADRs document significant decisions with context, alternatives, and rationale. Rules enforce; ADRs explain the why.

@ADRTemplate.md

## Workflow Routing

| Workflow     | Trigger                                            | Section                                |
|--------------|----------------------------------------------------|----------------------------------------|
| **Find**     | "list ADRs", "show decisions", "what did we decide"  | [Find Workflow](#find-workflow)         |
| **Create**   | "create ADR", "new ADR", "write ADR"                 | [Create Workflow](#create-workflow)     |
| **Validate** | "validate ADR", "check ADR", "lint ADR"              | [Validate Workflow](#validate-workflow) |
| **Capture**  | Post-compaction prompt, "capture ADRs from session"  | [Capture Workflow](#capture-workflow)   |

## ADR Conventions

### Placement

| Scope              | Location                             | When to use                          |
|--------------------|--------------------------------------|--------------------------------------|
| Ecosystem-spanning | `docs/decisions/` at project root    | Decisions affecting multiple modules |
| Module-internal    | `docs/decisions/` within the module  | Decisions scoped to one module       |

The directory path is configurable via `adr.directory` in `defaults.yaml`.

### Filename Prefix

Read `adr.prefix` from config:
- `date` (default): `YYYY-MM-DD-kebab-title.md` — today's date at creation
- `number`: `NNNN-kebab-title.md` — next available four-digit number

Prefixes are per-scope. Root and module directories count independently.

### Status Values

| Status                      | Meaning                                      |
|-----------------------------|----------------------------------------------|
| `Proposed`                  | Under discussion, not yet decided            |
| `Accepted`                  | Decision in effect                           |
| `Deprecated`                | No longer recommended, not replaced          |
| `Superseded: by <filename>` | Replaced by a newer ADR — link the successor |

Never modify an Accepted ADR's decision text. To revise, create a new ADR and mark the old one Superseded.

---

## Find Workflow

1. Read `adr.directory` from config if available. Then search for ADR files in order:

    - Configured directory (e.g. `docs/decisions/`)
    - `doc/adr/`
    - `docs/adr/`
    - `**/adr/`

    Use Glob to find markdown files with numbered or dated prefixes. Exclude template files.

2. Present an index table:

    ```markdown
    | #    | Title                            | Status   | Date       |
    |------|----------------------------------|----------|------------|
    | 0001 | Adopt Architecture Decision Records | Accepted | 2026-03-02 |
    ```

    Extract title from the H1 heading, status and date from frontmatter.

3. When asked about a specific topic, search ADR titles and content for relevant keywords. Read and summarize matching ADRs with: Context, Decision, Consequences, Status.

---

## Create Workflow

1. Determine scope: ecosystem-spanning (root `docs/decisions/`) or module-internal? If the user hasn't specified, ask.

2. If `docs/decisions/` does not exist in the target location, scaffold it: create the directory and copy `.mdschema` from the config path (`adr.schema`).

3. Read `adr.prefix` from config. For `date` mode, use today's date. For `number` mode, scan existing ADRs and assign the next available number.

4. Gather content from the user or conversation context: title (short noun phrase), context (what prompted this?), options considered, decision (what was chosen and why?), consequences (optional tradeoffs).

5. Choose the template: use `adr.template` (short, default) for straightforward decisions, `adr.full_template` (full MADR 4.0) for complex multi-stakeholder decisions. If unclear, default to the short template.

6. Fill in frontmatter (`status`, `date`) and sections. Write to `docs/decisions/<prefix>-kebab-title.md`.

7. Set status to `Proposed` unless the decision is already confirmed — then set `Accepted`.

8. Run the Validate workflow on the new file.

---

## Validate Workflow

1. If a file path was provided, validate that file. Otherwise, ask which ADR to validate or validate the entire `docs/decisions/` directory.

2. Check schema compliance. If `mdschema` is available:

    ```bash
    mdschema check "docs/decisions/*.md" --schema docs/decisions/.mdschema
    ```

3. Check content rules:
    - Filename matches the configured prefix pattern
    - `status` is one of: Proposed, Accepted, Deprecated, Superseded
    - `date` is YYYY-MM-DD format
    - `## Context` is present and non-empty
    - `## Decision` is present and non-empty
    - If status is Superseded: the successor filename is referenced

4. Report COMPLIANT (all checks pass) or NON-COMPLIANT (list failures with fixes, offer to fix automatically).

---

## Capture Workflow

Triggered by the SessionStart(compact) hook or by the user asking to capture decisions from the current session.

1. Review the current conversation context for architectural decisions. Look for: technology choices, pattern adoptions, convention changes, structural refactors, trade-off evaluations with explicit reasoning.

2. If ContextKeeper MCP is available, query `search_archive` for additional session context that may have been compressed away.

3. For each identified decision, run the Create workflow. Set status to `Accepted` if the decision was confirmed during the session, `Proposed` if it was discussed but not finalized.

4. If no architectural decisions are found, report that and exit.

---

## Constraints

- Never modify an Accepted ADR's decision text — create a new ADR and mark old as Superseded
- `docs/decisions/` must contain `.mdschema` when it exists — scaffold it if missing
- Status must be set at creation — never leave it blank
- Prefix mode and directory are read from config, not hardcoded — respect overrides
- Always search multiple common locations before concluding no ADRs exist
- Include links to related ADRs when decisions are connected
