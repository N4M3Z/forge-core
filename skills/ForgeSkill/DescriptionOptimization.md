# Description Optimization

The `description` field is the primary triggering mechanism: Claude sees only name + description when deciding whether to consult a skill. Claude tends to undertrigger, so descriptions should be a little pushy, naming both what the skill does and the concrete contexts that should invoke it, even when the user doesn't use the skill's own vocabulary.

Triggering mechanics worth knowing: Claude only consults skills for tasks it can't easily handle directly. Simple one-step queries ("read this PDF") may not trigger a skill even with a perfect description match; complex, multi-step, or specialized queries trigger reliably. Eval queries must be substantive enough that consulting a skill would actually help.

## Step 1: Generate trigger eval queries

Create 20 queries, a mix of should-trigger and should-not-trigger, saved as JSON:

```json
[
    {"query": "the user prompt", "should_trigger": true},
    {"query": "another prompt", "should_trigger": false}
]
```

Queries must be realistic: concrete and specific, with file paths, personal context, column names, company names, typos, casual speech, mixed lengths. Favor edge cases over clear-cut ones; the user signs off before the run.

- **Should-trigger (8-10)**: different phrasings of the same intent, formal and casual; cases where the user never names the skill or file type but clearly needs it; uncommon use cases; cases where this skill competes with another but should win.
- **Should-not-trigger (8-10)**: near-misses that share keywords or concepts but need something different: adjacent domains, ambiguous phrasing a naive keyword match would catch, contexts where another tool is more appropriate. Obviously irrelevant negatives test nothing.

## Step 2: Review with the user

Render the eval set for review using the bundled template:

1. Read `assets/eval_review.html`
2. Replace `__EVAL_DATA_PLACEHOLDER__` (the JSON array, unquoted), `__SKILL_NAME_PLACEHOLDER__`, `__SKILL_DESCRIPTION_PLACEHOLDER__`
3. Write to a temp file and open it in the browser
4. The user edits queries, toggles should-trigger, and clicks "Export Eval Set"
5. The export lands in `~/Downloads/eval_set.json`; take the most recent if there are duplicates

Bad eval queries produce bad descriptions; this review step is load-bearing.

## Step 3: Run the optimization loop

Warn the user it takes a while, then run in the background from this skill's directory:

```bash
python -m scripts.run_loop \
    --eval-set <path-to-trigger-eval.json> \
    --skill-path <path-to-skill> \
    --model <model-id-powering-this-session> \
    --max-iterations 5 \
    --verbose
```

Use the model ID powering the current session so the triggering test matches what the user experiences. The loop splits 60% train / 40% held-out test, measures the current description (each query 3 times), proposes improvements from the failures, and re-evaluates up to 5 iterations. It reports per-iteration results and returns JSON with `best_description`, selected by test score to avoid overfitting. Tail the output periodically to report progress.

Requires the `claude` CLI (`claude -p`); Claude Code only.

## Step 4: Apply the result

Update the skill's frontmatter with `best_description`, show the user before/after, and report the scores. For forge skills, keep the `USE WHEN` clause convention when merging the optimized text.
