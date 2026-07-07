---
name: DesignReview
description: "Verify a rendered interface against the DesignPrinciples canon from captured artifacts (screenshot + axe-core JSON per state and viewport). USE WHEN reviewing built UI, design review of a running app or component, checking a screenshot against design principles, or accessibility review of rendered output. Not for reviewing source code or unrendered designs."
version: 0.1.0
allowed-tools: Read, Glob, Grep
---

# DesignReview

Judge a rendered interface, not its source. Source review is blind on CSS-in-JS and React Native and cannot compute contrast; only rendered output verifies the `DesignPrinciples` canon. This skill is capture-agnostic: it consumes artifacts a separate tool produced and never runs a browser itself.

## Inputs

For each review target, expect two artifacts per (state, viewport):

- a screenshot `PNG`, and
- an `axe-core` JSON report from the same rendered state.

Name files so each maps to its target, state, and viewport: `<target>__<state>__<viewport>.png` and `<target>__<state>__<viewport>.axe.json`. States cover at least `empty`, `loading`, `error`, and `default`; viewports cover at least `mobile` and `desktop`. A manifest (or the caller's message) lists which targets, states, and viewports were captured.

If no artifacts are present, stop and say so plainly. Do not review from memory or from source, and do not report a pass.

## Capture

Capture is delegated, not bundled. Produce the artifacts with a tool the environment already has, such as a Playwright MCP: navigate to the target in each state, run `axe-core` against the live DOM, and save the screenshot and the axe JSON. The capture must fix the viewport, disable animation, and wait for fonts and network idle so the screenshot is reproducible.

## Review

1. **Discover** the artifacts (Glob the capture directory) and confirm which states and viewports exist.
2. **Hard checks come only from the axe JSON**, never from the image. Map rule results to `DesignPrinciples` checks:

    | axe rule        | DesignPrinciples check          | WCAG        |
    | --------------- | ------------------------------- | ----------- |
    | `color-contrast`| text contrast ≥ 4.5:1           | §1.4.3      |
    | `target-size`   | touch target ≥ 24px             | §2.5.8      |

    A rule in axe's `violations` is a verified-fail. A rule in `passes` is a verified-pass. A rule in `incomplete` (contrast over a gradient, image, or transformed node, or an unresolved background) is not-verified, never a pass.
3. **Judge the screenshots** for what a number cannot capture: structure before style, the anti-slop tells, and whether each state actually renders its job (an empty state with context and guidance, a real loading treatment, a recoverable error).
4. **State coverage.** A state with no artifact is not-verified. If only `default` was captured, report `empty`, `loading`, and `error` as not-verified rather than passing.
5. **No eyeballing hard numbers.** If a screenshot looks low-contrast but axe is silent or incomplete, record a not-verified suspicion that needs a computed check, not an estimated ratio.

## Output

One finding per issue, each tagged and citing the principle:

| Field    | Values                                          |
| -------- | ----------------------------------------------- |
| verdict  | `verified-fail` / `verified-pass` / `not-verified` |
| target   | target, state, viewport                         |
| check    | the `DesignPrinciples` check or foundation      |
| evidence | axe rule id, or what the screenshot shows        |

Lead with verified-fails, then not-verified gaps. A review that verified only the happy path says so.

## Red Flags

| Anti-pattern                                          | Fix                                                |
| ----------------------------------------------------- | -------------------------------------------------- |
| Reporting a contrast pass from axe `incomplete`       | Report not-verified; contrast was never computed   |
| Estimating a contrast ratio from the screenshot       | Hard numbers come only from axe                    |
| Passing states that were never captured               | Mark absent states not-verified                    |
| Reviewing from source because no artifacts were found | Stop and report the capture gap                    |

## Constraints

- Hard numbers come only from the axe JSON; the screenshot is for judgment, never measurement.
- axe `incomplete` and any absent state are not-verified, never a pass.
- With no artifacts the review is a no-op that reports the gap; it never falls back to source or memory.
- Cite `DesignPrinciples` for every finding.
