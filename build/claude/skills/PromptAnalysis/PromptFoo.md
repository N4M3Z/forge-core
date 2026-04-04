# PromptFoo Integration

Behavioral ablation testing — confirm whether a rule changes model behavior by running with/without it.

## Setup

```bash
npm install -g promptfoo
```

API keys required for each provider you want to test against. Set in environment:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
export OPENAI_API_KEY=sk-...
```

## How It Works

For a rule flagged as "likely redundant" by scan mode, generate a PromptFoo config that tests the rule's behavioral impact:

1. Extract the rule's instruction text
2. Build two system prompts: one with the rule included, one without
3. Generate adversarial test cases where the rule should matter
4. Run `promptfoo eval` against each target model
5. Compare pass rates — equal rates confirm redundancy

## Generated Config

The skill generates a `promptfooconfig.yaml` in a temp directory:

```yaml
description: "Ablation test for NoHeredoc.md"

providers:
    - id: anthropic:claude-sonnet-4-6
    - id: anthropic:claude-opus-4-6

prompts:
    - file://system-with-rule.txt
    - file://system-without-rule.txt

tests:
    - vars: {}
      assert:
        - type: llm-rubric
          value: "Response must use the Write tool to create files, never heredoc or cat with redirection"

    - vars:
        task: "Create a config file with 5 lines of YAML"
      assert:
        - type: not-contains
          value: "cat << 'EOF'"
        - type: not-contains
          value: "heredoc"

    - vars:
        task: "Write a shell script that outputs hello world"
      assert:
        - type: llm-rubric
          value: "Response must create the file using the Write tool, not echo or heredoc"
```

## Running

```bash
cd /tmp/promptprovenance-ablation
promptfoo eval
promptfoo view    # opens browser with results
```

## Interpreting Results

| With rule    | Without rule | Verdict                                                |
|--------------|--------------|--------------------------------------------------------|
| 100% pass    | 100% pass    | REDUNDANT — rule has no behavioral impact              |
| 100% pass    | < 90% pass   | NEEDED — rule prevents failures                        |
| < 100% pass  | < 100% pass  | WEAK — rule helps but doesn't fully prevent failures   |

For redundant rules, recommend adding `targets:` to skip for models where the rule has no impact. Do not recommend deletion — the rule may be needed for future weaker models.
