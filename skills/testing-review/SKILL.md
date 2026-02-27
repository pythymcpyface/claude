---
name: testing-review
description: Production readiness review for Testing. Reviews unit test coverage >80%, integration tests, E2E tests, regression tests, load tests, security tests, test quality, and TDD/BDD practices before production release. Use PROACTIVELY before releasing to production, when adding new features, or modifying critical business logic.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Testing Review Skill

Production readiness code review focused on Testing Strategy & Coverage. Ensures code is ready for production with comprehensive test coverage across all dimensions: unit, integration, E2E, regression, load, and security testing.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "test", "testing", "coverage", "unit", "e2e", "spec", "tdd", "bdd"
- New features or business logic added
- Critical path modifications
- Before major version releases
- CI/CD pipeline changes affecting tests
- Bug fixes (regression test needed)
- API contract changes
- Database schema migrations
- Authentication/authorization changes

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's testing framework and coverage tools:

```bash
# Detect JavaScript/TypeScript testing frameworks
grep -r "jest\|vitest\|mocha\|cypress\|playwright\|@testing-library" package.json 2>/dev/null && echo "JS/TS testing detected"

# Detect Python testing frameworks
grep -r "pytest\|unittest\|nose\|behave\|pytest-bdd" requirements.txt pyproject.toml setup.py 2>/dev/null && echo "Python testing detected"

# Detect Go testing
ls *_test.go 2>/dev/null | head -5 && echo "Go testing detected"
grep -r "testify\|ginkgo\|godog" go.mod 2>/dev/null && echo "Go testing framework detected"

# Detect Java testing
grep -r "junit\|testng\|cucumber" pom.xml build.gradle 2>/dev/null && echo "Java testing detected"

# Detect Ruby testing
grep -r "rspec\|cucumber\|minitest" Gemfile 2>/dev/null && echo "Ruby testing detected"

# Check for coverage tools
grep -r "coverage\|nyc\|istanbul\|pytest-cov\|go tool cover\|jacoco\|simplecov" package.json requirements.txt go.mod pom.xml Gemfile 2>/dev/null

# Find test directories
find . -type d -name "*test*" -o -name "*spec*" -o -name "__tests__" 2>/dev/null | grep -v node_modules | head -10

# Check for coverage reports
find . -name "coverage" -type d -o -name ".nyc_output" -o -name "lcov.info" -o -name "coverage.xml" 2>/dev/null | head -10
```

### Phase 2: Testing Checklist

Run all checks and compile results:

#### 1. Unit Test Coverage Review

Unit tests verify individual functions/methods in isolation.

| Check | Pattern | Status |
|-------|---------|--------|
| Coverage >= 80% | Code coverage meets minimum threshold | Required |
| Business logic covered | All critical business logic has tests | Required |
| Edge cases tested | Boundary conditions and edge cases covered | Required |
| Error paths tested | Error handling and exceptions tested | Required |
| Pure functions tested | Utility and helper functions tested | Required |
| No untested modules | No significant modules without tests | Required |
| Coverage report generated | CI/CD produces coverage reports | Required |
| Coverage gates enforced | Build fails on coverage threshold breach | Recommended |

**Search Patterns:**
```bash
# Find unit test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" 2>/dev/null | grep -v node_modules | head -20

# Check for coverage configuration
grep -r "coverageThreshold\|coverage\|statements\|branches\|functions\|lines" --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" 2>/dev/null | head -15

# Find test configuration
find . -name "jest.config.*" -o -name "vitest.config.*" -o -name "pytest.ini" -o -name "setup.cfg" -o -name "conftest.py" 2>/dev/null | head -10

# Check CI for coverage gates
grep -r "coverage\|codecov\|coveralls\|codacy" .github .gitlab-ci.yml Jenkinsfile circleci 2>/dev/null | head -10

# Find modules without corresponding tests
find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" 2>/dev/null | grep -v node_modules | grep -v test | grep -v spec | head -20
```

#### 2. Integration Tests Review

Integration tests verify component interactions and external dependencies.

