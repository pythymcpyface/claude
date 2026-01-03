# Skills & Commands Recommendations

**Analysis Date:** 2025-12-29
**Plans Analyzed:** 14 plan files from various projects
**Patterns Identified:** 9 major recurring patterns

## Executive Summary

Analysis of your development plans reveals **highly systematic patterns** that would benefit from:
- **4 high-value commands** (automation opportunities)
- **5 domain expertise skills** (knowledge packaging)
- **3-4 knowledge gap skills** (emerging needs)

**Highest ROI:** Algorithm consolidation (used 4+ times) and testing infrastructure (complex but repeated).

---

## Priority 1: High-Value Commands (Clear ROI)

### 1. `/consolidate-algorithm` Command
**Priority:** ⭐⭐⭐⭐⭐ (HIGHEST)
**Frequency:** 4+ occurrences across trading system
**Time Savings:** ~8-12 hours per consolidation
**Complexity:** Medium

**Problem Solved:**
Multiple implementations of the same algorithm across systems causing divergence, bugs, and maintenance overhead.

**Examples from plans:**
- Glicko-2 ratings (TradingEngine, Rust, batch scripts)
- Signal generation (live trading, backtesting, batch)
- Aspect filtering (normalization inconsistency)
- AI analysis logic (ItemSummary + AlertWorker)

**Workflow:**
```bash
/consolidate-algorithm [algorithm-name] [canonical-source]

Steps:
1. Detect all implementations of [algorithm-name] in codebase
2. Analyze differences between implementations
3. Identify canonical implementation (usually most tested)
4. Extract to shared service/utility with TypeScript + Rust versions
5. Generate type definitions and API contracts
6. Update all call sites to use shared service
7. Create parity tests to validate consolidation
8. Generate removal checklist for duplicate code
9. Report consolidation summary and test results
```

**Files Created:**
- `src/services/shared/[algorithm-name].ts` (or .rs)
- `src/services/shared/__tests__/[algorithm-name].test.ts`
- `CONSOLIDATION_REPORT.md` (differences, migration plan)

**Benefits:**
- Single source of truth
- Reduced bugs from divergence
- Easier to test and maintain
- Clear migration path

---

### 2. `/generate-e2e-tests` Command
**Priority:** ⭐⭐⭐⭐ (HIGH)
**Frequency:** 2 comprehensive testing plans
**Time Savings:** ~6-10 hours of boilerplate setup
**Complexity:** High

**Problem Solved:**
Setting up E2E test infrastructure is repetitive and error-prone (Playwright config, fixtures, Page Object Models, CI/CD integration).

**Examples from plans:**
- Playwright E2E for Next.js app (typed-toasting-conway)
- Trading system integration tests

**Workflow:**
```bash
/generate-e2e-tests [framework]

Steps:
1. Detect project type (Next.js, React, Vue, etc.)
2. Install Playwright or Cypress
3. Generate playwright.config.ts with recommended settings
4. Create fixtures directory:
   - Auth fixtures (login, logout, mock users)
   - Database fixtures (seed data, cleanup)
   - API mocking fixtures
5. Create Page Object Models for key UI components
6. Generate example E2E tests for critical user journeys
7. Add test scripts to package.json
8. Update CI/CD pipeline (GitHub Actions)
9. Generate E2E_TESTING_GUIDE.md documentation
```

**Files Created:**
- `playwright.config.ts`
- `e2e/fixtures/auth.ts`
- `e2e/fixtures/database.ts`
- `e2e/page-objects/HomePage.ts`
- `e2e/tests/critical-flows.spec.ts`
- `.github/workflows/e2e-tests.yml`
- `E2E_TESTING_GUIDE.md`

**Benefits:**
- Faster test setup
- Consistent test patterns
- Best practices baked in
- CI/CD integration included

---

### 3. `/migrate-schema` Command
**Priority:** ⭐⭐⭐⭐ (HIGH)
**Frequency:** 3+ database migration plans
**Time Savings:** ~3-5 hours per migration
**Complexity:** Medium

