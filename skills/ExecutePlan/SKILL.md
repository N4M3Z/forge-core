---
name: ExecutePlan
version: 0.1.0
description: "Execute an implementation plan inline — task by task in a single session. USE WHEN executing plan, run plan, implement plan, inline execution."
---

# ExecutePlan

Execute a WritePlan output in the current session, one task at a time. This is the sequential alternative to DeveloperSprint (parallel agents). Use ExecutePlan for smaller plans or when tasks have sequential dependencies.

1. **Load the plan** — read the plan file from `docs/plans/`
2. **Critical review** — before starting, check: are tasks ordered correctly? Are dependencies satisfied? Any gaps? If issues found, fix the plan first or ask the user.
3. **Set up workspace** — use a git worktree if the plan modifies existing code
4. **Execute task by task**:
    - Read the task specification
    - Implement exactly what the task says
    - Run the verification step specified in the task
    - Invoke VerifyCompletion before marking the task done
    - Move to the next task only after the current one passes
5. **Handle blockers** — if stuck, stop and ask the user. Never guess past a blocker.
6. **Final verification** — after all tasks, run the full build + test suite
7. **Report** — summarize what was done, what was skipped, what needs follow-up

## Constraints

- One task at a time — never batch or skip ahead
- Verify each task before proceeding to the next
- Stop on blockers — ask the user, don't guess
- No scope expansion beyond the plan
- Use git worktrees when modifying existing code
- For plans with independent tracks, use DeveloperSprint instead

## Sources

- <https://github.com/obra/superpowers>
