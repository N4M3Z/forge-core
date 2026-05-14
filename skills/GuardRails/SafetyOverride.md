## SafetyOverride

Operating safely when AI-safety plugins gate destructive commands. Each safety plugin in use is documented as a per-plugin companion (for example `SafetyNet.md`); this section covers the general decision discipline that applies to all of them.

### When to consult this section

1. A command just got blocked with a safety-plugin error. Look up the plugin's companion file for the mapped workaround.
2. Configuring a safety plugin for the first time. Custom rules, statusline, and so on. See the plugin's companion under § Configuration.
3. Deciding whether to disable or override a rule. Read § When not to disable in the plugin's companion before touching config.

### Constraints

- Never disable a safety plugin to push a blocked command through.
- Never retry the same blocked command with cosmetic variations to slip past the regex.
- When a block catches a genuine mistake, thank the guardrail and pick the safer path.
- For irrecoverable operations (force-push to main, drop production table, unbounded `rm`), prefer hand-off to the user over attempting the command yourself.
