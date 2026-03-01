#!/usr/bin/env bash
# system-check — forge ecosystem staleness diagnostic
# Usage: system-check.sh [--verbose]
#
# Checks six staleness vectors and outputs a structured report.
# Read-only — never modifies files.

set -uo pipefail

VERBOSE=false
[ "${1:-}" = "--verbose" ] && VERBOSE=true

# --- Resolve paths ---
SCRIPT_DIR="$(command cd "$(dirname "$0")" && pwd)"
MODULE_ROOT="${SCRIPT_DIR%/skills/SystemCheck}"
FORGE_ROOT="${FORGE_ROOT:-${MODULE_ROOT%/Modules/forge-core}}"
CLAUDE_SKILLS="$FORGE_ROOT/.claude/skills"
BIN_DIR="$HOME/.local/bin"

# Module list
MODULE_LIST=$(yq '.modules[]' "$FORGE_ROOT/defaults.yaml" 2>/dev/null \
    || "$FORGE_ROOT/Core/target/release/yaml" list "$FORGE_ROOT/defaults.yaml" modules 2>/dev/null \
    || echo "")

# Vault skills path (from config.yaml user.root)
USER_ROOT_REL=$(awk '/^  root:/{gsub(/"/,"",$2); if($2!="") {print $2; exit}}' "$FORGE_ROOT/config.yaml" 2>/dev/null || true)
if [ -n "$USER_ROOT_REL" ]; then
    case "$USER_ROOT_REL" in
        /*) USER_ROOT="$USER_ROOT_REL" ;;
        *)  USER_ROOT="$FORGE_ROOT/$USER_ROOT_REL" ;;
    esac
    VAULT_SKILLS="$USER_ROOT/Orchestration/Skills"
else
    VAULT_SKILLS=""
fi

# --- Counters ---
total_pass=0
total_fail=0

print_status() {
    local check="$1" status="$2" detail="$3"
    printf "| %-18s | %-19s | %s\n" "$check" "$status" "$detail"
}

# Strip YAML frontmatter, return body only
strip_body() {
    awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$1"
}

# =============================================================================
# Check 1: Installed Skills vs Source (manifest-based)
# =============================================================================
skills_stale=0
skills_orphan=0
skills_fresh=0
skills_ghost_module=0
skills_detail=""
MANIFEST="$CLAUDE_SKILLS/.manifest"

if [ -f "$MANIFEST" ]; then
    # Lookup: find which module owns a skill via .manifest
    manifest_module_for() {
        local target="$1" current=""
        while IFS= read -r line; do
            case "$line" in
                *:) current="${line%:}" ;;
                "- $target") echo "$current"; return ;;
            esac
        done < "$MANIFEST"
    }

    # Check each installed skill against its manifest source
    for installed_dir in "$CLAUDE_SKILLS"/*/; do
        [ -d "$installed_dir" ] || continue
        skill=$(basename "$installed_dir")
        installed_md="$installed_dir/SKILL.md"
        [ -f "$installed_md" ] || continue

        mod=$(manifest_module_for "$skill")

        if [ -z "$mod" ]; then
            # Not in manifest — orphaned (manually copied or from removed module)
            skills_orphan=$((skills_orphan + 1))
            $VERBOSE && skills_detail="$skills_detail  orphan: $skill (not in .manifest)"$'\n'
            continue
        fi

        # Resolve source path: Modules/$mod/skills/ or vault
        source_md=""
        if [ -f "$FORGE_ROOT/Modules/$mod/skills/$skill/SKILL.md" ]; then
            source_md="$FORGE_ROOT/Modules/$mod/skills/$skill/SKILL.md"
        elif [ -n "$VAULT_SKILLS" ] && [ -f "$VAULT_SKILLS/$skill/SKILL.md" ]; then
            source_md="$VAULT_SKILLS/$skill/SKILL.md"
        fi

        if [ -z "$source_md" ]; then
            # Manifest says module $mod owns it, but source is gone
            skills_ghost_module=$((skills_ghost_module + 1))
            $VERBOSE && skills_detail="$skills_detail  ghost: $skill (manifest says $mod, source missing)"$'\n'
            continue
        fi

        # Compare body only (install-skills merges claude: keys into frontmatter)
        installed_hash=$(strip_body "$installed_md" | shasum -a 256 | awk '{print $1}')
        source_hash=$(strip_body "$source_md" | shasum -a 256 | awk '{print $1}')

        if [ "$installed_hash" != "$source_hash" ]; then
            skills_stale=$((skills_stale + 1))
            $VERBOSE && skills_detail="$skills_detail  stale: $skill ($mod)"$'\n'
        else
            skills_fresh=$((skills_fresh + 1))
        fi
    done
