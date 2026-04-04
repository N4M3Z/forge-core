---
name: HtmlPlayground
description: "Generate single-file HTML demos comparing techniques side-by-side. USE WHEN preview css, compare css, css demo, show options, visual comparison, html playground, render demo."
version: 0.1.0
---

# HtmlPlayground

Generate a self-contained HTML file that renders techniques as side-by-side cards with realistic mock data. Open in browser for visual comparison before committing to production.

## When to use

Before adding CSS to a project (snippets, themes, component styles), render the candidates visually so the user can compare and choose. One HTML file, no dependencies, no build step.

## Instructions

1. Identify the CSS techniques to compare. Sources: conversation context, research findings, user description, or files in the working directory. Each technique becomes one card.

2. For each technique, determine:
   - A short title and source attribution (URL if available)
   - The CSS rules that define it
   - What realistic mock content looks like (tasks, cards, lists, forms — match the user's actual domain)

3. Generate a single HTML file at `/tmp/css-preview-{topic}.html` with this structure:

   - Dark theme by default using CSS variables (adapts if user prefers light)
   - `prefers-color-scheme` media query with light mode fallback
   - A grid of cards, one per technique, each self-contained
   - Each card has: title, source link, the rendered demo with realistic data
   - A final card showing all techniques combined (if they layer without conflict)
   - No external dependencies — all CSS inline, all fonts system

4. Open the file in the default browser.

5. Ask the user which techniques to adopt. Options: individual techniques by name, "all", or "none".

6. For adopted techniques, write the CSS to the appropriate location (snippet file, component stylesheet, or new file — based on context).

## Card design

Each card is a self-contained demo. Use these conventions:

- Card background slightly darker than page background
- Subtle border, rounded corners (12px)
- Title in the card header with source attribution as small text below
- Demo content uses the same CSS variable names as the target platform (Obsidian vars for vault snippets, standard custom properties for web projects)
- Mock data should feel real — use the user's actual project names, task descriptions, and entity types when known from conversation context

## HTML template skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{Topic} — CSS Preview</title>
<style>
    :root { /* dark mode variables */ }
    @media (prefers-color-scheme: light) { :root { /* light overrides */ } }
    /* page layout, card grid, shared base */
    /* per-technique CSS in labeled sections */
</style>
</head>
<body>
    <h1>{Topic}</h1>
    <p class="subtitle">{Context line}</p>
    <div class="grid">
        <!-- one .card per technique -->
    </div>
</body>
</html>
```

## Constraints

- Maximum 6 cards per preview (4 techniques + 1 combined is ideal)
- All CSS inline in a single `<style>` block — no external sheets
- No JavaScript unless the comparison requires interactivity (hover states, toggles)
- File goes to `/tmp/` — never write preview HTML into the project directory
- Source attribution is mandatory when the technique has a known origin
- Mock data must feel realistic, not lorem ipsum