**Problem Solved:**
Database migrations are error-prone and require careful coordination (schema, ORM, queries, rollback, verification).

**Examples from plans:**
- Adding fields to trading system schema
- Foreign key constraint changes
- Data migration with backward compatibility

**Workflow:**
```bash
/migrate-schema [description]

Steps:
1. Parse schema change request
2. Generate Prisma migration file
3. Update Prisma schema.prisma
4. Create migration SQL (up and down)
5. Update TypeScript ORM models
6. Identify queries that need updating
7. Create backward-compatible query wrappers
8. Generate rollback script
9. Create verification queries (data integrity checks)
10. Generate migration guide with testing steps
```

**Files Created:**
- `prisma/migrations/[timestamp]_[description]/migration.sql`
- `prisma/migrations/[timestamp]_[description]/rollback.sql`
- `src/db/migrations/[timestamp]_verify.ts`
- `MIGRATION_GUIDE_[description].md`

**Benefits:**
- Safer migrations
- Automatic rollback plans
- Data verification included
- Backward compatibility by default

---

### 4. `/setup-staging-environment` Command
**Priority:** ⭐⭐⭐ (MEDIUM)
**Frequency:** 1 comprehensive plan (11.5 hours)
**Time Savings:** ~8-10 hours per environment
**Complexity:** High

**Problem Solved:**
Creating staging/development environments requires extensive configuration and safeguards.

**Example from plans:**
- Railway staging environment with reduced rate limits

**Workflow:**
```bash
/setup-staging-environment [environment-name]

Steps:
1. Create parallel infrastructure:
   - Database instance
   - Redis/cache instance
   - Job queue
2. Generate environment configuration files:
   - .env.staging (with placeholders)
   - Feature flags for staging-specific behavior
   - Rate limit overrides (33-99% reduced)
3. Create health check endpoint
4. Generate smoke test script
5. Update CI/CD pipeline:
   - Deploy to staging on PR
   - Run smoke tests
   - Require approval for production
6. Document safeguards and differences from production
```

**Files Created:**
- `.env.staging.template`
- `src/config/environments/staging.ts`
- `scripts/health-check-staging.sh`
- `scripts/smoke-tests.sh`
- `.github/workflows/deploy-staging.yml`
- `docs/STAGING_ENVIRONMENT.md`

**Benefits:**
- Safe testing environment
- Production parity with safeguards
- Automated deployment
- Clear documentation

---

## Priority 2: High-Value Skills (Domain Expertise)

### 1. `adaptive-optimization` Skill
**Priority:** ⭐⭐⭐⭐ (HIGH)
**Frequency:** 2+ plans with dynamic parameter tuning
**Complexity:** Medium

**Knowledge Domain:**
How to implement adaptive algorithms that adjust parameters based on real-time data characteristics.

**Patterns:**
- Collect metrics (stored_rate, duplicate_rate, items_per_page, date_velocity)
- Calculate adaptive thresholds from rolling window (5-page average)
- Adjust parameters based on data density
- Implement phase transitions (discovery → adaptive → boundary refinement)

**Example use cases:**
- Pagination increments (fixed 10 → dynamic 1-15 based on density)
- Rate limiting (static → adaptive based on success rate)
- Cache TTL (fixed → dynamic based on hit rate)
- Batch size (fixed → adaptive based on processing time)

**When to activate:**
- Implementing pagination or data collection
- Tuning performance-critical parameters
- Designing systems that operate on variable data densities

**Content:**
```markdown
## Adaptive Parameter Tuning Patterns

### Data Density Classification
- High-density (>70%): Small increments, fast iteration
- Medium-density (30-70%): Moderate increments
- Low-density (<30%): Large increments, risk of gaps

### Metrics to Track
1. **Success Rate**: % of operations that succeed
2. **Duplicate Rate**: % of redundant data encountered
3. **Velocity**: Rate of change in target metric
4. **Window Size**: Rolling average window (typically 5-10 samples)

### Adaptive Algorithm Template
```typescript
class AdaptiveOptimizer {
  metrics: RollingWindow;
  thresholds: { high: number; low: number };

