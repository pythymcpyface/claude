# Integration Test Template

Use this template to define integration tests that verify service communication, data flow, and system interactions.

---

## How to Use This Template

1. **Complete during Phase 4.6: TDD Strategy Generation**
2. **Define integration scenarios** alongside unit tests
3. **Run integration gate**: `bash .claude/scripts/integration-gate.sh`
4. **Include in test suite** with appropriate tagging

---

## Integration Test Categories

### 1. API Endpoint Integration

#### HTTP Endpoint Tests

| Test | Description | Verification |
|------|-------------|--------------|
| Request/response format | Valid request returns expected response | Status code, headers, body structure |
| Error handling | Invalid input returns appropriate error | 4xx status, error message |
| Authentication | Unauthorized requests rejected | 401/403 status |
| Rate limiting | Exceeded rate limit throttles requests | 429 status, retry-after header |

#### Example API Integration Test

```javascript
// tests/integration/api-endpoints.test.ts
describe('POST /api/users', () => {
  it('should create a user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Test User', email: 'test@example.com' })
      .expect(201)

    expect(response.body).toHaveProperty('id')
    expect(response.body.name).toBe('Test User')
  })

  it('should return 400 for invalid email', async () => {
    await request(app)
      .post('/api/users')
      .send({ name: 'Test User', email: 'invalid' })
      .expect(400)
  })
})
```

---

### 2. Database Integration

#### Database Connection Tests

| Test | Description | Verification |
|------|-------------|--------------|
| Connection pool | Multiple concurrent connections handled | No connection errors, consistent results |
| Transaction rollback | Failed operations rollback | No partial data written |
| Migration status | Schema is up to date | All migrations applied |

#### Example Database Integration Test

```python
# tests/integration/database_test.py
def test_user_creation_with_transaction(db_session):
    """Test user creation is atomic"""
    with db_session.begin():
        user = User(name="Test", email="test@example.com")
        db_session.add(user)

    # Verify user was persisted
    retrieved = db_session.query(User).filter_by(email="test@example.com").first()
    assert retrieved is not None
    assert retrieved.name == "Test"
```

---

### 3. Service Communication

#### External Service Tests

| Test | Description | Verification |
|------|-------------|--------------|
| Service availability | Service is reachable | No connection errors |
| Request format | Valid request accepted | Success response |
| Timeout handling | Slow requests timeout | Fallback or error returned |
| Retry logic | Failed requests retry | Configured retries attempted |

#### Service Mocking Strategy

```javascript
// tests/integration/external-service.test.ts
import nock from 'nock'

describe('External Payment Service', () => {
  beforeEach(() => {
    nock('https://payment-api.example.com')
      .post('/charges')
      .reply(200, { status: 'succeeded', id: 'ch_123' })
  })

  it('should process payment via external service', async () => {
    const result = await processPayment(1000, 'tok_123')
    expect(result.status).toBe('succeeded')
  })
})
```

---

### 4. Data Flow Validation

#### End-to-End Flow Tests

| Test | Description | Verification |
|------|-------------|--------------|
| Complete user journey | User completes primary workflow | Expected final state |
| Data propagation | Changes flow through system | All components updated |
| State consistency | System state remains consistent | No orphaned or duplicate data |

#### Example E2E Flow Test

```typescript
// tests/e2e/user-registration-flow.test.ts
describe('User Registration Flow', () => {
  it('should complete full registration journey', async () => {
    // 1. Submit registration form
    const registerResponse = await request(app)
      .post('/api/register')
      .send({ email: 'user@example.com', password: 'SecurePass123' })
      .expect(201)

    const userId = registerResponse.body.id

    // 2. Verify email sent (mocked)
    expect(emailMock.lastCall?.args[0]).toBe('user@example.com')

    // 3. Verify email confirmation
    const confirmResponse = await request(app)
      .post('/api/confirm-email')
      .send({ token: registerResponse.body.confirmationToken })
      .expect(200)

    // 4. Verify user can login
    const loginResponse = await request(app)
      .post('/api/login')
      .send({ email: 'user@example.com', password: 'SecurePass123' })
      .expect(200)

    expect(loginResponse.body.token).toBeDefined()
  })
})
```

---

### 5. Fallback Behavior Testing

#### Error Recovery Tests

