---
name: Plan
version: 0.1.0
description: "Plan implementation work in two modes: bite-sized task-list plans written in plan mode, and reviewable plans published as commentable HTML artifacts with review rounds and delta refreshes. USE WHEN write implementation plan, plan implementation, create plan, spec approved, reviewable plan, commentable html plan, plan review round, refresh plan artifact, actioning an exported plan-review digest. Not for executing an approved plan (ExecutePlan)."
allowed-tools: Read, Write, Edit, Bash, Artifact, WebFetch
---

# Plan

One skill, two planning modes. A reviewable-plan artifact typically precedes a task list; ExecutePlan owns running an approved plan.

## Workflow Routing

| Request                                                                 | Route                          |
| ----------------------------------------------------------------------- | ------------------------------ |
| Bite-sized implementation task list from an approved spec               | [TaskPlan.md](TaskPlan.md)     |
| Reviewable plan artifact: build, publish, review round, digest, refresh | [ReviewPlan.md](ReviewPlan.md) |
| Render the commentable HTML plan page                                   | [HtmlPlan.md](HtmlPlan.md)     |
