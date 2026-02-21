# Feature File Template (Gherkin)

Use this template to create individual Gherkin feature files. Each feature maps to one or more related requirements.

---

## Gherkin Syntax Reference

| Keyword | Purpose |
|---------|---------|
| `Feature` | High-level description of functionality |
| `Background` | Steps run before each scenario |
| `Scenario` | Individual test case |
| `Scenario Outline` | Data-driven test with examples |
| `Given` | Preconditions (setup) |
| `When` | Actions (trigger) |
| `Then` | Expected outcomes (assertions) |
| `And` | Additional step of same type |
| `But` | Negative additional step |

---

## Feature File Structure

```gherkin
@tag1 @tag2 @REQ-XXX
Feature: [Feature Name]
  As a [role]
  I want [action]
  So that [benefit]

  Background:
    Given [common precondition]
    And [another precondition]

  # TEST-XXX-001
  Scenario: [Happy Path Description]
    Given [specific precondition]
    When [action]
    Then [expected result]
    And [additional assertion]

  # TEST-XXX-002
  Scenario: [Sad Path Description]
    Given [precondition]
    When [invalid action]
    Then [error result]

  # TEST-XXX-003
  Scenario Outline: [Data-Driven Description]
    Given [precondition with <placeholder>]
    When [action with <placeholder>]
    Then [result with <placeholder>]

    Examples:
      | placeholder | expected |
      | value1      | result1  |
      | value2      | result2  |
```

---

## Example: Authentication Feature

```gherkin
@authentication @REQ-010 @REQ-011 @REQ-012
Feature: User Authentication
  As a registered user
  I want to log in securely
  So that I can access my personalized content

  Background:
    Given the authentication service is running
    And the database connection is established
    And rate limiting is configured

  # TEST-010-001
  Scenario: Successful login with valid credentials
    Given a registered user with email "user@example.com"
    And password "ValidPass123!"
    When the user logs in with email "user@example.com" and password "ValidPass123!"
    Then the login should be successful
    And a JWT token should be returned
    And the token should expire in 24 hours
    And the last login timestamp should be updated

  # TEST-010-002
  Scenario: Login failure with incorrect password
    Given a registered user with email "user@example.com"
    When the user logs in with email "user@example.com" and password "WrongPassword!"
    Then the login should fail
    And the error message should be "Invalid email or password"
    And the failed attempt counter should be incremented
    And no JWT token should be returned

  # TEST-010-003
  Scenario: Login failure with non-existent email
    Given no user exists with email "nonexistent@example.com"
    When the user logs in with email "nonexistent@example.com" and password "AnyPassword123!"
    Then the login should fail
    And the error message should be "Invalid email or password"
    And the failed attempt counter should NOT be incremented

  # TEST-011-001
  Scenario: Account locked after 5 failed attempts
    Given a registered user with email "user@example.com"
    And 5 failed login attempts for email "user@example.com"
    When the user attempts to log in with valid credentials
    Then the login should fail
    And the error message should be "Account locked. Please reset your password."
    And an unlock email should be sent

  # TEST-011-002
  Scenario Outline: Password validation rules
    Given a password "<password>"
    When the password is validated
    Then the result should be <valid>
    And the error should be "<error>"

    Examples:
      | password        | valid  | error                          |
      | short           | false  | Password must be 8+ characters |
      | alllowercase1!  | false  | Must contain uppercase letter  |
      | ALLUPPERCASE1!  | false  | Must contain lowercase letter  |
      | NoNumbers!      | false  | Must contain a number          |
      | NoSpecial123    | false  | Must contain special character |
      | ValidPass123!   | true   |                                |

  # TEST-012-001
  Scenario: Session token invalidation on logout
    Given a logged-in user with valid token
    When the user logs out
    Then the token should be invalidated
    And subsequent API calls with the token should return 401 Unauthorized

  # TEST-012-002
  Scenario: Token refresh before expiration
    Given a logged-in user with token expiring in 1 hour
    When the user requests a token refresh
    Then a new valid token should be returned
    And the old token should remain valid until expiration
    And the new token should expire in 24 hours

  # TEST-010-004
  Scenario: Rate limiting blocks brute force attempts
    Given rate limiting is set to 10 attempts per minute
    When 11 login attempts are made within 1 minute from IP "192.168.1.1"
    Then the 11th attempt should be blocked
    And the error should be "Too many attempts. Please wait and try again."
    And a security alert should be logged
```

---

## Tagging Convention

| Tag Pattern | Purpose |
|-------------|---------|
| `@REQ-XXX` | Links to requirement |
| `@unit` | Unit test |
| `@integration` | Integration test |
| `@e2e` | End-to-end test |
| `@security` | Security-related test |
| `@slow` | Long-running test |
| `@wip` | Work in progress |

---

## Best Practices

### Scenario Writing
1. **One assertion per Then** - Keep scenarios focused
2. **Declarative over imperative** - Describe WHAT, not HOW
3. **Business language** - Use domain terms, not technical jargon
4. **Independent scenarios** - Each runs in isolation

### Background Usage
- Only for truly common setup
- Keep minimal - prefer explicit Given steps
- Don't include assertions

### Scenario Outline Usage
- Use for data-driven tests with same steps
- Examples table should be readable
- Limit to 5-10 example rows

### Naming Convention
- Feature file: `kebab-case.feature`
- Scenario ID: `TEST-XXX-YYY` in comment above scenario
- Descriptive names that explain the expected behavior

---

## Common Step Patterns

### Authentication Steps
```gherkin
Given a registered user with email "..."
Given a logged-in user with valid token
When the user logs in with email "..." and password "..."
Then the login should be successful
Then the login should fail
```

### CRUD Steps
```gherkin
Given an existing resource with id "..."
When the user creates a new resource with ...
When the user updates resource "..." with ...
When the user deletes resource "..."
Then the resource should be created
Then the resource should be updated
Then the resource should be deleted
```

### Validation Steps
```gherkin
Given input value "..."
When the input is validated
Then the validation should pass
Then the validation should fail with error "..."
```

### Error Steps
```gherkin
Then the response status should be ...
Then the error message should be "..."
Then no error should be thrown
```

---

*End of FEATURE template*
