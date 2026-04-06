#!/usr/bin/env bash
set -euo pipefail

# preserve-adrs — inject ADR index before compaction erases architectural context
# Event: PreCompact

cat > /dev/null

ADR_DIR="${FORGE_ADR_DIR:-docs/decisions}"
[ -d "$ADR_DIR" ] || exit 0

summary=""
for file in "$ADR_DIR"/*.md; do
    [ -f "$file" ] || continue
    title=$(grep -m1 '^title:' "$file" | sed 's/^title: *//;s/^"//;s/"$//')
    status=$(grep -m1 '^status:' "$file" | sed 's/^status: *//')
    [ -n "$title" ] || continue
    summary="${summary}- ${title} (${status})\\n"
done

[ -n "$summary" ] || exit 0

cat <<JSON
{
    "hookSpecificOutput": {
        "additionalContext": "Active ADRs:\\n${summary}"
    }
}
JSON
