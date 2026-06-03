---
name: error-resilience-review
description: Production readiness review for Error Resilience. Reviews circuit breaker patterns, retry strategies, fallback mechanisms, timeout configurations, and graceful degradation. Use PROACTIVELY before production releases, when integrating external services, or implementing critical workflows.
paths:
  - "**/errors/**"
  - "**/*.error.{ts,js}"
  - "**/retry*"
  - "**/circuit-breaker*"
  - "**/resilience/**"
  - "**/fallback*"
  - "**/timeout*"
  - "**/clients/**"
  - "**/integrations/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Error Resilience Review Skill

Production readiness code review focused on Error Resilience & Fault Tolerance. Ensures code is ready for production with proper circuit breaker patterns, retry strategies, fallback mechanisms, timeout configurations, and graceful degradation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "retry", "circuit breaker", "fallback", "timeout", "resilience", "fault tolerance"
- New external API integrations or service dependencies
- Database or cache connection code added
- Payment, notification, or third-party service integrations
- Critical business logic with external dependencies
- Microservice-to-microservice communication added
- Before major version releases with external dependencies

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
- Phase 2: Error Resilience Checklist
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
| Circuit Breaker | 20% |
| Retry Strategy | 20% |
| Fallback Mechanisms | 15% |
| Timeout Configuration | 15% |
| Error Handling | 15% |
| Rate Limiting | 10% |
| Bulkhead | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For monitoring and alerting on resilience metrics
- `/devops-review` - For deployment safety and rollback
- `/api-readiness-review` - For API error responses and rate limiting
- `/quality-check` - For code quality in error handling