| Check | Pattern | Status |
|-------|---------|--------|
| Database integration | Tests for database operations | Required |
| API integration | Tests for external API calls | Required |
| Service integration | Tests for microservice communication | Required |
| Message queue tests | Tests for async messaging | Conditional |
| Third-party integrations | Tests for external services (mocked or sandbox) | Required |
| Testcontainers/fixures | Isolated test environments | Recommended |
| Integration test separation | Separate from unit tests | Recommended |
| CI integration tests | Integration tests in CI pipeline | Required |

**Search Patterns:**
```bash
# Find integration test files
find . -name "*.integration.test.*" -o -name "*.integration.spec.*" -o -name "*integration*" -type f 2>/dev/null | grep -v node_modules | head -15

# Check for database testing
grep -r "testcontainers\|testcontainer\|mongod\|pg-mem\|sqlite.*memory\|redis-mock" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -10

# Find API test patterns
grep -r "supertest\|request.*test\|api.*test\|http.*test\|fetch.*test" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Check for mock/service patterns
grep -r "mock\|stub\|fake\|sandbox\|wiremock\|nock\|mitm" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -10

# Find test fixtures
find . -name "fixtures" -type d -o -name "__fixtures__" -o -name "test-data" 2>/dev/null | head -10
```

#### 3. E2E Tests Review

End-to-end tests verify complete user journeys.

| Check | Pattern | Status |
|-------|---------|--------|
| Critical user journeys | Key user flows tested | Required |
| Happy path tested | Primary success scenarios | Required |
| Error scenarios | User-facing error handling | Required |
| Browser compatibility | Cross-browser testing (if web app) | Recommended |
| Mobile responsiveness | Mobile device testing (if applicable) | Recommended |
| Accessibility tests | A11y compliance testing | Recommended |
| Visual regression | UI snapshot/comparison tests | Recommended |
| E2E in CI | E2E tests run in CI/CD | Recommended |

**Search Patterns:**
```bash
# Find E2E test files
find . -name "*.e2e.test.*" -o -name "*.e2e.spec.*" -o -name "*e2e*" -o -name "cypress" -type d -o -name "playwright" -type d 2>/dev/null | grep -v node_modules | head -15

# Check for E2E frameworks
grep -r "cypress\|playwright\|puppeteer\|selenium\|webdriver\|testcafe\|nightwatch" package.json requirements.txt 2>/dev/null | head -10

# Find E2E configuration
find . -name "cypress.config.*" -o -name "playwright.config.*" -o -name "wdio.conf.*" 2>/dev/null | head -10

# Check for page object models
find . -name "*page*.ts" -o -name "*page*.js" -o -name "*Page*.ts" -o -name "*Page*.js" 2>/dev/null | grep -i test | head -10

# Find E2E test specs
find . -path "*/cypress/e2e/*" -o -path "*/playwright/*.spec.*" -o -path "*/tests/e2e/*" 2>/dev/null | head -10
```

#### 4. Regression Tests Review

Regression tests prevent re-introduction of fixed bugs.

| Check | Pattern | Status |
|-------|---------|--------|
| Bug fixes have tests | Each bug fix includes a test | Required |
| Regression test suite | Dedicated regression tests exist | Required |
| Historical bug coverage | Known issues covered by tests | Recommended |
| No skipped tests | All regression tests run | Required |
| Regression in CI | Regression tests in CI pipeline | Required |
| Test case linking | Tests linked to issue/bug tracker | Recommended |

**Search Patterns:**
```bash
# Find regression test files
find . -name "*.regression.test.*" -o -name "*.regression.spec.*" -o -name "*regression*" 2>/dev/null | grep -v node_modules | head -10

# Check for issue references in tests
grep -r "#[0-9]\|issue\|bug\|fix\|GH-\|JIRA" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15

# Find skipped/pending tests
grep -r "skip\|pending\|xit\|xdescribe\|@skip\|@pytest.mark.skip" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Check for test case IDs
grep -r "TestCase\|test_case\|TEST_CASE_ID\|@testcase" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
```

#### 5. Load/Performance Tests Review

Load tests verify system behavior under stress.

