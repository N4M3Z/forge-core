Never assert the existence of a product, feature, API, CLI command, or convention without verifying it first. If you haven't read the source, fetched the docs, or confirmed with the user, say you're not sure.

When writing skill companions that document CLI tools, verify every command path and flag against `<tool> <subcommand> -h` before writing. Command names, flags, and subcommand paths drift across versions and are never guessable.

When uncertain, verify before stating: spawn a `WebResearcher` agent, use the `Explore` agent for codebase search, fetch URLs with `WebFetch`, or `Grep` locally. Verification takes seconds; recovering from a fabricated claim takes the whole session.

Fabricated names erode trust faster than any bug.

When claiming that Tool B supersedes Tool A, prove it empirically. Run both tools against identical fixtures and show the error output matches. Schema-level analysis ("they both check required fields") is insufficient — a subtle constraint in one tool might be missing from the other, and only running them reveals the gap.

When an agent returns assertions about file existence or constraint compliance ("all files verified on disk", "no duplicates against the exclusion list"), spot-check the critical claims before applying the output. Agents hallucinate about these reliably — treat such claims as proposals to verify, not facts.

Counts that subagents report ("12 files verified", "3 sidecars updated") violate [NoItemCounts][NIC] and are unreliable besides. If one slips through, recompute it yourself with `ls | wc -l`, `rg -c`, or equivalent before citing it. The specialist's count is a proposal; your recount is the fact.

Before claiming a tool "can't do X" or "has no analog for Y", check the tool's own config schema or `--help`, not docs or memory: config keys (sandbox modes, network allowlists, hook tables) are easy to miss, and the absence claim is what misleads. A sub-agent's summary of a doc is a proposal, not the source: when it contradicts a confident user or the decision is load-bearing, fetch and read the primary doc yourself before concluding.

Comparative claims about a third party (a competitor's product, "X beats Y", a rival's limits) must cite that party's primary or binding source, not aggregator or comparison portals — portals are routinely stale or wrong, and one adversarial pass against the primary source overturns many of them. Name the specific subject and read its authoritative document before asserting the comparison, especially where the claim is regulated or published.

[NIC]: NoItemCounts.md
