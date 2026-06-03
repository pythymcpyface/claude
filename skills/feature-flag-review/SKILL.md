---
name: feature-flag-review
description: Production readiness review for Feature Flag management. Reviews gradual rollout strategies, dark launches, kill switches, safety mechanisms, performance impact, and lifecycle management before production release. Use PROACTIVELY before releases with feature flags, when implementing new flags, or modifying flag configurations.
paths:
  - "**/flags/**"
  - "**/feature-flags/**"
  - "**/launchdarkly*"
  - "**/unleash*"
  - "**/split.io*"
  - "**/*flag*.{ts,js,py,rb,go}"
  - "**/experiments/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Feature Flag Review Skill

Production readiness code review focused on Feature Flag Management & Progressive Delivery. Ensures code is ready for production with proper rollout strategies, safety mechanisms, and lifecycle management.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "feature flag", "feature toggle", "flag", "toggle", "switch", "canary", "rollout", "dark launch"
- New feature flag implementations or flag service integrations
- Flag configuration changes or targeting rule modifications
- Before production releases with feature-flagged functionality
- When adding A/B testing or experimentation code
- Changes to flag management systems (LaunchDarkly, Unleash, Flagsmith)

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Stack Detection
- Phase 2: Feature Flag Readiness Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Flag Naming & Organization | 5% |
| Rollout Strategy | 15% |
| Dark Launch | 5% |
| Kill Switch & Rollback | 25% |
| Safety Mechanisms | 15% |
| Performance | 10% |
| Testing Coverage | 15% |
| Lifecycle Management | 10% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For flag usage metrics and monitoring
- `/error-resilience-review` - For circuit breakers and fallbacks
- `/api-readiness-review` - For API versioning with flags
- `/devops-review` - For deployment safety with flags
- `/quality-check` - For flag implementation quality
