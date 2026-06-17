## Align

Bring a prompt-shaped document into forge convention without changing its meaning.

### What to fix

| Axis              | Forge convention                                                               |
| ----------------- | ------------------------------------------------------------------------------ |
| Indentation       | Four spaces. No tabs. Applies to markdown, YAML, TOML, JSON, code blocks.      |
| Fence tags        | Every fenced code block carries a language tag. Use `sh`, not `bash`.          |
| Heading depth     | Max depth 3. No skipped levels (no H1 to H3 without H2 between).               |
| Heading style     | One H1 per document, matching the skill name in PascalCase.                    |
| Frontmatter keys  | `name`, `description`, `version`. Strip upstream fields forge does not use.    |
| Skill name        | PascalCase, two words, scope plus focus (for example `ProvenanceAudit`).       |
| Table alignment   | Pipes line up vertically; pad cells with spaces to the widest column.          |
| Trailing newline  | Every text file ends with a single `\n`.                                       |
| Wikilinks / paths | Spaces literal, not URL-encoded.                                               |

### What to preserve

- The skill's actual instructions and workflow
- Body structure and section order unless a heading level is wrong
- Code block contents; only fix the fence tag, never the code inside
- Emphasis and voice, except where convention conflicts

### Procedure

Fix frontmatter first; it gates downstream checks.

### Constraints

- Never rewrite content to fix alignment, only fix structure.
- If an upstream skill legitimately needs H4 or H5, flag it as a content issue, do not silently demote.
- Do not remove frontmatter fields the skill relies on for runtime behavior (`argument-hint`, `allowed-tools`, `hooks`).
- If the H1 title does not match the skill name, rename the file or rewrite the H1; do not leave them divergent.
