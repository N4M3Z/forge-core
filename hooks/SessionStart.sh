#!/usr/bin/env bash
# SessionStart hook: prompt ADR capture after compaction.
set -euo pipefail

INPUT=$(cat)
SOURCE=$(printf '%s' "$INPUT" | command grep -o '"source":"[^"]*"' | head -1 | cut -d'"' -f4)
[ "$SOURCE" = "compact" ] || [ "$SOURCE" = "resume" ] || exit 0

MODULE_ROOT="${FORGE_MODULE_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(command cd "$(dirname "$0")/.." && pwd)}}"

# Load prompt from config/defaults if yaml is available
if command -v yaml >/dev/null; then
    eval "$(yaml env "$MODULE_ROOT" hooks.ArchitectureDecision --prefix FORGE_ADR_HOOK)"
fi

echo "${FORGE_ADR_HOOK_PROMPT:-If the compacted context contained architectural decisions, pattern choices, or convention changes worth preserving, invoke the ArchitectureDecision skill to capture them as ADRs.}"
