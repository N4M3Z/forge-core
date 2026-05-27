Every repository ships an `INSTALL.md` at the repo root following the Mintlify install.md standard [MINTLIFY] for agent-executable installation. The file tells AI agents how to install and verify the software without polluting CLAUDE.md (behavioral), AGENTS.md (behavioral), or README.md (human-oriented).

Every skill whose use requires setup beyond its own SKILL.md — wiring a hook, dropping a config file, installing a binary, configuring a service — also ships an `INSTALL.md` next to its `SKILL.md`. Same Mintlify shape. SKILL.md keeps behavioral guidance ("when committing, follow these rules"); INSTALL.md keeps actionable setup ("symlink this script, paste this snippet into settings.json"). Skills with no setup beyond `make install` need no INSTALL.md.

Required elements (both scopes): H1 title, blockquote summary, conversational opening, OBJECTIVE, DONE WHEN (measurable success condition), TODO checklist (3-7 items), detailed steps with shell commands, EXECUTE NOW closing.

DONE WHEN embeds verification — no separate VERIFY.md needed. Template at `templates/init/INSTALL.md` in forge-cli [TEMPLATE].

[MINTLIFY]: https://github.com/mintlify/install-md "Mintlify install.md — standard for LLM-executable installation"
[TEMPLATE]: https://github.com/N4M3Z/forge-cli/blob/main/templates/init/INSTALL.md "INSTALL.md template"
