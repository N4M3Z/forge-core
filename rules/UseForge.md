Forge assembles and deploys module content to AI provider directories. Key behaviors to know:

A skill directory deploys its whole tree: `SKILL.md` is assembled (frontmatter stripped, provider transforms applied), and every other file is copied verbatim with its extension and subdirectory structure preserved. Ship a text helper inside the skill and call it at runtime via `${CLAUDE_SKILL_DIR}/...`. Non-UTF-8 binary files are skipped with a warning, and the executable bit is not preserved yet, so invoke a deployed script through its interpreter (`uv run helper`), not as a bare `./helper`. Compiled binaries still belong in `bin/` at the plugin root.

`forge install` deploys rules, skills, and agents, not hooks. Wire hooks manually into `~/.claude/settings.json` using absolute paths. Read the module's `hooks/hooks.json` for the full hook list and replace `${CLAUDE_PLUGIN_ROOT}` with the absolute path to your clone.

`forge install` re-assembles from source on every run; add `--force` to also overwrite user-modified deployed files.

`--target ~` deploys to user scope (`~/.claude/`, `~/.codex/`, etc.). The flag sets the base directory for provider directories. `--target ~/.claude` is wrong — it nests `~/.claude/.claude/`.

In CI, install forge via the composite action: `uses: N4M3Z/forge-cli/.github/actions/setup-forge@main`. Supports version pinning (`version: v0.3.0`), caching, and platform detection.

`build/` is transient — `forge assemble` wipes it on every run. `dist/` is preserved — release artifacts and anything that must survive subsequent `forge install` calls go there. Don't put release tarballs in `build/`; subsequent install will silently destroy them.
