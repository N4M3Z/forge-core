---
name: PublishPrompts
version: 0.2.0
description: "Provenance tracking and sync for inherited rules, skills, and agents. USE WHEN drift, sync, publish prompts, inheritance, upstream, propagate, adapt rules, check provenance."
---

# PublishPrompts

Track inheritance of rules, skills, and agents between forge modules and downstream company repos. Detects which files came from upstream, what's been adapted, and what upstream changes are available.

## Companion Script

`publish-prompts.sh` is a read-only drift reporter. It scans installed content against upstream module sources and reports provenance state. Manifests are written by the `forge install` command during `make install`.

```bash
bash Modules/forge-core/skills/PublishPrompts/publish-prompts.sh --type all --modules-dir Modules
```

For downstream repos (e.g., proton-agents):

```bash
bash skills/PublishPrompts/publish-prompts.sh --type all --modules-dir /path/to/forge/Modules
```

## Subskill Routing

| Keyword                          | Subskill | What it does                                |
|----------------------------------|----------|---------------------------------------------|
| "drift", "check", "status"      | Drift    | Scan and report provenance state            |
| "sync", "update", "propagate"   | Sync     | Pull upstream changes into adapted files    |
| "adopt", "add"                   | Adopt    | Start tracking a new upstream file          |
| "promote", "push upstream"       | Promote  | Push a local improvement back to forge      |
| "setup", "initialize"            | Setup    | Scaffold a downstream repo for inheritance  |

## Drift

Run the companion script to show the current state of all inherited content.

1. Run `publish-prompts.sh --type all` and present the table to the user.
2. Explain the states:
   - **pristine** — exact copy of upstream. Safe to auto-update.
   - **adapted** — intentionally modified from upstream. Needs manual review on sync.
   - **local** — not from any forge module. Not tracked.

## Sync

Propagate upstream changes to files tracked in the manifest.

1. Run `publish-prompts.sh --type all` to get current state.
2. For each file in the manifest, compare the current upstream body SHA against the manifest SHA:
   - **Match** → upstream unchanged since adoption. Nothing to do.
   - **Mismatch** → upstream has changed. Check local state:
     - **Pristine locally** → safe to auto-update. Copy upstream file, update manifest SHA.
     - **Adapted locally** → show 3-way context:
       - Read the upstream file (current version)
       - Read the local file (current version)
       - The manifest SHA is the common ancestor
       - Show what upstream changed (diff ancestor → upstream new)
       - Show what was customized locally (diff ancestor → local)
       - Ask user: accept upstream (reset to pristine), merge manually, or skip
3. After all decisions, update the manifest with new SHAs.

To compute the 3-way diff, use the manifest SHA to identify what the file looked like when it was adopted. If the upstream module is a git repo, you can retrieve the ancestor content:

```bash
# Find the commit where the upstream file had the adopted SHA
git -C Modules/forge-core log --all --format=%H -- rules/SelfLearning.md | while read commit; do
    sha=$(git -C Modules/forge-core show "$commit:rules/SelfLearning.md" | awk 'BEGIN{fm=0}/^---$/{fm++;next}fm>=2{print}' | shasum -a 256 | cut -d' ' -f1)
    if [ "${sha:0:8}" = "a3f047b9" ]; then
        echo "Ancestor commit: $commit"
        git -C Modules/forge-core show "$commit:rules/SelfLearning.md"
        break
    fi
done
```

## Adopt

Add a new upstream file to local tracking.

1. User specifies which upstream file to adopt (e.g., "adopt KnownIssues.md from forge-core").
2. Find the file in the specified module's `rules/`, `skills/`, or `agents/` directory.
3. Copy to the downstream repo's corresponding directory.
4. If the user wants to adapt it (e.g., strip forge branding, add `paths:` scoping), make the edits.
5. Run `make install` to regenerate the manifest with the new entry.

## Promote

Push a local improvement back upstream to a forge module.

1. User specifies which file to promote and which module it targets.
2. Read the local file and the manifest to identify the upstream module.
3. Show the diff between local and upstream (the adaptation).
4. Strip company-specific adaptations (paths: frontmatter, branding, project-specific references).
5. Copy the cleaned version to the forge module's source directory.
6. User commits in the forge module, pushes, bumps the submodule.
7. Remove the local override if it's now identical to upstream.
8. Run `make install` to update the manifest.

## Setup

Initialize a downstream repo for inheritance tracking.

1. Verify the repo has forge modules accessible (as submodules or at a known path).
2. Run the full provenance scan to identify existing inherited content.
3. Present the scan results — the user confirms which files should be tracked.
4. Suggest Makefile additions for 2-phase install (upstream → local overlay).
5. Run `make install` to generate manifests for all tracked content.

## Manifest Format

All three artifact types (rules, skills, agents) use a unified SHA map format. The `.manifest` file is written by install binaries during `make install` and grouped by source module:

```yaml
forge-core:
    GitConventions.md: 8f4ca9a50b03d3043a53d0007965a5dcf182bb236cea5f27...
    KeepChangelog.md: 1de3b2a8c0681396c7bd76be217f688958f44cf4a186c52c...
forge-council:
    AgentTeams.md: e1ae3ab285bc4d502508989d26ab41922e603908c78b61b9...
```

For rules and agents, the SHA is the body hash of the upstream source file (frontmatter stripped). For skills, it's the body hash of `SKILL.md`. State is computed at scan time:

- Installed body SHA matches manifest SHA → **pristine**
- Installed body SHA differs from manifest SHA → **adapted**
- Upstream source SHA differs from manifest SHA → **upstream updated** (sync available)
- File not in manifest → **local** (not tracked)

## Constraints

- Never auto-update adapted files — always show the diff and ask
- The manifest records upstream SHAs, not local SHAs — it's the merge-base
- Local-only files are never added to the manifest
- Strip forge branding per ContextualNaming when adopting files downstream
- Manifests are written by `forge install`, not by the companion script
