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

SLUG=$(basename "$PLAN_FILE")
DATE_PREFIX=$(date +%Y-%m-%d)
command cp "$PLAN_FILE" "$DEST_DIR/${DATE_PREFIX}-${SLUG}"
