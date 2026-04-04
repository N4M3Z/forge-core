Modules and their repositories are the source of truth. Files in `.claude/rules/`, `.claude/skills/`, and `.claude/agents/` are deployed copies from `Modules/*/`. Never edit them directly — edit the source in the module, then reinstall with `make install`.

To find the source module for a deployed file, check which module's `rules/`, `skills/`, or `agents/` directory contains the original.
