# LLMLingua Integration

Perplexity-based prompt compression — identify which tokens in a rule are predictable (low perplexity = the model already expects this content) vs surprising (high perplexity = novel information the model needs).

## Setup

```bash
pip install llmlingua
```

Requires a local small model for perplexity scoring (default: `microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank`). Downloads on first run (~500MB).

## How It Works

LLMLingua scores each token's perplexity relative to the surrounding context. Low-perplexity tokens are "obvious" to the model — it would predict them without being told. High-perplexity tokens carry novel information.

For prompt minimalization, low-perplexity rules are redundancy candidates: the model already expects this behavior.

## Usage

```python
from llmlingua import PromptCompressor

compressor = PromptCompressor(model_name="microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank")

result = compressor.compress_prompt(
    context=[rule_text],
    rate=0.5,                  # compress to 50%
    force_tokens=["[1]:", "---"],  # preserve structural markers
    condition_in_question="none"
)

print(f"Original: {result['origin_tokens']} tokens")
print(f"Compressed: {result['compressed_tokens']} tokens")
print(f"Ratio: {result['ratio']:.1%}")
print(f"Compressed text:\n{result['compressed_prompt']}")
```

## How the Skill Uses It

When invoked via `/PromptProvenance compress`, the skill:

1. Reads each rule file in the module
2. Runs LLMLingua compression at 50% rate
3. Compares original vs compressed: rules that compress heavily (>60% reduction) are likely redundant — the model already knows most of the content
4. Rules that resist compression (<30% reduction) contain novel information the model needs

```
PromptProvenance Compress: forge-core (27 rules)

HIGH COMPRESSION (likely redundant)
  SanitizeData.md ........ 73% compressible — model knows sanitization natively
  GitConventions.md ...... 68% compressible — conventional commits are well-known

LOW COMPRESSION (novel information)
  UseRTK.md .............. 12% compressible — rtk is project-specific, model can't know this
  EkctlCommands.md ....... 8% compressible — custom CLI tool, fully novel
```

## Limitations

- Perplexity measures token predictability, not behavioral impact — a rule can be predictable but still behaviorally necessary
- The scoring model is smaller than the target model — perplexity estimates are approximate
- Does not account for instruction-following dynamics (a model may "know" something but not "do" it without being told)
- Use as a pre-filter for PromptFoo ablation, not as a standalone verdict

## Fallback

If LLMLingua is not installed, the skill skips compression analysis and reports: "Install llmlingua for perplexity-based redundancy scoring."
