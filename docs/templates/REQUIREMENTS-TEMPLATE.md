# Requirements Template

Use this template to document requirements for features or bug fixes. Requirements represent WHAT needs to be built from the user's perspective.

---

## Generation Instructions

### Iterative Breakdown Process

**CRITICAL**: Requirements must be broken down to atomic units before proceeding to specifications.

1. **Generate initial requirements** from user input and clarifying questions
2. **Iterative breakdown loop (3-5 passes)**:
   - For each requirement, ask: "Can this be split into smaller, independently testable units?"
   - Break down until atomic (single function, single decision point, single file)
   - Stop when requirements seem "ridiculously small"
3. **Number sequentially**: REQ-001, REQ-002, etc.

### Atomic Requirement Indicators

A requirement is atomic when:
- Can be implemented in a single function or small set of functions
- Has clear, binary acceptance criteria (pass/fail)
- Independent of other requirements (minimal dependencies)
- Testable in isolation

### Format

Each requirement must include:
- **User Story**: As a [role], I want [action], so that [benefit]
- **Acceptance Criteria**: Specific, measurable, binary conditions
- **Dependencies**: Other requirements this depends on
- **Priority**: Must-have / Should-have / Nice-to-have

---

## Example Requirements

### REQ-001: Email Format Validation

**User Story**: As a system, I want to validate email addresses, so that only properly formatted emails are accepted.

**Acceptance Criteria**:
- [ ] Returns `true` for valid email format (user@domain.com)
- [ ] Returns `false` for email missing @ symbol
- [ ] Returns `false` for email missing domain
- [ ] Returns `false` for email with spaces
- [ ] Handles edge case: empty string returns `false`
- [ ] Handles edge case: null/undefined returns `false`

**Dependencies**: None

**Priority**: Must-have

---

### REQ-002: Email Domain Resolution

**User Story**: As a system, I want to verify the domain has MX records, so that emails are deliverable.

**Acceptance Criteria**:
- [ ] Returns `true` if domain has at least one MX record
- [ ] Returns `false` if domain has no MX records
- [ ] Returns `false` if DNS lookup fails
- [ ] Handles edge case: timeout after 5 seconds
- [ ] Handles edge case: invalid domain format

**Dependencies**: REQ-001

**Priority**: Should-have

---

## Document Structure

```markdown
# Requirements Document

## Context
[Feature description and background]

## Requirements

### REQ-001: [Title]
**User Story**: As a [role], I want [action], so that [benefit]

**Acceptance Criteria**:
- [ ] [AC1]
- [ ] [AC2]

**Dependencies**: None / REQ-XXX

**Priority**: Must-have

---

## Dependency Graph
[Visual representation of requirement dependencies]

## Priority Order
[Implementation order based on dependencies and priority]
```

---

*End of REQUIREMENTS template*
