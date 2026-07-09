Keep the backstory out of the artifact. In documentation, code, config, inline comments, and ADRs, never reference what was wrong, what was removed, or what changed: naming past errors anchors them in context and makes repeating them more likely.

A change's rationale, why this option and not the alternative, what it replaces or improves, belongs in the commit message, not in a comment or doc; the diff already shows what changed. Even positive justification ("via X, which manages Y") counts as narrating why.

Not: "Account 39501 was previously thought to be RELIS-only but actually has 854K entries."
Not: "`appearance` removed: bypassed when `theme` is set above, so the field is dead."
Not: "Claude Code over ACP via the registry, which manages the adapter version."

State the current truth instead; see [[PresentTense]].
