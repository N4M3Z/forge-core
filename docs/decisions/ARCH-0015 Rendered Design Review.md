---
title: "Rendered Design Review"
description: "Verify built UI against the DesignPrinciples canon from rendered artifacts, owning the review contract rather than the browser that produces them"
type: adr
category: architecture
tags:
    - architecture
    - design
    - review
    - accessibility
status: accepted
created: 2026-07-07
updated: 2026-07-08
author: "@N4M3Z"
project: forge-core
related: []
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Rendered Design Review

## Context and Problem Statement

The `DesignPrinciples` canon defines spec-anchored hard checks (WCAG contrast, target size) and durable foundations, but nothing verifies a built interface against them. Source-scanning cannot do it: regex over CSS-in-JS, styled-components, Tailwind arbitrary values, and React Native sees little, and no static scan computes rendered contrast, which semi-transparency, hover, and dark mode all change. A reviewer must judge the rendered result. The open question is how much infrastructure forge-core should own to make that possible without turning a markdown module into a browser-automation project.

## Decision Drivers

- Hard checks (contrast, target size) need computed values, not pixels judged by eye or source literals.
- forge-core deploys markdown only; executables and browsers are a maintenance liability it has so far avoided.
- The reviewer must not commit the flaw it polices: a happy-path-only screenshot cannot verify empty, loading, or error states.
- Users likely already run a screenshot and accessibility tool (Playwright MCP); forge should compose with it, not duplicate it.

## Considered Options

1. **Source-grep reviewer** — regex or AST checks in a skill or binary. Blind on CSS-in-JS and React Native, cannot compute contrast, fires on a minority of stacks.
2. **Own the capture** — ship a `bin/ui-shot` Playwright wrapper plus INSTALL.md producing a PNG and axe-core JSON per target. Turnkey, but inherits Chromium version drift, cross-platform browser installs, and INSTALL maintenance, and forge does not auto-deploy `bin/`. A markdown module takes on a browser dependency.
3. **Own the contract, not the browser** — a single capture-agnostic `DesignReview` skill that consumes artifacts (PNG plus axe-core JSON per state and viewport) produced by whatever tool the user has, maps axe rule IDs to DesignPrinciples checks, and reports pass, fail, or not-verified. Pure markdown, forge-native, no dependency to maintain, composes with an existing Playwright MCP. The user must produce the artifacts; capture is not turnkey.

**Risk Assessment** (option 3):

- **Technical Risk**: low — a markdown skill with no runtime.
- **Schedule Risk**: low — one skill.
- **Ecosystem Risk**: low — depends on an external capture tool by contract, not by code.

## Decision Outcome

Chosen option: **own the contract, not the browser (option 3)**, because it delivers rendered verification without forge-core taking on browser automation, and it composes with capture tooling the user already runs.

### Ideal implementation

A `DesignReview` skill in forge-core that:

- Defines a strict input contract: for each review target, a screenshot PNG plus an axe-core JSON report, named so a file maps to its target, state, and viewport, listed in a small manifest of targets by state by viewport.
- Sources hard checks only from the axe JSON (computed contrast, target size), never from the image, with an explicit prohibition on estimating hard numbers by eye.
- Maps axe rule IDs to DesignPrinciples checks (`color-contrast` to contrast, `target-size` to touch target).
- Treats axe `incomplete` (contrast over gradients, images, or transformed nodes, or an unresolved background) as not-verified, never as pass.
- Uses the screenshots for vision judgment only: structure-before-style, anti-slop tells, and state coverage.
- Requires state targets. Given only the happy path, it reports empty, loading, and error as not-verified rather than passing.
- Emits structured findings citing DesignPrinciples, each tagged verified-fail, verified-pass, or not-verified.

### What is missing today

- The `DesignReview` skill itself: the input contract, the axe-rule-to-principle map, and the reporting semantics.
- A named artifact manifest convention (targets, states, viewports, and file naming).
- A documented reference capture path (Playwright MCP) cited, not bundled.

### Dangers

- **False confidence through silence.** axe `incomplete` or a missing state reads as pass unless explicitly reported not-verified. This is the primary risk; the reporting semantics exist to close it.
- **Vision measurement leakage.** The model may estimate contrast from the image. The skill must forbid it and route "looks wrong but axe is silent" to a not-verified suspicion, not a number.
- **Non-determinism.** Font loading, subpixel rendering, and mid-flight animation make screenshots non-reproducible. Capture must fix the viewport, disable animation, and wait for fonts and network idle; the contract states this requirement even though a different tool satisfies it.
- **Token cost.** States by viewports multiplies images per review; keep the default target set small.
- **Capture gap.** With no configured capture tool the skill has nothing to read; it must degrade to an explicit no-op, not a silent pass.

### Consequences

- [+] Rendered verification of the DesignPrinciples canon with no browser dependency in forge-core.
- [+] Composes with an existing Playwright MCP or any tool honoring the contract.
- [-] Not turnkey: the user wires a capture tool and supplies targets. Mitigated by documenting one reference path and failing loudly when artifacts are absent.

### Scope for the first cut

Ship the `DesignReview` skill (contract, axe map, not-verified semantics), two viewports (mobile and desktop) as advisory, caller-supplied targets required. Defer bundled capture, multi-theme review, auto-discovery of states, and interaction or video review.

## Links

- [DesignPrinciples](../../skills/DesignPrinciples/SKILL.md) — the canon this reviewer verifies against
- [axe-core rule descriptions](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md) — rule IDs mapped to checks
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) — source of the hard checks