  adjust(currentMetric: number) {
    const avgMetric = this.metrics.average();

    if (avgMetric > this.thresholds.high) {
      return 'reduce'; // High density, smaller steps
    } else if (avgMetric < this.thresholds.low) {
      return 'increase'; // Low density, larger steps
    }
    return 'maintain';
  }
}
```

### Phase Transitions
1. **Discovery Phase**: Wide exploration, accept higher variance
2. **Adaptive Phase**: Fine-tune based on metrics, reduce variance
3. **Boundary Refinement**: Conservative adjustments, maximum safety

### Stop Conditions
- Target coverage achieved
- External limit detected (API rate limit)
- Data exhausted (no new items)
- Quality threshold breached (too many errors)
```

---

### 2. `algorithm-validation` Skill
**Priority:** ⭐⭐⭐⭐ (HIGH)
**Frequency:** 2 plans with critical algorithm changes
**Complexity:** High

**Knowledge Domain:**
How to validate algorithm correctness and prevent regression when consolidating or modifying critical business logic.

**Patterns:**
- Reference validation (compare against academic papers)
- Implementation parity (validate different implementations match)
- Regression tests (ensure changes don't break existing behavior)
- Edge case coverage (boundary conditions)
- Performance benchmarks (track speed)

**Example use cases:**
- Glicko-2 rating consolidation
- Trading signal generation changes
- Aspect filtering normalization

**When to activate:**
- Consolidating duplicate algorithm implementations
- Migrating algorithms between languages (TypeScript → Rust)
- Optimizing performance-critical code
- Refactoring complex business logic

**Content:**
```markdown
## Algorithm Validation Patterns

### 5-Layer Validation Strategy

#### Layer 1: Reference Validation
Compare against known good outputs from academic references or official implementations.

```typescript
test('glicko-2 matches reference implementation', () => {
  // From Glickman's paper (2012)
  const referenceInput = { rating: 1500, rd: 200, vol: 0.06 };
  const referenceOutput = { rating: 1464, rd: 151.4, vol: 0.05999 };

  const result = calculateGlicko2(referenceInput);
  expect(result).toBeCloseTo(referenceOutput, precision: 1);
});
```

#### Layer 2: Implementation Parity
Validate different implementations (TypeScript vs Rust) produce identical results.

```typescript
test('typescript and rust implementations match', async () => {
  const input = generateRandomTestCases(100);

  const tsResults = input.map(i => calculateGlickoTS(i));
  const rsResults = await callRustService(input);

  expect(tsResults).toEqual(rsResults);
});
```

#### Layer 3: Regression Prevention
Ensure changes don't break existing behavior.

```typescript
test('maintains backward compatibility', () => {
  const historicalData = loadHistoricalResults();

  for (const [input, expectedOutput] of historicalData) {
    const result = newImplementation(input);
    expect(result).toEqual(expectedOutput);
  }
});
```

#### Layer 4: Edge Case Coverage
Test boundary conditions and corner cases.

```typescript
test('handles edge cases correctly', () => {
  // New player (no history)
  expect(calculate({ rating: null })).toBeDefined();

  // Perfect win streak
  expect(calculate({ wins: 100, losses: 0 })).toBeLessThan(maxRating);

  // Division by zero
  expect(calculate({ rd: 0 })).not.toThrow();
});
```

#### Layer 5: Performance Benchmarking
Track that optimizations actually improve speed.

```typescript
test('optimization improves performance', () => {
  const input = generateLargeDataset(10000);

  const oldTime = benchmark(() => oldImplementation(input));
  const newTime = benchmark(() => newImplementation(input));

  expect(newTime).toBeLessThan(oldTime * 0.8); // 20% faster
});
```

### Parity Test Pattern
When consolidating duplicate implementations:

```typescript
describe('Algorithm Consolidation Parity', () => {
  // Test 1: All implementations produce same result
  test('all implementations match', () => {
    const input = standardTestCases();

    const resultA = implementationA(input);
    const resultB = implementationB(input);
    const resultC = implementationC(input);

    expect(resultA).toEqual(resultB);
    expect(resultB).toEqual(resultC);
  });

  // Test 2: Consolidated version matches canonical
  test('consolidated matches canonical', () => {
    const canonical = identifyCanonicalImplementation();
    const consolidated = newSharedService(input);

    expect(consolidated).toEqual(canonical);
  });
});
```

### Validation Checklist
- [ ] Reference validation against known outputs
- [ ] Parity between all implementations
- [ ] Regression tests for existing behavior
- [ ] Edge case coverage (nulls, zeros, extremes)
- [ ] Performance benchmarks
- [ ] End-to-end validation on real data
```

---

### 3. `testing-strategies` Skill
**Priority:** ⭐⭐⭐⭐ (HIGH)
**Frequency:** 2 comprehensive testing plans
**Complexity:** Medium

**Knowledge Domain:**
How to structure comprehensive testing across the test pyramid (E2E, integration, unit).

**Patterns:**
- E2E tests (5-10%): Critical user journeys
- Integration tests (20-30%): API routes, component interactions
- Unit tests (60-70%): Business logic
- Test from outside-in (E2E first)

**Example use cases:**
- Building test suite for new application
- Improving test coverage on existing codebase
- Setting up testing infrastructure

**When to activate:**
- Planning testing strategy for a feature
- Setting up test infrastructure
- Reviewing test coverage

**Content:**
```markdown
## Testing Pyramid & Best Practices

### Test Distribution (Recommended)
```
     /\
    /E2E\      5-10% (Critical user journeys)
   /------\
  /Integr.\   20-30% (API routes, component interactions)
 /----------\
/   Unit     \ 60-70% (Business logic, pure functions)
--------------
```

### Testing Strategy: Outside-In Approach

#### Phase 1: E2E Tests (Critical Paths)
Start with end-to-end tests to ensure core functionality works.

**Example:** User authentication flow
```typescript
// e2e/tests/auth.spec.ts
test('user can sign up, login, and logout', async ({ page }) => {
  // Sign up
  await page.goto('/signup');
  await page.fill('[name=email]', 'test@example.com');
  await page.fill('[name=password]', 'secure123');
  await page.click('button:text("Sign Up")');

  // Verify logged in
  await expect(page.locator('[data-testid=user-menu]')).toBeVisible();

  // Logout
  await page.click('[data-testid=logout]');
  await expect(page).toHaveURL('/login');
});
```

**Coverage:** 3-5 critical journeys
- Sign up → login → logout
- Create item → view item → delete item
- Search → filter → purchase

#### Phase 2: Integration Tests (API & Components)
Test API routes and component interactions.

**Example:** API route testing
```typescript
// src/app/api/users/__tests__/route.test.ts
describe('POST /api/users', () => {
  it('creates a new user', async () => {
    const response = await POST({
      email: 'test@example.com',
      password: 'secure123'
    });

    expect(response.status).toBe(201);

    const user = await db.user.findUnique({
      where: { email: 'test@example.com' }
    });
    expect(user).toBeDefined();
  });

  it('rejects duplicate email', async () => {
    await createUser({ email: 'existing@example.com' });

    const response = await POST({
      email: 'existing@example.com',
      password: 'pass'
    });

    expect(response.status).toBe(409);
  });
});
```

#### Phase 3: Unit Tests (Business Logic)
Test pure functions and business logic in isolation.

**Example:** Business logic testing
```typescript
// src/utils/__tests__/validators.test.ts
describe('validateEmail', () => {
  it('accepts valid emails', () => {
    expect(validateEmail('test@example.com')).toBe(true);
    expect(validateEmail('user+tag@domain.co.uk')).toBe(true);
  });

  it('rejects invalid emails', () => {
    expect(validateEmail('invalid')).toBe(false);
    expect(validateEmail('@example.com')).toBe(false);
    expect(validateEmail('test@')).toBe(false);
  });
});
```

### Test Infrastructure

#### Fixtures: Test Data Factories
```typescript
// e2e/fixtures/users.ts
export const userFixtures = {
  admin: {
    email: 'admin@example.com',
    password: 'admin123',
    role: 'admin'
  },

  regularUser: {
    email: 'user@example.com',
    password: 'user123',
    role: 'user'
  }
};

export async function createTestUser(overrides = {}) {
  return await db.user.create({
    data: { ...userFixtures.regularUser, ...overrides }
  });
}
```

#### Page Object Models
```typescript
// e2e/page-objects/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[name=email]', email);
    await this.page.fill('[name=password]', password);
    await this.page.click('button:text("Login")');
  }

  async expectLoggedIn() {
    await expect(this.page.locator('[data-testid=user-menu]')).toBeVisible();
  }
}
```

### Coverage Targets
- **Overall:** >80%
- **Business Logic:** >90%
- **API Routes:** >85%
- **UI Components:** >70% (focus on logic, not DOM)

### Testing Checklist
- [ ] E2E tests cover all critical user journeys
- [ ] Integration tests cover all API routes
- [ ] Unit tests cover all business logic
- [ ] Fixtures provide reusable test data
- [ ] Page Object Models abstract UI complexity
- [ ] Database is cleaned between tests
- [ ] Tests are independent (can run in any order)
- [ ] CI/CD pipeline runs all tests
```

