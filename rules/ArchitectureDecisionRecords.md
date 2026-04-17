Architecture Decision Records capture the why behind structural choices as markdown files in `docs/decisions/`. We use [structured-madr][MADR] with custom extensions for RACI accountability and provenance tracking (`templates/forge-adr.md`, validated by `templates/forge-adr.json`).

Required frontmatter: `title`, `description`, `type`, `category`, `tags`, `status`, `created`, `updated`, `author`, `project`, `responsible`, `accountable`, `consulted`, `informed`, `upstream`. Status values are lowercase: `proposed`, `accepted`, `deprecated`, `superseded`.

Before proposing architectural changes or challenging existing patterns, check the project's ADRs via the ArchitectureDecision skill. Do not contradict an accepted ADR without explicitly acknowledging it and proposing a superseding record.

After writing an ADR with body-level links to other ADRs, backfill those references into the `related:` frontmatter field. Body links are for human navigation; `related:` is for machine-readable cross-referencing.

When modifying code in an area governed by an ADR, re-read the ADR and verify it still describes reality. Drift between ADR claims and actual behavior is a docs bug — fix the ADR (or the code) before layering new behavior on top.

[MADR]: https://github.com/zircote/structured-madr
