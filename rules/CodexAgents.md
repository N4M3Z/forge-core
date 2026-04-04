Codex CLI does not support agent teams. Council skills use sequential Agent calls without `team_name`:

1. For each specialist, use Agent tool with `subagent_type` (no `team_name`). Collect results.
2. Present findings, ask user for input.
3. Spawn new Agent per specialist with prior transcript + next round instruction.
4. Repeat for all rounds, then synthesize.