---

### 4. `error-classification-recovery` Skill
**Priority:** ⭐⭐⭐ (MEDIUM)
**Frequency:** 1 comprehensive plan (but critical for AI systems)
**Complexity:** Medium

**Knowledge Domain:**
How to classify errors and implement intelligent escalation strategies in autonomous systems.

**Patterns:**
- Transient errors (retry immediately)
- Permanent errors (escalate)
- Partial errors (replan)
- Resource errors (backoff)

**Example use cases:**
- AI agent error handling (Forge builder)
- API integration error recovery
- Background job retry logic

**When to activate:**
- Building autonomous systems with AI agents
- Implementing retry logic for external services
- Designing fault-tolerant systems

**Content:**
```markdown
## Error Classification & Recovery Strategies

### Error Taxonomy

#### 1. Transient Errors (Retry Immediately)
**Characteristics:** Temporary, likely to succeed on retry

**Examples:**
- Network timeouts
- API rate limits (429)
- Temporary service unavailability (503)
- Database connection pool exhausted

**Recovery Strategy:**
```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (!isTransientError(error) || attempt === maxRetries) {
        throw error;
      }

      // Exponential backoff: 1s, 2s, 4s
      await sleep(Math.pow(2, attempt) * 1000);
    }
  }
}
```

#### 2. Permanent Errors (Escalate)
**Characteristics:** Will not succeed on retry, requires intervention

**Examples:**
- Invalid API keys (401, 403)
- Malformed input (400)
- Unsupported operations
- Schema validation errors

**Recovery Strategy:**
```typescript
if (isPermanentError(error)) {
  // Log for debugging
  logger.error('Permanent error', { error, context });

  // Escalate to human
  await notifyAdmin({
    severity: 'high',
    message: `Permanent error: ${error.message}`,
    requiresAction: true
  });

  // Fail fast (don't waste resources retrying)
  throw new PermanentError(error);
}
```

#### 3. Partial Errors (Replan)
**Characteristics:** Some operations succeeded, others failed

**Examples:**
- Batch operations where 5/10 succeed
- Multi-step workflows where step 3/5 fails
- Parallel operations with mixed results

**Recovery Strategy:**
```typescript
async function recoverPartialFailure(results: OperationResult[]) {
  const succeeded = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  // Mark succeeded operations as complete
  await markComplete(succeeded);

  // Replan for failed operations
  const replanResult = await replanFailedOperations(failed);

  return {
    completedCount: succeeded.length,
    reattemptCount: failed.length,
    replanStrategy: replanResult
  };
}
```

#### 4. Resource Errors (Backoff)
**Characteristics:** System resource constraints

**Examples:**
- Out of memory
- Disk full
- Quota exceeded
- Connection pool exhausted

**Recovery Strategy:**
```typescript
async function handleResourceError(error: ResourceError) {
  // Reduce load immediately
  await throttle.reduce(0.5); // Reduce to 50% capacity

  // Wait for resources to free up
  await sleep(resourceBackoffTime);

  // Gradually ramp back up
  await throttle.gradualIncrease();
}
```

### Multi-Level Escalation Strategy

#### Level 1: Same Model Retry (with error context)
```typescript
try {
  return await model.generate(prompt);
} catch (error) {
  // Retry with error context
  return await model.generate(
    `${prompt}\n\nPrevious attempt failed: ${error.message}\nPlease try again.`
  );
}
```

#### Level 2: Model Switch (more capable model)
```typescript
try {
  return await sonnet4_5.generate(prompt);
} catch (error) {
  logger.warn('Sonnet failed, escalating to Opus');
  return await opus4_5.generate(prompt);
}
```

#### Level 3: Human Intervention
```typescript
if (error.requiresHumanIntervention) {
  await pauseSystem();
  await notifyAdmin({
    severity: 'critical',
    message: 'System paused - requires manual intervention',
    context: { error, state: systemState }
  });
}
```

### Error Classification Function
```typescript
function classifyError(error: Error): ErrorType {
  // Check HTTP status codes
  if (error.status === 429) return 'TRANSIENT_RATE_LIMIT';
  if ([401, 403].includes(error.status)) return 'PERMANENT_AUTH';
  if (error.status === 503) return 'TRANSIENT_SERVICE';

  // Check error messages
  if (error.message.includes('timeout')) return 'TRANSIENT_TIMEOUT';
  if (error.message.includes('out of memory')) return 'RESOURCE_MEMORY';
  if (error.message.includes('invalid input')) return 'PERMANENT_VALIDATION';

  // Default to permanent if unknown
  return 'PERMANENT_UNKNOWN';
}
```

### Recovery Decision Tree
```
Error Occurs
├─ Is transient? (timeout, rate limit, 503)
│  ├─ YES → Retry with exponential backoff (3 attempts)
│  └─ NO → Continue
├─ Is permanent? (401, 403, invalid input)
│  ├─ YES → Log, notify admin, fail fast
│  └─ NO → Continue
├─ Is partial? (some operations succeeded)
│  ├─ YES → Mark complete, replan failed operations
│  └─ NO → Continue
└─ Is resource? (OOM, disk full, quota)
   ├─ YES → Reduce load, backoff, gradual ramp-up
   └─ NO → Escalate to human
