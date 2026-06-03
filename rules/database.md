---
paths:
  - "**/*.prisma"
  - "**/migrations/**"
  - "**/schema.sql"
  - "**/*.sql"
  - "**/prisma/**"
---

# Database Work

Detail: `.claude/docs/skill-references/extended/database-integrity.md`.

- Migrations are append-only. Never edit a migration after it's applied to any environment.
- Every schema change needs an up and a tested rollback path.
- Never use string concatenation for SQL. Parameterize.
- Don't add nullable columns to large tables without a backfill plan.
- Validate the migration runs cleanly against a copy of production data before merging.
