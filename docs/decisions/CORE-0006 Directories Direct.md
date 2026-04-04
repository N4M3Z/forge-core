---
title: Directories Direct
description: Directory names as routing decisions with functional consequences
type: adr
category: architecture
tags:
    - architecture
    - naming
status: accepted
created: 2026-03-19
updated: 2026-03-30
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Directories Direct

## Context and Problem Statement

Directory names are the primary navigation mechanism for both humans and AI tools. In an assembly pipeline where directory names drive variant resolution, provider targeting, and model selection, every directory name is a routing decision with functional consequences. A directory named `claude/` immediately tells you "this content is for Claude." A directory named `misc/` tells you nothing.

## Considered Options

1. **Categorization-first** — group by type (config/, docs/, scripts/). Familiar but tells you what something is, not where it goes or what it does.
2. **Function-first** — name by routing purpose (claude/, user/, rules/). Every name is a decision with functional consequences.

## Decision Outcome

Directories are navigation, not categorization. Every directory name is a routing decision — it tells the user (and the AI) where to find things and where new things belong.

Principles:

- Optimize for discoverability over categorization — "where would someone look for it?"
- A well-named directory eliminates the need for documentation about "where does X go?"
- Directory names in qualifier paths (`claude/`, `opus-4-6/`, `user/`) have functional consequences — a typo silently disables content
- Use "directories" not "folders" — in docs, commit messages, and conversation

### Consequences

- [+] Directory tree is self-documenting
- [+] No need for a separate "where to put things" guide
- [+] Qualifier directories double as routing labels — naming IS configuration
