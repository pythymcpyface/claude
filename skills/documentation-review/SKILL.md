---
name: documentation-review
description: Production readiness review for documentation. Reviews runbooks, architecture diagrams, on-call guides, API docs, and operational documentation. Use PROACTIVELY before production releases, when onboarding new team members, or after major system changes.
paths:
  - "**/*.md"
  - "**/docs/**"
  - "**/README*"
  - "**/CONTRIBUTING*"
  - "**/CHANGELOG*"
  - "**/runbooks/**"
  - "**/architecture/**"
  - "**/adr/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Documentation Review Skill

Production readiness review focused on Documentation completeness and quality. Ensures teams have the information needed to operate, troubleshoot, and maintain systems in production.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "deploy", "release", "production", "go live"
- New services or microservices are created
- Major architectural changes implemented
- New API endpoints or integrations added
- Database schema migrations
- Authentication/authorization changes
- Incident response procedures modified
- Team onboarding preparation

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Documentation Discovery
- Phase 2: Documentation Checklist
- Phase 3: Quality Assessment
- Phase 4: Gap Analysis
- Phase 5: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Documentation ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant documentation debt |
| 0-49 | BLOCK | Critical documentation missing |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Runbooks | 25% |
| Architecture Diagrams | 20% |
| On-Call Guides | 20% |
| API Documentation | 15% |
| README & Setup | 10% |
| Operational Docs | 10% |

---

