---
name: FrontendDesign
description: "Build distinctive, production-grade frontend interfaces that avoid generic AI aesthetics. USE WHEN the user asks for web components, pages, landing pages, dashboards, React / HTML / CSS layouts, or styling of any web UI. Not for backend or non-UI work."
version: 0.1.0
allowed-tools: Read, Grep, Write, Edit
upstream: https://github.com/davila7/claude-code-templates/blob/main/cli-tool/components/skills/creative-design/frontend-design/SKILL.md
---

# FrontendDesign

Create distinctive, production-grade web interfaces. Commit to an aesthetic direction and execute with precision — intentionality wins over intensity, whether the direction is bold maximalism or refined minimalism.

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
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

## Vary

No two designs should be the same. Vary themes (light/dark), fonts, aesthetics across generations. If the last output used a display serif and a teal-on-ink palette, the next should not.

## Constraints

- Produce real, working code — HTML/CSS/JS, React, Vue, etc. — not mockups
- Maintain a single aesthetic point-of-view across the whole output; do not mix brutalist typography with pastel gradients
- Accessibility and performance are not aesthetic concessions; they are part of production-grade
