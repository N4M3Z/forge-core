# Forge ADR Pattern

Forge ADRs use [structured-madr][1] as the base template, extended with `x-forge-` fields for RACI accountability and provenance tracking ([CORE-0005][2], [CORE-0007][3]).

The default template is `templates/forge-adr.md`, validated by `templates/forge-adr.json`. Both are overridable via `$ADR_TEMPLATE` and `$ADR_SCHEMA`.

Templates use `${VARIABLE}` placeholders resolvable by `envsubst`, with `%%` comments for inline guidance ([CORE-0008][4]).

[1]: https://github.com/zircote/structured-madr
[2]: docs/decisions/CORE-0005 ADR Template Choice.md
[3]: docs/decisions/CORE-0007 Forge MADR Extensions.md
[4]: docs/decisions/CORE-0008 Variables in Markdown Instructions and Templates.md
