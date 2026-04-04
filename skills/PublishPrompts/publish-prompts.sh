#!/usr/bin/env bash
# publish-prompts — read-only provenance scan and drift detection for rules, skills, agents
# Usage: publish-prompts.sh [--type rules|skills|agents|all] [--modules-dir DIR] [--target-dir DIR]
#
# Scans target directory against all forge modules to determine provenance.
# Manifests are written by the forge install command.
set -euo pipefail

TYPE="all"
MODULES_DIR=""
TARGET_DIR=""

while [ $# -gt 0 ]; do
    case "$1" in
        --type)       TYPE="$2"; shift 2 ;;
        --modules-dir) MODULES_DIR="$2"; shift 2 ;;
        --target-dir) TARGET_DIR="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: publish-prompts.sh [--type rules|skills|agents|all] [--modules-dir DIR] [--target-dir DIR]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --- Resolve paths ---
SCRIPT_DIR="$(command cd "$(dirname "$0")" && pwd)"
MODULE_ROOT="${SCRIPT_DIR%/skills/PublishPrompts}"
FORGE_ROOT="${FORGE_ROOT:-${MODULE_ROOT%/Modules/forge-core}}"

if [ -z "$MODULES_DIR" ]; then
    MODULES_DIR="$FORGE_ROOT/Modules"
fi

# --- SHA computation ---
body_sha() {
    if head -1 "$1" | grep -q '^---$'; then
        awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$1" | shasum -a 256 | cut -d' ' -f1
    else
        shasum -a 256 < "$1" | cut -d' ' -f1
    fi
}

# --- Provenance scan for a single artifact type ---
scan_type() {
    local artifact_type="$1"  # rules, skills, agents
    local target_dir="$2"

    if [ ! -d "$target_dir" ]; then
        return
    fi

    echo "## ${artifact_type^}"
    echo ""
    printf "| %-35s | %-16s | %-10s | %-8s |\n" "File" "Module" "State" "SHA"
    printf "| %-35s | %-16s | %-10s | %-8s |\n" "---" "---" "---" "---"

    # Determine file pattern based on type
    local files
    if [ "$artifact_type" = "skills" ]; then
        files=$(find "$target_dir" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | sort)
    else
        files=$(find "$target_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)
    fi

    while IFS= read -r f; do
        [ -z "$f" ] && continue
        local name
        if [ "$artifact_type" = "skills" ]; then
            name=$(basename "$(dirname "$f")")
        else
            name=$(basename "$f")
        fi

        # Search all modules for this file
        local found_module=""
        local upstream_sha=""
        for m in "$MODULES_DIR"/*/; do
            [ -d "$m" ] || continue
            local mname
            mname=$(basename "$m")
            local upstream_path
            if [ "$artifact_type" = "skills" ]; then
                upstream_path="$m/$artifact_type/$name/SKILL.md"
            else
                upstream_path="$m/$artifact_type/$name"
            fi
            if [ -f "$upstream_path" ]; then
                found_module="$mname"
                upstream_sha=$(body_sha "$upstream_path")
                break
            fi
        done

        # Same-repo provenance: check if the repo root has the source file
        if [ -z "$found_module" ]; then
            local repo_root
            repo_root="$(pwd)"
            local src_path
            if [ "$artifact_type" = "skills" ]; then
                src_path="$repo_root/$artifact_type/$name/SKILL.md"
            else
                src_path="$repo_root/$artifact_type/$name"
            fi
            local target_real
            target_real="$(cd "$target_dir" && pwd)"
            local src_dir_real
            src_dir_real="$(cd "$(dirname "$src_path")" 2>/dev/null && pwd)" || true
            if [ -f "$src_path" ] && [ "$src_dir_real" != "$target_real" ]; then
                found_module="$(basename "$repo_root")"
                upstream_sha=$(body_sha "$src_path")
            fi
        fi

        local local_sha
        local_sha=$(body_sha "$f")

        if [ -n "$found_module" ]; then
            if [ "$upstream_sha" = "$local_sha" ]; then
                local state="pristine"
            else
                local state="adapted"
            fi
            printf "| %-35s | %-16s | %-10s | %.8s |\n" "$name" "$found_module" "$state" "$upstream_sha"
        else
            printf "| %-35s | %-16s | %-10s | %-8s |\n" "$name" "—" "local" "—"
        fi
    done <<< "$files"

    echo ""
}

# --- Target resolution ---
# For --type all, --target-dir is a base (e.g., .claude) and the type is appended.
# For individual types, --target-dir points directly to the type directory.
# Auto-detection prefers .claude/<type> (installed) over <type> (source).
resolve_target() {
    local t="$1" explicit="$2"
    if [ -n "$explicit" ]; then
        echo "$explicit"
    elif [ -d "$(pwd)/.claude/$t" ]; then
        echo "$(pwd)/.claude/$t"
    elif [ -d "$(pwd)/$t" ]; then
        echo "$(pwd)/$t"
    elif [ -d "$FORGE_ROOT/$t" ]; then
        echo "$FORGE_ROOT/$t"
    fi
}

# --- Main ---
case "$TYPE" in
    rules|skills|agents)
        target=$(resolve_target "$TYPE" "$TARGET_DIR")
        if [ -n "$target" ] && [ -d "$target" ]; then
            scan_type "$TYPE" "$target"
        fi
        ;;
    all)
        for t in rules skills agents; do
            if [ -n "$TARGET_DIR" ]; then
                target=$(resolve_target "$t" "$TARGET_DIR/$t")
            else
                target=$(resolve_target "$t" "")
            fi
            if [ -n "$target" ] && [ -d "$target" ]; then
                scan_type "$t" "$target"
            fi
        done
        ;;
    *)
        echo "Unknown type: $TYPE (use rules, skills, agents, or all)" >&2
        exit 1
        ;;
esac
