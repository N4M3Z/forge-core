# Codex

Generate and maintain `AGENTS.md` for Codex CLI compatibility.

## Generate

Run `codex init` inside the module directory. This creates `AGENTS.md` with project instructions derived from the codebase.

```bash
codex init
```

Codex will not overwrite an existing `AGENTS.md`.

## Update

To regenerate after changes, rename the existing file first, then diff:

```bash
command mv AGENTS.md AGENTS.md.bak
codex init
diff AGENTS.md.bak AGENTS.md
```

Review the diff. Keep manual additions from `.bak` that the generator missed. Remove the `.bak` when satisfied.

## Agent Configuration

Codex agents use TOML in `~/.codex/config.toml` or `.codex/config.toml`:

```toml
[agents.default]
model = "o4-mini"
developer_instructions = "Follow project conventions."

[agents.worker]
model = "o4-mini"
sandbox_mode = "full"
```

Built-in roles: `default`, `worker`, `explorer`. Custom roles define `description`, `model`, `model_reasoning_effort`, `sandbox_mode`, `developer_instructions`.

## Skill Compatibility

Codex has no standalone skills format — instructions are embedded in `AGENTS.md` or agent config. Forge skills deploy as content within `AGENTS.md` via the Codex adapter (`Adapters/codex/install.sh`).

## Constraints

- Do not assume Codex supports Claude hook schema or config keys.
- Treat Codex compatibility as skill-first unless documented runtime hooks exist.
- `AGENTS.md` max combined size: 32 KiB (configurable via `project_doc_max_bytes`).
