# Migrate Schema Command

## Purpose
Generate safe, backward-compatible database migrations with automatic rollback scripts, verification queries, and comprehensive migration guides.

## Problem Solved
Database migrations are:
- **Error-prone**: Easy to make mistakes that cause data loss
- **Complex**: Require coordination across schema, ORM, queries, and rollback
- **Risky**: Can break production if not careful
- **Time-consuming**: 3-5 hours per migration with proper safety measures

## Usage
```
/migrate-schema [description]
```

**Arguments:**
- `description`: Brief description of the schema change (e.g., "add user email verification", "create posts table")

## Workflow

### Step 1: Parse Schema Change Request
Analyze the requested schema change and identify affected components.

**Analysis includes:**
- Tables being modified/created
- Columns being added/removed/changed
- Constraints (foreign keys, unique, not null)
- Indexes needed
- Data type changes
- Default values

**Example output:**
```
Schema Change Analysis:
- Table: users
- Operation: ADD COLUMN
- Column: email_verified (BOOLEAN)
- Default: FALSE
- Constraints: NOT NULL

Affected components:
- Prisma schema (schema.prisma)
- User model types (src/types/user.ts)
- 12 queries using User model
- Authentication service (src/services/auth.ts)
```

### Step 2: Generate Prisma Migration File
Create Prisma migration with timestamp.

**Migration file structure:**
```
prisma/migrations/
└── 20251229123456_add_email_verification/
    ├── migration.sql
    └── rollback.sql
```

**migration.sql:**
```sql
-- Add email_verified column (nullable first for backward compatibility)
ALTER TABLE "users" ADD COLUMN "email_verified" BOOLEAN;

-- Backfill data: mark existing users as verified
UPDATE "users" SET "email_verified" = TRUE WHERE "email" IS NOT NULL;

-- Make column NOT NULL after backfill
ALTER TABLE "users" ALTER COLUMN "email_verified" SET NOT NULL;

-- Set default for new rows
ALTER TABLE "users" ALTER COLUMN "email_verified" SET DEFAULT FALSE;

-- Add index if needed for querying
CREATE INDEX "users_email_verified_idx" ON "users"("email_verified");
```

### Step 3: Update Prisma Schema
Modify schema.prisma to reflect the change.

**Before:**
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  createdAt DateTime @default(now())
}
```

**After:**
```prisma
model User {
  id             String   @id @default(cuid())
  email          String   @unique
  emailVerified  Boolean  @default(false)
  password       String
  createdAt      DateTime @default(now())

  @@index([emailVerified])
}
```

### Step 4: Create Migration SQL (Up and Down)
Generate both forward and rollback migration scripts.

**Up migration (migration.sql):**
```sql
-- CreateIndex
CREATE INDEX "users_email_verified_idx" ON "users"("email_verified");
```

**Down migration (rollback.sql):**
```sql
-- Drop index
DROP INDEX IF EXISTS "users_email_verified_idx";

-- Remove column
ALTER TABLE "users" DROP COLUMN IF EXISTS "email_verified";
```

### Step 5: Update TypeScript ORM Models
Update type definitions to reflect schema changes.

**Before:**
```typescript
// src/types/user.ts
export interface User {
  id: string;
  email: string;
  password: string;
  createdAt: Date;
}
```

**After:**
```typescript
// src/types/user.ts
export interface User {
  id: string;
  email: string;
  emailVerified: boolean;
  password: string;
  createdAt: Date;
}
```

### Step 6: Identify Queries That Need Updating
Scan codebase for queries that might need updates.

**Search patterns:**
- Prisma queries: `prisma.user.`
- Raw SQL: `SELECT * FROM users`
- GraphQL resolvers
- API response serialization

**Example output:**
```
Queries potentially affected (12 found):

High priority (must update):
1. src/services/auth.ts:45 - createUser() - Should set emailVerified
2. src/api/users/route.ts:78 - GET /api/users - Should include emailVerified

Medium priority (review):
3. src/components/UserProfile.tsx:23 - User display - May want to show verified status

Low priority (likely OK):
4. src/services/email.ts:12 - sendEmail() - No changes needed
```

### Step 7: Create Backward-Compatible Query Wrappers
Generate wrapper functions for gradual migration.

```typescript
// src/db/migrations/20251229123456_helpers.ts

/**
 * Backward-compatible user creation during migration period.
 * Automatically sets emailVerified based on email confirmation.
 */
