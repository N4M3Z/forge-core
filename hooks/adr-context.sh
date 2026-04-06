#!/usr/bin/env bash
set -euo pipefail

# adr-context — inject existing ADR index when creating a new ADR
# Event: PreToolUse (Write)

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$FILE_PATH" ] || exit 0

ADR_DIR="${FORGE_ADR_DIR:-docs/decisions}"
[[ "$FILE_PATH" == "$ADR_DIR"/*.md ]] || exit 0
[ -d "$ADR_DIR" ] || exit 0

# Only fire for new files (not edits to existing)
[ -f "$FILE_PATH" ] && exit 0

index=""
for file in "$ADR_DIR"/*.md; do
    [ -f "$file" ] || continue
    name=$(basename "$file" .md)
    index="${index}- ${name}\\n"
done

[ -n "$index" ] || exit 0

cat <<JSON
{
    "hookSpecificOutput": {
        "additionalContext": "Existing ADRs (check for duplicates before creating):\\n${index}"
    }
}
JSON
