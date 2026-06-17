## Rescope

Narrow a skill's `allowed-tools` frontmatter to the tools the workflow actually invokes. Implicit `"*"` and undeclared scope are treated as bugs.

### What to narrow

- `allowed-tools: "*"`: treat as declaration of intent, not trust; enumerate explicitly.
- Missing `allowed-tools`: add the field with the narrowest set the skill needs.
- Overbroad grants (for example `Bash` when the skill only reads files): strip.
- Comma-separated strings with trailing whitespace, duplicates, or inconsistent casing: normalize.

### Procedure

1. Read the skill body end-to-end.
2. Identify every tool the workflow invokes. Watch for indirect invocation (a Bash command calling a tool the skill uses).
3. Start from zero. Add only the tools the workflow actually uses.
4. Prefer read-only scope (`Read`, `Grep`, `Glob`) over write or exec when the workflow allows.
5. If the skill invokes shell commands, grant `Bash` but note the expected command family in a comment or the description.
6. Grant `Skill` only when the workflow composes other skills as build steps.
7. Write the result as a comma-separated list in the frontmatter.

### Constraints

- Never grant `Bash` on speculation; find the command the skill runs.
- `*` is never an acceptable final value; if the skill genuinely needs everything, the skill is doing too much.
- Do not grant tools to "future-proof" the skill; add them when the workflow adds them.
- Document unusual grants in the skill body when the reason isn't obvious from the workflow.