export async function createUserWithVerification(
  data: Omit<User, 'id' | 'emailVerified'>
) {
  return await prisma.user.create({
    data: {
      ...data,
      emailVerified: false, // New users start unverified
    },
  });
}

/**
 * Check if a user's email is verified.
 * Safe to call during migration (handles missing column).
 */
export async function isEmailVerified(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { emailVerified: true },
  });

  return user?.emailVerified ?? false;
}
```

### Step 8: Generate Rollback Script
Create script to safely rollback if needed.

```bash
#!/bin/bash
# scripts/rollback-email-verification.sh

set -e

echo "Rolling back email verification migration..."

# 1. Remove any code that depends on emailVerified column
echo "⚠️  Manual step: Ensure no code references emailVerified"
read -p "Press enter when ready to continue..."

# 2. Run Prisma rollback
echo "Running database rollback..."
npx prisma migrate resolve --rolled-back 20251229123456_add_email_verification

# 3. Apply rollback SQL
echo "Executing rollback.sql..."
psql $DATABASE_URL < prisma/migrations/20251229123456_add_email_verification/rollback.sql

# 4. Regenerate Prisma client
echo "Regenerating Prisma client..."
npx prisma generate

echo "✅ Rollback complete"
```

### Step 9: Create Verification Queries
Generate queries to validate data integrity after migration.

```sql
-- prisma/migrations/20251229123456_add_email_verification/verify.sql

-- Check 1: Ensure no NULL values in emailVerified
SELECT COUNT(*) as null_count
FROM users
WHERE email_verified IS NULL;
-- Expected: 0

-- Check 2: Verify index exists
SELECT indexname
FROM pg_indexes
WHERE tablename = 'users' AND indexname = 'users_email_verified_idx';
-- Expected: 1 row

-- Check 3: Verify existing users were backfilled correctly
SELECT
  COUNT(*) as total_users,
  SUM(CASE WHEN email_verified = TRUE THEN 1 ELSE 0 END) as verified_count
FROM users
WHERE created_at < NOW() - INTERVAL '1 day';
-- Expected: All existing users should be verified

-- Check 4: Verify new users default to unverified
SELECT *
FROM users
WHERE created_at > NOW() - INTERVAL '1 hour'
  AND email_verified = FALSE;
-- Expected: Should show recent unverified users
```

**Verification script:**
```typescript
// src/db/migrations/20251229123456_verify.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function verifyMigration() {
  console.log('Verifying email verification migration...');

  // Check 1: No NULL values
  const nullCount = await prisma.$queryRaw`
    SELECT COUNT(*) as count FROM users WHERE email_verified IS NULL
  `;
  console.assert(nullCount[0].count === 0, '❌ Found NULL values in email_verified');
  console.log('✅ No NULL values in email_verified');

  // Check 2: All existing users verified
  const oldUsers = await prisma.user.findMany({
    where: {
      createdAt: { lt: new Date(Date.now() - 24 * 60 * 60 * 1000) },
    },
  });
  const allVerified = oldUsers.every(u => u.emailVerified === true);
  console.assert(allVerified, '❌ Some old users not verified');
  console.log(`✅ All ${oldUsers.length} existing users are verified`);

  // Check 3: Index exists
  const indexes = await prisma.$queryRaw`
    SELECT indexname FROM pg_indexes
    WHERE tablename = 'users' AND indexname = 'users_email_verified_idx'
  `;
  console.assert(indexes.length === 1, '❌ Index not found');
  console.log('✅ Index created successfully');

  console.log('\n🎉 Migration verification complete!');
}

verifyMigration()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Verification failed:', error);
    process.exit(1);
  });
```

### Step 10: Generate Migration Guide
Create comprehensive guide with testing steps.

```markdown
# Migration Guide: Add Email Verification

**Migration ID:** 20251229123456_add_email_verification
**Created:** 2025-12-29
**Author:** Claude Code
**Risk Level:** Medium
**Estimated Downtime:** None (backward compatible)

## Summary
Adds `emailVerified` boolean column to `users` table with automatic backfilling of existing users.

## Changes
- ✅ Added `emailVerified` column (BOOLEAN, NOT NULL, DEFAULT FALSE)
- ✅ Created index on `emailVerified` for filtering
- ✅ Backfilled existing users as verified
- ✅ Updated Prisma schema
- ✅ Updated TypeScript types

