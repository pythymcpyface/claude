# TDD Strategy Template

Use this template to map requirements to test cases. This document defines HOW we verify each requirement works correctly.

---

## Generation Instructions

### Test Case Mapping

For each REQ-XXX, generate comprehensive test cases covering:

1. **Happy Path**: Expected usage, valid inputs
2. **Sad Path**: Invalid inputs, error conditions
3. **Edge Cases**: Boundary values, empty/null, special characters
4. **Integration**: How this requirement interacts with others

### Test Case Format

Each test case must include:
- **Test ID**: TEST-XXX-001 (linked to REQ-XXX)
- **Description**: What is being tested
- **Given**: Initial state/preconditions
- **When**: Action being performed
- **Then**: Expected outcome
- **Type**: Unit / Integration / E2E

### Coverage Targets

- **Unit tests**: Each acceptance criterion gets at least one test
- **Edge cases**: Minimum 2-3 per requirement
- **Integration tests**: For requirement dependencies
- **Coverage goal**: >80% on business logic

---

## Example TDD Strategy

### REQ-001: Email Format Validation

#### Happy Path Tests

**TEST-001-001: Valid email returns true**
- **Given**: Email "user@example.com"
- **When**: Email validation function is called
- **Then**: Returns `true`
- **Type**: Unit

**TEST-001-002: Valid email with subdomain**
- **Given**: Email "user@mail.example.com"
- **When**: Email validation function is called
- **Then**: Returns `true`
- **Type**: Unit

**TEST-001-003: Valid email with plus sign**
- **Given**: Email "user+tag@example.com"
- **When**: Email validation function is called
- **Then**: Returns `true`
- **Type**: Unit

#### Sad Path Tests

**TEST-001-004: Missing @ symbol returns false**
- **Given**: Email "userexample.com"
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

**TEST-001-005: Missing domain returns false**
- **Given**: Email "user@"
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

**TEST-001-006: Email with spaces returns false**
- **Given**: Email "user @example.com"
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

#### Edge Cases

**TEST-001-007: Empty string returns false**
- **Given**: Empty string ""
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

**TEST-001-008: Null returns false**
- **Given**: null value
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

**TEST-001-009: Undefined returns false**
- **Given**: undefined value
- **When**: Email validation function is called
- **Then**: Returns `false`
- **Type**: Unit

#### Integration Tests

**TEST-001-010: Validation in registration flow**
- **Given**: User submits registration form with email
- **When**: Email validation is called during form submission
- **Then**: Invalid email shows error message
- **Type**: Integration

---

## Document Structure

```markdown
# TDD Strategy

## Overview
[Summary of testing approach]

## Test Fixtures
[Shared test data, mocks, utilities]

## Test Cases by Requirement

### REQ-001: [Title]
[All test cases for this requirement]

### REQ-002: [Title]
[All test cases for this requirement]

## Integration Scenarios
[Cross-requirement test scenarios]

## Performance Tests
[Load testing, stress testing if applicable]

## Security Tests
[Authorization, injection, input validation]

## Execution Order
[Test execution order based on dependencies]
```

---

## Test File Organization

```
tests/
├── unit/
│   ├── REQ-001-email-validation.test.ts
│   ├── REQ-002-domain-resolution.test.ts
│   └── ...
├── integration/
│   ├── registration-flow.test.ts
│   └── ...
├── fixtures/
│   ├── email-fixtures.ts
│   └── ...
└── setup.ts
```

---

## TDD Workflow Reminder

For each SPEC-XXX implementation:

1. **RED**: Write failing test from TDD-STRATEGY.md
2. **Run test**: Confirm it fails with expected error
3. **GREEN**: Write minimal implementation to pass
4. **Run test**: Confirm it passes
5. **REFACTOR**: Clean up code while tests pass
6. **Repeat**: Next test case

---

*End of TDD-STRATEGY template*
