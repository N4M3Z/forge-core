---
name: GuardRails
description: Usage and workarounds for AI-safety plugins that block destructive commands. USE WHEN a safety plugin blocks a command, safety-net error, guardrails, sandbox blocked, git reset --hard blocked, rm -rf blocked, workaround for a blocked command, safety plugin configuration.
version: 0.1.0
---

# GuardRails

Operate safely when AI-safety plugins gate destructive commands. Each safety plugin in use is documented as a companion file in this skill directory — read the relevant one when blocked or configuring.

Supported plugins:

- `SafetyNet.md` — [claude-code-safety-net](https://github.com/kenryu42/claude-code-safety-net): blocks common destructive git and shell commands.

Future plugins land as sibling companion files following the same shape: overview, what it catches, workarounds, configuration, when not to disable.

## When to consult this skill

1. A command just got blocked with a safety-plugin error. Read the plugin's companion file for the mapped workaround.
2. Configuring a safety plugin for the first time — custom rules, statusline, etc. See the companion's § Configuration.
3. Deciding whether to disable or override a rule. Consult § When not to disable before touching config.

## Constraints

- Never disable a safety plugin to push a blocked command through.
- Never retry the same blocked command with cosmetic variations to slip past the regex.
- When a block catches a genuine mistake, thank the guardrail and pick the safer path.
- For irrecoverable operations (force-push to main, drop production table, unbounded `rm`), prefer hand-off to the user over attempting the command yourself.