| Check | Pattern | Status |
|-------|---------|--------|
| Load test suite | Dedicated performance tests | Required |
| Concurrent user testing | Tests for multiple simultaneous users | Required |
| Throughput testing | Requests per second validation | Required |
| Response time validation | Latency assertions | Required |
| Resource monitoring | CPU, memory, network tracking | Recommended |
| Stress/breakpoint tests | System limits identified | Recommended |
| Load tests in CI | Automated performance testing | Recommended |
| Baseline performance | Performance benchmarks documented | Recommended |

**Search Patterns:**
```bash
# Find load/performance test files
find . -name "*.load.test.*" -o -name "*.performance.test.*" -o -name "*stress*" -o -name "*benchmark*" 2>/dev/null | grep -v node_modules | head -15

# Check for load testing tools
grep -r "k6\|artillery\|locust\|jmeter\|gatling\|vegeta\|loadtest\|autocannon" package.json requirements.txt go.mod 2>/dev/null | head -10

# Find performance test scripts
find . -name "k6*.js" -o -name "artillery*.yml" -o -name "locust*.py" -o -name "*benchmark*" 2>/dev/null | head -10

# Check for performance assertions
grep -r "performance\|throughput\|latency\|response.*time\|rps\|concurrent" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
```

#### 6. Security Tests Review

Security tests verify protection against common vulnerabilities.

| Check | Pattern | Status |
|-------|---------|--------|
| SQL injection tests | Tests for SQL injection prevention | Required |
| XSS tests | Cross-site scripting protection tests | Required |
| Authentication tests | Auth mechanism tests | Required |
| Authorization tests | Access control tests | Required |
| Input validation | Malformed input handling tests | Required |
| OWASP Top 10 | Coverage of major vulnerability classes | Recommended |
| Security scanning | SAST/DAST tools in CI | Required |
| Dependency scanning | Vulnerable dependency detection | Required |

**Search Patterns:**
```bash
# Find security test files
find . -name "*.security.test.*" -o -name "*.security.spec.*" -o -name "*security*" 2>/dev/null | grep -v node_modules | head -10

# Check for security testing libraries
grep -r "owasp\|snyk\|safety\|bandit\|brakeman\|bearer\|trivy" package.json requirements.txt Gemfile 2>/dev/null | head -10

# Find injection test patterns
grep -r "injection\|xss\|csrf\|sqli\|rce\|lfi\|ssti" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Check for auth tests
grep -r "auth\|login\|permission\|role\|access.*control\|jwt\|token" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15

# Find security scanning config
find . -name ".snyk" -o -name "safety-policy.yaml" -o -name ".trivy.yaml" -o -name "bandit.yaml" 2>/dev/null | head -5
```

#### 7. Test Quality Review

Test quality ensures tests are maintainable and reliable.

| Check | Pattern | Status |
|-------|---------|--------|
| No flaky tests | Tests pass consistently | Required |
| Meaningful assertions | Tests have clear assertions | Required |
| Test isolation | Tests don't depend on each other | Required |
| Proper mocking | External deps properly mocked | Required |
| Test naming | Clear, descriptive test names | Required |
| No test interdependence | Tests can run in any order | Required |
| Deterministic tests | No random failures | Required |
| Fast test suite | Unit tests complete quickly | Recommended |

**Search Patterns:**
```bash
# Check for flaky test markers
grep -r "flaky\|retry\|@flaky\|@retry" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Find assertion patterns
grep -r "expect\|assert\|should\|assertEqual\|assertEquals\|toBe\|toEqual" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -20

# Check for global state (anti-pattern)
grep -r "global\|shared\|singleton" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Find test timeouts
grep -r "timeout\|Timeout\|setInterval\|setTimeout" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Check for random data in tests
grep -r "random\|Math.random\|faker\|factory.*boy\|faker.js" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Find test lifecycle hooks
grep -r "beforeEach\|afterEach\|beforeAll\|afterAll\|setUp\|tearDown\|setup\|teardown" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15
```

#### 8. TDD/BDD Practices Review

Test-driven development ensures quality from the start.

