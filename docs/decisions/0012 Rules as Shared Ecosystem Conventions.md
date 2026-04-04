---
status: Accepted
date: 2026-02-28
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
promoted: [AuthorInModules.md]
tags: [architecture, rules]
---

# Rules as Shared Ecosystem Conventions

## Context and Problem Statement

Conventions like git commit format, naming standards, formatting preferences, and known issues were originally scattered — some in personal config, some in individual projects, some as tribal knowledge. Ecosystem-wide behavioral constraints need a shared home so they're consistently applied regardless of which project or tool is active.

## Decision Drivers

- Conventions like commit format and naming apply everywhere, not just in one project
- Rules deploy automatically via `make install` — no manual setup per project
- Rules must be version-controlled and reviewable, not buried in tool settings

## Considered Options

1. **Rules in personal config** — conventions live with user settings, but don't travel with the codebase and can't be shared
2. **Rules in a shared core module** — ecosystem-wide conventions ship alongside the build toolchain, available to any project that includes it
3. **Rules in the library layer** — deepest dependency, but libraries are for code, not behavioral constraints

## Decision Outcome

Chosen option: **Rules in a shared core module**. Ecosystem-wide conventions (GitConventions, NamingConventions, Formatting, ShellAliases, KnownIssues, RTK) live in `rules/` and deploy alongside skills. Any project that includes the core module gets these conventions automatically.

### Consequences

- [+] All projects share the same conventions without cross-dependency issues
- [+] Convention updates propagate via a single submodule bump
- [-] The core module grows beyond build tooling into ecosystem conventions — scope creep risk