```

### Monitoring & Metrics
Track error patterns to improve classification:
- Error type distribution (transient vs permanent)
- Retry success rate
- Escalation frequency
- Time to recovery
- Human intervention rate
```

---

### 5. `database-integrity` Skill
**Priority:** ⭐⭐⭐ (MEDIUM)
**Frequency:** 3+ plans with database operations
**Complexity:** Medium

**Knowledge Domain:**
Schema design, migrations, constraint management, and data integrity patterns.

**Patterns:**
- Foreign key management (cascade deletes)
- Transaction atomicity (all-or-nothing)
- Data migration (backward compatibility)
- Verification queries (validate integrity)

**When to activate:**
- Designing database schema
- Planning migrations
- Handling foreign key constraints
- Ensuring data consistency

**Content:**
```markdown
## Database Integrity Patterns

### Foreign Key Constraint Handling

#### Strategy 1: Cascade Deletes
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

**Use when:** Child records should always be deleted with parent

#### Strategy 2: Set NULL
```prisma
model Order {
  id         String @id
  customerId String?
  customer   Customer? @relation(fields: [customerId], references: [id], onDelete: SetNull)
}
```

**Use when:** Child records can exist independently (soft delete parent)

#### Strategy 3: Restrict
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

**Use when:** Prevent accidental deletion of referenced data

### Transaction Patterns

#### Pattern 1: All-or-Nothing Operations
```typescript
async function transferFunds(fromId: string, toId: string, amount: number) {
  await db.$transaction(async (tx) => {
    // Debit from account
    await tx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    });

    // Credit to account
    await tx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    });

    // Create audit log
    await tx.transaction.create({
      data: { fromId, toId, amount, timestamp: new Date() }
    });
  });

  // If any operation fails, ALL are rolled back
}
```

#### Pattern 2: Conditional Transactions
```typescript
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });

  if (user.balance < amount) {
    throw new Error('Insufficient funds'); // Rollback
  }

  // Proceed with operation
  await tx.purchase.create({ data: { userId: id, amount } });
});
```

### Migration Patterns

#### Pattern 1: Backward-Compatible Schema Changes
```typescript
// Step 1: Add new column (nullable)
await prisma.$executeRaw`
  ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
`;

