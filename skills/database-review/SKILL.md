---
name: database-review
description: Production readiness review for Database Migrations & Backup. Reviews migration scripts, rollback procedures, backup restoration testing, and data integrity verification before production release. Use PROACTIVELY before deployments, when modifying schemas, or adding new data stores.
tools: Read, Grep, Glob, Bash, AskUserQuestion
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

## Quick Reference: Implementation Patterns

### Idempotent Migration (PostgreSQL)

```sql
-- migrations/20240115_add_users_table.up.sql

-- Idempotent table creation
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Idempotent index creation
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_email'
  ) THEN
    CREATE INDEX idx_users_email ON users(email);
  END IF;
END $$;

-- Idempotent constraint addition
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_users_email'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);
  END IF;
END $$;
```

### Idempotent Migration (Knex.js)

```typescript
// migrations/20240115120000_add_users_table.ts
import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Check if table exists before creating
  const hasTable = await knex.schema.hasTable('users');

  if (!hasTable) {
    await knex.schema.createTable('users', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.string('email', 255).notNullable();
      table.string('status', 50).notNullable().defaultTo('pending');
      table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

      table.unique('email', { indexName: 'uq_users_email' });
    });
  }

  // Add index if not exists
  const hasIndex = await knex.raw(`
    SELECT 1 FROM pg_indexes
    WHERE indexname = 'idx_users_email'
  `);

  if (!hasIndex.rows.length) {
    await knex.raw('CREATE INDEX idx_users_email ON users(email)');
  }
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('users');
}
```

### Batch Migration for Large Tables

```sql
-- migrations/20240120_batch_update_users.sql

DO $$
DECLARE
  batch_size INT := 1000;
  updated_count INT := 1;
  total_updated INT := 0;
BEGIN
  WHILE updated_count > 0 LOOP
    UPDATE users
    SET status = 'active'
    WHERE id IN (
      SELECT id FROM users
      WHERE status IS NULL
      LIMIT batch_size
      FOR UPDATE SKIP LOCKED
    );

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    total_updated := total_updated + updated_count;

    -- Log progress
    RAISE NOTICE 'Updated % rows (total: %)', updated_count, total_updated;

    -- Small delay between batches
    PERFORM pg_sleep(0.1);

    COMMIT;
  END LOOP;

  RAISE NOTICE 'Migration complete. Total updated: %', total_updated;
END $$;
```

### Concurrent Index Creation

```sql
-- PostgreSQL
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email
ON users(email);

-- MySQL
CREATE INDEX idx_users_email
ON users(email)
ALGORITHM=INPLACE LOCK=NONE;

-- SQL Server
CREATE INDEX idx_users_email
ON users(email)
WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);
```

### Backup Script (PostgreSQL)

```bash
#!/bin/bash
# scripts/backup-database.sh

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="${DB_NAME:-production}"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

echo "Starting backup of ${DB_NAME}..."

# Create backup with pg_dump
pg_dump \
  --format=custom \
  --compress=9 \
  --verbose \
  --file="${BACKUP_FILE}" \
  "${DB_NAME}"

# Calculate checksum
CHECKSUM=$(sha256sum "${BACKUP_FILE}" | awk '{print $1}')
echo "${CHECKSUM}  ${BACKUP_FILE}" > "${BACKUP_FILE}.sha256"

# Verify backup integrity
echo "Verifying backup integrity..."
pg_verifybackup "${BACKUP_FILE}" || {
  echo "ERROR: Backup verification failed"
  exit 1
}

# Upload to cloud storage (example: AWS S3)
aws s3 cp "${BACKUP_FILE}" "s3://${S3_BUCKET}/backups/" \
  --server-side-encryption aws:kms

# Clean up old backups (keep last 30 days)
find "${BACKUP_DIR}" -name "*.dump" -mtime +30 -delete

echo "Backup complete: ${BACKUP_FILE}"
echo "Checksum: ${CHECKSUM}"
```

