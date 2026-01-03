# Database Integrity Skill

## Overview
Comprehensive patterns for ensuring database integrity through proper schema design, constraint management, transaction handling, and data validation.

## When to Activate
- Designing database schema
- Planning database migrations
- Handling foreign key constraints
- Ensuring data consistency
- Implementing transactional operations

## Foreign Key Constraint Handling

### Strategy 1: Cascade Deletes

**Use when:** Child records should always be deleted with parent

```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id     String @id @default(cuid())
  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

**Behavior:**
- Delete user → All their posts are automatically deleted
- Ensures no orphaned records
- Database enforces referential integrity

**Example:**
```typescript
// Delete user and all their posts
await prisma.user.delete({
  where: { id: userId }
});
// Posts are automatically deleted via CASCADE
```

### Strategy 2: Set NULL

**Use when:** Child records can exist independently (soft delete parent)

```prisma
model Order {
  id         String    @id
  customerId String?
  customer   Customer? @relation(fields: [customerId], references: [id], onDelete: SetNull)
}

model Customer {
  id     String  @id
  orders Order[]
}
```

**Behavior:**
- Delete customer → Orders remain but `customerId` becomes NULL
- Preserves historical data
- Allows analysis of deleted customer orders

**Example:**
```typescript
// Delete customer but keep their orders
await prisma.customer.delete({
  where: { id: customerId }
});
// Orders now have customerId = NULL
```

### Strategy 3: Restrict

**Use when:** Prevent accidental deletion of referenced data

```prisma
model Category {
  id       String    @id
  products Product[]
}

model Product {
  id         String   @id
  categoryId String
  category   Category @relation(fields: [categoryId], references: [id], onDelete: Restrict)
}
```

**Behavior:**
- Delete category with products → Error thrown
- Forces explicit handling of dependencies
- Prevents data loss

**Example:**
```typescript
// This will throw an error if category has products
try {
  await prisma.category.delete({
    where: { id: categoryId }
  });
} catch (error) {
  // Must delete products first or reassign them
  console.error('Cannot delete category with products');
}
```

### Strategy 4: No Action (Default)

**Use when:** Custom handling needed

```prisma
model Post {
  id       String  @id
  authorId String
  author   User    @relation(fields: [authorId], references: [id], onDelete: NoAction)
}
```

**Behavior:**
- Delete user → Application must handle orphaned posts
- Maximum flexibility
- Requires careful implementation

## Transaction Patterns

### Pattern 1: All-or-Nothing Operations

Ensure multiple operations complete together or all fail.

```typescript
async function transferFunds(
  fromId: string,
  toId: string,
  amount: number
) {
  await prisma.$transaction(async (tx) => {
    // Step 1: Debit from account
    await tx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    });

    // Step 2: Credit to account
    await tx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    });

    // Step 3: Create audit log
    await tx.transaction.create({
      data: {
        fromId,
        toId,
        amount,
        timestamp: new Date()
      }
    });
  });

  // If ANY operation fails, ALL are rolled back
}
```

### Pattern 2: Conditional Transactions

Validate conditions before proceeding.

```typescript
async function makePurchase(userId: string, itemId: string, amount: number) {
  await prisma.$transaction(async (tx) => {
    // Check user balance
    const user = await tx.user.findUnique({
      where: { id: userId }
    });

    if (!user || user.balance < amount) {
      throw new Error('Insufficient funds'); // Rollback
    }

    // Check item availability
    const item = await tx.item.findUnique({
      where: { id: itemId }
    });

    if (!item || item.stock < 1) {
      throw new Error('Item out of stock'); // Rollback
    }

    // Proceed with purchase
    await tx.user.update({
      where: { id: userId },
      data: { balance: { decrement: amount } }
    });

    await tx.item.update({
      where: { id: itemId },
      data: { stock: { decrement: 1 } }
    });

    await tx.purchase.create({
      data: { userId, itemId, amount }
    });
  });
}
```

### Pattern 3: Optimistic Locking

Prevent concurrent modification conflicts.

```typescript
async function updateWithOptimisticLocking(id: string, updates: any) {
  await prisma.$transaction(async (tx) => {
    // Read current version
    const current = await tx.record.findUnique({
      where: { id }
    });

    if (!current) {
      throw new Error('Record not found');
    }

    // Update with version check
    const updated = await tx.record.updateMany({
      where: {
        id,
        version: current.version // Only update if version matches
      },
      data: {
        ...updates,
        version: current.version + 1 // Increment version
      }
    });

    if (updated.count === 0) {
      throw new Error('Record was modified by another process');
    }
  });
}
```

## Migration Patterns

### Pattern 1: Backward-Compatible Schema Changes

Add columns safely without breaking existing code.

```typescript
// Step 1: Add new column (nullable)
await prisma.$executeRaw`
  ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
`;

