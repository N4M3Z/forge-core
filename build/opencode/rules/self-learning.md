After significant amount of work (multi-step implementations, agent team teardown, architecture decisions), spawn a **foreground Task agent** to capture transferable learnings before the session moves on.

The agent reviews what happened, extracts 1-3 reusable principles, and presents each via **AskUserQuestion** with Capture / Skip / Skip All options.

Default write target: `rules/` in the repo as concise rule files.