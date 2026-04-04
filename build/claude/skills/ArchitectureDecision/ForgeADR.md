# Forge ADR Configuration

Extends the ArchitectureDecision skill with forge ecosystem integration.

## Config Mapping

Forge modules use `defaults.yaml` (overridable in `config.yaml`) to set ADR env vars:

| Env var        | Config key       | Default            |
|----------------|------------------|--------------------|
| `$ADR_PATH`    | `adr.directory`  | `docs/decisions/`  |
| `$ADR_PREFIX`  | `adr.prefix`     | `number`           |

Additional config keys:
- `adr.template` — path to MADR light template
- `adr.full_template` — path to full Nygard-style template
- `adr.schema` — path to `.mdschema` for ADR validation

@Template.md

## ContextKeeper Integration

In the Capture workflow, after reviewing conversation context: if ContextKeeper MCP is available, query `search_archive` for additional session context that may have been compressed away. This recovers architectural decisions from compacted conversation history.
