#!/usr/bin/env bash
# PostToolUse hook: archive plan files to vault on ExitPlanMode.
# Passive mode — output discarded, errors to stderr only.
set -euo pipefail

command -v yq >/dev/null || exit 0

MODULE_ROOT="${FORGE_MODULE_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(command cd "$(dirname "$0")/.." && pwd)}}"

INPUT=$(cat)

TOOL_NAME=$(printf '%s' "$INPUT" | yq -p json '.tool_name // ""')
if [ "$TOOL_NAME" != "ExitPlanMode" ]; then
    exit 0
fi

if [ "${FORGE_DEBUG:-0}" = "1" ]; then
    printf '%s' "$INPUT" > /tmp/plan-hook-debug.json
fi

PLAN_FILE=$(command ls -t "$HOME/.claude/plans/"*.md 2>/dev/null | head -1)
if [ -z "$PLAN_FILE" ]; then
    exit 0
fi

USER_ROOT="${FORGE_USER_ROOT:-}"
if [ -z "$USER_ROOT" ]; then
    exit 0
fi

CONFIG="${MODULE_ROOT}/config.yaml"
DEFAULTS="${MODULE_ROOT}/defaults.yaml"
DEST_REL=""

if [ -f "$CONFIG" ]; then
    DEST_REL=$(yq '.hooks.PlanCopy.destination // ""' "$CONFIG")
fi

if [ -z "$DEST_REL" ] && [ -f "$DEFAULTS" ]; then
    DEST_REL=$(yq '.hooks.PlanCopy.destination // ""' "$DEFAULTS")
fi

if [ -z "$DEST_REL" ]; then
    DEST_REL="Resources/Plans/Claude"
fi

DEST_DIR="$USER_ROOT/$DEST_REL"
command mkdir -p "$DEST_DIR"

# Extract heading — grep skips frontmatter, handles "# Plan: X" and bare "# X"
HEADING=$(grep -m1 '^# ' "$PLAN_FILE" | sed 's/^# Plan: *//;s/^# *//' || true)

# Sanitize: replace filesystem-unsafe chars (/ \ : * ? " < > |) with -, truncate to 80
NAME=$(printf '%s' "$HEADING" | tr '/:*?<>|' '-' | tr $'\\\\' '-' | cut -c1-80)

# Fallback to original basename if name is empty (no heading, etc.)
if [ -z "$NAME" ]; then
    NAME=$(basename "$PLAN_FILE" .md)
fi

DATE_PREFIX=$(date +%Y-%m-%d)
BASE="${DATE_PREFIX} ${NAME}"
OUT="${BASE}.md"
N=1
while [ -f "$DEST_DIR/$OUT" ] && [ "$N" -le 99 ]; do
    OUT="${BASE} ${N}.md"
    N=$((N + 1))
done

# Resolve template path
TEMPLATE_PATH=""
if [ -f "$CONFIG" ]; then
    TEMPLATE_PATH=$(yq '.hooks.PlanCopy.template // ""' "$CONFIG")
fi
if [ -z "$TEMPLATE_PATH" ] && [ -f "$DEFAULTS" ]; then
    TEMPLATE_PATH=$(yq '.hooks.PlanCopy.template // ""' "$DEFAULTS")
fi

if [ -n "$TEMPLATE_PATH" ]; then
    case "$TEMPLATE_PATH" in
        /*) ;; # absolute — use as-is
        *)  TEMPLATE_PATH="$MODULE_ROOT/$TEMPLATE_PATH" ;;
    esac
fi

# Apply template or raw copy
if [ -n "$TEMPLATE_PATH" ] && [ -f "$TEMPLATE_PATH" ] && grep -q '{{CONTENT}}' "$TEMPLATE_PATH"; then
    {
        while IFS= read -r line || [ -n "$line" ]; do
            if [ "$line" = '{{CONTENT}}' ]; then
                cat "$PLAN_FILE"
            else
                line="${line//\{\{TITLE\}\}/$NAME}"
                line="${line//\{\{DATE\}\}/$DATE_PREFIX}"
                printf '%s\n' "$line"
            fi
        done < "$TEMPLATE_PATH"
    } > "$DEST_DIR/$OUT"
else
    command cp "$PLAN_FILE" "$DEST_DIR/$OUT"
fi

if [ "${FORGE_DEBUG:-0}" = "1" ]; then
    echo "PlanCopy: source=$PLAN_FILE dest=$DEST_DIR/$OUT template=${TEMPLATE_PATH:-none}" >&2
fi