| Check | Pattern | Status |
|-------|---------|--------|
| Test-first evidence | Tests written before implementation | Recommended |
| Given-When-Then | BDD structure in tests | Recommended |
| Descriptive scenarios | Clear test case descriptions | Required |
| One assertion per test | Focused test cases | Recommended |
| Test organization | Logical grouping of tests | Required |
| Behavior over implementation | Tests focus on behavior | Recommended |
| Living documentation | Tests document behavior | Recommended |
| Example mapping | Examples drive test cases | Recommended |

**Search Patterns:**
```bash
# Check for BDD patterns
grep -r "given\|when\|then\|describe\|context\|it\|scenario\|feature" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -20

# Find Gherkin/Cucumber files
find . -name "*.feature" 2>/dev/null | head -10

# Check for test organization
grep -r "describe\|context\|suite\|TestClass" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15

# Find example-based tests
grep -r "example\|scenario\|case\|each\|parameterize\|pytest.mark.parametrize\|@parameterized" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Check for documentation in tests
grep -r "/\*\*\|@description\|@example\|docstring\|'''test" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific testing gap
2. **Why it matters**: Impact on production reliability
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      TESTING PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Testing Framework: [Jest/pytest/testing/etc.]
Coverage Tool: [coverage.py/nyc/etc.]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

UNIT TEST COVERAGE
  [FAIL] Coverage at 65% (requirement: 80%)
  [PASS] Business logic tests present
  [WARN] Edge cases not fully covered
  [PASS] Error paths tested
  [FAIL] Coverage gates not enforced

INTEGRATION TESTS
  [PASS] Database integration tests present
  [WARN] API tests use live endpoints
  [FAIL] No message queue tests
  [PASS] Test fixtures organized

E2E TESTS
  [PASS] Critical user journeys tested
  [PASS] Happy path covered
  [WARN] No error scenario tests
  [FAIL] No accessibility tests

REGRESSION TESTS
  [FAIL] Bug fix #234 missing test
  [PASS] Regression suite exists
  [WARN] 3 skipped tests found
  [PASS] Tests linked to issues

LOAD/PERFORMANCE TESTS
  [FAIL] No load test suite
  [N/A]  Concurrent user testing (no suite)
  [N/A]  Throughput testing (no suite)
  [WARN] No performance baselines

SECURITY TESTS
  [PASS] SQL injection tests present
  [PASS] XSS protection tested
  [PASS] Authentication tests complete
  [FAIL] No authorization edge case tests
  [PASS] Snyk scanning in CI

TEST QUALITY
  [WARN] 2 flaky tests detected
  [PASS] Assertions meaningful
  [PASS] Tests isolated
  [PASS] Proper mocking implemented

TDD/BDD PRACTICES
  [PASS] BDD structure used
  [PASS] Descriptive test names
  [WARN] Some tests have multiple assertions
  [PASS] Tests organized by feature

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Unit Test Coverage Below 80%
  Impact: Insufficient coverage increases risk of undetected bugs
  Fix: Increase coverage to 80%+ with focus on uncovered modules
  File: jest.config.js

  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }

  // Add tests for:
  // - src/utils/format.ts (0% coverage)
  // - src/services/notification.ts (45% coverage)
  // - src/middleware/auth.ts (60% coverage)

[CRITICAL] No Load Test Suite
  Impact: System behavior under load unknown, may fail in production
  Fix: Implement load tests using k6 or Artillery
  File: tests/load/api-load.js (create)

  import http from 'k6/http';
  import { check, sleep } from 'k6';

  export const options = {
    stages: [
      { duration: '2m', target: 100 },  // Ramp up
      { duration: '5m', target: 100 },  // Steady state
      { duration: '2m', target: 0 },    // Ramp down
    ],
    thresholds: {
      http_req_duration: ['p(95)<500'],
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

[HIGH] Bug Fix Missing Test
  Impact: Regression risk - bug may be reintroduced
  Fix: Add regression test for issue #234
  File: tests/regression/login-timeout.test.ts (create)

  describe('Issue #234: Login timeout handling', () => {
    it('should handle slow authentication gracefully', async () => {
      // Mock slow auth service
      mockAuthService.delay(5000);

      const result = await login('user@example.com', 'password');

      expect(result.status).toBe('timeout');
      expect(result.error).toContain('Authentication timed out');
    });
  });

[HIGH] No Authorization Edge Case Tests
  Impact: Access control vulnerabilities may exist
  Fix: Add tests for authorization edge cases
  File: tests/security/authorization.test.ts

  describe('Authorization Edge Cases', () => {
    it('should deny access when user role is null', async () => {
      const user = { id: 1, role: null };
      const result = await canAccess(user, '/admin');
      expect(result).toBe(false);
    });

    it('should deny access to resources owned by other users', async () => {
      const user = { id: 1 };
      const resource = { id: 100, ownerId: 2 };
      const result = await canAccessResource(user, resource);
      expect(result).toBe(false);
    });

    it('should handle permission inheritance correctly', async () => {
      const manager = { id: 1, role: 'manager', departmentId: 5 };
      const employee = { id: 2, role: 'employee', departmentId: 5 };
      const result = await canManage(manager, employee);
      expect(result).toBe(true);
    });
  });

[MEDIUM] Flaky Tests Detected
  Impact: CI pipeline unreliable, developers lose trust in tests
  Fix: Identify and fix or quarantine flaky tests
  Files with flaky tests:
  - tests/integration/payment.test.ts (test: "should process refund")
  - tests/e2e/checkout.spec.ts (test: "should complete purchase")

  // Fix pattern - add proper waits:
  // BEFORE (flaky):
  await page.click('#submit');
  expect(await page.$('.success')).toBeTruthy();

  // AFTER (stable):
  await page.click('#submit');
  await page.waitForSelector('.success', { timeout: 5000 });
  expect(await page.$('.success')).toBeTruthy();

[MEDIUM] No Accessibility Tests
  Impact: WCAG compliance not verified, potential legal issues
  Fix: Add axe-core or similar accessibility testing
  File: tests/e2e/accessibility.spec.ts (create)

  import { test, expect } from '@playwright/test';
  import AxeBuilder from '@axe-core/playwright';

  test('homepage should not have accessibility violations', async ({ page }) => {
    await page.goto('/');

    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

[LOW] Multiple Assertions in Some Tests
  Impact: Tests harder to debug when they fail
  Fix: Split into focused single-assertion tests
  File: tests/services/user.test.ts

  // BEFORE (multiple assertions):
  it('should create user correctly', () => {
    const user = createUser({ name: 'John' });
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John');
    expect(user.createdAt).toBeDefined();
  });

  // AFTER (focused):
  it('should assign id when creating user', () => {
    const user = createUser({ name: 'John' });
    expect(user.id).toBeDefined();
  });

  it('should set user name correctly', () => {
    const user = createUser({ name: 'John' });
    expect(user.name).toBe('John');
  });

  it('should set creation timestamp', () => {
    const user = createUser({ name: 'John' });
    expect(user.createdAt).toBeDefined();
  });

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Increase unit test coverage to 80%+
2. [CRITICAL] Implement load testing suite
3. [HIGH] Add regression test for bug fix #234
4. [HIGH] Add authorization edge case tests
5. [MEDIUM] Fix or quarantine flaky tests
6. [MEDIUM] Add accessibility testing
7. [MEDIUM] Add message queue integration tests

After Production:
1. Implement performance baselines and regression testing
2. Add API contract testing with Pact
3. Implement mutation testing for test quality
4. Add visual regression testing
5. Set up test analytics dashboard
6. Implement test parallelization for faster feedback

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
| Unit Test Coverage | 20% |
| Integration Tests | 15% |
| E2E Tests | 15% |
| Regression Tests | 10% |
| Load/Performance Tests | 10% |
| Security Tests | 10% |
| Test Quality | 10% |
| TDD/BDD Practices | 10% |

---

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

## Integration with Other Reviews

This skill complements:
- `/security-review` - For security vulnerabilities
- `/performance-review` - For performance under load
- `/devops-review` - For CI/CD pipeline configuration
- `/quality-check` - For code quality validation