| Scenario | Test | Expected Behavior |
|----------|------|-------------------|
| Service unavailable | External service returns 503 | Use cached data or graceful degradation |
| Timeout | Request exceeds timeout | Return cached result or error message |
| Invalid response | Service returns malformed data | Handle error, log, return safe default |
| Rate limit exceeded | Service returns 429 | Retry with backoff |

#### Example Fallback Test

```javascript
// tests/integration/fallback-behavior.test.ts
describe('API Fallback Behavior', () => {
  it('should use cache when service unavailable', async () => {
    // Mock service failure
    nock('https://api.example.com')
      .get('/data')
      .reply(503)

    const result = await fetchDataWithFallback('123')
    expect(result.source).toBe('cache')
    expect(result.data).toBeDefined()
  })

  it('should retry with exponential backoff', async () => {
    let attempts = 0
    nock('https://api.example.com')
      .get('/data')
      .times(3)
      .reply(() => {
        attempts++
        return [503, { error: 'Service Unavailable' }]
      })
      .get('/data')
      .reply(200, { data: 'success' })

    const result = await fetchDataWithRetry('/data')
    expect(attempts).toBe(3)
    expect(result.data).toBe('success')
  })
})
```

---

## Integration Test Checklist

### Test Coverage

| Category | Checks |
|----------|--------|
| API Endpoints | [ ] Success paths, [ ] Error paths, [ ] Auth |
| Database | [ ] CRUD operations, [ ] Transactions, [ ] Constraints |
| External Services | [ ] Happy path, [ ] Timeouts, [ ] Retries |
| Data Flow | [ ] Complete workflows, [ ] State consistency |
| Fallbacks | [ ] Service failures, [ ] Cache fallbacks, [ ] Degrade gracefully |

### Test Environment

| Check | Status |
|--------|--------|
| Test database configured | [ ] |
- External services mocked | [ ] |
| Environment variables set | [ ] |
| Test data fixtures available | [ ] |

---

## Test Organization

```
tests/
├── integration/
│   ├── api/
│   │   ├── users.test.ts
│   │   └── auth.test.ts
│   ├── database/
│   │   ├── repositories.test.ts
│   │   └── migrations.test.ts
│   └── services/
│       ├── email.test.ts
│       └── payment.test.ts
├── e2e/
│   ├── registration-flow.test.ts
│   └── checkout-flow.test.ts
└── fixtures/
    ├── test-data.ts
    └── database-seed.ts
```

---

## Integration Testing Tools

### HTTP Testing

| Tool | Language | Use Case |
|------|----------|----------|
| supertest | JavaScript/TypeScript | HTTP endpoint testing |
| requests | Python | HTTP client for testing |
| rest-assured | Java | REST API testing |
| httptest | Go | HTTP testing |

### Service Mocking

| Tool | Language | Use Case |
|------|----------|----------|
| nock | JavaScript/TypeScript | HTTP mocking |
| MSW (Mock Service Worker) | JavaScript/TypeScript | API mocking |
| VCR | Ruby | HTTP recording/replay |
| wiremock | Java | HTTP stubbing |

### Database Testing

| Tool | Language | Use Case |
|------|----------|----------|
| testcontainers | Java, Python, Node | Docker test containers |
| sqlite | All | In-memory test database |
- transactional tests | All | Rollback after each test |

---

## Best Practices

1. **Isolation**: Each test should be independent
2. **Determinism**: Tests should produce same results on repeated runs
3. **Speed**: Keep tests fast by mocking slow external services
4. **Clear failure messages**: Tests should clearly indicate what failed
5. **Test data management**: Use fixtures for consistent test data
6. **Cleanup**: Clean up test data after each test
7. **Idempotency**: Tests should be runnable multiple times without side effects

---

## Running Integration Tests

### Command Examples

```bash
# Run all integration tests
npm run test:integration

# Run specific integration test suite
npm run test:integration -- api

# Run with coverage
npm run test:integration -- --coverage

# Run E2E tests
npm run test:e2e
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
jobs:
  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
```

---

## Document Completion

| Item | Status |
|------|--------|
| Integration scenarios defined | [ ] |
| API endpoint tests planned | [ ] |
| Database integration tests planned | [ ] |
- External service tests planned | [ ] |
| Fallback behavior tests planned | [ ] |
| E2E flows documented | [ ] |

---

## References

- [Testing Library](https://testing-library.com/)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [Nock HTTP Mocking](https://github.com/nock/nock)
- [Testcontainers](https://www.testcontainers.org/)

---

*End of INTEGRATION-TEST template*
