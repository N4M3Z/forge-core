A rule is a single `.md` file in `rules/`. The only valid subdirectories are locale directories (`rules/cs-CZ/`), harness and model qualifier directories (`rules/claude/`, `rules/claude/claude-opus-4-6/`), and gitignored `user/` overrides; see [PROV-0005](../docs/decisions/PROV-0005 Qualifier Directories for Model Targeting.md) for resolution precedence.

Frontmatter is optional. When present, it can carry `name`, `version`, `description`, `targets` (harness filter), and `mode` (`replace` | `append` | `prepend`) on qualifier variants. Assembly strips frontmatter before deployment.

Body is the instruction: concise, actionable prose. No headings required. Max depth 3 if headings are used.

Rules are always loaded into the AI context for every session ([Claude Code docs][CCDOCS]). Keep them short; every word costs tokens on every interaction.

[CCDOCS]: https://code.claude.com/docs/en/memory
