# SafetyNet

The [claude-code-safety-net][SAFETY] plugin is a Claude Code hook that blocks destructive commands before they execute. Community plugin by kenryu42. Catches the common mistakes most likely to lose work permanently.

## What it catches

| Blocked                                   | Why                                                          |
| ----------------------------------------- | ------------------------------------------------------------ |
| `rm -rf` outside cwd                      | Catastrophic data loss                                       |
| `git reset --hard`                        | Discards committed and staged work                           |
| `git checkout -- <files>`                 | Discards uncommitted changes permanently                     |
| `find -delete`                            | Fire-and-forget mass delete                                  |
| Force-push to main/master                 | Overwrites shared history                                    |
| `git branch -D`                           | Force-delete branches (may lose unmerged commits)            |
| `git checkout` with shell redirects       | Redirects parsed as positional args (silent data loss)       |

## Workarounds when blocked

| Blocked                             | Workaround                                                                                                |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `rm -rf` outside cwd                | `rm` specific files; `rm -r` scoped inside cwd; `find -print \| xargs rm -i` for controlled mass delete   |
| `git reset --hard`                  | `git stash` the work first, then `git reset` (soft/mixed), then apply selectively                         |
| `git checkout -- <files>`           | `git stash push [-u] -- <files>` — preserves changes in a recoverable stash; `git stash pop` restores     |
| `find -delete`                      | `find ... -print \| xargs rm -i` for review, or explicit `rm` per file                                    |
| Force-push to main                  | Merge via PR; never force-push protected branches                                                         |
| `git branch -D`                     | `git branch -d` for merged branches; hand unmerged deletes to the user                                    |
| `git checkout` with redirects       | Quote paths explicitly: `git checkout -- "file with spaces"`                                              |

## When blocked

1. Read the safety-net error — it cites the regex that matched and the rationale.
2. Map to a workaround above.
3. If no workaround fits, hand the command back to the user to run manually.
4. Do not retry the same blocked command with cosmetic variations.

## Configuration

Safety-net ships with three user-invocable commands:

- `/safety-net:set-custom-rules` — add user-specific blocks on top of the default ruleset.
- `/safety-net:verify-custom-rules` — inspect current custom rules and check they parse.
- `/safety-net:set-statusline` — toggle the statusline indicator showing the plugin is active.

Custom rules live in Claude Code settings; see the plugin's README for the schema.

## When not to disable

- **Never** disable to push a command that just got blocked. The block is usually catching a real mistake.
- **Never** disable in shared sessions or CI — the guardrail is part of the trust contract with the user.
- **Consider** disabling only in scoped, transient contexts (e.g. a throwaway sandbox) where you genuinely need the blocked operation and accept full responsibility.

## Sources

- [Plugin repo][SAFETY]

[SAFETY]: https://github.com/kenryu42/claude-code-safety-net
