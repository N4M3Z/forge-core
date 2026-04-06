#!/usr/bin/env bash
set -euo pipefail

# guard-naming — block misnamed artifacts
# Event: PreToolUse (Write)

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$FILE_PATH" ] || exit 0
[[ "$FILE_PATH" == *.md ]] || exit 0

base=$(basename "$FILE_PATH" .md)
[[ "$base" == .* ]] && exit 0

block() {
    cat <<JSON
{
    "decision": "block",
    "reason": "$1"
}
JSON
    exit 0
}

is_pascal() { printf '%s' "$1" | grep -qE '^[A-Z][a-zA-Z0-9]+$'; }

# Skills: directory must be PascalCase
if [[ "$FILE_PATH" == skills/*/SKILL.md ]]; then
    dir_name=$(printf '%s' "$FILE_PATH" | cut -d/ -f2)
    is_pascal "$dir_name" || block "Skill directory '${dir_name}' must be PascalCase"

# Agents: PascalCase filename
elif [[ "$FILE_PATH" == agents/*.md ]]; then
    is_pascal "$base" || block "Agent '${base}.md' must be PascalCase"

# Rules: PascalCase filename (root and qualifier subdirs)
elif [[ "$FILE_PATH" == rules/*.md ]] || [[ "$FILE_PATH" == rules/*/*.md ]]; then
    is_pascal "$base" || block "Rule '${base}.md' must be PascalCase"

# ADRs: PREFIX-NNNN Title format
elif [[ "$FILE_PATH" == docs/decisions/*.md ]]; then
    printf '%s' "$base" | grep -qE '^[A-Z]+-[0-9]+ .+' || block "ADR '${base}.md' must match PREFIX-NNNN Title"
fi
