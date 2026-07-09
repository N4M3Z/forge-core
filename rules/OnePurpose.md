One action, one purpose. Applies to every tool invocation — shell commands, file edits, agent dispatches, API calls. The user must be able to read, understand, and approve each action at a glance, and a failure must be attributable to one step.

Never chain unrelated operations (validate && stage && diff) into a single command line. Acceptable chaining: a guard and its single consequence (`mkdir -p dir && cd dir`), or a cheap probe before one action. Anything longer splits into separate invocations.

Pipelines that transform one data stream (`cmd | filter | sort`) are one purpose and stay together. The smell is `&&`/`;` joining independent actions, not pipes.

The same discipline holds beyond the shell: one edit per concern, one commit per changeset, one agent per task. Batching unrelated work into a single step hides what happened and forces all-or-nothing review.
