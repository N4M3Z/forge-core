Hook scripts MUST exit 0 always. A non-zero exit crashes the hook silently — Claude Code treats it as a hook failure, not a block decision. Communication is via stdout JSON only — stderr is invisible to Claude Code.

- Empty stdout = allow
- `{"decision":"block","reason":"..."}` = block (Stop)
- `{"hookSpecificOutput":{"additionalContext":"..."}}` = AI context injection (PostToolUse)

Guard files use `$PPID` or `$SESSION_ID` scoping to prevent repeat firing within a session.
