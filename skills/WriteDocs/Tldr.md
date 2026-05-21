# TLDR

A **TLDR** is a single-file one-pager about a tool. The audience is a future-you (or future AI session) that has used the tool before, walked away for weeks, and now needs to use it again without re-reading the man page. Not a tutorial. Not an exhaustive reference. The 80% path with the gotchas that hurt.

Inspired by the [tldr-pages][TLDR-PAGES] CLI ("simplified man pages"), which crowdsourced terse community-maintained examples per tool. tldr-pages itself has slowed considerably; this skill keeps the spirit (the 80% subset, no marketing prose, examples over reference) but scopes each TLDR to *your* config and *your* gotchas, not the lowest-common-denominator usage.

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

Filename: lowercase, kebab-case (`gitui.md`, `git-delta.md`, `tmux.md`).

## Shape

A TLDR follows this skeleton, in order. Skip a section when it doesn't apply; never reorder.

```
# <tool-name>

<one-line purpose>. <bold the single most load-bearing fact, e.g., the prefix key>.

## Invocation

<table: shell command → effect>

## Custom keybindings (in our <config-path>)

<read-this-way preamble if non-obvious>

### <category> (Panes / Windows / etc., if grouping helps)

<table: key → action>

## Save / quit semantics
<only when non-obvious — explicit save commands, what `q` does, what `:x` does>

## Plugins / extensions (if applicable)

<table: plugin → path → purpose>

## Notable config baked in

<bullet list of one-line settings worth remembering>

## <App-specific interaction notes>

<e.g., URL clicks inside tmux+Ghostty>

## Config + reload

- Canonical: <dotfiles path>
- Deployed: <deployed path>
- Deploy: <deploy command, often `chezmoi apply <path>`>
- Reload: <reload command — don't make readers restart the tool>

## Sources

<bulleted reference list — upstream repo, official docs, key issues>
```

Reference implementations: `forge-provision/docs/tldrs/tmux.md` (rich, multi-section), `forge-provision/docs/tldrs/revdiff.md` (terse, single-purpose tool), `forge-provision/docs/tldrs/tuicr.md` (focuses on save semantics).

## Anti-patterns

| Pattern                                                          | Why it fails                                                                          |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Copying the man page                                             | Readers already have `--help`; TLDR is the curated subset.                            |
| Listing every flag                                                | Curate. If a flag never comes up, leave it out.                                       |
| No "Config + reload" section                                      | A TLDR you can't act on is just trivia.                                               |
| Sources section missing                                           | Readers can't find drift between TLDR and upstream.                                   |
| Marketing language ("the modern", "the powerful", "the best")    | Future-you doesn't need to be sold on the tool you're already using.                  |
| Decision-comparison sections                                     | Those belong in a separate landscape skill or ADR, not in the TLDR.                   |
| Date stamps in the body                                          | TLDRs are evergreen. Date them only when chronology matters.                          |
| Heading depth past `###`                                          | A TLDR you have to outline is over-structured.                                        |

## Maintenance

A TLDR drifts the moment upstream changes a default. Two cheap habits keep drift down:

1. **Touch on every session that touches the tool's config.** If you reload the tool's config during a session, scan its TLDR for accuracy. One-paragraph diff in the same commit.
2. **Verify sources at touch-time.** Every reference link should resolve and still describe what you cite. Dead links signal stale content.