### Backup Restoration Test Script

```bash
#!/bin/bash
# scripts/test-backup-restore.sh

set -e

TEST_DB="test_restore_$(date +%s)"
BACKUP_FILE="${1:-./backups/latest.dump}"

echo "Testing backup restoration..."
echo "Backup file: ${BACKUP_FILE}"

# Verify backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
  echo "ERROR: Backup file not found"
  exit 1
fi

# Verify checksum
if [ -f "${BACKUP_FILE}.sha256" ]; then
  echo "Verifying checksum..."
  sha256sum -c "${BACKUP_FILE}.sha256" || {
    echo "ERROR: Checksum verification failed"
    exit 1
  }
fi

# Create test database
echo "Creating test database: ${TEST_DB}"
psql -c "CREATE DATABASE ${TEST_DB};"

# Restore backup
echo "Restoring backup..."
pg_restore \
  --dbname="${TEST_DB}" \
  --verbose \
  "${BACKUP_FILE}"

# Verify data integrity
echo "Verifying data integrity..."

# Check table counts
TABLE_COUNT=$(psql -d "${TEST_DB}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
echo "Tables restored: ${TABLE_COUNT}"

# Check for expected tables
EXPECTED_TABLES=("users" "orders" "products")
for table in "${EXPECTED_TABLES[@]}"; do
  EXISTS=$(psql -d "${TEST_DB}" -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '${table}');")
  if [ "${EXISTS}" = " t" ]; then
    echo "  ✓ Table '${table}' exists"
  else
    echo "  ✗ Table '${table}' MISSING"
  fi
done

# Check foreign key integrity
FK_INVALID=$(psql -d "${TEST_DB}" -t -c "
  SELECT COUNT(*)
  FROM (
    SELECT table_name
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
  ) t;
")
echo "Foreign key constraints: ${FK_INVALID}"

# Run custom integrity checks if available
if psql -d "${TEST_DB}" -c "SELECT verify_data_integrity();" > /dev/null 2>&1; then
  psql -d "${TEST_DB}" -c "SELECT verify_data_integrity();"
fi

# Cleanup
echo "Cleaning up test database..."
psql -c "DROP DATABASE ${TEST_DB};"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Backup restoration test: PASSED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Prisma Migration Pattern

```prisma
// schema.prisma

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  status    Status   @default(PENDING)
  orders    Order[]
  createdAt DateTime @default(now()) @map("created_at")

  @@map("users")
}

model Order {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  user      User     @relation(fields: [userId], references: [id])
  createdAt DateTime @default(now()) @map("created_at")

  @@index([userId])
  @@map("orders")
}

enum Status {
  PENDING
  ACTIVE
  INACTIVE
}
```

```bash
# Migration workflow
# 1. Create migration
prisma migrate dev --name add_orders_table

# 2. Test in staging
prisma migrate deploy

# 3. Production deployment
prisma migrate deploy

# 4. Rollback if needed
prisma migrate resolve --rolled-back add_orders_table
```

### Data Integrity Check Constraints

```sql
-- migrations/20240125_add_check_constraints.sql

-- Email format validation
ALTER TABLE users
ADD CONSTRAINT chk_users_email_format
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Status validation
ALTER TABLE users
ADD CONSTRAINT chk_users_status
CHECK (status IN ('pending', 'active', 'inactive'));

-- Positive values
ALTER TABLE orders
ADD CONSTRAINT chk_orders_amount_positive
CHECK (amount >= 0);

-- Date validation
ALTER TABLE orders
ADD CONSTRAINT chk_orders_dates
CHECK (created_at <= updated_at OR updated_at IS NULL);
```

---

## Integration with Other Reviews

This skill complements:
- `/disaster-recovery-review` - For backup strategy and DR planning
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For database monitoring
- `/performance-review` - For query optimization
- `/quality-check` - For code quality
