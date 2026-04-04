# ContextKeeper Integration

In the Capture workflow, if [c0ntextkeeper][1] MCP is available, query `search_archive` for additional session context that may have been compressed away. This recovers architectural decisions from compacted conversation history.

Use `fetch_context` with scope `project` and a query describing the decision topic. Run this before reviewing conversation context — compacted sessions lose the reasoning that ADRs need to preserve.

[1]: https://github.com/c0ntextkeeper/c0ntextkeeper
