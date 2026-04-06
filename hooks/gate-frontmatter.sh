#!/usr/bin/env bash
set -euo pipefail

# gate-frontmatter — block .md writes that violate .mdschema
# Event: PreToolUse (Write|Edit)

INPUT=$(cat)
command -v mdschema >/dev/null 2>&1 || exit 0

FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$FILE_PATH" ] || exit 0
[[ "$FILE_PATH" == *.md ]] || exit 0

# Walk up from file directory to find nearest .mdschema
SCHEMA=""
dir=$(dirname "$FILE_PATH")
while [ "$dir" != "." ] && [ "$dir" != "/" ]; do
    if [ -f "$dir/.mdschema" ]; then
        SCHEMA="$dir/.mdschema"
        break
    fi
    dir=$(dirname "$dir")
done
# Check current directory too
[ -z "$SCHEMA" ] && [ -f ".mdschema" ] && SCHEMA=".mdschema"

[ -n "$SCHEMA" ] || exit 0

if ! errors=$(mdschema check "$FILE_PATH" --schema "$SCHEMA" 2>&1); then
    cat <<JSON
{
    "decision": "block",
    "reason": "Schema violation in ${FILE_PATH}:\\n${errors}"
}
JSON
fi
