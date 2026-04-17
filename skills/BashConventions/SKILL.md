---
name: BashConventions
version: 0.1.0
description: "Bash and shell scripting pitfalls — BSD vs GNU tools, set -euo pipefail traps, glob behavior, subprocess env. USE WHEN writing or reviewing shell scripts (.sh files), Makefiles with shell recipes, or install scripts."
paths:
    - "**/*.sh"
    - "**/Makefile"
---

# BashConventions

## Tooling

macOS ships BSD tools — `shasum -a 256` not `sha256sum`, BSD awk lacks 3-arg `match()`.

## set -euo pipefail traps

- `grep` with 0 matches → exit 1. Fix: `grep ... || true`
- `((VAR++))` with VAR=0 → exit 1. Fix: `VAR=$((VAR + 1))`
- `[ cond ] && action` where cond is false → exit 1. Fix: `if [ cond ]; then action; fi`
- `find | while read` runs loop in subshell. Fix: `while read; done < <(find ...)`

## printf flags collision

`printf '---\n...'` fails — printf parses `---` as flags. Use heredoc or `printf '%s\n' '---'`.

## Glob and dotfiles

`cp -r dir/*` skips dotfiles — the `*` glob doesn't match hidden files. Use `cp -r dir/.` (trailing `/.`) when destination must include hidden files. Common silent bug: install scripts that drop `.manifest`, `.env`, `.provenance/` etc. without error.

## Python subprocess proxy inheritance

Python subprocesses inherit proxy env vars even after `unset` in the parent bash shell. When calling Python scripts that make HTTP requests from bash, use `env -u http_proxy -u https_proxy python3 script.py`, or add `urllib.request.install_opener(urllib.request.build_opener(urllib.request.ProxyHandler({})))` at the top of the Python script.


## Additional references

@BashPatterns.md
