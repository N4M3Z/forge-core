Gemini CLI does not have the Agent or Task tools. Council skills use direct `@AgentName` invocation instead:

1. For each specialist, invoke `@AgentName` with the round prompt inline. Collect results.
2. Present findings, ask user for input.
3. Invoke `@AgentName` again per specialist with prior transcript + next round instruction.
4. Repeat for all rounds, then synthesize.
