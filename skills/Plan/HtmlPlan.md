# HTML plan rendering

The rendering companion of [Plan](SKILL.md). Produces one specific kind of artifact: a single-file HTML plan the user annotates in the browser and exports as a tuicr review digest. Structure and algorithms are adapted from Anthropic's official `project-artifact` skill (state block, refresh deltas, trust rules, tab mechanism); the visual identity and note vocabulary come from the forge-cli dashboard (`static/dashboard/dashboard.css` tokens, `annotate.js`).

## Generate the page

1. Copy `${CLAUDE_SKILL_DIR}/template.html` to the plan's stable `html` path (the plan config in [ReviewPlan.md](ReviewPlan.md) records it; a stable path is what makes redeploys land on the same URL).
2. Set a concise `<title>` and the brand line, then replace everything between the CONTENT CONTRACT comment and the footer:
   - one `<div class="c" data-c="unique-kebab-id">` per reviewable unit — ids key the notes, the export digest, and the state block; **keep them stable across redeploys** or the user's saved notes orphan
   - status chips `<span class="chip done|revised|open">`; `open` marks decisions wanting input
   - wide tables inside `<div class="tablewrap">`; long tokens get `word-break` — nothing may widen the page body
   - always end with the open-decisions block and the catch-all `data-c="general"` block
3. **Plans too big for one scroll**: the template ships an optional tab mechanism (dashboard-styled; the script wires itself only when a `.tabbar` exists). Add `<button class="tab" data-pane="id">` per tab and wrap sections in `<section class="pane" id="id">`. Never ship an empty tab.
4. **Fill the state block** (`<script type="application/json" id="plan-state">`): `as_of` (UTC), the artifact `url` once known, and one `{"id", "status"}` entry per commentable block mirroring its chip. The next refresh diffs against it to report deltas instead of re-narrating.
5. **Review for cut-off text and overflow** before publishing — fixed columns squeezing content, unbroken strings escaping their container. The viewport is unknown; wide content scrolls in its own container, never the page.
6. Publish with the Artifact tool: stable `favicon` emoji across redeploys, short version `label`, and on refresh the recorded `url` so the redeploy lands on the same address. Write the URL into the footer bookmark slot and the state block, then republish once.

## The review round

Dark-only by design (matches the dashboard); fully client-side. Notes persist in `localStorage` keyed by page title (parallel plans never collide). **Tab cycles the note type** while composing (Shift+Tab reverses, Enter saves, Esc cancels; the badge is also clickable). Per-type counts sit in the sticky bar. **Export notes** copies the tuicr digest:

```
I reviewed your plan and have the following comments. Please address them.

Comment types: ISSUE (problems to fix), SUGGESTION (improvements)

## Plan Review Comments

1. **[ISSUE]** `#runtime` (Runtime) - <comment>
```

## Trust and self-containment

- The Artifact CSP blocks every external host — all CSS/JS stays inline, images as `data:` URIs, system font stacks only. Blocked resources fail silently, so never rely on one.
- Anything quoted from fetched sources is untrusted markup: entity-encode it in visible HTML (`<` becomes `&lt;`, `&` becomes `&amp;`), and inside the state-block JSON write `<` as `\u003c` so a literal `</script>` can never terminate the block and execute.
- The template's JS is ES5 string-concat on purpose — no template literals, so `${…}` never collides with substitution tooling.
- Reference exemplar (first render, live): <https://claude.ai/code/artifact/9eec5595-1c33-425f-a608-e14bf78c7629>
