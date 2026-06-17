Haiku 4.5 has a 200K context window (vs 1M for Sonnet/Opus 4.6) and no adaptive thinking ([Anthropic release notes][HAIKU45]). Work within these constraints:

When reviewing large MRs, focus on the files most likely to contain defects (business logic, data access) rather than scanning everything. If the diff exceeds what you can hold in context, say so and recommend splitting the review.

Do not attempt multi-file architectural analysis across more than 3-4 files. Escalate to a Sonnet or Opus specialist when the task requires cross-cutting reasoning.

[HAIKU45]: https://www.anthropic.com/news/claude-haiku-4-5
