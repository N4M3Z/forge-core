---
title: "Test fixture for canary validation"
description: "A structurally valid ADR used to verify the validator accepts good input"
type: adr
category: test
tags:
    - test
    - canary
status: accepted
created: 2026-04-05
updated: 2026-04-05
author: "@test"
project: forge-core
responsible:
    - "@test"
accountable:
    - "@test"
consulted: []
informed: []
upstream: []
---

# Test Fixture

## Context and Problem Statement

This fixture verifies the validation chain accepts structurally valid ADRs.

## Considered Options

1. Include a passing fixture
2. Only test failures

## Decision Outcome

Chosen option: include a passing fixture, because a validator that rejects everything is as broken as one that accepts everything.
