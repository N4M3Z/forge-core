# DesignReview Fixture — Expected Findings

Reference artifacts for the `DesignReview` skill, captured with Playwright + axe-core (`capture.mjs` against `dash.html?variant=bad`, desktop viewport 1440x900, reduced motion, fonts and network idle). A correct review of this fixture produces the findings below; deviations indicate contract drift in the skill.

## Artifacts

| File                                | Contents                                                        |
| ----------------------------------- | --------------------------------------------------------------- |
| `baddash__default__desktop.png`     | Populated dashboard with seeded defects                        |
| `baddash__default__desktop.axe.json`| axe report: `color-contrast` + `target-size` violations         |
| `baddash__empty__desktop.png`       | Empty state (context + guidance + CTA, no violations)          |
| `baddash__empty__desktop.axe.json`  | axe report: no violations                                       |
| `dash.html`                         | Source page; `?variant=bad\|good`, `?state=default\|empty\|loading\|error` |
| `capture.mjs`                       | Capture script (playwright + @axe-core/playwright)             |

## Expected verdicts

| verdict        | state   | check                              | evidence                                                             |
| -------------- | ------- | ---------------------------------- | -------------------------------------------------------------------- |
| verified-fail  | default | text contrast ≥ 4.5:1              | axe `color-contrast`: `.card .label` at 1.46:1 (#c9ccd1 on #f3f4f6) |
| verified-fail  | default | touch target (WCAG 2.5.8)          | axe `target-size`: R/F/M buttons 18×18px, clustered under 24px spacing |
| judgment-fail  | default | ages-poorly smell / intent check   | emoji (🚀📊⚙️) as the only nav iconography — flag intent, not auto-fail |
| verified-pass  | empty   | state completeness                 | heading + explanation + CTA, no axe violations                       |
| not-verified   | loading | all checks                          | state absent from this fixture — must NOT be reported as pass        |
| not-verified   | error   | all checks                          | state absent from this fixture — must NOT be reported as pass        |

## Contract points this fixture exercises

- Hard verdicts sourced only from the axe JSON, ratios quoted from it, never estimated off the PNG.
- Absent states (`loading`, `error` here) reported not-verified, never passing.
- `target-size` semantics: WCAG 2.5.8 includes a spacing exception — an isolated small button passes legitimately; only the clustered R/F/M row violates.
- Screenshot findings are `judgment-fail`, reserved axe-backed findings are `verified-*`.

Regenerate after editing `dash.html`:

```sh
npm install playwright @axe-core/playwright && npx playwright install chromium
node capture.mjs dash.html baddash bad default,empty
```
