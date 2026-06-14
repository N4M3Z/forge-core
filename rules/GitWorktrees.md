Use git worktrees for parallel feature work instead of stashing or switching branches. Worktrees live in `.worktrees/<branch-name>` inside the repo; add `.worktrees/` to `.gitignore` before creating the first worktree. Setup, safety checks, and cleanup mechanics: [GitWorktrees companion](../skills/VersionControl/GitWorktrees.md).

When spawning agents for parallel implementation, use `isolation: "worktree"` so each agent works on an isolated copy without conflicting with the main tree or other agents.
