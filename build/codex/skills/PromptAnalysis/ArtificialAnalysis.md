# Artificial Analysis Integration

Query model capability scores to inform redundancy estimates. Provides benchmark context: how does a model rank on coding, reasoning, safety, and instruction following?

## API

```bash
curl -s "https://api.artificialanalysis.ai/api/v2/data/llms/models" \
    -H "x-api-key: $ARTIFICIAL_ANALYSIS_API_KEY" | jq '.[] | select(.name == "Claude Opus 4.6")'
```

Returns composite scores across coding, math, reasoning, and science from the Intelligence Index v4.0 (aggregates Terminal-Bench Hard, SciCode, and others).

## How the Skill Uses It

When scan mode estimates redundancy, it can optionally enrich the estimate with benchmark data:

```
NoHeredoc.md
  [redundancy:HIGH] model self-assessment: already follows this natively
  [benchmark] Claude Opus 4.6: coding=1561 Elo, intelligence=92.3
  [benchmark] Claude Haiku 4.5: coding=1320 Elo, intelligence=78.1
  recommendation: target to haiku-tier models only
```

The benchmark scores don't directly answer "does this model avoid heredocs?" but they provide calibration: a model with 1561 coding Elo is more likely to follow coding best practices natively than one with 1320.

## Limitations

- No task-specific capability scores (no "SQL injection prevention" metric)
- Composite scores, not granular: coding, math, reasoning, science
- Primarily covers frontier models, limited open-source coverage
- Scores update with new benchmark runs, not real-time
- Attribution required when displaying scores

## Fallback

If the API key is not set or the API is unreachable, the skill falls back to model self-assessment only. The benchmark subskill is always optional.
