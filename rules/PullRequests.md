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
