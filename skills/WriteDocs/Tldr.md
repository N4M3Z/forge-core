# TLDR

A **TLDR** is a [tldr-pages][TLDR-PAGES] page: a command name, a one- or two-line description, and up to eight example/command pairs. The audience is a future-you (or future AI session) that has used the tool before, walked away for weeks, and needs the 80% path back without re-reading the man page. Not a tutorial, not a reference, not a cheatsheet.

Write the genuine tldr-pages format, the same shape the project ships, so pages stay portable, predictable, and free of prose to maintain. Tool-specific config, gotchas, and rationale do **not** belong in a TLDR; they live in the tool's ADR or in config and script comments.

[TLDR-PAGES]: https://github.com/tldr-pages/tldr

## When to write a TLDR

| Signal                                                                                  | TLDR worth it? |
| --------------------------------------------------------------------------------------- | -------------- |
| Tool's `--help` already covers the 80% path cleanly                                     | No             |
| Subtle save/quit grammar (`:x` vs `:wq` vs `ZZ`, `q` warns vs `q` exits)                | Yes            |
| Config-file layering with non-obvious precedence (theme vs override)                    | Yes            |
| Keybindings that differ from upstream defaults in your dotfiles                         | Yes            |
| Multi-session usage will benefit from a single landing page                             | Yes            |
| Tool wraps another tool in a way that masks the underlying behavior                     | Yes            |
| Tool is a one-time install you'll never reconfigure                                     | No             |

If two answers say yes, write the TLDR. If only one says yes, an inline comment in the relevant config file is usually enough.

## Where TLDRs live

| Project type                                                  | Path                                                |
| ------------------------------------------------------------- | --------------------------------------------------- |
| Tool is essential to a specific repo                          | `<repo>/docs/tldrs/<tool>.md`                       |
| Tool spans projects, knowledge module exists                  | `<knowledge-module>/docs/tldrs/<tool>.md`           |
| Tool is personal-workflow level (cross-project, cross-repo)   | dotfiles or personal knowledge vault                |

Filename: lowercase, kebab-case (`jj.md`, `git-delta.md`, `tmux.md`).

## Shape

A TLDR is the tldr-pages format exactly: a title, a blockquote, then example/command pairs. No section headings, no tables, no bold or italics in the body.

```
# command-name

> Short, snappy description; one line, two at most.
> See also: `related-command`.
> More information: <https://example.com/docs>.

- Imperative description of what the command does:

`command --flag {{placeholder}}`

- Another example, described in the imperative and ending with a colon:

`command subcommand {{path/to/file}}`
```

Rules:

- **Title**: the command name exactly (`jj`, `git commit`), no backticks.
- **Description**: at most two lines, each prefixed `>`. An optional `> See also:` line references related commands. The final line is always `> More information: <url>.` in angle brackets, and is the TLDR's only source link.
- **Examples**: at most eight. Each is a `-` bullet whose description is in the imperative mood ("List all files", not "Lists" or "Listing") and ends with a colon, then a blank line, then exactly one command in backticks.
- **Placeholders**: `{{placeholder}}`, snake_case for multi-word. Paths `{{path/to/file}}`; multiple values `{{file1 file2 ...}}`; mutually exclusive `{{a|b|c}}`; ranges `{{1..5}}`.
- **Commands**: prefer GNU-style long options (`--help`), space-separated (`--opt arg`). Keypresses use `<Ctrl c>`, `<Enter>`.
- **No styling**: no bold, italics, tables, or extra `##` sections; the tldr-pages client renders emphasis itself.

Reference: the [tldr-pages `pages/`][TLDR-PAGES] directory for canonical examples; `forge-provision/docs/tldrs/jujutsu.md` is the first in-repo page in this format. Older `docs/tldrs/*.md` predate it (rich one-pagers) and are queued for migration.

## Anti-patterns

| Pattern                                                          | Why it fails                                                                          |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Copying the man page                                             | Readers already have `--help`; a TLDR is the curated 80% subset.                      |
| Listing every flag                                                | Eight examples max; keep the ones that actually recur.                                |
| Tables, prose paragraphs, or `##` headings                       | tldr-pages is title + blockquote + example pairs only.                                |
| Bold or italics in the body                                       | Reserved for the client's emphasis rendering.                                         |
| Config, gotchas, or rationale in the page                         | Those belong in the tool's ADR or in config/script comments, not a TLDR.              |
| Non-imperative descriptions ("Lists files")                       | Use the imperative and end with a colon ("List files:").                              |
| Marketing language ("the modern", "the powerful", "the best")    | Future-you doesn't need to be sold on the tool you're already using.                  |
| Date stamps in the body                                          | TLDRs are evergreen. Date them only when chronology matters.                          |

## Maintenance

A TLDR drifts the moment upstream changes a command or flag. Two cheap habits keep drift down:

1. **Touch on every session that uses the tool.** If a command in the page changed, fix it in the same commit.
2. **Verify the "More information" link at touch-time.** A dead link signals stale content.
