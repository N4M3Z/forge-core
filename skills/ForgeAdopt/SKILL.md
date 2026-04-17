---
name: ForgeAdopt
description: "Adopt a community skill from an upstream URL into forge. Fetches the source, applies transforms, produces a working SKILL.md with SLSA provenance. USE WHEN adopting a community skill from aitmpl, anthropics/skills, or a similar catalog."
version: 0.1.0
argument-hint: <upstream-url>
allowed-tools: Bash, WebFetch, Read, Write, Edit, Grep, Glob
---

# ForgeAdopt

Orchestrating workflow for adopting a community skill into forge. Produces a first-class `SKILL.md` with a SLSA provenance sidecar, following the strategy in [ARCH-0012](docs/decisions/ARCH-0012 Community Adoption Strategy.md) and the mechanism in [ARCH-0013](docs/decisions/ARCH-0013 Markdown-First Adoption Mechanism.md).

## Workflow

### 1. Fetch and pin

Accept an upstream URL. Resolve its commit SHA and fetch content at that commit:

```sh
# For GitHub sources
gh api "repos/<owner>/<repo>/commits?path=<path>&per_page=1" --jq '.[0].sha'
curl -sSL "https://raw.githubusercontent.com/<owner>/<repo>/<sha>/<path>" -o /tmp/claude/upstream-<slug>.md
shasum -a 256 /tmp/claude/upstream-<slug>.md
```

Record: commit SHA, commit-pinned permalink, content SHA-256.

### 2. Read and decide

Read the upstream file. Apply [ARCH-0012](docs/decisions/ARCH-0012 Community Adoption Strategy.md)'s selection rules:

| Check | Reject if... |
|-------|--------------|
| Artifact class | It's a rule or an agent, not a skill |
| Name collision | An existing first-party forge skill has the same name |
| Duplication | It duplicates a forge skill without demonstrable delta |
| Use intent | The maintainer won't actually invoke it |
| Placement | No existing module is a natural domain home |

Pick the destination module. If nothing fits, defer the adoption; do not create a new module to house a single imported skill.

### 3. Apply transforms

Transforms are named operations that will extract into their own skills as patterns stabilize. In v1 they run inline:

| Transform  | What it does                                                                                                |
| ---------- | ----------------------------------------------------------------------------------------------------------- |
| `align`    | Rename to PascalCase; fix indent, fence language tags, heading depth; strip upstream frontmatter fields forge doesn't use |
| `rescope`  | Add or tighten `allowed-tools` to the narrowest set the skill actually uses                                 |
| `debrand`  | Remove hardcoded vendor references (specific tool names, external services, "powered by X" language)        |
| `minimize`   | Collapse motivational or marketing prose while preserving directive content                                 |
| `extract`  | Move bulk reference material into `@`-included companion files so the always-loaded `SKILL.md` stays lean   |

Record which transforms were applied; it guides the commit message and is what future transform-skill dependencies will represent in the sidecar.

### 4. Add forge frontmatter

Minimum adopted-skill frontmatter:

```yaml
---
name: <PascalCaseName>
description: "<one sentence>. USE WHEN <trigger>. Not for <anti-trigger>."
version: 0.1.0
allowed-tools: <comma-separated narrow list>
upstream: <url-to-main-branch-file>
---
```

The `upstream` field is a human-facing pointer without SHA ([PROV-0006](docs/decisions/PROV-0006 Adoption Metadata in Provenance Sidecars.md)); the SHA pin lives in the sidecar.

### 5. Write the artifact

Land at `skills/<PascalCaseName>/SKILL.md` in the destination module. Compute its SHA-256 after writing:

```sh
shasum -a 256 skills/<PascalCaseName>/SKILL.md
```

### 6. Write the provenance sidecar

Land at `skills/<PascalCaseName>/.provenance/SKILL.yaml`:

```yaml
provenance:
    _type: https://in-toto.io/Statement/v1
    subject:
        - name: skills/<Name>/SKILL.md
          digest:
              sha256: <adopted-sha256>
    predicateType: https://slsa.dev/provenance/v1
    predicate:
        buildDefinition:
            buildType: https://forge-cli/adopt/v1
            externalParameters:
                upstream_url: <commit-pinned-url>
            resolvedDependencies:
                - name: upstream
                  uri: <commit-pinned-url>
                  digest:
                      sha256: <upstream-sha256>
                - name: ForgeAdopt
                  uri: forge-core/skills/ForgeAdopt/SKILL.md
                  digest:
                      sha256: <ForgeAdopt-sha256>
        runDetails:
            builder:
                id: forge-cli
                version:
                    forge: <version>
            metadata:
                startedOn: <iso-8601>
```

Every adoption records `ForgeAdopt` itself as a dependency — the orchestrator is a build input. When individual transform skills extract (`DebrandPrompt`, `MinimizePrompt`, etc.), each applied transform adds its own entry under `resolvedDependencies`.

### 7. Commit

One commit per adoption. Commit message carries the prose rationale — what was preserved, what was cut, why the destination was chosen, which transforms fired. Rationale lives here, not in the sidecar ([PROV-0006](docs/decisions/PROV-0006 Adoption Metadata in Provenance Sidecars.md)).

## Constraints

- Skills only — rules and agents are excluded from adoption ([ARCH-0012](docs/decisions/ARCH-0012 Community Adoption Strategy.md))
- First-party forge skills take precedence on name conflicts; rename the adoption or reject it
- Every adoption writes a provenance sidecar; an adoption without provenance is not an adoption
- Defer the adoption if no existing module is a natural home; do not create new modules for one skill
- Adopt at most 3-5 skills in the initial phase — selectivity is the point
- Recompute the adopted artifact's SHA-256 and sync it to the provenance sidecar after ANY post-adoption edit. The sidecar's `subject.digest.sha256` must match the current file content, not the initial adoption state
