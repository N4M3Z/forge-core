Invoke [LearnFrom][LEARNFROM] to capture transferable learnings whenever ANY of these fire during a session:

- Teardown of a council, agent team, workflow, or any other multi-agent run
- A history rewrite touching 5+ commits (squash, force-push, rebase)
- A skill, agent, or rule rename, move, or deletion
- 3+ corrections from the user in a single topic (messages starting with `no`, `don't`, `actually`, `wait`, `stop`, `what are you doing`)
- Before closing a work stream spanning 3+ merged PRs
- After discovering a forge-cli / tool bug worth filing as an upstream issue

[LearnFrom][LEARNFROM] scans the session, proposes updates to rules, skills, and agents, and presents each via AskUserQuestion with Capture / Adjust / Skip options.

[LEARNFROM]: ../skills/LearnFrom/SKILL.md
