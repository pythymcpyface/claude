# Bug Specification Template

Use this template to document bugs using EARS syntax for precise specification and regression test generation.

---

## Purpose

Transform bug reports into:
1. Precise EARS-formatted specifications
2. Regression test scenarios (Gherkin)
3. Root cause traceability
4. Fix verification criteria

---

## Document Structure

```markdown
# Bug Specification

## Bug Metadata
- **Bug ID**: BUG-XXX
- **Severity**: CRITICAL | HIGH | MEDIUM | LOW
- **Status**: Open | In Progress | Fixed | Verified
- **Original Report**: [Link to bug report]

## EARS Specification

### Normal Behavior (Expected)

**Pattern**: [EARS Pattern Type]

**Specification**:
[Full EARS statement describing expected behavior]

### Buggy Behavior (Actual)

**Pattern**: [EARS Pattern Type]

**Specification**:
[Full EARS statement describing buggy behavior]

## Root Cause Analysis

[Technical explanation of WHY the bug occurs]

## Regression Tests

[Gherkin scenarios to prevent regression]

## Fix Verification

[Criteria for confirming the fix]
```

---

## Example Bug Specification

### BUG-001: Login Null Pointer Exception

## Bug Metadata
- **Bug ID**: BUG-001
- **Severity**: HIGH
- **Status**: Fixed
- **Original Report**: `.claude/docs/fix/login-null-pointer/BUG-REPORT.md`

## EARS Specification

### Normal Behavior (Expected)

**Pattern**: Event-Driven

**Specification**:
> When a user submits a login form with a null email value, the system shall return a validation error "Email is required" and shall not throw an exception.

**Acceptance Criteria**:
- [ ] Returns validation error for null email
- [ ] Returns HTTP 400 status
- [ ] No exception thrown
- [ ] Error response is JSON formatted
- [ ] Request is logged for audit

### Buggy Behavior (Actual)

**Pattern**: Unwanted

**Specification**:
> The system shall not throw a NullPointerException when email value is null.

**Current Behavior**:
```
java.lang.NullPointerException: Cannot invoke "String.length()" because "email" is null
    at com.app.auth.LoginService.validateEmail(LoginService.java:42)
    at com.app.auth.LoginService.login(LoginService.java:28)
```

## Root Cause Analysis

**Location**: `LoginService.java:42`

**Code**:
```java
// Buggy code
if (email.length() > 0) {  // NullPointerException here
    // validation logic
}
```

**Why it fails**:
- Missing null check before calling `length()` method
- Assumes email parameter is never null

**Correct pattern**:
```java
if (email != null && email.length() > 0) {
    // validation logic
}
```

## Regression Tests

### features/bug-001-login-null-email.feature

```gherkin
@regression @BUG-001 @security
Feature: Login Null Email Handling
  As a robust authentication system
  I want to handle null email gracefully
  So that users receive helpful error messages instead of crashes

  Background:
    Given the login service is running
    And the authentication endpoint is available

  # REG-001-001
  Scenario: Null email returns validation error
    Given a login request with null email
    And a valid password "Password123!"
    When the login endpoint is called
    Then the response status should be 400
    And the error message should be "Email is required"
    And the response should be valid JSON
    And no exception should be logged

  # REG-001-002
  Scenario: Empty email returns validation error
    Given a login request with email ""
    And a valid password "Password123!"
    When the login endpoint is called
    Then the response status should be 400
    And the error message should be "Email is required"

  # REG-001-003
  Scenario: Whitespace-only email returns validation error
    Given a login request with email "   "
    And a valid password "Password123!"
    When the login endpoint is called
    Then the response status should be 400
    And the error message should be "Email is required"

  # REG-001-004
  Scenario: Valid email with null password
    Given a login request with email "user@example.com"
    And a null password
    When the login endpoint is called
    Then the response status should be 400
    And the error message should be "Password is required"
    And no exception should be logged

  # REG-001-005
  Scenario Outline: All null/empty combinations handled gracefully
    Given a login request with email "<email>" and password "<password>"
    When the login endpoint is called
    Then the response status should be 400
    And no exception should be logged

    Examples:
      | email              | password     |
      | null               | null         |
      | null               | Password123! |
      | user@example.com   | null         |
      | ""                 | ""           |
      | ""                 | Password123! |
```

## Fix Verification

### Pre-Fix Test Results
```
REG-001-001: FAIL - NullPointerException
REG-001-002: FAIL - NullPointerException
REG-001-003: PASS (empty string handled differently)
REG-001-004: FAIL - NullPointerException
REG-001-005: ALL FAIL
```

### Post-Fix Test Results
```
REG-001-001: PASS
REG-001-002: PASS
REG-001-003: PASS
REG-001-004: PASS
REG-001-005: ALL PASS
```

### Verification Checklist
- [x] All regression tests pass
- [x] No exceptions in logs
- [x] Correct HTTP status codes returned
- [x] Error messages are user-friendly
- [x] Similar patterns in codebase reviewed
- [x] Code review approved
- [x] Security review approved (input validation)

---

## Similar Pattern Search

After fixing, search codebase for similar patterns:

```bash
# Find similar null-check issues
grep -rn "\.length()" --include="*.java" | grep -v "!= null"

# Find similar validation patterns
grep -rn "if (" --include="*.java" | grep "\.isEmpty\|\.isBlank"
```

**Locations Reviewed**:
- [x] `LoginService.java` - Fixed
- [x] `RegistrationService.java` - No issue (has null check)
- [x] `PasswordResetService.java` - Fixed similar pattern
- [x] `ProfileService.java` - No issue (uses Optional)

---

## Journey Traceability

**Related Journey**: JOURNEY-001 (User Registration), Step 4

**Related Requirements**:
- REQ-001: Email format validation (updated to include null handling)
- REQ-0079: Null input handling (new requirement added)

**Tests Updated**:
- TEST-001-006: Null email handling (added)
- TEST-001-007: Undefined email handling (added)

---

*End of BUG-SPECIFICATION template*
