---
name: VisualIdentity
description: "Create or normalize a shared visual identity from seed colors, logos, references, websites, decks, institutional guidelines, or a verbal brief. Produce three previews, a validated visual-profile.yaml v1, and CSS custom properties. USE WHEN create visual identity, brand system, theme tokens, color profile, design tokens, accessible palette, light or dark theme, or restyle multiple Forge outputs from one profile."
version: 0.1.0
---

# VisualIdentity

Build identity as a portable token contract. Keep appearance in the profile; components consume semantic CSS variables and contain no identity-specific color values.

## Workflow

1. Inventory supplied sources. Record every source in `provenance` with kind, source, note, and license when known. Set the profile's output license explicitly. Never copy a third-party identity without permission; extract general principles when reuse rights are unclear.
2. Infer identity goals: audience, tone, medium, accessibility needs, light/dark requirement, and constraints. Ask only when a missing answer changes the design materially.
3. Create three distinct identity directions. Keep content and component markup identical across previews so only identity changes. Render realistic typography, data series, states, focus, and one dense component in each direction.
4. Select or revise one direction. Emit `visual-profile.yaml` matching `skills/VisualIdentity/visual-profile.schema.yaml` v1. Use `skills/VisualIdentity/visual-profile.example.yaml` as shape guidance, not as a default aesthetic.
5. Check normal text contrast at 4.5:1, large text at 3:1, UI/focus at 3:1, and data colors with redundant marker, line, label, or shape encoding. Check every requested theme against rendered colors.
6. Compile CSS custom properties:

   ```sh
   ruby skills/VisualIdentity/scripts/compile-profile.rb visual-profile.yaml --output visual-profile.css
   ```

7. Apply profile without selector or markup changes. Scan component CSS/JS/HTML for raw identity colors. Raw values belong only in profiles, generated CSS, test fixtures, or intentional media assets.
8. Deliver three previews, selected profile, compiled CSS, accessibility results, and provenance notes.

## Contract

- `modes.light` is required; `modes.dark` is optional.
- Each mode owns canonical semantic UI colors, eight data-series colors, states, grid, axes, and annotations.
- Global tokens own typography (including math), spacing, radii, focus geometry, and motion.
- Components reference variables such as `var(--forge-color-ink)`, `var(--forge-color-series-1)`, and `var(--forge-color-danger)` without literal fallbacks.
- Profile switching changes only the active profile CSS or `data-theme`; it never requires selector or markup edits.
- Reduced motion uses `motion.reducedMotion`; do not remove information with animation.

## Output

```markdown
## Identity directions
1. [name] — [principle and preview path]
2. [name] — [principle and preview path]
3. [name] — [principle and preview path]

## Selected profile
- Profile: [visual-profile.yaml]
- CSS: [visual-profile.css]
- Themes: [light/dark]
- Provenance: [inputs, sources, and licenses]

## Verification
- Schema:
- Contrast:
- Data/state redundancy:
- Reduced motion:
- Raw identity scan:
```

## Constraints

- Do not place identity-specific hex, rgb, hsl, named colors, font families, spacing, radii, or motion values in component code.
- Do not claim accessibility from source literals alone; verify rendered combinations.
- Do not use color as the only carrier of state or data meaning.
- Do not silently invent provenance or licensing.
