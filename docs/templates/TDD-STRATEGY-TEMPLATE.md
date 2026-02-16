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

## Test Quality Requirements

### Test Quality Indicators
- **Descriptive names**: Each test should describe what, when, and then
- **Single assertion per test**: Tests should verify one behavior
- **Independence**: Tests should not depend on each other
- **Deterministic**: No random data without seeding
- **Fast**: Unit tests should run in milliseconds
- **Readable**: Tests should serve as documentation

### Test Quality Checklist
| Quality Check | Description |
|---------------|-------------|
| Assertion quality | Tests have meaningful assertions (not just "no error") |
| Test descriptions | Descriptive names, not generic `test()` or `it('')` |
| Test isolation | Setup/teardown used for shared state |
| Edge case coverage | Tests cover boundaries, empty, null, invalid inputs |
| Test doubles | Mocks/stubs used appropriately for external dependencies |

---

## Property-Based Testing Guidance

### When to Use Property-Based Testing
- Complex business logic with many input combinations
- Data transformation functions
- State management operations
- Serialization/deserialization
- Any function where examples don't cover all cases

### Properties to Define
1. **Inverses**: `roundtrip(decode(x)) === x`
2. **Idempotence**: `f(f(x)) === f(x)`
3. **Commutativity**: `f(x, y) === f(y, x)`
4. **Invariants**: Output always satisfies some condition
5. **Associativity**: `f(f(x, y), z) === f(x, f(y, z))`

### Property-Based Testing Tools
- **JavaScript/TypeScript**: fast-check, jsverify
- **Python**: Hypothesis, pytest-quickcheck
- **Ruby**: rantly, rushcheck
- **Java**: jqwik
- **Haskell**: QuickCheck

---

## Mutation Testing Considerations

### What is Mutation Testing?
Mutation testing introduces small changes (mutations) to your code and verifies that your tests catch them. If tests pass despite code changes, the tests may be insufficient.

### When to Use Mutation Testing
- Critical business logic paths
- Security-sensitive operations
- Complex algorithms
- Before major releases
- Refactoring validation

### Mutation Testing Tools
- **JavaScript/TypeScript**: stryker-mutator
- **Python**: mutmut, pytest-mut
- **Ruby**: mutant
- **Java**: PITest
- **C#**: Stryker.NET

### Mutation Score Targets
- **Critical code**: >90% mutation score
- **Business logic**: >80% mutation score
- **Infrastructure code**: >60% mutation score

---

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

## Test Quality Requirements
[Test quality indicators and checklist]

## Property-Based Testing
[Properties to verify for complex logic]

## Mutation Testing Plan
[Mutation testing targets and tools]

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
