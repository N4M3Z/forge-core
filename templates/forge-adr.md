---
title: "${TITLE}"
description: "${DESCRIPTION}"              %% one-sentence summary of the decision %%
type: adr
category: ${CATEGORY}                      %% architecture, process, governance, security, etc. %%
tags:
    - ${TAG}
status: ${STATUS}                          %% proposed | accepted | deprecated | superseded %%
created: ${DATE}
updated: ${DATE}
author: "${AUTHOR}"
project: ${PROJECT}
related: []
responsible: ["${AUTHOR}"]
accountable: ["${AUTHOR}"]
consulted: []
informed: []
upstream: []
---

# ${TITLE}

## Context and Problem Statement

${CONTEXT}                                 %% what forced a decision, what constraints apply, 3-6 sentences %%

## Decision Drivers

- ${DRIVER_1}                              %% force or concern influencing the choice %%
- ${DRIVER_2}

## Considered Options

1. **${OPTION_1}** — ${OPTION_1_DESCRIPTION}   %% brief description with inline pros/cons %%
2. **${OPTION_2}** — ${OPTION_2_DESCRIPTION}

%% Optional: per-option risk assessment for complex multi-stakeholder decisions
**Risk Assessment**:
- **Technical Risk**: ${TECHNICAL_RISK}    %% low | medium | high — implementation complexity, unknowns %%
- **Schedule Risk**: ${SCHEDULE_RISK}      %% low | medium | high — delivery timeline impact %%
- **Ecosystem Risk**: ${ECOSYSTEM_RISK}    %% low | medium | high — cross-module or cross-repo impact %%
%%

## Decision Outcome

Chosen option: **${CHOSEN_OPTION}**, because ${RATIONALE}.

### Consequences

- [+] ${POSITIVE}                          %% positive outcome — what improves %%
- [-] ${NEGATIVE}                          %% negative outcome or tradeoff — what gets harder, and mitigations %%

## Related Decisions

- [${RELATED_ADR}](${RELATED_FILE}) — ${RELATIONSHIP}   %% how the decisions connect %%

## Links

- [${LINK_NAME}](${LINK_URL}) — ${LINK_DESCRIPTION}     %% prior art, specs, discussions %%

%% Optional: audit trail for compliance-sensitive decisions

## Audit

### ${DATE}

**Status:** ${AUDIT_STATUS}                %% pending | complete %%

| Finding                 | Files | Lines | Assessment |
| ----------------------- | ----- | ----- | ---------- |
| Awaiting implementation | -     | -     | pending    |

**Summary:** ${AUDIT_SUMMARY}

**Action Required:** ${AUDIT_ACTION}       %% what needs to happen before the next audit %%
%%
