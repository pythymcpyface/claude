# testing-review — Implementation Patterns

Reusable code snippets and configuration templates for testing-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Jest Configuration with Coverage

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{js,ts}',
  ],
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
  ],
};
```

### Pytest Configuration with Coverage

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --cov=src --cov-report=xml --cov-fail-under=80
```

### Go Test with Coverage

```go
// Run tests with coverage
// go test -cover -coverprofile=coverage.out ./...
// go tool cover -html=coverage.out -o coverage.html

// Example test
func TestUserService_Create(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        want    *User
        wantErr bool
    }{
        {
            name: "valid user",
            input: CreateUserInput{
                Email: "test@example.com",
                Name:  "Test User",
            },
            want: &User{
                Email: "test@example.com",
                Name:  "Test User",
            },
            wantErr: false,
        },
        {
            name: "invalid email",
            input: CreateUserInput{
                Email: "invalid",
                Name:  "Test User",
            },
            want:    nil,
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CreateUser(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("CreateUser() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("CreateUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### BDD with Jest

```typescript
// Using describe/it for BDD
describe('UserService', () => {
  describe('when creating a new user', () => {
    it('should validate email format', () => {
      const result = createUser({ email: 'invalid' });
      expect(result.error).toBe('Invalid email format');
    });

    it('should hash the password', () => {
      const result = createUser({ password: 'plain' });
      expect(result.user.password).not.toBe('plain');
    });

    it('should send welcome email', async () => {
      await createUser({ email: 'test@example.com' });
      expect(emailService.send).toHaveBeenCalledWith(
        'test@example.com',
        'welcome'
      );
    });
  });
});
```

### E2E Test with Playwright

```typescript
// tests/e2e/checkout.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Checkout flow', () => {
  test('should complete purchase successfully', async ({ page }) => {
    await page.goto('/products');

    // Add item to cart
    await page.click('[data-testid="add-to-cart"]');
    await expect(page.locator('.cart-count')).toHaveText('1');

    // Go to checkout
    await page.click('[data-testid="checkout"]');

    // Fill shipping info
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="address"]', '123 Test St');

    // Complete purchase
    await page.click('[data-testid="place-order"]');

    // Verify success
    await expect(page.locator('.order-confirmation')).toBeVisible();
  });
});
```

### Integration Test with Testcontainers

```typescript
// tests/integration/user.repository.test.ts
import { GenericContainer } from 'testcontainers';
import { UserRepository } from '../../src/repositories/user.repository';

describe('UserRepository', () => {
  let container;
  let repository;

  beforeAll(async () => {
    container = await new GenericContainer('postgres:15')
      .withExposedPorts(5432)
      .withEnvironment({ POSTGRES_PASSWORD: 'test' })
      .start();

    repository = new UserRepository({
      host: container.getHost(),
      port: container.getMappedPort(5432),
      password: 'test',
    });
  });

  afterAll(async () => {
    await container.stop();
  });

  it('should create and retrieve user', async () => {
    const user = await repository.create({
      email: 'test@example.com',
      name: 'Test User',
    });

    const found = await repository.findById(user.id);
    expect(found.email).toBe('test@example.com');
  });
});
```

### Security Test Examples

```typescript
// tests/security/injection.test.ts
describe('SQL Injection Protection', () => {
  it('should sanitize user input in queries', async () => {
    const maliciousInput = "'; DROP TABLE users; --";

    const result = await searchUsers(maliciousInput);

    // Should not throw and should return empty or safe results
    expect(result).toBeDefined();
    expect(result.error).toBeUndefined();
  });

  it('should use parameterized queries', async () => {
    const query = getUserQuery("1' OR '1'='1");

    // Query should be parameterized, not string concatenation
    expect(query.sql).not.toContain("OR '1'='1'");
    expect(query.params).toContain("1' OR '1'='1");
  });
});

// tests/security/xss.test.ts
describe('XSS Protection', () => {
  it('should escape HTML in user input', async () => {
    const xssPayload = '<script>alert("xss")</script>';

    const result = await createPost({ title: xssPayload });

    expect(result.title).not.toContain('<script>');
    expect(result.title).toContain('&lt;script&gt;');
  });
});
```

### K6 Load Test

```javascript
// tests/load/api-load.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '5m', target: 100 },   // Stay at 100 users
    { duration: '2m', target: 200 },   // Ramp up to 200 users
    { duration: '5m', target: 200 },   // Stay at 200 users
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

---

