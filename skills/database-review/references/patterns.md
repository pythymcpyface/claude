# database-review — Implementation Patterns

Reusable code snippets and configuration templates for database-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

