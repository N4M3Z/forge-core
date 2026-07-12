# DestructiveCommandGuard

[dcg][DCG] (Destructive Command Guard) blocks destructive shell commands before an
agent runs them. It is one binary whose installer wires the PreToolUse-style hook
across harnesses (Claude Code, Codex, Gemini, Cursor, and more): it reads the tool
payload on stdin and emits a deny verdict on a match. It is a *net, not a
boundary* — the Seatbelt/container sandbox is what stops a malicious command; dcg
catches the accidental ones most likely to lose work permanently.

## What it catches

Out of the box (the `core` and `system.disk` packs):

| Blocked                                | Why                                                     |
| -------------------------------------- | ------------------------------------------------------- |
| `rm -rf` outside cwd                   | Catastrophic data loss                                  |
| `git reset --hard`                     | Discards committed and staged work                      |
| `git restore <file>` (worktree)        | Overwrites uncommitted changes permanently              |
| `git checkout -- <files>`              | Discards uncommitted changes permanently                |
| Force-push to a protected branch       | Overwrites shared history                               |
| `git branch -D`                        | Force-delete branches (may lose unmerged commits)       |
| `dd` / `mkfs` on a device              | Wipes disks                                             |
| Redirect-truncate to a home/root path  | `> ~/file` destroys the file before writing             |

Optional packs cover containers, kubernetes, cloud, and databases; enable the ones
that match your tooling in the config.

## Workarounds when blocked

dcg cites the matched rule and the rationale, and offers the recovery path:

- `dcg explain "<command>"` — why it blocked, with safer alternatives.
- `dcg allowlist add <rule-id> --project` — exempt a rule in this repo (persistent).
- `dcg allow-once` — a one-shot code to run a single blocked command.

| Blocked                       | Workaround                                                          |
| ----------------------------- | ------------------------------------------------------------------ |
| `rm -rf` outside cwd          | `rm` specific files; scope `rm -r` inside cwd                       |
| `git reset --hard`            | `git stash` first, then a soft/mixed reset, apply selectively      |
| `git restore <file>`          | `git restore --staged` only (keeps the worktree); or `git stash`   |
| Force-push to main            | Merge via PR; never force-push protected branches                  |
| Redirect-truncate to ~/file   | Append (`>>`), back up first, or use a `/tmp/claude/` scratch path  |

## Configuration

dcg is config-driven under `~/.config/dcg/`:

- `config.toml` — enable packs (`[packs] enabled = [...]`); `core.*` is always on.
- `packs/*.yaml` — custom packs. The forge pack (`forge.yaml`) is the
  partner-extensible surface: add commands your team must never run by accident as
  `destructive_patterns` (name + fancy-regex + severity + explanation), then
  `dcg pack validate` the file.

Installed and configured by forge-provision (`scripts/install/dcg.sh` pins and
verifies the signed release; `scripts/configure/dcg.sh` deploys the config and
pack). The PreToolUse hook lives in the harness settings and dcg self-heals it.

## When not to disable

- **Never** disable to push a command that just got blocked — the block is usually
  catching a real mistake.
- **Never** disable in shared sessions or CI — the guardrail is part of the trust
  contract with the user.
- dcg is fail-open (a ~200 ms deadline; on a parse error or timeout it allows the
  command). It is the net; the sandbox is the boundary. Do not lean on it as a
  security control — lean on the sandbox.

[DCG]: https://github.com/Dicklesworthstone/destructive_command_guard
