# ClaudeBaseline

Recommended user-scope `~/.claude/settings.json` baseline grounded in Anthropic docs and community best practice. Run when bootstrapping a new machine, after major Claude Code upgrades, or as a periodic hygiene check.

Follow the 6-phase workflow from `SKILL.md` (Scope, Inventory, Audit, Report, Apply, Verify), substituting the audit rules and baseline below.

## Baseline skeleton

```json
{
    "$schema": "https://json.schemastore.org/claude-code-settings.json",
    "model": "claude-opus-4-7[1m]",
    "theme": "dark",
    "maxSkillDescriptionChars": 2048,
    "enableAllProjectMcpServers": false,
    "permissions": {
        "defaultMode": "auto",
        "deny": [
            "Read(~/.ssh/**)", "Edit(~/.ssh/**)",
            "Read(~/.aws/**)", "Read(~/.gnupg/**)", "Read(~/.kube/**)",
            "Read(~/.docker/config.json)", "Read(~/.config/gh/**)",
            "Read(~/.git-credentials)", "Read(~/.npmrc)", "Read(~/.pypirc)",
            "Read(~/.gem/credentials)", "Read(~/Library/Keychains/**)",
            "Edit(~/.bashrc)", "Edit(~/.zshrc)",
            "Edit(~/.bash_profile)", "Edit(~/.zprofile)", "Edit(~/.profile)"
        ]
    },
    "env": {
        "BASH_DEFAULT_TIMEOUT_MS": "180000",
        "BASH_MAX_TIMEOUT_MS": "900000"
    },
    "statusLine": {"type": "command", "command": "<path>", "padding": 0},
    "hooks": {}
}
```

## Defensive denies

Per [permissions docs][PERMS], Read/Edit denies apply to Claude's first-party file tools and the closed Bash command list (`cat`, `head`, `tail`, `sed`). They do NOT apply to wrapped commands. Treat as personal safeguards, not security boundaries.

Targets adapted from [Trail of Bits config][TOB]. SSH gets both Read and Edit denies because keys are equally sensitive to read or modify. Other credential stores get Read-only denies. Shell rc files get Edit-only (reading is often legitimate, editing should always be explicit).

## Env vars

| Var | Value | Rationale |
|---|---|---|
| `BASH_DEFAULT_TIMEOUT_MS` | `"180000"` | 2 min default per [ENV], bump to 3 min |
| `BASH_MAX_TIMEOUT_MS` | `"900000"` | 10 min default per [ENV], bump to 15 min |

Excluded by design:

- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` rolls up telemetry, autoupdater, feedback survey, and error reporting per [env-vars][ENV]. It also blocks the outbound channel Remote Control uses to bridge terminal sessions to claude.ai and the mobile app. Set it only if you do not use Remote Control and accept the autoupdater opt-out.
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` (no documented numeric default, "varies by model") and `MAX_THINKING_TOKENS` (appears only contextually in the docs). Setting either to a fabricated value risks regressions.

## Model pin

Set `model` for a session-default:

- `claude-opus-4-7[1m]` for max headroom (1M context), most expensive
- `claude-opus-4-7` for the same model at standard 200K context
- `claude-sonnet-4-6` as a budget baseline; use `/model` per session to escalate

Per-session `/model` swap still works regardless of the pin.

## StatusLine

The community default is [ccstatusline][CCSL] (model, branch/PR, token speed, context %). Alternative is [ccusage][CCU] when cost tracking matters more than git state.

```json
"statusLine": {"type": "command", "command": "<absolute-path>", "padding": 0}
```

## Behavioural verification of undocumented keys

Some keys appear in active configs but not in [settings docs][SETTINGS]. Verify before keeping:

- `skipAutoPermissionPrompt`. Hypothesis: suppresses the Shift+Tab auto-mode opt-in dialog. Test: `mv ~/.claude/settings.json ~/.claude/settings.json.aside`, launch, Shift+Tab to auto, observe whether the prompt appears. Restore and repeat with original settings.
- `advisorModel`. Hypothesis: sets the model used for `advisor()` calls. Test: call `advisor()` in a session, inspect `~/.claude/sessions/<latest>/` and `~/.claude/telemetry/` for a recorded model. Toggle the value in a throwaway session and re-check.
- `skillListingMaxDescChars`. Hypothesis: probable rename of documented `maxSkillDescriptionChars` (default 1536). Test: find a skill SKILL.md description between 1537 and 2048 characters (`wc -c`), observe where the listing truncates.

Drop keys that fail behavioural tests rather than carrying dead config.

## RTK + deny interaction

When [RTK][RTK] runs as a PreToolUse hook, it rewrites `cat ~/.ssh/id_rsa` to `rtk cat ~/.ssh/id_rsa`. The closed wrapper list per [PERMS] (`timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs`) does NOT include `rtk`, so a `Read(~/.ssh/**)` deny may miss the rewritten form.

Post-deploy test: ask Claude to `cat ~/.git-credentials` in a fresh session. If it goes through, RTK bypasses denies. Mitigations: RTK-side exclusion for sensitive paths, or move enforcement to OS-level sandboxing.

## Verified facts from Anthropic docs

These ground the recommendations and should not be re-litigated:

- Path anchor forms per [PERMS]: `//path` filesystem root, `~/path` home, `/path` project root, `path` cwd. `**` is recursive descent.
- Read-only built-in Bash commands need no allow rule: `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, read-only `git`.
- Scope precedence (high to low): managed > CLI args > project local > project shared > user.
- `Bash(curl URL *)` filtering is fragile per [PERMS] warning. Prefer `WebFetch(domain:...)` for URL allowlists.

## Pitfalls

- Do not put `permissions.allow` sprawl in user scope. Project-specific allows belong in project-scope `.claude/settings.local.json`.
- Do not rely on user-scope deny as a security boundary. Project and local scope can override, and Bash subprocesses bypass it entirely without OS-level sandboxing.
- Do not use broad wildcards (`Bash(*)`) as a consolidation strategy. Issue [#27139] documents resolver bugs with broad wildcards.
- Do not put credentials in `env`. Settings files end up in dotfile repos.
- Do not paste cross-cutting settings from blogs without confirming against the docs. The schemastore JSON publishes lazily and unknown keys are silently ignored.

## Sources

[SETTINGS]: https://code.claude.com/docs/en/settings "Claude Code settings reference"
[PERMS]: https://code.claude.com/docs/en/permissions "Configure permissions"
[ENV]: https://code.claude.com/docs/en/env-vars "Environment variables"
[TOB]: https://github.com/trailofbits/claude-code-config "Trail of Bits, claude-code-config"
[CCSL]: https://github.com/sirmalloc/ccstatusline "ccstatusline"
[CCU]: https://ccusage.com/guide/statusline "ccusage statusline"
[RTK]: https://github.com/rtk-ai/rtk "RTK, Rust Token Killer"
[#27139]: https://github.com/anthropics/claude-code/issues/27139 "Broad wildcard permissions not respected"
