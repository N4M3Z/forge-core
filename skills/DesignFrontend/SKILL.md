---
name: DesignFrontend
description: "Build distinctive, production-grade frontend interfaces that avoid generic AI aesthetics. USE WHEN the user asks for a landing page, marketing site, hero, brand or premium aesthetic, or the styling and visual direction of web components. For data-dense dashboards, admin panels, and analytics UI use DesignDashboard instead. Not for backend or non-UI work."
version: 0.1.0
allowed-tools: Read, Grep, Write, Edit
upstream: https://github.com/davila7/claude-code-templates/blob/main/cli-tool/components/skills/creative-design/frontend-design/SKILL.md
---

# DesignFrontend

Create distinctive, production-grade web interfaces. Commit to an aesthetic direction and execute with precision: intentionality wins over intensity, whether the direction is bold maximalism or refined minimalism.

## Foundations

- **Structure before style.** Generic layout, not palette, is what makes UI read as templated. Fix hierarchy first.
- **Tokens before values.** Colors, radii, spacing trace to semantic tokens; no raw hex in component code.
- **State completeness.** Every interactive element covers default, hover, focus-visible, active, disabled, loading.
- **Color never alone.** Status in color is always paired with an icon, label, or shape.

Hard accessibility self-checks before shipping (verify against the rendered UI, not the source): text contrast ≥ 4.5:1, UI/focus indicators ≥ 3:1, touch targets ≥ 24px (WCAG 2.2 §1.4.3, §1.4.11, §2.5.8 [WCAG]). `DesignPrinciples` holds the full cross-cutting canon, including advisory thresholds and the named-law vocabulary.

## Direction

Before coding, decide on a clear aesthetic direction. Pick one and stay true to it:

- Brutally minimal, maximalist chaos, retro-futuristic, organic, luxury, playful, editorial, brutalist, art deco, pastel, industrial — or a point of your own choosing.

Name the context, the audience, and the one thing someone will remember about the result.

## Aesthetics

| Axis        | Guidance                                                                                                         |
| ----------- | ---------------------------------------------------------------------------------------------------------------- |
| Typography  | Distinctive, characterful choices. Pair a display font with a refined body font. Avoid generic system fonts.      |
| Color       | Dominant colors with sharp accents outperform evenly distributed palettes. Use CSS variables for consistency.     |
| Motion      | High-impact moments over scattered interactions. One orchestrated page load beats many micro-interactions.        |
| Layout      | Asymmetry, overlap, diagonal flow, grid-breaking. Generous negative space OR controlled density — commit.         |
| Atmosphere  | Gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, grain overlays.    |

Match implementation complexity to the vision: maximalist designs get elaborate animations and effects; minimalist designs demand restraint, precision, and attention to spacing and detail.

## Avoid

- Overused font families (Inter, Roboto, Arial, system fonts, Space Grotesk — don't converge on "safe" choices across generations)
- Cliched color schemes (purple gradients on white is the canonical offender)
- Charity/wellness clichés — cream backgrounds with forest green and warm orange/terracotta accents read as spa-yoga-retreat, undermine credibility for donor-facing, institutional, or business audiences. For serious contexts, default to editorial palettes (white + hard black + one decisive accent)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

## Vary

No two designs should be the same. Vary themes (light/dark), fonts, aesthetics across generations. If the last output used a display serif and a teal-on-ink palette, the next should not.

## Constraints

- Produce real, working code — HTML/CSS/JS, React, Vue, etc. — not mockups
- Maintain a single aesthetic point-of-view across the whole output; do not mix brutalist typography with pastel gradients
- Accessibility and performance are not aesthetic concessions; they are part of production-grade
- Iterate one visual variable per round when refining a design with the user. Bundling changes (illustration + color logic + label edits in one push) forces the user to accept or reject the whole package; they can't keep the parts that landed and discard the parts that didn't. This costs at least one extra round per bundle.

## Sources

[WCAG]: https://www.w3.org/TR/WCAG22/ "Web Content Accessibility Guidelines (WCAG) 2.2, W3C Recommendation"
