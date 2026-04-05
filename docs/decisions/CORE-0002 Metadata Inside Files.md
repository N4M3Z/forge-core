---
title: Metadata Inside Files
description: Metadata belongs inside the file it describes, not in external databases or sidecar files
type: adr
category: architecture
tags:
    - architecture
    - metadata
    - portability
status: accepted
created: 2026-03-30
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related:
    - "CORE-0001 Markdown as System Language.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Metadata Inside Files

## Context and Problem Statement

[CORE-0001](CORE-0001 Markdown as System Language.md) established markdown as the universal format. Every markdown file needs metadata — status, author, tags, relationships, dates. Where does that metadata live?

Knowledge management tools have historically taken two approaches: store metadata in an external database alongside files, or embed metadata directly inside each file.

## Decision Drivers

- Files move between systems — git repos, Obsidian vaults, AI tool contexts, CI pipelines, shared drives
- When a file moves, its metadata must move with it — orphaned metadata is invisible and eventually lost
- Multiple tools must read the same metadata — Obsidian, Claude Code, GitHub, shell scripts, CI validators
- No single tool should be the gatekeeper of metadata — the file itself is the source of truth

## Considered Options

1. **External database** — tools like [Evernote][EVERNOTE], [DEVONThink][DEVON], [TheBrain][BRAIN], and [Bear][BEAR] store metadata in a proprietary database outside the files. Queries are fast, but metadata is invisible when files are viewed in git, a text editor, or an AI tool's context window. Metadata is lost when files move between systems. The database becomes a single point of failure and vendor lock-in.
2. **Separate sidecar files** — `.yaml` or `.json` files alongside each `.md`. Keeps data in the filesystem but doubles file count, sidecars drift from canonical content, and renaming or moving a file orphans its sidecar silently.
3. **Metadata inside the file** — embed metadata directly in the file using a standard format. When a file moves, its metadata moves with it. Every tool that reads the file has immediate access to its metadata. No external dependency, no drift, no orphaning.

## Decision Outcome

Metadata belongs inside the file it describes. Not in an external database, not in a sidecar, not in a separate tracking system.

When a file moves, its metadata moves with it. When a file is read, its metadata is immediately available. When a file is deleted, its metadata is deleted. There is no synchronization problem because there is nothing to synchronize.

[Obsidian][OBS] proved this at scale — a vault of thousands of markdown files with embedded frontmatter, queryable by Dataview, searchable by Properties, portable across machines via git. No database server, no sync service, no proprietary format.

The specific mechanism for embedding metadata in markdown files is YAML frontmatter.

### Consequences

- **Positive:** Files are self-describing and portable across any system that can read text
- **Positive:** No external dependency for metadata — no database, no service, no proprietary format
- **Positive:** Eliminates an entire class of bugs (orphaned metadata, stale sidecars, sync failures)
- **Negative:** File size increases slightly — mitigated by frontmatter being compact YAML

[EVERNOTE]: https://evernote.com/
[DEVON]: https://www.devontechnologies.com/apps/devonthink
[BRAIN]: https://thebrain.com/
[BEAR]: https://bear.app/
[OBS]: https://obsidian.md/
