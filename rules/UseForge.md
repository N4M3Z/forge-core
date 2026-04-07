Forge assembles and deploys module content to AI provider directories. Key behaviors to know:

Assembly deploys only `.md` files. Non-markdown files (Python scripts, shell scripts, YAML sidecars) in skill directories are silently dropped. Ship executables in `bin/` at the plugin root instead.

`--force` overwrites user-modified deployed files but does not re-assemble from source. Clear the build cache (`rm -rf build/`) before reinstalling if source changed since last assembly.

`--target ~` deploys to user scope (`~/.claude/`, `~/.codex/`, etc.). The flag sets the base directory for provider directories. `--target ~/.claude` is wrong — it nests `~/.claude/.claude/`.

In CI, install forge via the composite action: `uses: N4M3Z/forge-cli/.github/actions/setup-forge@main`. Supports version pinning (`version: v0.3.0`), caching, and platform detection.
