---
name: database-review
description: Production readiness review for Database Migrations & Backup. Reviews migration scripts, rollback procedures, backup restoration testing, and data integrity verification before production release. Use PROACTIVELY before deployments, when modifying schemas, or adding new data stores.
paths:
  - "**/migrations/**"
  - "**/*.prisma"
  - "**/schema.{sql,prisma,rb}"
  - "**/*.sql"
  - "**/db/**"
  - "**/database/**"
  - "**/models/**/*.{ts,js,py,rb}"
  - "**/seeders/**"
  - "**/alembic/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Database Review Skill

Production readiness code review focused on database migrations and backup/restore procedures. Ensures databases are ready for production with tested migrations, verified backup restoration, and data integrity checks.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "migration", "schema", "database", "sql", "prisma", "sequelize", "typeorm"
- Migration files are added or modified
- Database schema changes detected
- New database connections or ORMs introduced
- Backup/restore scripts are modified
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
- Phase 2: Database Readiness Checklist
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
| Migration Scripts | 25% |
| Rollback Procedures | 25% |
| Backup Restoration | 20% |
| Data Integrity | 15% |
| Migration Safety | 10% |
| Schema Documentation | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/disaster-recovery-review` - For backup strategy and DR planning
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For database monitoring
- `/performance-review` - For query optimization
- `/quality-check` - For code quality
