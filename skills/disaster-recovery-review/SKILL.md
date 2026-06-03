---
name: disaster-recovery-review
description: Production readiness review for Disaster Recovery & Business Continuity. Reviews backup strategy (3-2-1-1-0 rule), RPO/RTO testing, failover procedures, and DR documentation before production release. Use PROACTIVELY before deployments, when modifying data storage, or setting up new infrastructure.
paths:
  - "**/backup/**"
  - "**/disaster-recovery/**"
  - "**/dr/**"
  - "**/runbooks/**"
  - "**/failover/**"
  - "**/*.tf"
  - "**/terraform/**"
  - "**/k8s/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Disaster Recovery Review Skill

Production readiness code review focused on Disaster Recovery & Business Continuity. Ensures code and infrastructure are ready for production with proper backup strategy, recovery objectives, failover procedures, and documented DR plans.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "backup", "disaster", "recovery", "failover", "database", "migration"
- Database schema changes or new tables added
- New data storage systems introduced (Redis, Elasticsearch, etc.)
- Infrastructure changes affecting data persistence
- Multi-region or HA configuration changes
- Before major version releases
- New production environment setup

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
- Phase 2: Disaster Recovery Checklist
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
| 3-2-1-1-0 Backup Rule | 30% |
| RPO/RTO Testing | 25% |
| Failover Procedures | 20% |
| DR Runbooks | 15% |
| Communication Plans | 5% |
| DR Drills | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For monitoring and alerting
- `/security-review` - For security vulnerabilities
- `/quality-check` - For code quality
