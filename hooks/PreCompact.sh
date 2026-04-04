#!/usr/bin/env bash
# PreCompact hook: flag ADR capture opportunity before context compaction.
set -euo pipefail

command -v yaml >/dev/null || exit 0

MODULE_ROOT="${FORGE_MODULE_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(command cd "$(dirname "$0")/.." && pwd)}}"

eval "$(yaml env "$MODULE_ROOT" adr --prefix FORGE_ADR)"

ADR_DIR="${FORGE_ADR_DIRECTORY:-docs/decisions}"
[ -d "$ADR_DIR" ] || exit 0

INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | command grep -o '"session_id":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$SESSION_ID" ] || exit 0

TRANSCRIPT=$(printf '%s' "$INPUT" | command grep -o '"transcript_path":"[^"]*"' | head -1 | cut -d'"' -f4)

command mkdir -p "$MODULE_ROOT/logs/claude"

printf '%s\n' \
    "session_id=${SESSION_ID}" \
    "transcript_path=${TRANSCRIPT}" \
    "adr_dir=${ADR_DIR}" \
    "cwd=$(pwd)" \
    "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    > "$MODULE_ROOT/logs/claude/${SESSION_ID}.session"
