# Codex

Generate and maintain `AGENTS.md` for Codex CLI compatibility.

## Generate

Run `codex init` inside the module directory. This creates `AGENTS.md` with project instructions derived from the codebase.

```bash
codex init
```

Codex will not overwrite an existing `AGENTS.md`.

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

Codex has no standalone markdown skills format. `forge install` assembles each skill file into TOML (`name`, `description`, `developer_instructions`) under `build/codex/skills/<SkillName>/` and deploys it to the `.codex` target directory.

## Constraints

- Do not assume Codex supports Claude hook schema or config keys.
- Treat Codex compatibility as skill-first unless documented runtime hooks exist.
- `AGENTS.md` max combined size: 32 KiB (configurable via `project_doc_max_bytes`).
