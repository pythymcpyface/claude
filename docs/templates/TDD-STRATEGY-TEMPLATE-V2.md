# TDD Strategy Template V2 (Gherkin/BDD)

Use this template to create executable Gherkin specifications from EARS requirements. Generates BDD scenarios that map directly to test code.

---

## Generation Instructions

### EARS to Gherkin Mapping

| EARS Pattern | Gherkin Mapping |
|--------------|-----------------|
| Ubiquitous | `Given` (precondition) + `Then` (expected behavior) |
| Event-Driven | `When` (trigger) + `Then` (response) |
| State-Driven | `Given` (state) + `When` (action) + `Then` (response) |
| Optional | `Given` (feature enabled) + `When/Then` |
| Unwanted | `When` (condition) + `Then` (should not) |

### Scenario Generation Rules

For each requirement:
1. **Happy Path**: Primary acceptance criteria
2. **Sad Path**: Error conditions and invalid inputs
3. **Edge Cases**: Boundary values, null/empty, special cases
4. **Integration**: Cross-requirement interactions

### Test ID Convention

- `TEST-XXX-YYY` where XXX = requirement ID, YYY = scenario number
- Example: `TEST-001-001` = first test for REQ-001

---

## Document Structure

```markdown
# TDD Strategy (Gherkin)

## Overview
[Testing approach summary]

## Test Configuration
- **Framework**: [Jest/Vitest/Cucumber/etc.]
- **Coverage Target**: >80% business logic
- **Execution**: Unit → Integration → E2E

## Feature Files

[Generated .feature files organized by feature area]

## Test Fixtures
[Shared test data and mocks]

## Step Definitions
[Reusable step definition mappings]

## Coverage Matrix
[Requirements to Tests mapping]
```

---

## Example Feature File

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
  Scenario: Valid email with subdomain
    Given an email address "user@mail.example.com"
    When the email validation is performed
    Then the result should be valid

  # TEST-001-003
  Scenario: Valid email with plus sign
    Given an email address "user+tag@example.com"
    When the email validation is performed
    Then the result should be valid

  # TEST-001-004
  Scenario Outline: Invalid email formats
    Given an email address "<email>"
    When the email validation is performed
    Then the result should be invalid
    And the error should be "<error>"

    Examples:
      | email              | error                    |
      | userexample.com    | Missing @ symbol         |
      | user@              | Missing domain           |
      | @example.com       | Missing local part       |
      | user @example.com  | Contains spaces          |
      | user@example       | Missing TLD              |

  # TEST-001-005
  Scenario: Empty string email
    Given an email address ""
    When the email validation is performed
    Then the result should be invalid
    And the error should be "Email is required"

  # TEST-001-006
  Scenario: Null email value
    Given a null email value
    When the email validation is performed
    Then the result should be invalid
    And the error should be "Email is required"

  # TEST-001-007
  Scenario: Undefined email value
    Given an undefined email value
    When the email validation is performed
    Then the result should be invalid
    And the error should be "Email is required"
```

### features/registration.feature

```gherkin
@integration @REQ-002 @REQ-003
Feature: User Registration Flow
  As a new user
  I want to register an account
  So that I can access the system

  Background:
    Given the registration service is initialized
    And the database is connected

  # TEST-002-001
  Scenario: Successful registration with new email
    Given a valid email "newuser@example.com"
    And a valid password "Password123!"
    When the user submits the registration form
    Then the user should be created with status "unverified"
    And a verification email should be sent
    And the response should include "Check your email"

  # TEST-003-001
  Scenario: Registration with duplicate email
    Given an existing user with email "existing@example.com"
    And a registration attempt with email "existing@example.com"
    When the user submits the registration form
    Then the error message should be "This email is already registered"
    And a link to "/forgot-password" should be displayed

  # TEST-005-001
  Scenario: Rate limiting blocks excess attempts
    Given rate limiting is enabled with limit 5 per hour
    And 5 registration attempts from IP "192.168.1.1"
    When a 6th registration attempt is made from IP "192.168.1.1"
    Then the attempt should be blocked
    And the error should be "Too many attempts, try again later"
```

### features/password-security.feature

```gherkin
@security @REQ-006
Feature: Password Security
  As a security-conscious system
  I want to ensure passwords are never exposed
  So that user credentials remain secure

  Background:
    Given the registration service is initialized

  # TEST-006-001
  Scenario: Password is hashed before storage
    Given a registration with password "MySecret123!"
    When the user is created
    Then the stored password should be a bcrypt hash
    And the hash should not be "MySecret123!"

  # TEST-006-002
  Scenario: Password not in error logs
    Given a registration that will fail
    And a password "MySecret123!"
    When the error is logged
    Then the log should not contain "MySecret123!"

  # TEST-006-003
  Scenario: Password redacted in error responses
    Given a registration with password "MySecret123!"
    When the API returns an error response
    Then the response body should not contain "MySecret123!"
```

---

## Step Definitions Reference

### Common Steps

```typescript
// email.steps.ts
Given('an email address {string}', (email: string) => {
  this.testEmail = email;
});

Given('a null email value', () => {
  this.testEmail = null;
});

When('the email validation is performed', async () => {
  this.result = await emailValidator.validate(this.testEmail);
});

Then('the result should be valid', () => {
  expect(this.result.isValid).toBe(true);
});

Then('the result should be invalid', () => {
  expect(this.result.isValid).toBe(false);
});

Then('the error should be {string}', (error: string) => {
  expect(this.result.error).toBe(error);
});
```

---

## Coverage Matrix

| Requirement | Test IDs | Coverage |
|-------------|----------|----------|
| REQ-001: Email Format | TEST-001-001 to TEST-001-007 | 100% |
| REQ-002: Uniqueness Check | TEST-002-001 to TEST-002-004 | 100% |
| REQ-003: Duplicate Handling | TEST-003-001 to TEST-003-004 | 100% |
| REQ-004: Password Strength | TEST-004-001 to TEST-004-005 | 100% |
| REQ-005: Rate Limiting | TEST-005-001 to TEST-005-004 | 100% |
| REQ-006: Password Security | TEST-006-001 to TEST-006-004 | 100% |

---

## Test File Organization

```
tests/
├── features/
│   ├── email-validation.feature
│   ├── registration.feature
│   └── password-security.feature
├── step-definitions/
│   ├── email.steps.ts
│   ├── registration.steps.ts
│   └── password.steps.ts
├── fixtures/
│   ├── users.fixture.ts
│   └── emails.fixture.ts
└── support/
    ├── hooks.ts
    └── world.ts
```

---

## Execution Strategy

### Phase 1: Unit Tests (Red)
1. Run all `@unit` tagged scenarios
2. Each scenario should FAIL initially (RED)
3. Document expected failure behavior

### Phase 2: Implementation (Green)
1. Write minimal code to pass each test
2. Run tests after each implementation
3. Confirm GREEN (passing)

### Phase 3: Integration Tests
1. Run all `@integration` tagged scenarios
2. Test cross-component interactions
3. Verify database/API integration

### Phase 4: Security Tests
1. Run all `@security` tagged scenarios
2. Verify no credential leakage
3. Run OWASP validation

---

## Quality Gates

Before marking tests complete:
- [ ] All scenarios have valid Gherkin syntax
- [ ] Each REQ-XXX has corresponding TEST-XXX-XXX
- [ ] Happy path, sad path, and edge cases covered
- [ ] Step definitions are reusable
- [ ] Fixtures are isolated and repeatable
- [ ] Coverage >80% on business logic

---

*End of TDD-STRATEGY-V2 template*
