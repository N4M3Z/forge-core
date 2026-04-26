Forge assembles and deploys module content to AI provider directories. Key behaviors to know:

Assembly deploys only `.md` files. Non-markdown files (Python scripts, shell scripts, YAML sidecars) in skill directories are silently dropped. Ship executables in `bin/` at the plugin root instead.

`forge install` deploys rules, skills, and agents, not hooks. Wire hooks manually into `~/.claude/settings.json` using absolute paths. Read the module's `hooks/hooks.json` for the full hook list and replace `${CLAUDE_PLUGIN_ROOT}` with the absolute path to your clone.

`--force` overwrites user-modified deployed files but does not re-assemble from source. Clear the build cache (`rm -rf build/`) before reinstalling if source changed since last assembly.

`--target ~` deploys to user scope (`~/.claude/`, `~/.codex/`, etc.). The flag sets the base directory for provider directories. `--target ~/.claude` is wrong — it nests `~/.claude/.claude/`.

In CI, install forge via the composite action: `uses: N4M3Z/forge-cli/.github/actions/setup-forge@main`. Supports version pinning (`version: v0.3.0`), caching, and platform detection.

`build/` is transient — `forge assemble` wipes it on every run. `dist/` is preserved — release artifacts and anything that must survive subsequent `forge install` calls go there. Don't put release tarballs in `build/`; subsequent install will silently destroy them.
