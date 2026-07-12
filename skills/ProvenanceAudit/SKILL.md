---
name: ProvenanceAudit
version: 0.1.0
description: "Audit forge module provenance and deployment integrity — inspect deployed sidecars, detect drift, clean stale artifacts after renames, trace adoption chains. USE WHEN running forge provenance, auditing a deployed target, debugging drift, cleaning up after a skill rename, or investigating sidecar state."
allowed-tools: Bash, Read, Grep, Glob
---

# ProvenanceAudit

Operational procedures for auditing `.provenance/` sidecars in forge deployments and source repos. `forge provenance` checks deployment integrity: it reads sidecar SLSA attestations, compares the recorded SHA-256 digest against the deployed file content, and reports per-module verification rates. Complements [NoVendorLockIn][ASM] (how assembly rewrites sidecars).

## Manifest vs provenance

The two records answer different questions:

- **Provenance**: "what produced this file?"
- **Manifest**: "was this deployed file modified since we last put it there?"

The manifest is created when files land at the target, whether via `forge deploy` (from `build/`) or `forge copy` (direct from source). It lives at the target as a `.manifest` dotfile.

Provenance lives at two layers. Source-side `.provenance/` records adoption (`adopt/v1`): upstream URL, pinned commit, transform skills applied. Build-side `build/<provider>/.provenance/` records assembly (`assemble/v1`), regenerated on every install.

## Audit a deployed target

`forge provenance` expects a deployed provider directory (`~/.claude`, `~/.opencode`, `~/.codex`, `~/.gemini`) — the deploy sidecars it reads are written by `forge install` in `assemble/v1` form. Running it against a source module (`forge provenance` inside a repo, where `--target` defaults to `.`) reports every subject as orphan, because source sidecars use `adopt/v1` or `init/v1` buildTypes that the audit reader doesn't resolve.

```sh
forge provenance --target ~/.claude                  # audit user-scope deployment
forge provenance --target ~/.claude --show-orphans   # include unverified files
forge provenance --target ~/.claude --json           # machine-readable output
```

Per-module results look like:

```
https://github.com/N4M3Z/forge-core → ✓ 156 verified
https://github.com/N4M3Z/forge-dev  → ✓ 53 verified
forge-text                           → ✗ 21/22 verified
```

A `✗` means at least one deployed file's digest doesn't match its sidecar — either a post-deploy edit or a tamper. Diff the deployed file against `build/<provider>/<path>` to identify what drifted.

## Compare two trees

`forge drift` compares a module against an upstream reference, or verifies a module's assembled build against where it was deployed.

```sh
forge drift --source . --upstream ~/upstream-module   # this module vs an upstream module tree
forge drift --target ~                                 # build/<provider> vs ~/.<provider>, scoped to this module
```

`--upstream` compares two module trees by name. `--target <BASE>` mirrors `forge install --target <BASE>`: it diffs each `build/<provider>` against `<BASE>/<provider-target>`, scoped to this module's files via the deployed `.manifest` and provenance attribution, so other modules sharing the deployment are never reported. The two modes are mutually exclusive.

Do not compare source against deployed content directly: assembly transforms (frontmatter stripping, heading removal) always show as drift. Use `--target` to verify the build, or `--upstream` for a like-for-like module comparison.

## Trace an adoption chain

Deployed sidecars carry the `assemble/v1` buildType with a single input (the source file). The richer `adopt/v1` sidecar — with upstream URL, pinned commit, AdoptArtifact reference, and transform-skill digests — exists only in the source repo.

```sh
cat agents/.provenance/SkillReviewer.yaml
# resolvedDependencies:
#   - name: upstream
#     uri: https://raw.githubusercontent.com/...
#     digest: sha256:...
#   - name: AdoptArtifact
#     uri: forge-core/skills/AdoptArtifact/SKILL.md
#     digest: sha256:...
```

## Clean stale deployments after a rename

`forge install` is additive, not idempotent for renames. After renaming `skills/OldName` → `skills/NewName` and reinstalling, the old directory persists at every deployed target. Explicit cleanup is required across every provider:

```sh
for provider in .claude .codex .opencode .gemini; do
    dir="$HOME/$provider/skills/OldName"
    [ -d "$dir" ] && rm -rf "$dir"
done
```

If the safety-net plugin blocks `rm -rf` paths outside cwd, use a per-file loop (`find "$dir" -type f -delete; find "$dir" -type d -empty -delete`) or ask the user to run the cleanup in their terminal.

After cleanup, confirm: `ls ~/.claude/skills/ | grep -iE "OldName|NewName"` should return only `NewName`.

## Update sidecars across the rename's blast radius

Renaming a skill, agent, or transform that appears as a `resolvedDependencies` entry in OTHER artifacts' sidecars has ecosystem-wide impact. Every sidecar referencing the old identifier (name, uri, digest if the content changed) must be updated:

```sh
# Find all sidecars that reference the old name as a dependency
rg -l "name: OldName" --glob "**/.provenance/*.yaml"
```

Before calling a rename complete, grep every checked-out forge module repo for the old name — sidecars in sibling modules are the most-missed targets.

## Debug orphan reports

`--show-orphans` lists deployed files with no sidecar. Common causes:

- File was added manually (bypassing `forge install`) — reinstall or delete
- Sidecar naming mismatch — forge expects `<basename>.yaml` but some writers produce `<basename>.md.yaml` (see [forge-cli#31][CLI31])

Known forge-cli limitations: `adopt/v1` sidecars aren't rendered by the CLI (schema mismatch on `externalParameters.source` — see [forge-cli#30][CLI30]). For those, `cat` the YAML directly.

[ASM]: ../../rules/NoVendorLockIn.md
[CLI30]: https://github.com/N4M3Z/forge-cli/issues/30
[CLI31]: https://github.com/N4M3Z/forge-cli/issues/31