// Step 2: Backfill data
await prisma.$executeRaw`
  UPDATE users
  SET email_verified = TRUE
  WHERE email_confirmed_at IS NOT NULL;
`;

// Step 3: Make non-nullable (after backfill verified)
await prisma.$executeRaw`
  ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
`;
```

### Pattern 2: Data Migration with Rollback

Safely migrate data with backup.

```typescript
// migration.ts
export async function up(db: PrismaClient) {
  // Step 1: Backup data
  const backup = await db.users.findMany();
  await db.userBackup.createMany({ data: backup });

  // Step 2: Perform migration
  await db.$executeRaw`
    ALTER TABLE users ADD COLUMN full_name TEXT;
    UPDATE users SET full_name = first_name || ' ' || last_name;
  `;

  // Step 3: Verify migration
  const invalidRecords = await db.$queryRaw`
    SELECT COUNT(*) FROM users WHERE full_name IS NULL
  `;

  if (invalidRecords[0].count > 0) {
    throw new Error('Migration validation failed');
  }
}

export async function down(db: PrismaClient) {
  // Rollback
  await db.$executeRaw`
    ALTER TABLE users DROP COLUMN full_name;
  `;

  // Optionally restore from backup
  const backup = await db.userBackup.findMany();
  await db.users.deleteMany();
  await db.users.createMany({ data: backup });
}
```

### Pattern 3: Zero-Downtime Migrations

Migrate without stopping the application.

```typescript
// Phase 1: Add new column (nullable)
await prisma.$executeRaw`ALTER TABLE users ADD COLUMN new_email TEXT;`;

// Phase 2: Dual-write period (application writes to both columns)
async function updateUserEmail(userId: string, email: string) {
  await prisma.user.update({
    where: { id: userId },
    data: {
      email,      // Old column
      newEmail: email  // New column
    }
  });
}

// Phase 3: Backfill old data
await prisma.$executeRaw`
  UPDATE users SET new_email = email WHERE new_email IS NULL;
`;

// Phase 4: Make new column NOT NULL
await prisma.$executeRaw`
  ALTER TABLE users ALTER COLUMN new_email SET NOT NULL;
`;

// Phase 5: Switch application to read from new column
// Phase 6: Drop old column
await prisma.$executeRaw`ALTER TABLE users DROP COLUMN email;`;

// Phase 7: Rename new column
await prisma.$executeRaw`
  ALTER TABLE users RENAME COLUMN new_email TO email;
`;
```

## Data Verification Queries

### Verify Foreign Key Integrity

Find orphaned records (foreign key points to non-existent parent).

```sql
-- Find posts without a valid user
SELECT p.*
FROM posts p
LEFT JOIN users u ON p.user_id = u.id
WHERE u.id IS NULL;
```

```typescript
// Programmatic check
async function findOrphanedPosts() {
  const orphans = await prisma.$queryRaw`
    SELECT p.* FROM posts p
    LEFT JOIN users u ON p.user_id = u.id
    WHERE u.id IS NULL
  `;

  if (orphans.length > 0) {
    console.error(`Found ${orphans.length} orphaned posts`);
    return orphans;
  }

  console.log('✅ No orphaned posts found');
  return [];
}
```

### Verify Uniqueness Constraints

Find duplicate records that violate uniqueness.

```sql
-- Find duplicate emails (should be unique)
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

```typescript
async function findDuplicateEmails() {
  const duplicates = await prisma.$queryRaw`
    SELECT email, COUNT(*) as count
    FROM users
    GROUP BY email
    HAVING COUNT(*) > 1
  `;

  if (duplicates.length > 0) {
    console.error(`Found ${duplicates.length} duplicate emails`);
    return duplicates;
  }

  console.log('✅ All emails are unique');
  return [];
}
```

### Verify Data Consistency

Ensure calculated fields match their source data.

```sql
-- Ensure order totals match line items
SELECT o.id, o.total, SUM(li.price * li.quantity) as calculated_total
FROM orders o
JOIN line_items li ON o.id = li.order_id
GROUP BY o.id, o.total
HAVING o.total != SUM(li.price * li.quantity);
```

```typescript
async function verifyOrderTotals() {
  const inconsistent = await prisma.$queryRaw`
    SELECT o.id, o.total, SUM(li.price * li.quantity) as calculated_total
    FROM orders o
    JOIN line_items li ON o.id = li.order_id
    GROUP BY o.id, o.total
    HAVING o.total != SUM(li.price * li.quantity)
  `;

  if (inconsistent.length > 0) {
    console.error(`Found ${inconsistent.length} orders with incorrect totals`);
    return inconsistent;
  }

  console.log('✅ All order totals are correct');
  return [];
}
```

## Isolation Patterns

### Pattern 1: Test Data Separation

