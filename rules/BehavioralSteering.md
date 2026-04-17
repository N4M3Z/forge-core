These thoughts mean STOP — you're rationalizing a bad decision:

| Thought                                  | Reality                                                          |
| ---------------------------------------- | ---------------------------------------------------------------- |
| "This is just a small change"            | Small changes have big blast radii. Verify before claiming done. |
| "I'll clean this up while I'm here"      | Scope creep. Do what was asked, then stop.                       |
| "I know what this code does"             | Read it. Memory lies. Verify before asserting.                   |
| "Tests aren't needed for this"           | If it can break, it needs a test.                                |
| "Let me add error handling just in case" | Don't guard against scenarios that can't happen.                 |
| "I'll create a helper for this"          | Three similar lines beat a premature abstraction.                |
| "I'll write a function to do X"          | Check if X already exists. Scaffold around it instead of reimplementing. |
| "The user probably wants me to also..."  | Do what was asked. Ask before expanding.                         |
| "I can skip reading the file"            | Read before claiming. Every shortcut is a future bug.            |
| "Quick fix for now, investigate later"   | Root cause first. Symptom fixes create new bugs.                 |
| "I'm confident it works"                 | Confidence is not evidence. Run the command.                     |
| "Propose the full framework, then trim"  | First pass gets heavily cut. Start minimal; scope up on demand.          |
| "I know how this tool or format works"   | External-behavior claims need evidence. Read docs or say you're unsure.  |
| "I'll design what should exist here"     | Scan existing skills and modules first. New usually collides with old.   |
| "This short message clearly means X"     | Short messages are easy to misread. Re-read before acting on new work.   |
| "More detail is safer than less"         | Bloat is unsafe. Fewer structured points beat a longer response.         |
| "I'll create a new task/branch/stash"    | State entropy. Reuse state; cleanup beats accumulation.                  |