else
    # No manifest — fall back to directory scan
    for installed_dir in "$CLAUDE_SKILLS"/*/; do
        [ -d "$installed_dir" ] || continue
        skill=$(basename "$installed_dir")
        installed_md="$installed_dir/SKILL.md"
        [ -f "$installed_md" ] || continue

        source_md=""
        for search_dir in "$FORGE_ROOT/Core/skills" "$FORGE_ROOT"/Modules/*/skills; do
            if [ -f "$search_dir/$skill/SKILL.md" ]; then
                source_md="$search_dir/$skill/SKILL.md"
                break
            fi
        done
        if [ -z "$source_md" ] && [ -n "$VAULT_SKILLS" ] && [ -f "$VAULT_SKILLS/$skill/SKILL.md" ]; then
            source_md="$VAULT_SKILLS/$skill/SKILL.md"
        fi

        if [ -z "$source_md" ]; then
            skills_orphan=$((skills_orphan + 1))
            $VERBOSE && skills_detail="$skills_detail  orphan: $skill"$'\n'
            continue
        fi

        installed_hash=$(strip_body "$installed_md" | shasum -a 256 | awk '{print $1}')
        source_hash=$(strip_body "$source_md" | shasum -a 256 | awk '{print $1}')

        if [ "$installed_hash" != "$source_hash" ]; then
            skills_stale=$((skills_stale + 1))
            $VERBOSE && skills_detail="$skills_detail  stale: $skill"$'\n'
        else
            skills_fresh=$((skills_fresh + 1))
        fi
    done
fi

skills_total=$((skills_fresh + skills_stale + skills_orphan + skills_ghost_module))
if [ "$skills_stale" -eq 0 ] && [ "$skills_orphan" -eq 0 ] && [ "$skills_ghost_module" -eq 0 ]; then
    c1_status="FRESH"
    c1_detail="$skills_total skills"
    total_pass=$((total_pass + 1))
else
    parts=""
    [ "$skills_stale" -gt 0 ] && parts="${skills_stale} stale"
    [ "$skills_orphan" -gt 0 ] && parts="${parts:+$parts, }${skills_orphan} orphaned"
    [ "$skills_ghost_module" -gt 0 ] && parts="${parts:+$parts, }${skills_ghost_module} ghost"
    c1_status="STALE ($parts)"
    c1_detail="$skills_fresh/$skills_total fresh"
    total_fail=$((total_fail + 1))
fi

# =============================================================================
# Check 2: Binary Freshness
# =============================================================================
bins_stale=0
bins_fresh=0
bins_detail=""

