Do not symlink plugins into the cache — Claude Code periodically wipes `~/.claude/plugins/cache/`.

macOS TCC permissions are separate from Claude Code sandbox and permission settings: EventKit tools (`ekctl`) need their own TCC grant even when the command itself is allowed.

Subagents spawned with `mode: 'auto'` cannot write to git submodule paths even with `bypassPermissions`. Symptom: agent reports completion but no files were created. Workaround: do the writes from the parent session, or accept the permission prompt manually when it surfaces.

Homebrew's `pip3` on macOS enforces PEP 668 strictly — `pip3 install`, `pip3 install --user`, and `pip3 install --break-system-packages` all fail with "No virtual environment found." Use `uv venv <dir>` to create an isolated environment, then `uv pip install --python <dir>/bin/python <package>`. Don't keep retrying pip flags; the wrapper rejects all of them by design.