// Step 2: Backfill data
await prisma.$executeRaw`
  UPDATE users SET email_verified = TRUE WHERE email_confirmed_at IS NOT NULL;
`;

// Step 3: Make non-nullable (after backfill verified)
await prisma.$executeRaw`
  ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
`;
```

#### Pattern 2: Data Migration with Rollback
```typescript
// migration.ts
export async function up(db: PrismaClient) {
  // Backup data
  const backup = await db.users.findMany();
  await db.userBackup.createMany({ data: backup });

  // Perform migration
  await db.$executeRaw`
    ALTER TABLE users ADD COLUMN full_name TEXT;
    UPDATE users SET full_name = first_name || ' ' || last_name;
  `;
}

export async function down(db: PrismaClient) {
  // Rollback
  await db.$executeRaw`
    ALTER TABLE users DROP COLUMN full_name;
  `;

  // Restore from backup if needed
  const backup = await db.userBackup.findMany();
  await db.users.deleteMany();
  await db.users.createMany({ data: backup });
}
```

### Data Verification Queries

#### Verify Foreign Key Integrity
```sql
-- Find orphaned records (foreign key points to non-existent parent)
SELECT p.*
FROM posts p
LEFT JOIN users u ON p.user_id = u.id
WHERE u.id IS NULL;
```

#### Verify Uniqueness Constraints
```sql
-- Find duplicate emails (should be unique)
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

