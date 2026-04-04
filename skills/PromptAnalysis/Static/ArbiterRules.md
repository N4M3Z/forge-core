# Arbiter Detection Rules

Extracted from "Arbiter: Static Analysis of AI System Prompts" (arXiv 2603.08993v1). Five built-in evaluation rules for the directed analysis phase.

## Rule Table

| Rule                          | Type                 | Method           | Cost     |
|-------------------------------|----------------------|------------------|----------|
| Mandate-prohibition conflict  | Direct contradiction | LLM + structural | LLM call |
| Scope overlap redundancy      | Scope overlap        | LLM              | LLM call |
| Priority marker ambiguity     | Priority ambiguity   | Structural       | Zero     |
| Implicit dependency           | Unresolved dependency| LLM              | LLM call |
| Verbatim duplication          | Scope overlap        | Structural       | Zero     |

## Structural Rules (zero cost)

### Priority Marker Ambiguity

Detect multiple authority declarations without a complete precedence specification. Look for competing priority markers:

- `IMPORTANT:`, `CRITICAL:`, `MUST`, `ALWAYS` appearing in unrelated sections without an ordering relationship
- Parallel execution guidance coexisting with sequential workflow requirements
- Multiple sections claiming override authority

### Verbatim Duplication

Content hash matching across structural positions. The same instruction restated in multiple locations.

Example from Claude Code: "read before editing" appears in the general behavioral section, the Edit tool definition, and the Write tool definition.

## LLM Rules (require model evaluation)

### Mandate-Prohibition Conflict

Two blocks where one contains a mandatory instruction (`ALWAYS`, `MUST`, `use frequently`) and another contains a prohibition (`NEVER`, `do not`, `avoid`) on the same scope.

Example from Claude Code: TodoWrite says "use VERY frequently" while the commit workflow says "NEVER use the TodoWrite or Agent tools."

### Scope Overlap Redundancy

The same constraint restated in multiple locations with subtle wording differences. Not verbatim duplication — semantically equivalent but differently phrased.

### Implicit Dependency

Constraints that interact to create undeclared dead zones. Neither rule is wrong individually, but together they eliminate all valid options.

Example from Claude Code: plan mode restricts file-editing tools, general policy prohibits Bash for file operations. No tool satisfies both constraints simultaneously.

## AST Decomposition

Each block receives four attributes before rule evaluation:

| Attribute | Values                                                                          |
|-----------|---------------------------------------------------------------------------------|
| Tier      | system, domain, application                                                     |
| Category  | identity, security, tool-usage, workflow, format, memory_policy, environment, meta |
| Modality  | mandate, prohibition, guidance, information                                     |
| Scope     | which tools/behaviors the block governs                                         |

Block classification prompts are not published in the paper.

## Search Space Reduction

Initial space: O(n^2 x R) where n = blocks, R = rules. For 56 blocks and 5 rules: ~15,680 evaluations. Pre-filtering using rule-specific constraints reduces to 100-200 relevant pairs. Filtering predicates are not published.

## Findings Summary (Claude Code v2.1.50)

21 interference patterns found. 20/21 (95%) statically detectable. Only "Conciseness vs TodoWrite overhead" required LLM semantic reasoning.

Critical findings: TodoWrite mandate contradicts commit and PR restrictions (4 patterns). Scope overlap: read-before-edit restated across general section, Edit tool, and Write tool definitions.

[1]: https://arxiv.org/html/2603.08993v1 "Arbiter paper"
