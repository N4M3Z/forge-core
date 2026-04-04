# Gemini

Generate and maintain `GEMINI.md` for Gemini CLI compatibility.

## Generate

Run `gemini init` inside the module directory. This creates `GEMINI.md` with project instructions derived from the codebase.

```bash
gemini init
```

Gemini will not overwrite an existing `GEMINI.md`.

## Update

To regenerate after changes, rename the existing file first, then diff:

```bash
command mv GEMINI.md GEMINI.md.bak
gemini init
diff GEMINI.md.bak GEMINI.md
```

Review the diff. Keep manual additions from `.bak` that the generator missed. Remove the `.bak` when satisfied.

## Configuration

Gemini CLI uses `settings.json` for project config. The instruction filename is configurable:

```json
{
    "context": {
        "fileName": ["GEMINI.md", "AGENTS.md"]
    }
}
```

Supports `@./path.md` import syntax (same as Claude Code) for modular instructions.

## Agent Configuration

Gemini agents use TOML files in `.gemini/agents/`:

```toml
name = "reviewer"
display_name = "Code Reviewer"
description = "Reviews code for quality."
tools = ["read_file", "search"]

[prompts]
system_prompt = "You are a code reviewer."
```

## Skill Support

Gemini CLI follows the [Agent Skills](https://agentskills.io) standard. Skills live in `.gemini/skills/` or `.agents/skills/`, each with `SKILL.md`. Forge's `install-skills` binary handles deployment.

## Portability Patterns

Use `FORGE_MODULE_ROOT` as the primary env var with fallbacks:

```bash
MODULE_ROOT="${FORGE_MODULE_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(command cd "$(dirname "$0")/.." && pwd)}}"
```

In SKILL.md body bash snippets, do NOT use `${}` variable expansion — use hardcoded relative paths:

```bash
MODULE="Modules/<module-name>"
[ -d "$MODULE" ] || MODULE="."
```
