PR titles and commit messages describe what changed, not why it was discovered. The change stands on its own.

### Body Structure

PR bodies must follow a structured format:

1. **## Summary**
   - Bulleted list of key changes.
   - Reference relevant files or architectural decisions using `[Name][Path.md]` syntax.

2. **## Test plan**
   - Use standard markdown task lists: `- [x]` for completed tests, `- [ ]` for pending.
   - Describe commands run and their results.

### Platform Tooling

When a repository is managed by a supported platform (GitHub, GitLab), you MUST use the respective CLI (`gh`, `glab`) for the entire lifecycle.

- **Feedback First**: If told there is feedback, immediately use `gh pr view --comments` or `gh pr view --web` before asking for clarification.
- **Discovery**: Check `gh pr list` or `gh issue list` to avoid duplicating existing work.
- **Operations**: Use CLI tools for PR creation (`--fill`), status checks, and merging.

### Stacked PRs

When a feature branch targets another feature branch as its base, the child PR's content does not cascade to main when the parent PR merges. Squash-merging PR A (`feature-A` → `main`) creates a new commit on main with A's content but leaves `origin/feature-A` as a divergent branch. PR B (`feature-B` → `feature-A`) then merges into the divergent `feature-A`, not main.

Retarget PR B to main after PR A merges, or it will appear "merged" on GitHub while its content never reaches main.
