---
name: core-engineering
description: Security and testing essentials for all code. Always loaded.
---

# Core Engineering Patterns

## Security Essentials (OWASP Top 5)

### 1. Injection Prevention
```typescript
// SQL - Use parameterized queries
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// NoSQL - Sanitize operators
const query = { username: sanitize(input) }; // Remove $gt, $where, etc.

// Command - Never interpolate user input
execFile('convert', [inputFile, outputFile]); // Not exec(`convert ${input}`)
```

### 2. Authentication
```typescript
// Passwords: bcrypt or Argon2 (NEVER MD5/SHA1)
const hash = await bcrypt.hash(password, 12);

// Sessions: Cryptographic randomness
const sessionId = crypto.randomBytes(32).toString('hex');

// Tokens: Short-lived, secure storage
const token = jwt.sign(payload, secret, { expiresIn: '15m' });
```

### 3. XSS Prevention
```typescript
// Escape output in templates
<div>{escapeHtml(userContent)}</div>

// CSP headers
Content-Security-Policy: default-src 'self'; script-src 'self'

// HttpOnly cookies for sessions
res.cookie('session', token, { httpOnly: true, secure: true, sameSite: 'strict' });
```

### 4. Secrets Management
```typescript
// Environment variables only
const apiKey = process.env.API_KEY;

// Never commit secrets
// .gitignore: .env, *.pem, credentials.json

// Validate presence at startup
if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL required');
```

### 5. Input Validation
```typescript
// Validate at boundaries
const schema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150),
});
const validated = schema.parse(req.body);

// Whitelist, don't blacklist
const allowedFields = ['name', 'email'];
const filtered = pick(input, allowedFields);
```

---

## Testing Pyramid

### Distribution
- **60-70% Unit**: Fast, isolated, mock dependencies
- **20-30% Integration**: Service boundaries, database, APIs
- **5-10% E2E**: Critical user paths only

### Unit Test Principles
```typescript
// Arrange-Act-Assert
test('calculateTotal returns sum of item prices', () => {
  // Arrange
  const items = [{ price: 10 }, { price: 20 }];

  // Act
  const result = calculateTotal(items);

  // Assert
  expect(result).toBe(30);
});

// Test behavior, not implementation
// Mock external dependencies only
// One assertion per test (when practical)
```

### Integration Test Principles
```typescript
// Test real database interactions
// Test API contract compliance
// Test service-to-service communication
// Use test containers or in-memory databases
```

### E2E Test Principles
```typescript
// Critical paths only: login, checkout, core features
// Stable selectors: data-testid, not CSS classes
// Retry flaky assertions
// Run in CI, not blocking local dev
```

---

## When to Load Extended Skills

If working on:
- **Database/migrations** → Read `skills/extended/database-integrity.md`
- **Algorithm changes** → Read `skills/extended/algorithm-validation.md`
- **Error handling systems** → Read `skills/extended/error-classification-recovery.md`
- **Performance tuning** → Read `skills/extended/adaptive-optimization.md`
