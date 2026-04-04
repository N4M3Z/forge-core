# ClaudePermissions

Audit and clean the `permissions.allow` array in Claude Code settings files. This array grows organically — every approved command gets auto-appended verbatim, accumulating cruft over time.

## Permission Groups

Organize the `allow` array in this order, separated by blank lines:

| Group                      | Description                              | Examples                                         |
|----------------------------|------------------------------------------|--------------------------------------------------|
| **Non-Bash tools**         | Top-level tool grants, MCP servers, Skills | `WebSearch`, `mcp__*`, `Skill(...)`              |
| **Standard CLI**           | Common commands with wildcard            | `Bash(git:*)`, `Bash(cargo:*)`, `Bash(make:*)`   |
| **RTK post-rewrite**       | Commands after RTK hook rewrite          | `Bash(rtk:*)`, `Bash(rtk make:*)`                |
| **Aliased commands**       | Shell aliases require `command` prefix   | `Bash(command cp:*)`, `Bash(command cd:*)`        |
| **Forge tools (PATH)**     | Installed binaries via `make install`    | `Bash(safe-read:*)`, `Bash(dispatch:*)`           |
| **Forge tools (relative)** | Module binaries not installed to PATH    | `Bash(Modules/forge-obsidian/bin/forge-draft:*)` |
| **Hooks utilities**        | Gitignored personal scripts              | `Bash(Hooks/calendar-today.sh:*)`                |
| **WebFetch domains**       | Allowed web domains                      | `WebFetch(domain:github.com)`                    |

The `ask` array stays at the bottom, unchanged.

## Cruft Patterns

Flag and remove entries matching these patterns:

| Pattern                      | Why it's cruft                                                       | Example                                                    |
|------------------------------|----------------------------------------------------------------------|------------------------------------------------------------|
| **Loop fragments**           | Partial shell syntax from multi-line commands                        | `Bash(for f in ...)`, `Bash(do)`, `Bash(done)`             |
| **Variable assignments**     | Not commands — will never match any invocation                       | `Bash(PREV_DIR="$PWD")`                                    |
| **Env-prefixed commands**    | One-shot invocations with env context baked in                       | `Bash(FORGE_LIB=... command make:*)`                       |
| **Path-pinned duplicates**   | Same binary via absolute or relative path when bare wildcard exists  | `Bash(/Users/.../safe-read:*)` when `safe-read:*` present  |
| **Stale build paths**        | `target/release/` or `target/debug/` paths for binaries now on PATH  | `Bash(Modules/.../target/release/insight:*)`                |
| **One-shot debug**           | Pinned invocations to `/tmp/`, `Scratch/`, or test paths             | `Bash(builtin .../install-agents --dst /tmp/test/...)`     |
| **File existence checks**    | One-off `[ -f ... ]` tests                                          | `Bash([ -f "$SCRIPT_DIR/Core/..." ])`                      |
| **Internal functions**       | Bash function names, not external commands                           | `Bash(strip_front:*)`, `Bash(parse_yaml_list:*)`           |
| **Multi-line blobs**         | Entire scripts pasted as a single permission entry                   | Long `for`/`do`/`done` blocks spanning multiple lines      |
| **Venv paths**               | Python from `.venv/` when `python3` already allowed                  | `Bash(/path/.venv/bin/python3:*)`                          |
| **One-off WebFetch domains** | Individual blog posts, single-visit research sites                   | `WebFetch(domain:random-blog.dev)`                         |
| **Invalid WebFetch domains** | Filenames or malformed entries                                       | `WebFetch(domain:agent-skills.md)`                         |

## Redundancy Rules

Entries covered by broader wildcards already in the list:

| If this exists  | Then these are redundant                                             |
|-----------------|----------------------------------------------------------------------|
| `Bash(X:*)`     | `Bash(X --help:*)`, `Bash(X --version:*)`, `Bash(X subcommand:*)`   |
| `Bash(X:*)`     | `Bash(/absolute/path/to/X:*)`, `Bash(relative/path/to/X:*)`         |
| `Bash(rtk:*)`   | `Bash(rtk X:*)` for any X (but see RTK awareness below)             |
| `Bash(X:*)`     | `Bash(command X:*)` — UNLESS X is aliased                           |

### Alias Exception

Commands aliased in the shell (`cp`, `mv`, `rm`, `cd`) need their `command` prefix form (`Bash(command cp:*)`) even when the bare wildcard (`Bash(cp:*)`) exists. The alias intercepts the bare form, so `command` bypasses it. Both entries serve different purposes — don't flag `command X:*` as redundant for aliased commands.

### RTK Awareness

Permission checking runs AFTER PreToolUse hooks. When RTK rewrites `make ...` → `rtk make ...`, the permission check evaluates the rewritten form. Both are needed:

- `Bash(make:*)` — matches the original command (before hook)
- `Bash(rtk make:*)` or `Bash(rtk:*)` — matches the rewritten command (what gets permission-checked)

Do NOT flag `rtk X:*` entries as redundant with `X:*` — they serve different stages of the permission pipeline. A broad `Bash(rtk:*)` covers all post-rewrite forms at once.

### Consolidation Heuristic

When 3+ entries share a command prefix, propose consolidating to a single wildcard:

```
Bash(mdschema --version:*)  }
Bash(mdschema help:*)       } → Bash(mdschema:*)
Bash(mdschema derive:*)     }
```

## Guidelines

- **Keep** anything the user intentionally uses across sessions
- **Keep** `du`, `md5`, `xargs`, `source` — generally useful utilities
- **Keep** RTK post-rewrite entries alongside base entries
- **Remove** duplicates, fragments, and auto-grant noise
- **Consolidate** 3+ same-prefix entries into wildcards
- When unsure, **ask** — don't silently remove potentially intentional entries
- Report before/after entry count per file
