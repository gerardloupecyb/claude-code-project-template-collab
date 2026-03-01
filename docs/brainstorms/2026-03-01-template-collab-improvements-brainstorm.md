# Brainstorm: project-template-collab improvements

**Date:** 2026-03-01
**Participants:** Gerard + Claude

## What We're Exploring

Gaps and improvements to the collaborative project template after V1 launch.
Three axes: workflow gaps, onboarding/DX, and external integrations.

## Key Findings

### Workflow Gaps

| Gap | Impact |
|-----|--------|
| No CI/CD | Broken code discovered late by other dev |
| No PR template | No traceability between PRs and PAUL phases |
| No merge strategy defined | Messy history, conflict resolution unclear |
| No branch protection | Direct push to main possible |
| Flywheel not linked to handoff | Dev B misses new patterns from Dev A |
| team-sync is on-demand only | No forced sync at session start |

### Onboarding / DX

| Problem | Detail |
|---------|--------|
| Too many concepts | 7+ systems to understand (PAUL, Compound, CARL, DevContainer, MEMORY split, 3 collab modes, flywheel) |
| CLAUDE.md = 463 lines | Wall of text, no prioritization |
| No post-setup validation | No check that PAUL, CARL, MCP are properly configured |
| No cheat sheet | Dev must dig through CLAUDE.md to find the right command |

### External Integrations

| Integration | Value | Complexity | Status |
|-------------|-------|------------|--------|
| Linear | Visual tracking, reporting, velocity | Low (official MCP) | Backlog V2 |
| Notion | Human layer, stakeholders, decisions | Medium (sync risk) | Backlog V2 |
| Slack/Discord | Handoff notifications, conflict alerts | Medium | To explore |
| CI/CD (GitHub Actions) | Auto tests, lint, deploy | Medium | To implement |
| PR automation | Template, auto-label, phase link | Low | To implement |

## Decisions

1. **Quick wins to implement now:** PR template, basic CI, cheat sheet, check-setup.sh
2. **V2 backlog:** Linear, Notion, Slack notifications, CLAUDE.md split
3. **CI/CD to explore deeper** before implementation

## Open Questions

- What tests to run in CI? (depends on project — template should be generic)
- Should branch protection be enforced by template or left to team?
- How to notify Dev B when Dev A pushes new patterns?
- Should CLAUDE.md be split into smaller files or kept monolithic?

## CI/CD Deep Dive

### Recommended approach: Progressive (3 levels)

**Level 1 — Collab workflow checks (always on):**
- MEMORY-{dev}.md updated in PR
- PR template filled (phase, dev, pre-flight verdict)
- No orphan handoffs
- SUMMARY.md exists (paul:unify was run)

**Level 2 — Quality lint (on by default, can disable):**
- markdownlint on docs/, memory/, handoffs/
- shellcheck on scripts

**Level 3 — Project tests (off by default, dev activates):**
- Placeholder section for project-specific tests
- Placeholder section for deploy

### Why progressive:
- Level 1 is unique to this stack (no other CI checks PAUL workflow compliance)
- Level 2 costs almost nothing (fast, generic)
- Level 3 respects dev autonomy (can't guess project stack)

### Implementation:
```
.github/
  workflows/
    collab-checks.yml          → Level 1 (always on)
    quality.yml                → Level 2 (on by default)
  PULL_REQUEST_TEMPLATE.md     → PR template linked to PAUL phases
```

### Alternatives considered:
- Workflow checks only — misses code quality basics
- Full template with placeholders — false green if placeholder not filled
- Workflow + generic lint — no upgrade path to project tests

## Next

Capture complete. Run `/workflows:plan` when ready to implement quick wins.
