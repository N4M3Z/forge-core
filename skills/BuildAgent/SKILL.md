---
name: BuildAgent
description: "Create, validate, or audit agent definitions. USE WHEN create agent, new agent, build agent, scaffold agent, validate agent, audit agents, agent conventions, agent frontmatter."
metadata:
    version: 0.1.0
---

# BuildAgent

Scaffold, validate, and audit agent markdown files following forge conventions. Agents are markdown files with frontmatter that deploy to provider-specific directories via `install-agents`.

## Workflow Routing

| Workflow | Trigger | Section |
|----------|---------|---------|
| **Create** | "create agent", "new agent", "build agent" | [Create Workflow](#create-workflow) |
| **Validate** | "validate agent", "check agent" | [Validate Workflow](#validate-workflow) |
| **Audit** | "audit agents", "check all agents" | [Audit Workflow](#audit-workflow) |

## Agent Conventions

### Naming

All agent identifiers use **PascalCase** with no spaces, hyphens, or abbreviations:

| Field | Format | Example |
|-------|--------|---------|
| `name` | PascalCase | `SecurityArchitect` |
| Source filename | PascalCase.md | `SecurityArchitect.md` |
| Deployed filename | PascalCase.md | `~/.claude/agents/SecurityArchitect.md` |
| Task subagent_type | PascalCase | `subagent_type: "SecurityArchitect"` |

Rules:
- No spaces: `GameMaster` not `Game Master`
- No hyphens: `SecurityArchitect` not `security-architect`
- No abbreviations: `DocumentationWriter` not `DocWriter`
- Compound terms keep internal caps: `DevOps` stays `DevOps`
- Single words capitalize first letter: `Ghostwriter`, `Opponent`

### Where Agents Live

| Location | Purpose |
|----------|---------|
| `agents/` | Module agents (shipped with the module) |
| User vault workspace | Personal agents |

Agent `name` must be **unique across all locations** -- sync overwrites by name.

### Module Agent Frontmatter

Module agents use flat frontmatter -- deployment config (model, tools) lives in `defaults.yaml`, not in the agent file:

```yaml
---
name: AgentName
description: "Role -- capabilities. USE WHEN trigger phrases."
version: 0.1.0
---
```

**Field reference:**

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | PascalCase, matches filename |
| `description` | Yes | Pattern: `"Role -- capabilities. USE WHEN triggers."` |
| `version` | Yes | Semantic version |

Model and tool assignments live in `defaults.yaml`:

```yaml
agents:
    - name: SecurityArchitect
      model: fast
      tools: Read, Grep, Glob, Bash
```

**Semantic model tiers:**

| Tier | Maps to | Use for |
|------|---------|---------|
| fast | sonnet / gemini-2.0-flash | Implementation, analysis, most specialist work |
| strong | opus / gemini-2.5-pro | Deep reasoning, critical decisions |

### Body Structure

```markdown
> One-line summary of role and scope. Shipped with forge-{module}.

## Role

2-3 sentences. Who is this agent? What perspective does it bring?

## Expertise

- Domain 1
- Domain 2
- Domain 3
- Domain 4
- Domain 5

## Instructions

### When Reviewing Code (or contextual heading)

1. Numbered steps. Concrete, actionable, ordered.
2. ...

### When Designing or Planning (or contextual heading)

1. Numbered steps for alternative modes.
2. ...

## Output Format

Structured template for findings using markdown headings.

## Constraints

- Stay focused on [domain] -- don't review [other domains]
- Reference specific files and line numbers
- If the [domain] is solid, say so -- don't invent problems
- Every critique must include a concrete suggestion
- Communicate findings to the team lead via SendMessage when done
```

**Body guidelines:**
- Lead with a blockquote summary (`> ...`). End with "Shipped with forge-{module}." for module agents.
- Keep Role to 2-3 sentences. Don't pad with generic filler.
- Expertise: 4-6 concrete domains, not abstract qualities
- Instructions: numbered, actionable, in priority order
- Total body: 50-80 lines. Under 40 is too thin, over 100 is bloated.

**Mandatory constraint clauses:**
- **Honesty clause**: "If the [domain] is solid, say so -- don't invent problems. Every critique must include a concrete suggestion."
- **Team communication clause** (council/team agents): "Communicate findings to the team lead via SendMessage when done."

**Example data rule:** All examples must use synthetic data (Jane Doe, jdoe@example.com, Acme Corp). Never use real PII -- agent files deploy to public repos.

### Deployment

Module agents deploy via `install-agents` from forge-lib:

```bash
make install-agents                        # all providers
lib/bin/install-agents agents --scope user  # user-level install
```

Deployment adds a `# synced-from: OriginalFilename.md` header for provenance tracking. Tool mapping to provider equivalents happens automatically.

---

## Create Workflow

### Step 1: Understand the agent

Determine:
1. What role does this agent fill?
2. What domain expertise does it need?
3. Is it standalone or part of a team (like council)?
4. What tools does it need? (Read-only? Full access?)
5. What model tier? (fast for most work, strong for reasoning)

If unclear, ask using AskUserQuestion.

### Step 2: Choose the location

| Scenario | Location |
|----------|----------|
| Part of a forge module | `agents/AgentName.md` |
| Personal agent | User vault workspace |

### Step 3: Check for naming conflicts

The name must be unique across all source directories.

### Step 4: Write the agent file

Follow the frontmatter and body structure from [Agent Conventions](#agent-conventions).

### Step 5: Deploy

```bash
make install-agents
```

### Step 6: Verify

The agent will be available as a `subagent_type` after restarting the session.

---

## Validate Workflow

### Step 1: Read the agent file

### Step 2: Check frontmatter

- [ ] `name` present and uses PascalCase
- [ ] `name` has no spaces, hyphens, or abbreviations
- [ ] `name` matches the filename (without .md)
- [ ] `description` follows pattern: `"Role -- capabilities. USE WHEN triggers."`
- [ ] `version` present

### Step 3: Check body structure

- [ ] Starts with blockquote summary (`> ...`)
- [ ] Has Role section (2-3 sentences)
- [ ] Has Expertise section (4-6 items)
- [ ] Has Instructions with actionable numbered steps
- [ ] Has Output Format with structured template
- [ ] Has Constraints with scope boundaries
- [ ] Constraints include honesty clause
- [ ] No real PII in examples
- [ ] Total length is 50-80 lines

### Step 4: Report

**COMPLIANT** or **NON-COMPLIANT** with specific issues and fixes.

---

## Audit Workflow

### Step 1: Scan all agent sources

```bash
ls agents/*.md
```

### Step 2: Check each agent

Run the Validate workflow checklist against every agent. Report:

| Agent | Name OK | FM OK | Body OK | Issues |
|-------|---------|-------|---------|--------|
| Developer | Y | Y | Y | -- |
| ... | ... | ... | ... | ... |

### Step 3: Check for conflicts

- Duplicate `name` values
- Names that don't follow PascalCase
- For module agents: verify defaults.yaml lists all agents in roster
- For module agents: verify deployed model/tools match defaults.yaml

### Step 4: Report summary

Total agents, compliant count, issues found, recommended fixes.

---

## Constraints

- Never create an agent without `name` in frontmatter
- Always use PascalCase for agent names -- non-negotiable
- Model and tool config belongs in defaults.yaml, not agent frontmatter
- Agent descriptions must follow pattern: `"Role -- capabilities. USE WHEN triggers."`
- For council/team agents, include scope note in description
- After creating or modifying agents, deploy to see changes
