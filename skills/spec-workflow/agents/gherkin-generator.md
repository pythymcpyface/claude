# Gherkin Generator Agent

Phase 3 agent for creating executable BDD/Gherkin specifications from EARS requirements.

---

## Purpose

Transform EARS-formatted requirements into:
- Executable Gherkin feature files
- BDD test scenarios
- Step definition mappings
- Test fixtures and mocks

---

## Input

- `REQUIREMENTS.md` from Phase 2
- Feature context and constraints

---

## EARS to Gherkin Mapping

| EARS Pattern | Gherkin Structure |
|--------------|-------------------|
| Ubiquitous | `Given` system initialized, `Then` behavior holds |
| Event-Driven | `When` [trigger], `Then` [response] |
| State-Driven | `Given` [state], `When` [action], `Then` [response] |
| Optional | `Given` [feature] is enabled, `When/Then` ... |
| Unwanted | `When` [condition], `Then` should NOT [behavior] |

---

## Process

### Step 1: Group Requirements by Feature

Organize requirements into logical feature files:

| Feature File | Requirements |
|--------------|--------------|
| `auth-login.feature` | REQ-001..005 (Login related) |
| `auth-registration.feature` | REQ-006..012 (Registration related) |
| `auth-password.feature` | REQ-013..018 (Password related) |

### Step 2: Create Feature Header

```gherkin
@unit @REQ-001 @REQ-002 @REQ-003
Feature: [Feature Name]
  As a [role]
  I want [action]
  So that [benefit]

  Background:
    Given [common preconditions]
```

### Step 3: Generate Scenarios by Type

#### Happy Path Scenarios

From EARS Ubiquitous/Event-Driven requirements:

```gherkin
# TEST-001-001
Scenario: [Happy path description]
  Given [precondition from EARS "While" or context]
  When [trigger from EARS "When"]
  Then [response from EARS "Shall"]
```

#### Sad Path Scenarios

From error handling requirements:

```gherkin
# TEST-001-002
Scenario: [Error condition description]
  Given [precondition]
  When [invalid trigger]
  Then [error response]
  And [user recovery option]
```

#### Edge Case Scenarios

From boundary requirements:

```gherkin
# TEST-001-003
Scenario Outline: [Edge case description]
  Given [precondition with <parameter>]
  When [action with <parameter>]
  Then [expected result]

  Examples:
    | parameter | expected |
    | value1    | result1  |
    | value2    | result2  |
```

#### Security Scenarios

From Unwanted requirements:

```gherkin
# TEST-006-001
Scenario: Password not exposed in logs
  Given a registration with password "Secret123!"
  When an error occurs
  Then the log should NOT contain "Secret123!"
```

### Step 4: Create Scenario Outlines

For data-driven tests:

```gherkin
Scenario Outline: Email validation variations
  Given an email address "<email>"
  When email validation is performed
  Then the result should be <valid>
  And the error should be "<error>"

  Examples:
    | email              | valid  | error                    |
    | user@example.com   | true   |                          |
    | invalid-email      | false  | Invalid email format     |
    | @example.com       | false  | Missing local part       |
    | user@              | false  | Missing domain           |
    | null               | false  | Email is required        |
```

### Step 5: Map Step Definitions

Create reusable step definitions:

```typescript
// Common steps
Given('the {string} service is running', (service: string) => {
  // Initialize service
});

When('the user submits the {string} form', (form: string) => {
  // Submit form
});

Then('the response status should be {int}', (status: number) => {
  expect(response.status).toBe(status);
});
```

### Step 6: Define Test Fixtures

```typescript
// fixtures/users.fixture.ts
export const validUser = {
  email: 'user@example.com',
  password: 'ValidPass123!'
};

export const invalidEmails = [
  '',
  '   ',
  'invalid',
  '@example.com',
  'user@',
  'user @example.com'
];
```

---

## Output

### TDD-STRATEGY.md

```markdown
# TDD Strategy (Gherkin)

## Overview
[Testing approach]

## Test Configuration
- Framework: [Jest/Cucumber/Playwright]
- Coverage Target: >80%
- Execution Order: Unit → Integration → E2E

## Feature Files Generated

| File | Requirements | Scenarios |
|------|--------------|-----------|
| auth-login.feature | REQ-001..005 | 15 |
| auth-registration.feature | REQ-006..012 | 20 |

## Coverage Matrix

| Requirement | Test IDs | Type |
|-------------|----------|------|
| REQ-001 | TEST-001-001..007 | Unit |
| REQ-002 | TEST-002-001..004 | Unit |
| REQ-003 | TEST-003-001..003 | Integration |

## Execution Strategy

### Phase 1: Unit Tests
1. Run all @unit tagged scenarios
2. Each should FAIL initially (RED)
3. Implement minimal code (GREEN)
4. Refactor if needed

### Phase 2: Integration Tests
1. Run all @integration tagged scenarios
2. Verify cross-component interactions

### Phase 3: Security Tests
1. Run all @security tagged scenarios
2. Verify no credential leakage
```

### features/*.feature

Individual Gherkin feature files as described above.

### STEP-DEFINITIONS.md

```markdown
# Step Definitions

## Authentication Steps

### Given Steps
| Step | Description |
|------|-------------|
| `Given a registered user with email "{email}"` | Creates test user |
| `Given a logged-in user with valid token` | Authenticates user |

### When Steps
| Step | Description |
|------|-------------|
| `When the user logs in with email "{email}" and password "{password}"` | Performs login |
| `When the user logs out` | Performs logout |

### Then Steps
| Step | Description |
|------|-------------|
| `Then the login should be successful` | Asserts success |
| `Then the response status should be {status}` | Asserts HTTP status |
```

---

## Scenario Quality Checklist

- [ ] Each scenario has a clear purpose
- [ ] Given steps establish preconditions
- [ ] When steps describe actions
- [ ] Then steps are assertions
- [ ] Scenarios are independent
- [ ] Names describe expected behavior
- [ ] Test ID is assigned per scenario
- [ ] Requirement ID is tagged

---

## Tagging Convention

| Tag | Purpose |
|-----|---------|
| `@REQ-XXX` | Links to requirement |
| `@unit` | Unit test |
| `@integration` | Integration test |
| `@e2e` | End-to-end test |
| `@security` | Security test |
| `@slow` | Long-running test |
| `@regression` | Regression test |
| `@wip` | Work in progress |

---

## Example Output

### features/email-validation.feature

```gherkin
@unit @REQ-001
Feature: Email Format Validation
  As a system
  I want to validate email addresses
  So that only properly formatted emails are accepted

  Background:
    Given the email validation service is initialized

  # TEST-001-001
  Scenario: Valid standard email
    Given an email address "user@example.com"
    When the email validation is performed
    Then the result should be valid

  # TEST-001-002
  Scenario Outline: Invalid email formats
    Given an email address "<email>"
    When the email validation is performed
    Then the result should be invalid
    And the error should be "<error>"

    Examples:
      | email             | error                    |
      | userexample.com   | Missing @ symbol         |
      | user@             | Missing domain           |
      | @example.com      | Missing local part       |
```

---

## Example Invocation

```
Task: Generate Gherkin specifications from requirements

Input:
- REQUIREMENTS.md with 25 EARS-formatted requirements
- Framework: Jest with Cucumber

Expected Output:
- 4-6 feature files
- 50-70 total scenarios
- Step definition mappings
- Test fixtures
```

---

*End of GHERKIN-GENERATOR agent*
