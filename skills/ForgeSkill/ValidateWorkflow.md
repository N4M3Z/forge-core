## Step 1: Read the target skill

Read the SKILL.md file.

## Step 2: Check frontmatter

- [ ] `name:` present and uses correct casing
- [ ] `description:` is single-line with `USE WHEN` clause
- [ ] `description:` is under 1024 characters
- [ ] No deprecated fields (`triggers:`, `workflows:` arrays)
- [ ] Optional fields (`argument-hint:`, `version:`) are correctly formatted

## Step 3: Check body structure

- [ ] Starts with `# SkillName` heading (matches `name:` frontmatter)
- [ ] Has clear instructions (numbered steps, usage section, or workflow routing)
- [ ] If multiple workflows: `## Workflow Routing` table present
- [ ] Constraints or rules section for boundary conditions
- [ ] No unnecessary sections or boilerplate

## Step 4: Check CLI tool integration (if applicable)

- [ ] Tool path is documented
- [ ] Usage examples with `bash` blocks
- [ ] Intent-to-flag mapping table (if tool has flags)
- [ ] Output format described

## Step 5: Check content quality

- [ ] Inputs and outputs stated explicitly (what the skill consumes, what artifact it produces)
- [ ] Guardrails pause rather than auto-escalate — no silent jump from read-only analysis to executing targets or installing tooling
- [ ] No authoring-environment fingerprints: stdlib-only probes use a preflight-resolved `python3`, not `uv run python`; no personal paths, package managers, or aliases the target machine may lack
- [ ] Deliverable is an artifact (table, file, verdict schema), not prose

## Step 6: Report

**COMPLIANT** — all checks pass.

**NON-COMPLIANT** — list failures with specific fixes. Offer to fix automatically.
