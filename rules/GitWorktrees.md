Use git worktrees for parallel feature work instead of stashing or switching branches. Each worktree gets its own working directory with a shared `.git` store -- no context switching, no stash conflicts.

```sh
git worktree add .worktrees/feature-branch feature-branch
git worktree remove .worktrees/feature-branch
git worktree list
```

Worktrees live in `.worktrees/<branch-name>` inside the repo, ignored by `.gitignore`. Add `.worktrees/` to `.gitignore` before creating the first worktree so the parallel checkouts do not appear in `git status` of the main tree. The sibling-directory pattern (`../repo-branchname`) also works but pollutes the parent directory and breaks paths in IDE workspaces and editor projects.

When spawning agents for parallel implementation, use `isolation: "worktree"` so each agent works on an isolated copy without conflicting with the main tree or other agents.
