---
name: VerifyCompletion
version: 0.1.0
description: "Verify work before claiming done. USE WHEN about to claim work is complete, fixed, or passing, before committing or creating PRs."
---

# VerifyCompletion

No completion claims without fresh verification evidence. Run the command, read the output, then claim the result.

## The Gate Function

Before claiming any status or expressing satisfaction:

1. **Identify** the command that proves the claim
2. **Run** the full command now (not from memory, not from a previous run)
3. **Read** the complete output, check exit code, count failures
4. **Match** the output to your claim — does it confirm what you're about to say?
5. **Only then** make the claim, citing the evidence

Skip any step and the claim is unverified.

## Verification Requirements

| Claim             | Requires                                 | Not sufficient                          |
| ----------------- | ---------------------------------------- | --------------------------------------- |
| Tests pass        | Test command output showing 0 failures   | Previous run, "should pass"             |
| Linter clean      | Linter output showing 0 errors           | Partial check, extrapolation            |
| Build succeeds    | Build command exit 0                     | Linter passing, "logs look good"        |
| Bug fixed         | Reproducing original symptom: now passes | Code changed, assumed fixed             |
| Requirements met  | Line-by-line checklist against spec      | Tests passing                           |
| Agent completed   | VCS diff shows expected changes          | Agent reports "success"                 |

## Red Flags

| Thought                                 | Reality                                              |
| --------------------------------------- | ---------------------------------------------------- |
| "Should work now"                       | Run the verification.                                |
| "I'm confident"                         | Confidence is not evidence.                          |
| "Just this once"                        | No exceptions.                                       |
| "Linter passed"                         | Linter is not the compiler. Run the build.           |
| "Agent said success"                    | Verify independently. Agents report intent, not fact.|
| "Partial check is enough"              | Partial proves nothing about the whole.              |
| "I already tested this earlier"         | Earlier is not now. State changes between runs.      |
| "It's a small change, can't break"     | Small changes break large systems. Verify.           |

## Constraints

- Never express satisfaction ("Done!", "Perfect!", "All good!") before running verification
- Never trust a previous run — re-run now
- Never trust agent success reports without checking the diff
- "Should", "probably", "seems to" are never verification
