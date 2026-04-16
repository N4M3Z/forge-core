---
name: WritePlan
version: 0.1.0
description: "Create a detailed implementation plan with bite-sized tasks. USE WHEN spec approved, plan implementation, create plan, write implementation plan."
---

# WritePlan

Transform an approved spec or requirements into a step-by-step implementation plan. Every task is concrete, every command is real, every file path exists or is specified.

The spec was already approved during Brainstorming or DesignSpec. The plan is a mechanical decomposition — it doesn't need a second approval gate. The gate is the execution handoff.

Enter plan mode before writing the plan. This keeps the plan in the runtime's attention during subsequent execution.

1. **Enter plan mode** — call EnterPlanMode to switch to planning context
2. **Load the spec** — read the approved DesignSpec or requirements document
3. **Map file structure** — document which files will be created or modified, in what order
4. **Write tasks** — break implementation into 2-5 minute steps with actual code and commands
5. **Self-review** — verify every task is executable without ambiguity
6. **Exit plan mode** — call ExitPlanMode with the plan content for user approval
7. **Save** — write to `docs/plans/YYYY-MM-DD-<feature>-plan.md`
8. **Execution handoff** — present via AskUserQuestion: "Plan written to `<path>`. Execute with ExecutePlan (inline, sequential) or DeveloperSprint (parallel agents)?"

## Task Format

Each task must contain:
- What to do (one sentence)
- Which file(s) to create or modify (exact paths)
- The actual code or commands (not pseudocode, not descriptions)
- How to verify it worked (test command or expected output)

## Red Flags

| Thought                                           | Reality                                                          |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| "Implement the authentication module"             | That's a project, not a task. Break it into 2-5 minute steps.    |
| "TBD — figure out during implementation"          | If you can't specify it now, the spec is incomplete. Go back.    |
| "Add appropriate error handling"                  | Specify which errors and how to handle each one.                 |
| "Follow the existing pattern"                     | Name the pattern, cite the file, show the code.                  |
| "The developer will know what to do"              | The developer is an agent with no context. Spell it out.         |
| "This task might take 30 minutes"                 | Split it. Every task should be verifiable in under 5 minutes.    |

## Constraints

- No placeholders: TBD, TODO, "implement X", "appropriate Y" are forbidden
- Every task must be completable in 2-5 minutes
- File structure comes before implementation tasks
- Tasks include actual code, not descriptions of code
- Plan must reference which spec it implements
- Save as a file, not just conversation output
