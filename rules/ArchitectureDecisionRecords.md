Architecture Decision Records capture the why behind structural choices as markdown files in `docs/decisions/`. We use [structured-madr][MADR] with custom extensions for RACI accountability and provenance tracking (`templates/forge-adr.md`, validated by `templates/forge-adr.json`).

Required frontmatter: `title`, `description`, `type`, `category`, `tags`, `status`, `created`, `updated`, `author`, `project`. Status values are lowercase: `proposed`, `accepted`, `deprecated`, `superseded`.

Before proposing architectural changes or challenging existing patterns, check the project's ADRs via the ArchitectureDecision skill. Do not contradict an accepted ADR without explicitly acknowledging it and proposing a superseding record.

[MADR]: https://github.com/zircote/structured-madr
