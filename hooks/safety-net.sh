#!/bin/sh
# hooks/safety-net.sh
#
# Claude Code PreToolUse hook for Bash. Inspects `git commit` invocations and
# blocks the call when any staged blob matches a pattern from
# ~/.config/forge/safety-net.
#
# `safety-net` is the user's list of anything that must never enter a
# repo — current and deprecated identifiers, internal hostnames, personal
# phones, vendor names, anything you can describe as a regex. One extended
# regex per line, `#` comments allowed.
#
# Auto-discovered via hooks.json when forge-core is installed as a Claude Code
# plugin. No manual settings.json wiring needed.
#
# Override the config path via FORGE_SAFETY_NET.
#
# Exits 0 always per the HookScripts rule. Communicates via JSON on stdout.

input=$(cat 2>/dev/null || true)

# Heuristic: act only when the tool input contains a git commit command
case "$input" in
    *'"command"'*'git commit'*) ;;
    *) exit 0 ;;
esac

config="${FORGE_SAFETY_NET:-${HOME}/.config/forge/safety-net}"
[ -r "$config" ] || exit 0

patterns=$(grep -Ev '^[[:space:]]*(#|$)' "$config" 2>/dev/null | paste -sd '|' - 2>/dev/null)
[ -z "$patterns" ] && exit 0

staged=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
[ -z "$staged" ] && exit 0

hit_count=$(
    printf '%s\n' "$staged" \
        | xargs -I{} git show ":{}" 2>/dev/null \
        | grep -cE "$patterns" 2>/dev/null \
        || printf '0'
)

if [ -n "$hit_count" ] && [ "$hit_count" -gt 0 ]; then
    if command -v jq >/dev/null 2>&1; then
        jq -nc \
            --arg msg "safety-net: ${hit_count} danger-string hit(s) in staged content. Unstage the offending lines or update ${config}." \
            '{decision: "block", reason: $msg}'
    else
        printf '{"decision":"block","reason":"safety-net: %s danger-string hit(s) in staged content. Unstage the offending lines or update %s."}\n' "$hit_count" "$config"
    fi
fi

exit 0
