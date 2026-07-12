---
name: DesignPrinciples
description: "Canonical cross-cutting design principles that DesignFrontend and DesignDashboard build on: durable framework-agnostic foundations, WCAG-anchored hard checks, and advisory thresholds. Reference library that other design skills cite, not invoked directly."
version: 0.1.0
disable-model-invocation: true
---

# Design Principles

The single source for design foundations shared across `DesignFrontend` (distinctive/premium aesthetics) and `DesignDashboard` (data-dense product UI). Those skills derive their inline digests from this canon and cite it by name; keep thresholds here so they do not drift.

## Foundations

Framework-agnostic and durable. These hold regardless of stack (Tailwind, CSS-in-JS, vanilla, React Native).

- **Structure before style.** Generic *layout* is what makes AI-generated UI read as templated, not the palette. Fix information hierarchy (what is dominant, what is grouped, what is deferred) before touching color or type.
- **Tokens before values.** Every color, radius, and spacing value traces to a semantic token, so retheming is a config edit, not a find-replace. No raw hex in component code.
- **State completeness.** Every interactive element defines default, hover, focus-visible, active, disabled, and (if async) loading. Every data-bearing view defines empty, loading, and error, not just the populated happy path.
- **Color never alone.** Status encoded in color is always paired with an icon, label, or shape. One semantic color-to-meaning mapping, applied everywhere.
- **Progressive disclosure.** The default view shows what a user checks at a glance; detail is revealed on demand.
- **Reference, don't invent.** Study real top-tier examples for the surface being built, then adapt. A blank page converges on the statistical-average output.

## Shared visual profile

Use `skills/VisualIdentity/visual-profile.schema.yaml` v1 when one identity must span multiple outputs. `VisualIdentity` creates the profile and compiled CSS. `DesignFrontend`, `DesignDashboard`, `HtmlPlayground`, `PublicationFigures`, and presentation modules consume the same semantic contract.

- Identity values live in `visual-profile.yaml`; generated CSS exposes `--forge-*` custom properties.
- Components use semantic variables without literal fallbacks. Profile switching changes CSS or `data-theme`, never markup or selectors.
- Data and state palettes come from active `modes.*.colors` and retain redundant non-color encodings.
- If no profile exists, create one before implementing reusable components. One-off exploratory sketches may use temporary tokens, but must normalize them into a profile before delivery.

## Hard checks

Spec-defined, verifiable against rendered/computed output. Run as a self-check before shipping. These are the only thresholds worth failing on.

| Check                   | Threshold                        | Source                          |
| ----------------------- | -------------------------------- | ------------------------------- |
| Text contrast           | ≥ 4.5:1 (normal), ≥ 3:1 (large)  | WCAG 2.2 §1.4.3 AA [WCAG]       |
| UI / focus indicator    | ≥ 3:1 against adjacent color     | WCAG 2.2 §1.4.11, §2.4.11 [WCAG]|
| Touch target            | ≥ 24px (AA), prefer ≥ 44px (AAA) | WCAG 2.2 §2.5.8, §2.5.5 [WCAG]  |

Contrast needs the *rendered* color (semi-transparency, hover, and dark mode change it), not the source literal. Verify against the running UI, not a grep.

## Advisory

Conventions and heuristics, not standards. Parameterize to the design system; suggest, never hard-fail.

- Spacing on a consistent grid (commonly 4px or 8px; Android leans 4pt). Consistency matters more than the specific base.
- Type scale in `rem` with a consistent ratio; avoid arbitrary one-off sizes.
- Small palette plus one decisive accent. Restraint reads as intentional.
- Roughly 5-9 primary items per view before splitting into tabs or drill-down (Miller's Law).
- Motion around 150-200ms with consistent easing; snappier reads as cheap, but this is preference, not defect.

## Ages poorly

Dated 2026 tells, useful as a smell, not a ban. The durable rule is *do not ship the framework default unchanged* and *decide the palette deliberately*, not "never use gradients." Treat these as prompts to check intent, not automatic rejections: emoji used as interface icons, an unmodified default Tailwind/shadcn palette, blue-to-purple gradient hero on white, gradient-filled avatar circles as image placeholders, Inter/Roboto as the only typeface, every chart the same default bar.

## Named laws

Advisory vocabulary for reasoning about a design, not pass/fail: Fitts's Law (target size and distance), Hick's Law (choice count and decision time), Miller's Law (7±2 chunks), Jakob's Law (match learned conventions), aesthetic-usability effect, Gestalt grouping (proximity, similarity, closure).

## Sources

[WCAG]: https://www.w3.org/TR/WCAG22/ "Web Content Accessibility Guidelines (WCAG) 2.2, W3C Recommendation"
