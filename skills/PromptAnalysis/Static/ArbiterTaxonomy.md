# Arbiter Interference Taxonomy

Complete taxonomy of interference patterns found in Claude Code v2.1.50. Extracted from "Arbiter: Static Analysis of AI System Prompts" (arXiv 2603.08993v1).

## All 21 Patterns

| #     | Type                 | Blocks                                         | Severity | Static? |
|-------|----------------------|------------------------------------------------|----------|---------|
| 1     | Direct contradiction | TodoWrite mandate vs commit restriction         | Critical | Yes     |
| 2     | Direct contradiction | TodoWrite reinforcement vs commit restriction   | Critical | Yes     |
| 3     | Direct contradiction | TodoWrite mandate vs PR restriction             | Critical | Yes     |
| 4     | Direct contradiction | TodoWrite reinforcement vs PR restriction       | Critical | Yes     |
| 5     | Scope overlap        | TodoWrite mandate vs TodoWrite tool definition  | Major    | Yes     |
| 6     | Priority ambiguity   | Security policy duplicated                      | Minor    | Yes     |
| 7     | Scope overlap        | Conciseness vs TodoWrite overhead               | Major    | No      |
| 8     | Scope overlap        | Conciseness vs WebSearch sources                | Minor    | Yes     |
| 9     | Scope overlap        | Task tool search vs Explore agent               | Major    | Yes     |
| 10-11 | Scope overlap        | Read-before-edit vs Edit/Write tools            | Minor    | Yes     |
| 12-13 | Scope overlap        | No-new-files vs Edit/Write tools                | Minor    | Yes     |
| 14-15 | Scope overlap        | Dedicated tools vs Bash/Grep tools              | Minor    | Yes     |
| 16    | Scope overlap        | No time estimates vs asking questions            | Minor    | Yes     |
| 17    | Implicit dependency  | Commit restrictions vs Bash policy              | Minor    | Yes     |
| 18    | Implicit dependency  | Plan mode restrictions vs tool policy            | Minor    | Yes     |
| 19-20 | Scope overlap        | No-emoji vs Edit/Write tools                    | Minor    | Yes     |
| 21    | Priority ambiguity   | Parallel calls vs commit workflow                | Minor    | Yes     |

20/21 (95%) statically detectable. Only #7 required LLM semantic reasoning.

## Multi-Model Discovery Distribution

| Model            | Focus area                                           |
|------------------|------------------------------------------------------|
| Claude Opus 4.6  | Structural contradictions, security surfaces         |
| DeepSeek V3.2    | Hidden references, delegation loopholes              |
| Kimi K2.5        | Economic exploitation, cognitive load                |
| Grok 4.1         | Permission schema gaps                               |
| Llama 4 Maverick | Constraint inconsistency                             |
| MiniMax M2.5     | Trust architecture flaws, impossible instructions    |
| Qwen3-235B       | Contextual contradictions                            |
| GLM 4.7          | Data integrity, temporal paradoxes                   |

Non-monotonic discovery: pass 7 (MiniMax) produced 20 findings after pass 6 yielded only 5. Different models see different categories of interference.

## Architecture-Failure Correlation

| Architecture | Failure class                           | Example                                              |
|--------------|-----------------------------------------|------------------------------------------------------|
| Monolithic   | Growth-level bugs at subsystem boundaries | TodoWrite contradictions across workflow modules     |
| Flat         | Simplicity trade-offs                   | Identity confusion, leaked implementation details    |
| Modular      | Design-level bugs at composition seams  | Gemini save_memory data loss during compression      |

[1]: https://arxiv.org/html/2603.08993v1 "Arbiter paper"
