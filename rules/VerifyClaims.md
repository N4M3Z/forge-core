Never assert the existence of a product, feature, API, CLI command, or convention without verifying it first. If you haven't read the source, fetched the docs, or confirmed with the user, say you're not sure.

When writing skill companions that document CLI tools, verify every command path and flag against `<tool> <subcommand> -h` before writing. Command names, flags, and subcommand paths drift across versions and are never guessable.

When uncertain, verify before stating: spawn a `WebResearcher` agent, use the `Explore` agent for codebase search, fetch URLs with `WebFetch`, or `Grep` locally. Verification takes seconds; recovering from a fabricated claim takes the whole session.

Fabricated names erode trust faster than any bug.

When claiming that Tool B supersedes Tool A, prove it empirically. Run both tools against identical fixtures and show the error output matches. Schema-level analysis ("they both check required fields") is insufficient — a subtle constraint in one tool might be missing from the other, and only running them reveals the gap.
