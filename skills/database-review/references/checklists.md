# database-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for database-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's database technology to apply appropriate checks:

```bash
# Detect databases and ORMs
grep -r "postgres\|mysql\|mongodb\|redis\|sqlite\|dynamodb" --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" 2>/dev/null | head -10

# Detect ORM/framework
grep -r "prisma\|sequelize\|typeorm\|knex\|drizzle\|mongoose\|sqlalchemy\|django\|rails\|activerecord\|gorm\|ent" --include="*.json" --include="*.toml" --include="*.mod" 2>/dev/null | head -10

# Detect migration directories
find . -type d -name "migrations" -o -name "migrate" -o -name "db" 2>/dev/null | head -10

# Detect migration files
find . -name "*.migration.*" -o -name "*_migration.*" -o -name "*migrate*.sql" -o -name "*_migrate*.ts" 2>/dev/null | head -20

# Detect backup configurations
grep -r "pg_dump\|mysqldump\|mongodump\|backup\|restore\|snapshot" --include="*.sh" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

### Phase 2: Database Readiness Checklist

Run all checks and compile results:

#### 1. Migration Scripts Review

| Check | Pattern | Status |
|-------|---------|--------|
| Migration files present | Migration directory exists with versioned files | Required |
| Idempotent migrations | Migrations can run multiple times safely | Required |
| Up/down migrations | Both forward and rollback migrations exist | Required |
| Transaction wrapping | Migrations wrapped in transactions where possible | Required |
| Naming convention | Consistent naming (timestamp_description.sql) | Required |
| No data loss | Schema changes don't drop columns without migration | Required |
| Index creation | New indexes created concurrently (no table locks) | Recommended |
| Large table handling | Batch operations for large data migrations | Recommended |

**Search Patterns:**
```bash
# Find migration files
find . -path "*/migrations/*" -name "*.sql" -o -path "*/migrations/*" -name "*.ts" -o -path "*/migrations/*" -name "*.js" 2>/dev/null | head -30

# Check for up/down migrations
grep -r "up\|down\|up_sql\|down_sql\|forward\|rollback" --include="*.sql" --include="*.ts" --include="*.js" migrations/ 2>/dev/null | head -20

# Check for transactions
grep -r "BEGIN\|COMMIT\|START TRANSACTION\|ROLLBACK\|transaction" --include="*.sql" migrations/ 2>/dev/null | head -20

# Check for dangerous operations
grep -r "DROP TABLE\|DROP COLUMN\|TRUNCATE\|DELETE FROM" --include="*.sql" migrations/ 2>/dev/null | head -10

# Check for concurrent index creation
grep -r "CONCURRENTLY\|ONLINE\|WITH (ONLINE" --include="*.sql" migrations/ 2>/dev/null | head -10
```

#### 2. Rollback Procedures Review

| Check | Pattern | Status |
|-------|---------|--------|
| Rollback scripts exist | Every migration has a corresponding rollback | Required |
| Rollback tested | Rollback procedure verified in staging | Required |
| Rollback documented | Step-by-step rollback instructions | Required |
| Data preservation | Rollback preserves existing data | Required |
| Quick rollback | Rollback can be executed within RTO | Required |
| Automated rollback | CI/CD supports automatic rollback on failure | Recommended |

**Search Patterns:**
```bash
# Find rollback files
find . -name "*rollback*" -o -name "*revert*" -o -name "*down*" 2>/dev/null | head -10

# Check for rollback documentation
grep -ri "rollback\|revert\|undo\|roll.*back" --include="*.md" 2>/dev/null | head -10

# Check for down migrations in ORM
grep -r "down\|rollback" --include="*.ts" --include="*.js" migrations/ 2>/dev/null | head -15

# Check CI/CD for rollback automation
grep -r "rollback\|revert\|undo" --include="*.yml" --include="*.yaml" .github/ .gitlab-ci.yml 2>/dev/null | head -10
```

#### 3. Backup Restoration Testing

| Check | Pattern | Status |
|-------|---------|--------|
| Backup procedure exists | Automated backup scripts/config | Required |
| Backup frequency defined | Backups run at appropriate intervals | Required |
| Restoration tested | Backup restore verified in last 30 days | Required |
| Restoration documented | Step-by-step restore instructions | Required |
| Point-in-time recovery | PITR capability for critical databases | Recommended |
| Cross-region backup | Backups stored in different region | Recommended |
| Backup encryption | Backups encrypted at rest and in transit | Required |
| Backup integrity check | Automated verification of backup files | Required |

**Search Patterns:**
```bash
# Find backup scripts
find . -name "*backup*" -o -name "*dump*" -o -name "*snapshot*" 2>/dev/null | head -20

# Check for backup configurations
grep -r "pg_dump\|mysqldump\|mongodump\|redis-cli.*save\|backup" --include="*.sh" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -15

