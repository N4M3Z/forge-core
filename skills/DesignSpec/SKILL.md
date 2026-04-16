---
name: DesignSpec
version: 0.1.0
description: "Write a formal design spec from brainstorming output or requirements. USE WHEN design approved, write spec, formalize design, spec document."
---

# DesignSpec

Produce a formal design specification from approved brainstorming output or direct requirements. The spec is the contract between design and implementation — WritePlan and DeveloperSprint consume it.

1. **Gather input** — read the approved design (from Brainstorming output or user description)
2. **Write the spec** — structured markdown covering all sections below
3. **Self-review** — run the checklist before presenting
4. **Save** — write to `docs/specs/YYYY-MM-DD-<topic>-design.md`
5. **User review** — present for approval. No implementation until approved.

## Spec Structure

Scale sections to complexity. Simple specs skip sections that don't apply.

- **Problem Statement** — what exists today, why it's insufficient
- **Proposed Approach** — what we're building, key design decisions
- **API / Interface Design** — public surface, data shapes, commands
- **Data Flow** — how data moves through the system
- **Edge Cases** — known boundary conditions and how they're handled
- **Test Strategy** — what to test, how to verify correctness
- **Out of Scope** — what this spec explicitly does NOT cover

## Self-Review Checklist

Before presenting the spec, verify:

| Check        | Question                                                   |
| ------------ | ---------------------------------------------------------- |
| Completeness | Could someone implement this without asking questions?      |
| Consistency  | Do all sections agree with each other?                     |
| Clarity      | Is every term unambiguous? No "should", "might", "maybe"? |
| Scope        | Does this solve the stated problem without gold-plating?   |
| YAGNI        | Is every feature justified by a stated requirement?        |

## Red Flags

| Thought                                      | Reality                                                        |
| -------------------------------------------- | -------------------------------------------------------------- |
| "The design is clear enough, skip the spec"  | If it's clear, the spec writes fast. If not, you need it more. |
| "I'll fill in the details during coding"     | That's not a spec, it's a wish list.                           |
| "Edge cases can wait"                        | Edge cases found during coding cost 10x more to handle.        |
| "The user already approved the design"       | Design approval is not spec approval. Write it down.           |
| "This spec is too short"                     | Short specs for simple problems are correct. Don't pad.        |

## Constraints

- Every section must be concrete — no placeholders, TBD, or TODO
- Spec must be saved as a file, not just presented in conversation
- User must approve the spec before implementation begins
- Hand off to WritePlan or DeveloperSprint after approval
