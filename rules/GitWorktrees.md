Use git worktrees for parallel feature work instead of stashing or switching branches. Each worktree gets its own working directory with a shared `.git` store — no context switching, no stash conflicts.

```sh
git worktree add ../repo-feature feature-branch
git worktree remove ../repo-feature
git worktree list
```

Worktree directories live alongside the main clone, named `repo-branchname`. Never create worktrees inside the main working tree — they pollute the file listing and confuse tools.

When spawning agents for parallel implementation, use `isolation: "worktree"` so each agent works on an isolated copy without conflicting with the main tree or other agents.
