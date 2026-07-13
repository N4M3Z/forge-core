PR titles and commit messages describe what changed, not why it was discovered. The change stands on its own.

Every PR or issue reference in output the user reads — chat replies, reports, review handoffs, docs — carries its link: `[#67](https://github.com/owner/repo/pull/67)` or the bare URL, never a naked `#67`. The bare number is fine only where the platform auto-links it (PR bodies, commit messages, GitHub comments).

### Body Structure

PR bodies explain the *why* before the *what* in as few sentences as possible. One-sentence sections beat padded sections. Code snippets, bulleted "Summary" lists, and prose that paraphrases the diff are forbidden. The diff already shows the code.

Sections, in order, omitting any that add nothing:

1. **## Problem** — what does not work, from the user's or operator's perspective. Include the failing invocation, error message, or surprising output. For features, name the missing capability.
2. **## Fix** (or **## Approach** for features) — what changes, in prose. Do not duplicate the diff.
3. **## Out of scope** — what is deliberately *not* changed. Omit when obvious.
4. **## Test plan** — markdown task list: `- [x]` completed, `- [ ]` pending. Cite the commands run.

Link the closing issue with `Closes #NN` at the top of the body.

For pure chores (version bumps, lockfile updates) Problem + Test plan suffice.

### Platform Tooling

When a repository is managed by a supported platform (GitHub, GitLab), you MUST use the respective CLI (`gh`, `glab`) for the entire lifecycle.

- **Feedback First**: If told there is feedback, immediately use `gh pr view --comments` or `gh pr view --web` before asking for clarification.
- **Discovery**: Check `gh pr list` or `gh issue list` to avoid duplicating existing work.
- **Operations**: Use CLI tools for PR creation (`--fill`), status checks, and merging.

### Stacked PRs

When a feature branch targets another feature branch as its base, the child PR's content does not cascade to main when the parent PR merges. Squash-merging PR A (`feature-A` → `main`) creates a new commit on main with A's content but leaves `origin/feature-A` as a divergent branch. PR B (`feature-B` → `feature-A`) then merges into the divergent `feature-A`, not main.

Retarget PR B to main after PR A merges, or it will appear "merged" on GitHub while its content never reaches main.
