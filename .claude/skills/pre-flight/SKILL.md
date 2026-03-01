---
name: pre-flight
description: >
  Multi-agent review of PAUL plans BEFORE execution. Runs architecture,
  security, performance, and spec-flow agents in parallel against PLAN.md
  files to catch design flaws before they become code. Trigger when user
  says "pre-flight", "preflight", "gate check", "validate plan",
  "review plan before executing", or between /paul:plan and /paul:apply.
---

# Pre-Flight — Multi-Agent Plan Review

Validate that a PAUL plan is **sain** (not just complet) before execution.
PAUL's acceptance criteria verify what to build. Pre-flight verifies the plan
won't create security holes, performance bottlenecks, architectural
anti-patterns, or missed user flows.

---

## When to trigger

- After `/paul:plan` completes successfully
- Before `/paul:apply` starts
- When user explicitly asks for plan validation
- When the plan touches: authentication, payments, data migration,
  external APIs, or user-facing flows

---

## Inputs

Locate the plan files to review:

1. Read `.paul/STATE.md` to identify the current phase number
2. Find all plan files in `.paul/phases/{phase}/`
3. Also read `.paul/PROJECT.md` and `.paul/ROADMAP.md` for context
4. Check `docs/solutions/` for relevant learnings (via learnings-researcher)

If no plan files found, inform the user and suggest running `/paul:plan` first.

---

## Execution — launch 4 agents in parallel

Launch ALL four agents simultaneously using the Agent tool. Each agent
receives the plan content + project context as input.

### Agent 1: Architecture Strategist

```
subagent_type: architecture-strategist
```

Review for: component boundaries, coupling, data flow, API consistency,
separation of concerns, over/under-engineering.

### Agent 2: Security Sentinel

```
subagent_type: security-sentinel
```

Review for: auth gaps, input validation, hardcoded secrets, OWASP top 10,
data exposure risks.

### Agent 3: Performance Oracle

```
subagent_type: performance-oracle
```

Review for: N+1 queries, missing indexes, unbounded queries, caching gaps,
scalability concerns.

### Agent 4: Spec Flow Analyzer

```
subagent_type: spec-flow-analyzer
```

Review for: user flow coverage, edge cases, error handling, state transitions,
dead-end flows.

---

## Output — Pre-Flight Report

```markdown
# Pre-Flight Report — Phase {N}

**Date:** {date}
**Dev:** {dev name}
**Plans reviewed:** {list of plan files}
**Verdict:** GO / CONDITIONAL GO / NO-GO

## Summary
{2-3 sentence overall assessment}

## Findings

### Architecture
- {finding — severity: LOW/MEDIUM/HIGH/CRITICAL}

### Security
- {finding — severity: LOW/MEDIUM/HIGH/CRITICAL}

### Performance
- {finding — severity: LOW/MEDIUM/HIGH/CRITICAL}

### Spec Completeness
- {finding — severity: LOW/MEDIUM/HIGH/CRITICAL}

## Verdict Rationale
{Why GO/CONDITIONAL/NO-GO}

## Required Changes (if CONDITIONAL or NO-GO)
1. {Change — which plan file, which task, what to fix}

## Recommended Improvements (optional, non-blocking)
1. {Improvement}
```

### Verdict rules

- **GO** — No HIGH or CRITICAL findings. Proceed to `/paul:apply`.
- **CONDITIONAL GO** — Has MEDIUM findings. Can proceed if user acknowledges.
- **NO-GO** — Has HIGH or CRITICAL findings. Must fix before execution.

Save report to `.paul/phases/{phase}/PREFLIGHT.md`.

---

## What this skill does NOT do

- Replace PAUL's acceptance criteria (AC verify what, pre-flight verifies how)
- Modify plan files (read-only analysis)
- Block execution (user can override CONDITIONAL GO)
- Review code (this reviews plans, /workflows:review reviews code)
