---
targets: [claude]
---
Cowork silently drops all plugin hooks. The CLI is spawned with `--setting-sources user`, which excludes plugin-scoped hook discovery ([GitHub #27398][ISSUE]). All hook types (command, prompt, agent) are affected. No error is surfaced.

Skills, agents, and MCP servers work in Cowork ([plugins reference][PLUGINS]). Hooks are unsupported at this time.

Any behavior that must work in Cowork cannot rely on hooks. Ship it as a rule (always loaded) or a skill (user-invoked) instead.

[ISSUE]: https://github.com/anthropics/claude-code/issues/27398
[PLUGINS]: https://code.claude.com/docs/en/plugins-reference
