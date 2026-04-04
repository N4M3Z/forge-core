Rules, agents, and skills are authored in their source module (`Modules/<module>/rules/`, `agents/`, `skills/`), not directly in `.claude/`. The module repo is the source of truth — `.claude/` is the install target.

When creating new content during a session, write it in the owning module so it can be committed and shared via GitHub. `make install` deploys module content to `.claude/` with any platform-specific metadata.
