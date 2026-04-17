Do not symlink plugins into the cache — Claude Code periodically wipes `~/.claude/plugins/cache/`.

Obsidian Linter auto-formats frontmatter between read and write, causing "file modified since read" errors with the Edit tool.

`ekctl` (EventKit CLI) and other data-gathering tools (slackdump, DiscordChatExporter.Cli, sqlite3, m365) are pre-approved in `sandbox.excludedCommands` in both `settings.json` and `settings.local.json`. macOS TCC permissions are separate and must also be granted for EventKit tools.

If the [safety-net][SAFETY] plugin is installed, the following commands are blocked from AI agents: `rm -rf` outside cwd, `git reset --hard`, `find -delete`, force-push to main, `git branch -D` (force-delete branches), `git checkout` with shell redirects parsed as positional args. For destructive ops, either hand the command back to the user to run in their own terminal, or use less-aggressive alternatives (`git stash`, `find -print | xargs rm`, `git switch` instead of `git checkout`).

[SAFETY]: https://github.com/kenryu42/claude-code-safety-net

Subagents spawned with `mode: 'auto'` cannot write to git submodule paths even with `bypassPermissions`. Symptom: agent reports completion but no files were created. Workaround: do the writes from the parent session, or accept the permission prompt manually when it surfaces.
