---
name: observability-review
description: Production readiness review for monitoring and observability. Reviews code for logging, metrics, distributed tracing, alerting, and SLO compliance. Use PROACTIVELY before production releases, when adding new API endpoints, services, or critical features.
paths:
  - "**/logging/**"
  - "**/metrics/**"
  - "**/tracing/**"
  - "**/observability/**"
  - "**/monitoring/**"
  - "**/*logger*"
  - "**/*metric*"
  - "**/prometheus*"
  - "**/grafana*"
  - "**/datadog*"
  - "**/opentelemetry*"
  - "**/otel*"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Observability Review Skill

Production readiness code review focused on Monitoring & Observability. Ensures code is ready for production with proper logging, metrics, distributed tracing, and alerting before release.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "deploy", "release", "production", "go live"
- New API endpoints or routes are added
- New services or microservices are created
- Database migrations or schema changes
- Authentication/authorization changes
- Payment or transaction processing code
- Critical business logic modifications

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, gap analysis report template | `references/checklists.md` |
| Reusable code snippets (logging, metrics, tracing, health) | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Stack Detection (framework, language)
- Phase 2: Observability Checklist (logging, metrics, tracing, alerting, health, SLO)
- Phase 3: Gap Analysis (missing? why it matters? how to fix? priority)
- Phase 4: Output Report (overall score, checklist results, gap analysis, recommendations)

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
| Logging | 20% |
| Metrics | 25% |
| Tracing | 20% |
| Alerting | 20% |
| Health | 15% |

---

## Integration with Other Reviews

This skill complements:
- `/devops-review` — for deployment and infrastructure observability
- `/error-resilience-review` — for error handling and reporting
- `/performance-review` — for latency metrics and SLI definition
- `/disaster-recovery-review` — for runbooks and incident response
