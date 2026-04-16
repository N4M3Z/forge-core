---
name: ExtractPrompt
description: "Move bulk reference material from the main SKILL.md body into @-included companion files so the always-loaded content stays lean. USE WHEN an adopted or authored skill's body exceeds its information density because it inlines reference tables, pricing, catalogs, or per-variant guidance."
version: 0.1.0
allowed-tools: Read, Edit, Write
---

# ExtractPrompt

Move bulk reference material out of `SKILL.md` into companion files referenced with `@` includes. The SKILL.md stays the entrypoint an AI reads to decide behavior; companions load on demand when the AI needs the reference data. Referenced by [ForgeAdopt](../ForgeAdopt/SKILL.md) as the `extract` transform.

Follows [ARCH-0002](docs/decisions/ARCH-0002 Skills Companion Files.md).

## What to extract

| Content shape                                                              | Extract to a companion?            |
| -------------------------------------------------------------------------- | ---------------------------------- |
| Long reference table (model pricing, language-specific rules, catalogs)    | Yes                                |
| Per-variant guidance (one section per framework, language, or ecosystem)    | Yes, one companion per variant     |
| Command reference (many commands, each with flags and examples)             | Yes, if it spans more than a screen |
| Full example project                                                        | Yes, always                        |
| Workflow that decides HOW to use the skill                                  | No, stays in `SKILL.md`            |
| Constraints, red flags, anti-patterns                                       | No, stays in `SKILL.md`            |
| Decision tables with 3-7 rows                                               | No, inline                         |

## Procedure

1. Identify candidate sections — content that is reference material rather than instruction.
2. For each candidate, move it to a companion file named by its scope (`PythonReference.md`, `Tables.md`, `ModelPricing.md`).
3. Replace the extracted block with an `@` include in `SKILL.md`:

    ```markdown
    ## Language-specific guidance

    @python-security.md
    @typescript-security.md
    @go-security.md
    ```

4. Keep the section heading in `SKILL.md` so the AI knows the companion exists.
5. Re-read `SKILL.md` alone. It should still be a complete instruction — the AI must be able to decide what to do without loading the companion.

## Naming

- Companions live in the same directory as `SKILL.md`
- PascalCase for conceptual companions (`TemplateReference.md`, `SchemaValidation.md`)
- kebab-case for variant-keyed companions (`python-django-security.md`)
- One companion per topic; do not bundle unrelated reference material

## Constraints

- `SKILL.md` must remain complete as instruction on its own — companions are reference, not required loading
- Never extract decision-making content; the AI needs it to choose which companion to read
- Do not create a companion unless at least 200 words would move; smaller moves are just fragmentation
- Keep companion files under 2000 words each; split further if they grow
- Do not nest companions (a companion cannot `@`-include another companion) — compose at the SKILL.md level
