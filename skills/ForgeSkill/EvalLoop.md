# Eval Loop

Run test cases against a skill, review results with the user, improve, repeat. This is one continuous sequence; don't stop partway through.

Results live in `<skill-name>-workspace/` as a sibling of the skill directory, organized by iteration (`iteration-1/`, `iteration-2/`), with one directory per test case named `eval-<ID>-<descriptive-name>`. The aggregator discovers only `eval-*` directories, and each config directory must contain `run-<R>/` subdirectories holding `outputs/`, `grading.json`, and `timing.json`; files placed directly in the config directory are ignored. Create directories as you go, not upfront.

## Write test cases

Draft 2-3 realistic test prompts, the kind a real user would type. Confirm them with the user before running. Save to `evals/evals.json` (prompts only; assertions come later):

```json
{
    "skill_name": "ExampleSkill",
    "evals": [
        {
            "id": 1,
            "prompt": "User's task prompt",
            "expected_output": "Description of expected result",
            "files": []
        }
    ]
}
```

Full schema, including the `assertions` field: [references/schemas.md](references/schemas.md).

Skills with objectively verifiable outputs (file transforms, data extraction, code generation, fixed workflows) benefit from assertions. Subjective skills (writing style, design) are better judged qualitatively; don't force assertions onto human-judgment outputs.

## Step 1: Spawn all runs in the same turn

For each test case, spawn two subagents in the same turn, one with the skill and one baseline, so everything finishes together.

With-skill run prompt:

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>-<name>/with_skill/run-1/outputs/
- Outputs to save: <what the user cares about>
```

Baseline run, same prompt:

- New skill: no skill at all; save to `without_skill/outputs/`.
- Improving an existing skill: snapshot first (`cp -r <skill-path> <workspace>/skill-snapshot/`), point the baseline at the snapshot, save to `old_skill/outputs/`.

Write an `eval_metadata.json` per test case (assertions may be empty for now):

```json
{
    "eval_id": 0,
    "eval_name": "descriptive-name-here",
    "prompt": "The user's task prompt",
    "assertions": []
}
```

## Step 2: Draft assertions while runs are in progress

Good assertions are objectively verifiable and have descriptive names that read clearly in the benchmark viewer. Update `eval_metadata.json` and `evals/evals.json` once drafted, and explain to the user what they'll see in the viewer.

## Step 3: Capture timing as each run completes

Each subagent completion notification carries `total_tokens` and `duration_ms`. Save immediately to `timing.json` in the run directory; the notification is the only place this data exists. Process notifications as they arrive, never batch.

```json
{
    "total_tokens": 84852,
    "duration_ms": 23332,
    "total_duration_seconds": 23.3
}
```

## Step 4: Grade, aggregate, launch the viewer

1. **Grade each run.** Spawn a grader subagent (instructions: [agents/grader.md](agents/grader.md)) evaluating each assertion against the outputs; save `grading.json` in each `run-<R>/` directory. The expectations array MUST use the fields `text`, `passed`, `evidence`, and the file MUST carry a `summary` object (`passed`, `failed`, `total`, `pass_rate`); the aggregator and viewer depend on these exact names. Check programmatically verifiable assertions with a script, not by eyeballing.
2. **Aggregate.** From this skill's directory: `python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>`. Produces `benchmark.json` and `benchmark.md` (pass rate, time, tokens, mean, stddev, delta). Put each with_skill version before its baseline counterpart.
3. **Analyst pass.** Read the benchmark data for patterns the aggregates hide: non-discriminating assertions, high-variance evals, time/token tradeoffs. See the "Analyzing Benchmark Results" section of [agents/analyzer.md](agents/analyzer.md).
4. **Launch the viewer** before doing your own revision pass; get outputs in front of the human first:

    ```bash
    nohup python <skill-dir>/eval-viewer/generate_review.py \
        <workspace>/iteration-N \
        --skill-name "<name>" \
        --benchmark <workspace>/iteration-N/benchmark.json \
        > /dev/null 2>&1 &
    VIEWER_PID=$!
    ```

    For iteration 2+, add `--previous-workspace <workspace>/iteration-<N-1>`. Headless or no-display environments: pass `--static <output_path>` to write standalone HTML instead of serving; feedback then downloads as `feedback.json`, which you copy into the workspace. Always use `generate_review.py`; never hand-write viewer HTML.

5. **Tell the user** the viewer is open: the Outputs tab collects per-case feedback, the Benchmark tab shows the quantitative comparison.

## Step 5: Read the feedback

When the user says they're done, read `feedback.json`. Empty feedback on a case means it was fine; focus on cases with specific complaints. Kill the viewer: `kill $VIEWER_PID 2>/dev/null`.

## Improve the skill

- **Generalize from the feedback.** The skill must work across many prompts, not just the test set. Avoid fiddly overfit patches and rigid MUSTs; if an issue is stubborn, try a different framing or working pattern instead.
- **Keep the prompt lean.** Read the transcripts, not just outputs. If the skill makes the model do unproductive work, cut the part causing it and re-measure.
- **Explain the why.** Reframe all-caps imperatives as reasoning the model can apply; that generalizes better than rote instruction.
- **Bundle repeated work.** If every test run independently wrote the same helper script, move that script into `scripts/` and reference it from the skill.

Then rerun everything into `iteration-<N+1>/` (baselines included), launch the viewer with `--previous-workspace`, and read the new feedback. Stop when the user is happy, the feedback is all empty, or progress stalls.

## Blind comparison (optional)

For a rigorous "is the new version actually better?" answer: give two outputs to an independent agent without revealing which is which, let it judge, then analyze why the winner won. Instructions: [agents/comparator.md](agents/comparator.md) and [agents/analyzer.md](agents/analyzer.md). Requires subagents; the human review loop is usually sufficient.

## Harness adaptations

- **No subagents** (e.g. claude.ai): run test cases yourself, one at a time, skill instructions in context. Skip baselines and quantitative benchmarking; present outputs inline and gather feedback conversationally.
- **No browser or display**: skip the viewer server, use `--static`, present file outputs by path.
- **Description optimization** requires `claude -p` (Claude Code only): see [DescriptionOptimization.md](DescriptionOptimization.md).
- **Packaging for claude.ai upload**: `python -m scripts.package_skill <path/to/skill-folder>` produces a `.skill` file; works anywhere with Python. Not needed for forge modules, which deploy via `forge install`.
- **Updating an existing skill**: preserve the original `name` and directory name unchanged; copy read-only installs to a writable location before editing.
