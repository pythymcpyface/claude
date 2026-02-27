---
description: Production readiness review for Database Migrations & Backup. Reviews migration scripts, rollback procedures, backup restoration testing, and data integrity verification before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Database Review Command

Run a comprehensive production readiness review focused on database migrations and backup/restore procedures.

## Purpose

Review code and infrastructure before production release to ensure:
- Migration scripts are safe, idempotent, and tested
- Rollback procedures exist and have been verified
- Backup restoration has been tested recently
- Data integrity constraints are in place
- Migration safety measures are implemented
- Schema documentation is complete

## Workflow

### 1. Load the Database Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/database-review/SKILL.md
```

### 2. Detect Project Stack

Identify the database technology and ORM:
```bash
# Database detection
grep -r "postgres\|mysql\|mongodb\|redis\|sqlite\|dynamodb" --include="*.json" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10

# ORM detection
grep -r "prisma\|sequelize\|typeorm\|knex\|drizzle\|mongoose\|sqlalchemy\|django\|gorm" --include="*.json" --include="*.toml" 2>/dev/null | head -10

# Migration directory detection
find . -type d -name "migrations" -o -name "migrate" 2>/dev/null | head -10

# Migration file detection
find . -name "*.migration.*" -o -name "*_migration.*" -o -name "*migrate*.sql" 2>/dev/null | head -20
```

### 3. Run Database Readiness Checks

Execute all checks in parallel:

**Migration Scripts:**
```bash
# Find migration files
find . -path "*/migrations/*" -name "*.sql" -o -path "*/migrations/*" -name "*.ts" 2>/dev/null | head -30

# Check for up/down migrations
grep -r "up\|down\|forward\|rollback" --include="*.sql" --include="*.ts" migrations/ 2>/dev/null | head -20

# Check for transactions
grep -r "BEGIN\|COMMIT\|START TRANSACTION\|transaction" --include="*.sql" migrations/ 2>/dev/null | head -20

# Check for dangerous operations
grep -r "DROP TABLE\|DROP COLUMN\|TRUNCATE" --include="*.sql" migrations/ 2>/dev/null | head -10
```

**Rollback Procedures:**
```bash
# Find rollback files
find . -name "*rollback*" -o -name "*revert*" -o -name "*.down.*" 2>/dev/null | head -10

# Check for rollback documentation
grep -ri "rollback\|revert\|undo" --include="*.md" 2>/dev/null | head -10

# Check CI/CD for rollback automation
grep -r "rollback\|revert" --include="*.yml" --include="*.yaml" .github/ .gitlab-ci.yml 2>/dev/null | head -10
```

**Backup Restoration:**
```bash
# Find backup scripts
find . -name "*backup*" -o -name "*dump*" -o -name "*snapshot*" 2>/dev/null | head -20

# Check for restore scripts
find . -name "*restore*" 2>/dev/null | head -10

# Check for backup verification
grep -r "verify\|integrity\|checksum\|validate" --include="*backup*" 2>/dev/null | head -10

# Check for PITR configuration
grep -r "pitr\|point.*in.*time\|wal.*archive\|binlog" --include="*.conf" --include="*.yml" 2>/dev/null | head -10
```

**Data Integrity:**
```bash
# Check for foreign keys
grep -r "FOREIGN KEY\|REFERENCES\|fk_" --include="*.sql" migrations/ 2>/dev/null | head -15

# Check for unique constraints
grep -r "UNIQUE\|unique_index\|uq_" --include="*.sql" migrations/ 2>/dev/null | head -15

# Check for check constraints
grep -r "CHECK\|check(" --include="*.sql" migrations/ 2>/dev/null | head -10
```

**Migration Safety:**
```bash
# Check for batch operations
grep -r "BATCH\|LIMIT\|chunk" --include="*.sql" migrations/ 2>/dev/null | head -10

# Check for timeout settings
grep -r "timeout\|lock_wait\|statement_timeout" --include="*.sql" --include="*.conf" 2>/dev/null | head -10

# Check for lock-related settings
grep -r "ACCESS EXCLUSIVE\|LOCK" --include="*.sql" migrations/ 2>/dev/null | head -10
```

**Schema Documentation:**
```bash
# Find schema documentation
find . -name "schema*.md" -o -name "database*.md" -o -name "erd*" 2>/dev/null | head -10

# Check for Prisma/schema files
find . -name "schema.prisma" -o -name "*.prisma" 2>/dev/null | head -5

# Check for migration changelog
find . -name "CHANGELOG*.md" -o -name "MIGRATION*.md" 2>/dev/null | head -5
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Migration Scripts, Rollback, Backup Restoration, Data Integrity, Migration Safety, Documentation)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code/infrastructure examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must fix before production (missing rollbacks, untested restoration)
2. **High** - Should fix before or immediately after release (batch limits, documentation)
3. **Medium** - Should add within first week (PITR, check constraints)
4. **Low** - Nice to have (ERD diagrams, query patterns docs)

## Usage

```
/database-review
```

## When to Use

- Before production deployments
- When adding or modifying migration files
- When changing database schema
- When adding new databases or data stores
- When modifying backup/restore procedures
- During database compliance audits
- Before major version releases
- When setting up new production environments

## Integration with Other Commands

Consider running alongside:
- `/disaster-recovery-review` - For backup strategy and DR planning
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For database monitoring and alerting
- `/performance-review` - For query optimization
- `/quality-check` - For code quality
- `/review-pr` - For comprehensive PR review
