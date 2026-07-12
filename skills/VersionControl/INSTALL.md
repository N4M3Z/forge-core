# Safety Net

> Create the safety-net config file so the hook can block AI-initiated commits containing PII, deprecated identifiers, or other user-defined patterns.

I want you to set up the safety-net pre-commit hook for me. Execute all the steps below autonomously.

## OBJECTIVE

Create `~/.config/forge/safety-net` (one extended regex per line) so the `safety-net` Claude Code hook, auto-discovered from forge-core's `hooks/hooks.json`, blocks commits that match any pattern.

## DONE WHEN

Staging a file containing a pattern from `~/.config/forge/safety-net` and attempting `git commit` inside Claude Code triggers a block decision from the safety-net hook.

## TODO

- [ ] Create `~/.config/forge/` directory
- [ ] Create `~/.config/forge/safety-net` with initial patterns
- [ ] Verify the hook fires on a test commit

## Steps

### Create the config directory

```sh
mkdir -p ~/.config/forge
```

### Create the safety-net config

One extended regex per line, `#` comments allowed. Include anything that must never enter any repo: deprecated emails, personal phones, internal hostnames, legacy handles, vendor names.

```sh
touch ~/.config/forge/safety-net
```

Populate with your patterns. This file lives in the private dotfiles repo and deploys to every machine.

### Verify

1. Stage a test file containing a string that matches one of your patterns
2. Attempt `git commit` inside Claude Code
3. The safety-net hook should emit a block decision with a match count
4. Unstage the test file after confirming

### Prerequisites

The safety-net hook is auto-discovered when forge-core is installed as a Claude Code plugin. No manual hook wiring needed.

gitleaks (Layer 1 of the pre-commit checks) is a shared module prerequisite documented in the [module INSTALL.md](../../INSTALL.md).

EXECUTE NOW: Complete the above TODO list to achieve: a staged commit containing a safety-net pattern triggers a block.