for link in "$BIN_DIR"/*; do
    [ -L "$link" ] || continue
    target=$(readlink "$link" 2>/dev/null)

    case "$target" in
        "$FORGE_ROOT"*) ;;
        *) continue ;;
    esac

    bin_name=$(basename "$link")
    if [ ! -f "$target" ]; then
        bins_stale=$((bins_stale + 1))
        $VERBOSE && bins_detail="$bins_detail  missing: $bin_name"$'\n'
        continue
    fi

    # Find crate root (up from target/release/binary)
    crate_dir=$(dirname "$(dirname "$(dirname "$target")")")
    [ -d "$crate_dir/src" ] || continue

    newer=$(find "$crate_dir/src" -name '*.rs' -newer "$target" 2>/dev/null | head -1)
    if [ -n "$newer" ]; then
        bins_stale=$((bins_stale + 1))
        $VERBOSE && bins_detail="$bins_detail  stale: $bin_name"$'\n'
    else
        bins_fresh=$((bins_fresh + 1))
    fi
done

if [ "$bins_stale" -eq 0 ]; then
    c2_status="FRESH"
    c2_detail="$bins_fresh binaries"
    total_pass=$((total_pass + 1))
else
    c2_status="STALE ($bins_stale)"
    c2_detail="$bins_fresh/$((bins_fresh + bins_stale)) fresh"
    total_fail=$((total_fail + 1))
fi

# =============================================================================
# Check 3: Lib Submodule Consistency
# =============================================================================
lib_commits=""
lib_detail=""
lib_count=0

for lib_dir in "$FORGE_ROOT"/Modules/*/lib; do
    [ -d "$lib_dir" ] || continue
    [ -e "$lib_dir/.git" ] || continue
    mod=$(basename "$(dirname "$lib_dir")")
    sha=$(command git -C "$lib_dir" rev-parse HEAD 2>/dev/null || echo "unknown")
    short="${sha:0:7}"
    lib_commits="$lib_commits$sha"$'\n'
    lib_count=$((lib_count + 1))
    $VERBOSE && lib_detail="$lib_detail  $mod: $short"$'\n'
done

unique=$(printf '%s' "$lib_commits" | sort -u | grep -c . || true)

if [ "$unique" -le 1 ]; then
    canonical=$(printf '%s' "$lib_commits" | sort -u | head -1)
    c3_status="CONSISTENT"
    c3_detail="${canonical:0:7} across $lib_count modules"
    total_pass=$((total_pass + 1))
else
    c3_status="DRIFT ($unique commits)"
    c3_detail="$lib_count modules"
    total_fail=$((total_fail + 1))
fi

# =============================================================================
# Check 4: Version Drift
# =============================================================================
drift_count=0
drift_detail=""

for mod in $MODULE_LIST; do
    mod_dir="$FORGE_ROOT/Modules/$mod"
    [ -d "$mod_dir" ] || continue

    v_module="" v_plugin="" v_cargo=""
    [ -f "$mod_dir/module.yaml" ] && v_module=$(awk '/^version:/{gsub(/"/,""); print $2; exit}' "$mod_dir/module.yaml" 2>/dev/null)
    [ -f "$mod_dir/.claude-plugin/plugin.json" ] && v_plugin=$(python3 -c "import json; print(json.load(open('$mod_dir/.claude-plugin/plugin.json')).get('version',''))" 2>/dev/null)
    [ -f "$mod_dir/Cargo.toml" ] && v_cargo=$(awk -F'"' '/^version/{print $2; exit}' "$mod_dir/Cargo.toml" 2>/dev/null)

    versions=""
    [ -n "$v_module" ] && versions="$versions $v_module"
    [ -n "$v_plugin" ] && versions="$versions $v_plugin"
    [ -n "$v_cargo" ] && versions="$versions $v_cargo"

    unique_v=$(echo "$versions" | tr ' ' '\n' | grep -v '^$' | sort -u | wc -l | tr -d ' ')
    if [ "$unique_v" -gt 1 ]; then
        drift_count=$((drift_count + 1))
        labels=""
        [ -n "$v_module" ] && labels="${labels}module=$v_module "
        [ -n "$v_plugin" ] && labels="${labels}plugin=$v_plugin "
        [ -n "$v_cargo" ] && labels="${labels}cargo=$v_cargo"
        $VERBOSE && drift_detail="$drift_detail  $mod: $labels"$'\n'
    fi
done

if [ "$drift_count" -eq 0 ]; then
    c4_status="CLEAN"
    c4_detail="all versions aligned"
    total_pass=$((total_pass + 1))
else
    c4_status="DRIFT ($drift_count)"
    c4_detail="$drift_count modules mismatched"
    total_fail=$((total_fail + 1))
fi

# =============================================================================
# Check 5: Submodule Pointer Drift
# =============================================================================
sub_dirty=0
sub_detail=""

