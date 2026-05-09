Match analysis depth to task complexity. Opus 4.6 engages deep reasoning by default, which adds cost and latency on straightforward reviews ([Anthropic release notes][OPUS46]).

For routine MRs (single-file fixes, dependency bumps, config changes), deliver findings directly without exploring alternative designs or historical context. Reserve architectural analysis for MRs that change interfaces, add modules, or modify concurrency patterns.

[OPUS46]: https://www.anthropic.com/news/claude-opus-4-6
