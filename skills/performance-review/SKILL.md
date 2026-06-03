---
name: performance-review
description: Production readiness review for performance and scalability. Reviews load testing at 2-3x peak capacity, auto-scaling configuration, resource optimization, and performance baselines before production release. Use PROACTIVELY before releasing to production, when adding resource-intensive features, or modifying infrastructure.
paths:
  - "**/load-test*/**"
  - "**/perf/**"
  - "**/benchmark*/**"
  - "**/*.bench.{ts,js,py,go}"
  - "**/k6/**"
  - "**/locust*"
  - "**/cache/**"
  - "**/queries/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Performance Review Skill

Production readiness code review focused on Performance & Scalability. Ensures systems are ready for production with proper load testing, auto-scaling, resource optimization, and performance baselines.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "deploy", "release", "production", "go live", "scale", "performance"
- New services or microservices are created
- Database schema changes or migrations
- Caching layer modifications
- Background job/worker implementations
- Infrastructure or deployment configuration changes
- Resource-intensive features (file uploads, data processing, ML inference)
- Before major traffic events (product launches, marketing campaigns)

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Stack & Infrastructure Detection
- Phase 2: Performance Checklist
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
| Load Testing | 25% |
| Auto-Scaling | 20% |
| Resource Optimization | 20% |
| Database Performance | 15% |
| Performance Baselines | 10% |
| Traffic Management | 10% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging, metrics, tracing
- `/api-readiness-review` - For API versioning and rate limiting
- `/devops-review` - For deployment and CI/CD
- `/error-resilience-review` - For error handling and retries
