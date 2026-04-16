---
name: Brainstorming
version: 0.1.0
description: "Collaborative ideation before implementation — explore context, clarify intent, propose approaches. USE WHEN starting creative work, new features, design decisions, or modifying behavior."
---

# Brainstorming

Turn ideas into designs through structured dialogue. Explore context, ask questions, propose approaches with trade-offs, get approval before implementation.

No implementation until design is approved — not code, not scaffolding, not "just a quick prototype."

1. **Explore context** — check files, docs, recent commits relevant to the idea
2. **Ask clarifying questions** — one at a time, understand purpose, constraints, success criteria
3. **Propose 2-3 approaches** — with trade-offs and a recommendation
4. **Present the design** — scale detail to complexity (a few sentences for simple, sections for complex)
5. **Get approval** — the user must approve before any implementation begins
6. **Hand off** — invoke DesignSpec for formal spec, or WritePlan for direct planning

Every project goes through this process. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short, but it must exist and be approved.

## Asking Questions

Ask one question at a time. Wait for the answer before asking the next. Bundling questions overwhelms and produces shallow answers.

Good questions uncover constraints the user hasn't stated:
- "Who will use this?" (audience shapes API design)
- "What happens when this fails?" (error handling strategy)
- "Does this need to work with X?" (integration constraints)
- "What's the simplest version that would be useful?" (scope discipline)

## Proposing Approaches

Present 2-3 distinct approaches, not variations of the same idea. Each approach gets:
- One-sentence summary
- Key trade-off (what you gain, what you lose)
- When it's the right choice

Lead with your recommendation and explain why.

## Red Flags

| Thought                                        | Reality                                                          |
| ---------------------------------------------- | ---------------------------------------------------------------- |
| "This is too simple to need a design"          | Simple projects are where bad assumptions waste the most time.   |
| "I already know what they want"                | You know what you assumed. Ask.                                  |
| "Let me just start coding and we'll iterate"   | Iteration without direction is thrashing.                        |
| "The user seems impatient, skip to building"   | Rushing produces rework. A short design is still a design.       |
| "I'll figure it out as I go"                   | That's exploration, not implementation. Explore, then design.    |
| "There's only one way to do this"              | There are always trade-offs. Name them.                          |

## Constraints

- Never start implementation before design approval — this is a hard gate
- Ask one question at a time, not batches
- Always propose at least two approaches with trade-offs
- Scale design detail to complexity — don't over-specify simple projects
- Hand off to DesignSpec or WritePlan, never directly to code
