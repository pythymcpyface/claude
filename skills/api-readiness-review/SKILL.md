---
name: api-readiness-review
description: Production readiness review for API design. Reviews versioning strategy, rate limiting implementation, and documentation completeness before production release. Use PROACTIVELY before releasing APIs, when adding new endpoints, or modifying API contracts.
paths:
  - "**/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/handlers/**"
  - "**/*.api.{ts,js,py,rb,go}"
  - "**/openapi.{yml,yaml,json}"
  - "**/swagger.{yml,yaml,json}"
  - "**/graphql/**"
  - "**/*.graphql"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# API Readiness Review Skill

Production readiness code review focused on API design and contract quality. Ensures APIs are ready for production with proper versioning, rate limiting, and documentation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "api", "endpoint", "route", "rest", "graphql", "grpc"
- New API endpoints or routes are added
- OpenAPI/Swagger specs are modified
- API middleware or interceptors are changed
- Rate limiting or throttling code is modified
- Before major version releases of APIs
- When deprecating or removing endpoints

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
- Phase 2: API Readiness Checklist
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
| API Versioning | 35% |
| Rate Limiting | 35% |
| Documentation | 30% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging, metrics, tracing
- `/security-review` - For authentication, authorization
- `/devops-review` - For deployment and CI/CD
- `/quality-check` - For code quality