# Check for restore scripts
find . -name "*restore*" 2>/dev/null | head -10

# Check for backup verification
grep -r "verify\|integrity\|checksum\|validate" --include="*backup*" --include="*restore*" 2>/dev/null | head -10

# Check for PITR configuration
grep -r "pitr\|point.*in.*time\|wal.*archive\|binlog\|oplog" --include="*.conf" --include="*.yml" --include="*.tf" 2>/dev/null | head -10

# Check for encryption
grep -r "encrypt\|cipher\|kms\|pgp" --include="*backup*" 2>/dev/null | head -10
```

#### 4. Data Integrity Verification

| Check | Pattern | Status |
|-------|---------|--------|
| Foreign key constraints | FK constraints defined and enabled | Required |
| Unique constraints | Duplicate prevention in place | Required |
| Not null constraints | Required fields enforced at DB level | Required |
| Check constraints | Data validation at DB level | Recommended |
| Data validation tests | Tests verify data integrity post-migration | Required |
| Referential integrity | No orphan records after migration | Required |
| Constraint naming | Consistent naming convention for constraints | Recommended |

**Search Patterns:**
```bash
# Check for foreign keys
grep -r "FOREIGN KEY\|REFERENCES\|fk_\|FK_" --include="*.sql" migrations/ 2>/dev/null | head -15

# Check for unique constraints
grep -r "UNIQUE\|unique_index\|uq_" --include="*.sql" migrations/ 2>/dev/null | head -15

# Check for not null constraints
grep -r "NOT NULL\|notNull" --include="*.sql" migrations/ 2>/dev/null | head -15

# Check for check constraints
grep -r "CHECK\|check(" --include="*.sql" migrations/ 2>/dev/null | head -10

# Check for data validation in tests
grep -r "integrity\|constraint\|validation\|verify" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
```

#### 5. Migration Safety Checks

| Check | Pattern | Status |
|-------|---------|--------|
| Non-blocking migrations | Migrations don't lock tables for extended periods | Required |
| Batch size limits | Large updates batched to avoid locks | Required |
| Timeout configuration | Migration timeouts configured appropriately | Required |
| Dry-run capability | Migrations can be tested without applying | Recommended |
| Staging verification | Migrations tested in staging first | Required |
| Monitoring during migration | Alerts for long-running migrations | Recommended |
| Connection pooling | Proper connection handling during migrations | Required |

**Search Patterns:**
```bash
# Check for batch operations
grep -r "BATCH\|LIMIT\|chunk\|batch" --include="*.sql" migrations/ 2>/dev/null | head -10

# Check for timeout settings
grep -r "timeout\|lock_wait\|statement_timeout" --include="*.sql" --include="*.conf" --include="*.yml" 2>/dev/null | head -10

# Check for dry-run support
grep -r "dry.*run\|simulate\|preview\|explain" --include="*.sql" --include="*.sh" migrations/ 2>/dev/null | head -10

# Check for lock-related settings
grep -r "LOCK\|lock_timeout\|lock.*mode\|ACCESS EXCLUSIVE" --include="*.sql" migrations/ 2>/dev/null | head -10
```

#### 6. Schema Documentation

| Check | Pattern | Status |
|-------|---------|--------|
| ERD diagram | Entity relationship diagram exists | Recommended |
| Schema documentation | Tables and columns documented | Required |
| Index documentation | Indexes and their purpose documented | Recommended |
| Migration changelog | History of schema changes documented | Required |
| Query patterns doc | Common query patterns documented | Recommended |

**Search Patterns:**
```bash
# Find schema documentation
find . -name "schema*.md" -o -name "database*.md" -o -name "erd*" -o -name "ERD*" 2>/dev/null | head -10

# Check for Prisma/schema files
find . -name "schema.prisma" -o -name "*.prisma" 2>/dev/null | head -5

# Check for migration changelog
find . -name "CHANGELOG*.md" -o -name "MIGRATION*.md" 2>/dev/null | head -5

# Check for inline documentation
grep -r "@description\|@table\|@column\|comment on" --include="*.sql" --include="*.ts" --include="*.prisma" 2>/dev/null | head -15
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific database readiness gap
2. **Why it matters**: Impact on production stability and data integrity
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         DATABASE READINESS PRODUCTION REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Database: [detected databases]
ORM/Tool: [detected ORM]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

MIGRATION SCRIPTS
  [PASS] Migration files present (12 migrations)
  [PASS] Idempotent migrations detected
  [FAIL] Missing down migrations for 3 files
  [PASS] Transaction wrapping present
  [WARN] Some migrations use ACCESS EXCLUSIVE lock
  [PASS] No data loss operations detected

ROLLBACK PROCEDURES
  [FAIL] Not all migrations have rollback scripts
  [FAIL] Rollback not tested in last 30 days
  [WARN] Rollback documentation incomplete
  [PASS] Data preservation strategy exists