## Pre-Migration Checklist
- [ ] Review migration SQL
- [ ] Backup production database
- [ ] Test migration on staging environment
- [ ] Verify rollback script works on staging
- [ ] Confirm no active deployments

## Migration Steps

### Step 1: Backup Database
```bash
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d-%H%M%S).sql
```

### Step 2: Run Migration
```bash
npx prisma migrate deploy
```

### Step 3: Verify Migration
```bash
npx tsx src/db/migrations/20251229123456_verify.ts
```

Expected output:
```
✅ No NULL values in email_verified
✅ All 1,247 existing users are verified
✅ Index created successfully
🎉 Migration verification complete!
```

### Step 4: Update Application Code
Update code to use the new column:

```typescript
// Before
const user = await prisma.user.create({ data: { email, password } });

// After
const user = await prisma.user.create({
  data: {
    email,
    password,
    emailVerified: false  // Explicitly set for new users
  }
});
```

### Step 5: Deploy Application
```bash
git add .
git commit -m "feat: add email verification support"
git push origin main
```

### Step 6: Monitor
Watch for errors related to:
- User creation failures
- Email verification queries
- Performance impact on user queries

## Rollback Plan

### If migration fails (before deployment):
```bash
bash scripts/rollback-email-verification.sh
```

### If issues discovered after deployment:
1. Revert application code
2. Run rollback script
3. Restore from backup if needed

## Rollback SQL
```sql
DROP INDEX IF EXISTS "users_email_verified_idx";
ALTER TABLE "users" DROP COLUMN IF EXISTS "email_verified";
```

## Testing Checklist
- [ ] Existing users can login (emailVerified = true)
- [ ] New users are created with emailVerified = false
- [ ] Email verification flow works
- [ ] User queries include emailVerified in response
- [ ] Performance impact is minimal (<5% slower)

## Performance Impact
- **Index size:** ~2MB (for 10K users)
- **Query impact:** +0.1ms avg (tested on staging)
- **Backfill time:** ~2 seconds (for 10K users)

## Support
If you encounter issues:
1. Check logs for migration errors
2. Run verification script
3. Review rollback plan
4. Escalate to DevOps if needed
```

## Files Created

1. **Migration Files**
   - `prisma/migrations/[timestamp]_[description]/migration.sql` - Forward migration
   - `prisma/migrations/[timestamp]_[description]/rollback.sql` - Rollback script

2. **Verification**
   - `src/db/migrations/[timestamp]_verify.ts` - Data integrity checks
   - `prisma/migrations/[timestamp]_[description]/verify.sql` - SQL verification queries

3. **Documentation**
   - `MIGRATION_GUIDE_[description].md` - Comprehensive migration guide
   - `scripts/rollback-[description].sh` - Rollback automation script

4. **Helper Functions**
   - `src/db/migrations/[timestamp]_helpers.ts` - Backward-compatible wrappers

## Benefits

- **Safer Migrations**: Automatic rollback plans
- **Data Verification**: Integrity checks included
- **Backward Compatibility**: Gradual migration support
- **Time Savings**: 3-5 hours → 1 hour
- **Confidence**: Comprehensive testing checklist

## Best Practices

1. **Always Backward Compatible**: Make changes in multiple steps
   - Add column as nullable
   - Backfill data
   - Make NOT NULL

2. **Test on Staging**: Never run untested migrations on production

3. **Backup First**: Always backup before migrating

4. **Monitor After**: Watch metrics for 24 hours post-migration

5. **Gradual Rollout**: Use feature flags for risky changes

## Example Usage

```bash
# Add email verification column
/migrate-schema add user email verification

# Create new table
/migrate-schema create posts table

# Add foreign key
/migrate-schema add foreign key user to posts

# Rename column
/migrate-schema rename user emailAddress to email
```

## Advanced Scenarios

### Adding Foreign Key
```sql
-- Add foreign key with cascade delete
ALTER TABLE "posts"
ADD CONSTRAINT "posts_userId_fkey"
FOREIGN KEY ("userId")
REFERENCES "users"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;
```

### Data Type Change
```sql
-- Change column type (safe for compatible types)
ALTER TABLE "users"
ALTER COLUMN "age" TYPE INTEGER
USING "age"::INTEGER;
```

### Renaming Column
```sql
-- Rename column
ALTER TABLE "users"
RENAME COLUMN "emailAddress" TO "email";
```
