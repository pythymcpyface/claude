# Specification Template

Copy this template for each new specification. Replace bracketed content with actual specification details.

---

## Specification ID: SPEC-XXX

### User Story
As a **[user role]**,
I want **[action/capability]**,
so that **[benefit/value]**.

### Acceptance Criteria
- [ ] **[AC1]**: [Specific, measurable criterion]
- [ ] **[AC2]**: [Specific, measurable criterion]
- [ ] **[AC3]**: [Specific, measurable criterion]

---

## Functional Specification

### Input

**Data Format:** [exact format - JSON, form data, etc.]

**Required Fields:**
| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| `[field_name]` | `[type]` | `[validation rules]` | `[description]` |

**Optional Fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `[field_name]` | `[type]` | `[default]` | `[description]` |

**Constraints:**
- [Length limits, format requirements, etc.]

### Processing

**Algorithm:**
1. [Step 1 - exact processing logic]
2. [Step 2 - exact processing logic]
3. [Step 3 - exact processing logic]
4. [Decision point: if condition then action else alternative action]
5. [Step 5 - exact processing logic]

**Decision Points:**
- [Condition 1]: [Action if true]
- [Condition 2]: [Action if true]

### Output

**Success Response:**
```json
{
  "status": "success",
  "data": { [response structure] }
}
```

**Error Responses:**
| Error Code | Condition | Response |
|------------|-----------|----------|
| `ERR_001` | [error condition] | `{ "status": "error", "code": "ERR_001", "message": "[message]" }` |
| `ERR_002` | [error condition] | `{ "status": "error", "code": "ERR_002", "message": "[message]" }` |

### Database Operations

**Tables Accessed:**
- `[table_name]` - [operation: read/write]

**Read Operations:**
```sql
[exact query if applicable]
```

**Write Operations:**
- [Table]: [operation - insert/update/delete]
- [Fields]: [list]
- [Transaction scope]: [what's included]

**Transactions:**
- Scope: [what operations are atomic]
- Isolation level: [if applicable]
- Rollback conditions: [when to rollback]

### API Contract

**Endpoint:** `[METHOD] /path/to/resource`

**Request Headers:**
| Header | Required | Value |
|--------|----------|-------|
| `Content-Type` | Yes | `application/json` |
| `Authorization` | Yes | `Bearer {token}` |

**Request Body:**
```json
{
  "[field]": "[value]",
  "[field]": "[value]"
}
```

**Response Codes:**
| Code | Condition |
|------|-----------|
| `200` | Success |
| `400` | Validation error |
| `401` | Unauthorized |
| `403` | Forbidden |
| `404` | Not found |
| `500` | Server error |

**Authentication:** [required/optional]

**Rate Limiting:** [if applicable]

### Error Handling

| Error Condition | Trigger | Response | Logging | Alerting |
|----------------|----------|----------|---------|----------|
| [Error 1] | [trigger condition] | [response code/message] | [log level] | [alert level] |
| [Error 2] | [trigger condition] | [response code/message] | [log level] | [alert level] |

**Retry Logic:**
- [When to retry, backoff strategy, etc.]

### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Empty input | [how to handle] |
| Maximum length input | [how to handle] |
| Special characters | [how to handle] |
| Concurrent requests | [how to handle] |
| [Edge case N] | [how to handle] |

### Performance Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| Response time (p50) | [<X>ms] | [how measured] |
| Response time (p95) | [<X>ms] | [how measured] |
| Response time (p99) | [<X>ms] | [how measured] |
| Throughput | [>X req/s] | [how measured] |
| Concurrent users | [>X] | [how measured] |

### Security Requirements

**Authorization:**
- Who can access: [roles/permissions]
- Access level: [read/write/admin]

**Data Sensitivity:**
- Classification: [public/internal/confidential]
- Encryption: [at rest/in transit/both]

**Audit Logging:**
- What to log: [operations, data accessed, user]
- When to log: [before/after operation]
- Log retention: [how long]

**Input Sanitization:**
- [How to prevent XSS, injection, etc.]

### Safety & Reliability

| Failure Mode | Consequence | Safeguards | Fallback Behavior |
|--------------|-------------|------------|-------------------|
| [Failure 1] | [severity] | [prevention] | [what happens on failure] |
| [Failure 2] | [severity] | [prevention] | [what happens on failure] |

**Data Integrity:**
- [How data corruption is prevented]
- [How data is validated]
- [Rollback strategy]

### Testing Requirements

**Unit Tests:**
- [Number] tests minimum
- Coverage: [>X%]
- Test cases: [list key test cases]

**Integration Tests:**
- [Scenarios to test]
- [Dependencies to verify]

**E2E Tests:**
- [Key workflows to test]

**Performance Tests:**
- [Load testing requirements]
- [Stress testing requirements]

**Security Tests:**
- [Authorization tests]
- [Injection tests]
- [Input validation tests]

### Dependencies

**Requires:**
- SPEC-[XXX]: [specification name]
- SPEC-[XXX]: [specification name]

**Required By:**
- SPEC-[XXX]: [specification name]
- SPEC-[XXX]: [specification name]

### Implementation Notes

**Common Mistakes:**
- [Mistake 1]: [how to avoid]
- [Mistake 2]: [how to avoid]

**System Considerations:**
- [Consideration 1]
- [Consideration 2]

**Testing Approach:**
- [How to test this specification]
- [What fixtures to use from TEST-FIXTURES.md]

---

## Estimation

**Estimated Implementation Time:** [X] minutes (target: 15-30)

**Complexity:** [Low/Medium/High]

**Risk Level:** [Low/Medium/High]

---

*End of SPEC-XXX template*