BACKUP RESTORATION
  [PASS] Backup scripts present
  [PASS] Daily backup schedule configured
  [FAIL] Restoration not tested recently
  [FAIL] No restoration documentation
  [WARN] Point-in-time recovery not configured
  [PASS] Backups encrypted at rest

DATA INTEGRITY
  [PASS] Foreign key constraints defined
  [PASS] Unique constraints in place
  [PASS] Not null constraints enforced
  [WARN] Missing check constraints
  [PASS] Data validation tests present

MIGRATION SAFETY
  [WARN] Some migrations may cause extended locks
  [FAIL] No batch size limits for large updates
  [PASS] Timeout configuration present
  [PASS] Staging verification documented

SCHEMA DOCUMENTATION
  [WARN] No ERD diagram found
  [FAIL] Schema documentation missing
  [PASS] Migration changelog maintained
  [WARN] Index documentation incomplete

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Missing Rollback Migrations
  Impact: Cannot safely revert schema changes in production
  Fix: Add down migrations for all schema changes
  File: migrations/

  -- Example: migrations/20240115_add_users_table.down.sql
  DROP TABLE IF EXISTS users;

  -- Or in TypeScript (Knex):
  exports.down = function(knex) {
    return knex.schema.dropTableIfExists('users');
  };

[CRITICAL] Backup Restoration Not Tested
  Impact: Cannot guarantee data recovery in disaster scenario
  Fix: Test backup restoration in staging environment
  File: scripts/test-backup-restore.sh

  #!/bin/bash
  # Test backup restoration

  # 1. Create test database
  psql -c "CREATE DATABASE test_restore;"

  # 2. Restore from latest backup
  pg_restore -d test_restore ./backups/latest.dump

  # 3. Verify data integrity
  psql -d test_restore -c "SELECT COUNT(*) FROM users;"

  # 4. Run integrity checks
  psql -d test_restore -c "SELECT verify_data_integrity();"

  # 5. Cleanup
  psql -c "DROP DATABASE test_restore;"

  echo "Backup restoration test: PASSED"

[HIGH] No Batch Size Limits for Large Updates
  Impact: Large migrations can lock tables for extended periods
  Fix: Implement batch processing for large data changes
  File: migrations/20240120_update_user_status.sql

  -- Instead of:
  -- UPDATE users SET status = 'active' WHERE status IS NULL;

  -- Use batched updates:
  DO $$
  DECLARE
    batch_size INT := 1000;
    updated_count INT;
  BEGIN
    LOOP
      UPDATE users SET status = 'active'
      WHERE id IN (
        SELECT id FROM users
        WHERE status IS NULL
        LIMIT batch_size
      );

      GET DIAGNOSTICS updated_count = ROW_COUNT;
      EXIT WHEN updated_count = 0;

      COMMIT;
    END LOOP;
  END $$;

[HIGH] Missing Schema Documentation
  Impact: Developers don't understand database structure
  Fix: Create comprehensive schema documentation
  File: docs/database-schema.md

  # Database Schema Documentation

  ## Users Table
  | Column | Type | Nullable | Description |
  |--------|------|----------|-------------|
  | id | UUID | No | Primary key |
  | email | VARCHAR(255) | No | User email (unique) |
  | status | VARCHAR(50) | No | Account status |
  | created_at | TIMESTAMP | No | Creation timestamp |

  ## Indexes
  - `idx_users_email`: Unique index on email for fast lookups
  - `idx_users_status`: Index on status for filtering

  ## Relationships
  - users.id -> orders.user_id (1:N)

[MEDIUM] Extended Lock Migrations Detected
  Impact: May cause downtime during deployment
  Fix: Use concurrent index creation and online DDL
  File: migrations/20240118_add_index.sql

  -- PostgreSQL: Use CONCURRENTLY
  CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

  -- MySQL: Use ALGORITHM=INPLACE, LOCK=NONE
  CREATE INDEX idx_users_email ON users(email)
  ALGORITHM=INPLACE LOCK=NONE;

[MEDIUM] No Point-in-Time Recovery Configured
  Impact: Cannot restore to specific point before data loss
  Fix: Enable WAL archiving for PostgreSQL or binlog for MySQL
  File: postgresql.conf

  # PostgreSQL PITR Configuration
  wal_level = replica
  archive_mode = on
  archive_command = 'cp %p /archive/%f'
  max_wal_senders = 3

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add rollback migrations for all schema changes
2. [CRITICAL] Test backup restoration and document procedure
3. [HIGH] Implement batch processing for large migrations
4. [HIGH] Create schema documentation with ERD
5. [MEDIUM] Use concurrent index creation to avoid locks

After Production:
1. Schedule monthly backup restoration tests
2. Implement point-in-time recovery
3. Add check constraints for data validation
4. Set up migration monitoring and alerting
5. Create query patterns documentation

═══════════════════════════════════════════════════════════════
```

---

