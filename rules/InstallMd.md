Every repository ships an `INSTALL.md` following the Mintlify install.md standard [1] for agent-executable installation. The file tells AI agents how to install and verify the software without polluting CLAUDE.md (behavioral), AGENTS.md (behavioral), or README.md (human-oriented).

Required elements: H1 title, blockquote summary, conversational opening, OBJECTIVE, DONE WHEN (measurable success condition), TODO checklist (3-7 items), detailed steps with shell commands, EXECUTE NOW closing.

DONE WHEN embeds verification — no separate VERIFY.md needed. Template at `templates/INSTALL.md` in forge-cli [2].

[1]: https://github.com/mintlify/install-md "Mintlify install.md — standard for LLM-executable installation"
[2]: https://github.com/N4M3Z/forge-cli/blob/main/templates/INSTALL.md "INSTALL.md template"
