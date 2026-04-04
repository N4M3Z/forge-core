Markdown tables must be column-aligned. Pad cells with spaces so pipes form straight vertical lines.

This is a formatting invariant, not a suggestion. Every table in every file — rules, skills, ADRs, companion files, ARCHITECTURE.md, code block examples. A table with misaligned pipes is a bug to be fixed before moving on.

Procedure: before writing any table, determine the widest content in each column, then pad every cell in that column to the same width. Verify alignment visually before submitting. If a table was written misaligned, fix it immediately — do not continue to the next task.