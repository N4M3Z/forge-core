# Entire backend

Command reference for running SessionSearch against the [Entire CLI](https://docs.entire.io). Search is a cloud feature — it requires `entire login` (GitHub device flow) and network access to entire.io.

## Primary search

```bash
entire search "<query>" --json
```

Filter flags, combinable:

```bash
entire search "<query>" --json --repo owner/name --branch branch-name --author "Name" --date week
```

Inline filters are also supported in the query string: `author:<name>`, `date:<week|month>`, `branch:<name>`, `repo:<owner/name>`, `repo:*` (all accessible repos).

## Deep-read a result

Open the transcript behind a specific checkpoint id from the search results:

```bash
entire explain --checkpoint <checkpoint-id> --full --no-pager
```

If `--full` fails, fall back to:

```bash
entire explain --checkpoint <checkpoint-id> --raw-transcript --no-pager
```

## Failure modes

- "authentication required" → the user must run `entire login`
- Command not found → install: `brew tap entireio/tap && brew install --cask entire`
- The namespaced forms `entire checkpoint search` / `entire checkpoint explain` are the current verbs; if a bare verb is rejected, retry the namespaced form
