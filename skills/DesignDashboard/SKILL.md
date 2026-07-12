---
name: DesignDashboard
description: "Build data-dense product UI — dashboards, admin panels, analytics views, data tables, KPI screens. USE WHEN the user asks for a dashboard, admin panel, analytics UI, data table, metrics/KPI layout, or reporting interface. For marketing, landing, or brand-aesthetic pages use DesignFrontend instead."
version: 0.1.0
allowed-tools: Read, Grep, Write, Edit
---

# DesignDashboard

Design data UI as a systems discipline: restraint, legibility, and behavior across data shapes and non-happy-path states. This is the opposite of marketing design, density and clarity win over atmosphere and distinctiveness.

## Foundations

- **Structure before style.** Generic layout, not palette, is what makes UI read as templated. Fix hierarchy first.
- **Tokens before values.** Colors, radii, spacing trace to semantic tokens; no raw hex in component code.
- **State completeness.** Every interactive element covers default, hover, focus-visible, active, disabled, loading; every data view covers empty, loading, error.
- **Color never alone.** Status in color is always paired with an icon, label, or shape.

Hard accessibility self-checks before shipping (verify against the rendered UI, not the source): text contrast ≥ 4.5:1, UI/focus indicators ≥ 3:1, touch targets ≥ 24px (WCAG 2.2 §1.4.3, §1.4.11, §2.5.8 [WCAG]). `DesignPrinciples` holds the full cross-cutting canon, including advisory thresholds and the named-law vocabulary.

## Structure first

Let the data's shape drive the component, not the reverse. Prototype against real or realistic data before choosing a pattern: a single value is a stat card, a metric with 50 categories is a table, not a pie. Component choice is a data-shape decision, not an aesthetic one.

## Layout

- The sidebar is the product's spine: group nav by relevance, sink low-frequency items (settings) to the bottom, pair icons with short labels, and always mark the active item.
- Primary metrics go where the eye lands first; secondary detail sits behind tabs, drawers, or drill-downs.
- Cap the default view at roughly 5-9 top-level metrics. Beyond that, split — do not stack everything on one screen.
- Use denser typography and tighter hierarchy steps than a marketing page; dashboards trade whitespace for information.

## Charts

Match chart type to data shape. Default to boring-but-legible over novel.

| Data shape          | Chart                     |
| ------------------- | ------------------------- |
| Trend over time     | Line                      |
| Category comparison | Bar                       |
| Part of whole       | Pie / stacked bar         |
| Single value        | Stat card / sparkline     |

A pie with more than ~6 slices, a line chart on categorical data, or a single stat rendered as a table are mismatches, treat them as defects.

## States

"UI is what you can't see." The polish of a dashboard lives outside the populated screenshot, and these are the most verifiable gap in any dashboard PR.

- **Empty:** context (why is this empty) + guidance (the next action) + a CTA when the user can resolve it.
- **Loading:** skeletons that do not break screen-reader navigation.
- **Error:** a recoverable message, not a blank panel.
- **Overflow:** truncation and wrapping behavior for long labels and large numbers.

## Interaction

Optimistic updates (apply instantly, reconcile with the backend after) keep a dashboard feeling responsive. Surface confirmations and failures through toasts. Use modals for complex actions, popovers for lightweight settings.

## Red Flags

| Anti-pattern                                    | Fix                                              |
| ----------------------------------------------- | ------------------------------------------------ |
| Only the populated happy-path state is designed | Design empty, loading, error, and overflow first |
| Chart type does not match the data's shape      | Re-pick from the chart table by data shape       |
| Everything visible at once, no hierarchy        | Progressive disclosure: glance view + drill-down |
| Sidebar has no active-item indicator            | Mark the current nav item                        |

## Constraints

- Produce real, working code, not mockups.
- Self-check the hard accessibility thresholds from the shared principles before shipping; contrast against the rendered UI, not the source literal.
- Advisory thresholds (spacing grid, metric count, motion) parameterize to the target design system, do not hard-fail on them.

## Sources

[WCAG]: https://www.w3.org/TR/WCAG22/ "Web Content Accessibility Guidelines (WCAG) 2.2, W3C Recommendation"
