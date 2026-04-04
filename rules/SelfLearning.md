After significant AI-driven work (council debates, multi-step implementations, architecture decisions), spawn a **foreground Task agent** to capture transferable learnings before the session moves on.

The agent reviews what happened, extracts 1-3 reusable principles, and presents each via **AskUserQuestion** with Capture / Skip / Skip All options.

Default write target: `.claude/rules/` in the repo as concise rule files. When forge-reflect is installed, `/MemoryCapture` provides vault-based capture with Insight/Imperative/Idea classification.
