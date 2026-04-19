# Security

## Reporting a Vulnerability

Email **martin.zeman@pm.me** with `[forge-core security]` in the subject. Include affected file, reproduction steps, and impact. Expect acknowledgement within 72 hours.

## Scope of This Document

forge-core documents the **adoption mechanism** — how external content enters the forge ecosystem. For security concerns about third-party prompts adopted into consumer modules (e.g. forge-dev), see that module's own `SECURITY.md`.

## Supply Chain Model

### `ForgeAdopt` contract

Every external adoption must:

1. Fetch upstream content via a commit-pinned raw URL (never a mutable branch reference)
2. Record the upstream `sha256` digest in a SLSA provenance sidecar under `.provenance/`
3. Record the deployed file's `sha256` digest in the same sidecar (`subject.digest.sha256`)
4. List `ForgeAdopt` itself as a build dependency in `resolvedDependencies`
5. Preserve copyright / attribution as required by the upstream license

The `skills/ForgeAdopt/SKILL.md` file is the canonical workflow.

### Sidecar schema

```yaml
provenance:
    _type: https://in-toto.io/Statement/v1
    subject:
        - name: <path>
          digest:
              sha256: <deployed-content-sha>
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
                      sha256: <upstream-sha>
                - name: ForgeAdopt
                  uri: forge-core/skills/ForgeAdopt/SKILL.md
                  digest:
                      sha256: <forgeadopt-sha>
```

### Verification procedure

```sh
forge validate .        # schema + content checks
forge provenance .      # deployed-vs-sidecar digest match
```

`forge provenance` reports per-module verification. Any file whose on-disk digest does not match its sidecar's `subject.digest.sha256` is flagged. A mismatch means either a benign post-adoption edit without sidecar refresh, or content drift that warrants investigation.

## Maintainer Responsibilities

- New adoptions go through `ForgeAdopt` — SHA-pinned URLs, provenance sidecars, attribution footers
- Pin bumps re-verify the SLSA chain and re-read behavioural content before merging
- Release tags pin `validate.sh` and schema artifacts so downstream modules' pre-commit hooks have stable hashes to anchor

## Scope

In scope:

- Weaknesses in the `ForgeAdopt` workflow that would allow unverified content to enter the ecosystem
- Missing or falsifiable provenance fields in sidecars
- Schema or attribution requirements that fail to protect license compliance

Out of scope:

- Behavioural issues in specific adopted skills — report to the consuming module's `SECURITY.md`
- Issues in the `forge-cli` binary itself — see [forge-cli](https://github.com/N4M3Z/forge-cli)