while IFS= read -r line; do
    [ -z "$line" ] && continue
    prefix="${line:0:1}"
    mod=$(echo "$line" | sed 's/^[+ -]//' | awk '{print $2}')
    case "$prefix" in
        +) sub_dirty=$((sub_dirty + 1)); $VERBOSE && sub_detail="$sub_detail  ahead: $mod"$'\n' ;;
        -) sub_dirty=$((sub_dirty + 1)); $VERBOSE && sub_detail="$sub_detail  not init: $mod"$'\n' ;;
    esac
done < <(command git -C "$FORGE_ROOT" submodule status 2>&1)

if [ "$sub_dirty" -eq 0 ]; then
    c5_status="CLEAN"
    c5_detail="all pointers match HEAD"
    total_pass=$((total_pass + 1))
else
    c5_status="DIRTY ($sub_dirty)"
    c5_detail="$sub_dirty submodules diverged"
    total_fail=$((total_fail + 1))
fi

# =============================================================================
# Check 6: Hook Config Completeness
# =============================================================================
SETTINGS="$FORGE_ROOT/.claude/settings.json"
EXPECTED="SessionStart PreToolUse PostToolUse Stop PreCompact UserPromptSubmit SubagentStop SessionEnd Notification"

if [ ! -f "$SETTINGS" ]; then
    c6_status="MISSING"
    c6_detail="no .claude/settings.json"
    total_fail=$((total_fail + 1))
else
    hooks_missing=0
    hooks_detail=""
    for event in $EXPECTED; do
        if ! python3 -c "import json; h=json.load(open('$SETTINGS')).get('hooks',{}); assert '$event' in h" 2>/dev/null; then
            hooks_missing=$((hooks_missing + 1))
            hooks_detail="$hooks_detail $event"
        fi
    done

    if [ "$hooks_missing" -eq 0 ]; then
        c6_status="COMPLETE"
        c6_detail="all 9 events configured"
        total_pass=$((total_pass + 1))
    else
        c6_status="MISSING ($hooks_missing)"
        c6_detail="$hooks_detail"
        total_fail=$((total_fail + 1))
    fi
fi

# =============================================================================
# Report
# =============================================================================
echo "=== System Check ==="
echo "| Check              | Status              | Details"
echo "|--------------------|---------------------|--------"
print_status "Installed Skills" "$c1_status" "$c1_detail"
print_status "Binaries" "$c2_status" "$c2_detail"
print_status "Lib Consistency" "$c3_status" "$c3_detail"
print_status "Version Drift" "$c4_status" "$c4_detail"
print_status "Submodule Pointers" "$c5_status" "$c5_detail"
print_status "Hook Config" "$c6_status" "$c6_detail"
echo ""

if [ "$total_fail" -eq 0 ]; then
    echo "All checks passed."
else
    echo "Fixes:"
    [ "$skills_stale" -gt 0 ] || [ "$skills_orphan" -gt 0 ] && echo "  Skills:     make install-skills"
    [ "$bins_stale" -gt 0 ] && echo "  Binaries:   make build && make install-binaries"
    [ "$unique" -gt 1 ] 2>/dev/null && echo "  Lib drift:  update lib submodules to canonical commit"
    [ "$drift_count" -gt 0 ] && echo "  Versions:   align versions in affected modules"
    [ "$sub_dirty" -gt 0 ] && echo "  Submodules: commit parent repo"
    [ "${hooks_missing:-0}" -gt 0 ] && echo "  Hooks:      make install-hooks"
fi

# Verbose detail
if $VERBOSE; then
    echo ""
    [ -n "$skills_detail" ] && printf '%s\n%s' "--- Installed Skills ---" "$skills_detail"
    [ -n "$bins_detail" ] && printf '%s\n%s' "--- Binaries ---" "$bins_detail"
    [ -n "$lib_detail" ] && printf '%s\n%s' "--- Lib Submodules ---" "$lib_detail"
    [ -n "$drift_detail" ] && printf '%s\n%s' "--- Version Drift ---" "$drift_detail"
    [ -n "$sub_detail" ] && printf '%s\n%s' "--- Submodule Pointers ---" "$sub_detail"
fi