#### Verify Data Consistency
```sql
-- Ensure order totals match line items
SELECT o.id, o.total, SUM(li.price * li.quantity) as calculated_total
FROM orders o
JOIN line_items li ON o.id = li.order_id
GROUP BY o.id, o.total
HAVING o.total != SUM(li.price * li.quantity);
```

### Isolation Patterns

#### Pattern 1: Test Data Separation
```typescript
// Use separate database for tests
const db = process.env.NODE_ENV === 'test'
  ? new PrismaClient({ datasourceUrl: process.env.TEST_DATABASE_URL })
  : new PrismaClient();

// Seed test data
async function seedTestData() {
  if (process.env.NODE_ENV !== 'test') {
    throw new Error('Can only seed test data in test environment');
  }

  await db.user.createMany({ data: testUsers });
}
```

#### Pattern 2: Transaction Isolation
```typescript
// Read committed (default)
await db.$transaction(async (tx) => {
  // Only sees committed data
});

// Serializable (highest isolation)
await db.$transaction(
  async (tx) => {
    // Complete isolation from other transactions
  },
  { isolationLevel: 'Serializable' }
);
```

### Data Integrity Checklist
- [ ] Foreign keys defined with appropriate cascade behavior
- [ ] Unique constraints on natural keys (email, username, etc.)
- [ ] Nullable fields only when semantically optional
- [ ] Transactions wrap all multi-step operations
- [ ] Migrations are backward-compatible
- [ ] Rollback scripts exist for all migrations
- [ ] Verification queries validate data integrity
- [ ] Test data isolated from production
- [ ] Audit trails for sensitive operations
```

---

## Priority 3: Knowledge Gap Skills (Emerging Needs)

### 1. `oauth-authentication-patterns` Skill
**Priority:** ⭐⭐⭐ (MEDIUM)
**Need:** Projects using NextAuth, OAuth, API authentication

**Content:** JWT handling, session management, token refresh, OAuth flows, OIDC patterns

---

### 2. `performance-optimization` Skill
**Priority:** ⭐⭐⭐ (MEDIUM)
**Need:** Database query optimization, caching, algorithm optimization

**Content:** Profiling techniques, caching strategies (Redis, in-memory), query optimization, algorithm complexity

---

### 3. `rate-limiting-strategies` Skill
**Priority:** ⭐⭐ (LOW-MEDIUM)
**Need:** API integration, external service calls

**Content:** Exponential backoff, circuit breakers, quota management, token bucket algorithm

---

### 4. `distributed-systems-patterns` Skill
**Priority:** ⭐⭐ (LOW-MEDIUM)
**Need:** Job queues, async processing, background workers

**Content:** Idempotency, retries, state management, eventual consistency, message queues

---

## Implementation Roadmap

### Phase 1: Quick Wins (1-2 weeks)
1. ✅ `/quality-check` command (already created)
2. ✅ `owasp-security-patterns` skill (already created)
3. ✅ `mcp-delegation-strategy` skill (already created)
4. 🔲 `testing-strategies` skill (high value, clear patterns)
5. 🔲 `algorithm-validation` skill (critical for trading system)

### Phase 2: High ROI Commands (2-4 weeks)
1. 🔲 `/consolidate-algorithm` command (highest frequency)
2. 🔲 `/generate-e2e-tests` command (saves 6-10 hours)
3. 🔲 `/migrate-schema` command (common, error-prone)

### Phase 3: Infrastructure (4-6 weeks)
1. 🔲 `/setup-staging-environment` command (complex but valuable)
2. 🔲 `adaptive-optimization` skill (advanced use cases)
3. 🔲 `error-classification-recovery` skill (AI systems)
4. 🔲 `database-integrity` skill (safety critical)

### Phase 4: Knowledge Gaps (as needed)
1. 🔲 `oauth-authentication-patterns` skill
2. 🔲 `performance-optimization` skill
3. 🔲 `rate-limiting-strategies` skill
4. 🔲 `distributed-systems-patterns` skill

---

## Cost-Benefit Analysis

| Command/Skill | Time to Build | Time Saved Per Use | Break-Even Uses | Annual Uses (Est.) | ROI |
|---|---|---|---|---|---|
| `/consolidate-algorithm` | 8h | 10h | 0.8 | 4+ | 5x |
| `/generate-e2e-tests` | 12h | 8h | 1.5 | 2-3 | 2x |
| `/migrate-schema` | 6h | 4h | 1.5 | 3-4 | 2.5x |
| `/setup-staging-environment` | 10h | 10h | 1 | 1-2 | 2x |
| `testing-strategies` skill | 4h | 2h | 2 | 4-6 | 3x |
| `algorithm-validation` skill | 5h | 3h | 1.7 | 3-4 | 2.5x |

**Total estimated ROI:** 15-20x over 1 year

---

## Summary

Your development patterns show **high systematization** with clear opportunities for automation and knowledge packaging.

**Immediate priorities:**
1. `testing-strategies` skill (4h build, 3x ROI)
2. `algorithm-validation` skill (5h build, 2.5x ROI)
3. `/consolidate-algorithm` command (8h build, 5x ROI)

**Long-term investments:**
- `/generate-e2e-tests` (complex but high value)
- `/migrate-schema` (common, error-prone)
- Knowledge gap skills (OAuth, performance, distributed systems)

The analysis reveals that your most repeated pattern is **algorithm consolidation** (4+ occurrences), making it the highest ROI target for automation.