Use separate database for tests.

```typescript
// Use separate database for tests
const db = process.env.NODE_ENV === 'test'
  ? new PrismaClient({
      datasourceUrl: process.env.DATABASE_URL_TEST
    })
  : new PrismaClient();

// Seed test data
async function seedTestData() {
  // Ensure we're in test environment
  if (process.env.NODE_ENV !== 'test') {
    throw new Error('Can only seed test data in test environment');
  }

  // Clear existing data
  await db.post.deleteMany();
  await db.user.deleteMany();

  // Seed test users
  await db.user.createMany({
    data: [
      {
        email: 'admin@test.com',
        password: hashPassword('admin123'),
        role: 'admin'
      },
      {
        email: 'user@test.com',
        password: hashPassword('user123'),
        role: 'user'
      }
    ]
  });
}
```

### Pattern 2: Transaction Isolation Levels

Control how transactions interact.

```typescript
// Read Committed (default)
// Only sees committed data from other transactions
await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });
  // May see different value if another transaction commits
});

// Serializable (highest isolation)
// Complete isolation from other transactions
await prisma.$transaction(
  async (tx) => {
    const user = await tx.user.findUnique({ where: { id } });
    // Guaranteed consistent view, even if other transactions modify data
  },
  {
    isolationLevel: 'Serializable'
  }
);

// Repeatable Read
// Consistent reads within transaction
await prisma.$transaction(
  async (tx) => {
    const user1 = await tx.user.findUnique({ where: { id } });
    // ... other operations ...
    const user2 = await tx.user.findUnique({ where: { id } });
    // user1 and user2 are guaranteed to be the same
  },
  {
    isolationLevel: 'RepeatableRead'
  }
);
```

## Constraint Management

### Check Constraints

Enforce business rules at the database level.

```sql
-- Ensure positive balance
ALTER TABLE accounts
ADD CONSTRAINT balance_positive CHECK (balance >= 0);

-- Ensure valid email format
ALTER TABLE users
ADD CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- Ensure date range validity
ALTER TABLE events
ADD CONSTRAINT valid_date_range CHECK (end_date >= start_date);
```

```prisma
// Prisma schema with check constraints
model Account {
  id      String @id
  balance Decimal

  @@check("balance >= 0", name: "balance_positive")
}

model Event {
  id        String   @id
  startDate DateTime
  endDate   DateTime

  @@check("end_date >= start_date", name: "valid_date_range")
}
```

### Unique Constraints

Enforce uniqueness on single or multiple columns.

```prisma
model User {
  id    String @id
  email String @unique
}

// Composite unique constraint
model UserRole {
  userId String
  roleId String

  @@unique([userId, roleId], name: "user_role_unique")
}
```

### Default Values

Ensure columns always have values.

```prisma
model Post {
  id        String   @id @default(cuid())
  createdAt DateTime @default(now())
  published Boolean  @default(false)
  views     Int      @default(0)
}
```

## Data Integrity Checklist

### Schema Design
- [ ] Foreign keys defined with appropriate cascade behavior
- [ ] Unique constraints on natural keys (email, username, etc.)
- [ ] Nullable fields only when semantically optional
- [ ] Check constraints for business rules
- [ ] Default values for required fields
- [ ] Indexes on foreign keys and frequently queried columns

### Transactions
- [ ] Transactions wrap all multi-step operations
- [ ] Optimistic locking for concurrent updates
- [ ] Proper isolation level selected
- [ ] Timeout configured for long transactions

### Migrations
- [ ] Migrations are backward-compatible
- [ ] Rollback scripts exist for all migrations
- [ ] Verification queries validate data integrity
- [ ] Backups taken before migrations
- [ ] Tested on staging environment

### Verification
- [ ] No orphaned records (foreign key integrity)
- [ ] No duplicate values (uniqueness)
- [ ] Calculated fields match source data (consistency)
- [ ] All constraints are enforced

### Testing
- [ ] Test data isolated from production
- [ ] Database cleaned between tests
- [ ] Tests are independent (can run in any order)
- [ ] Transaction rollback in tests

### Audit
- [ ] Audit trails for sensitive operations
- [ ] Soft deletes for important data
- [ ] Version tracking for conflict detection

## Best Practices

1. **Foreign Keys Always**: Define foreign keys for referential integrity
2. **Transactions for Multiple Operations**: Use transactions for related operations
3. **Validate at Database**: Use constraints, not just application validation
4. **Test Migrations**: Always test on staging first
5. **Backup Before Migration**: Always backup production data
6. **Monitor After Migration**: Watch for anomalies
7. **Use Cascade Carefully**: Understand implications of cascade deletes
8. **Isolation for Tests**: Separate test database from development
9. **Verify After Migration**: Run verification queries
10. **Document Constraints**: Explain business rules in comments
