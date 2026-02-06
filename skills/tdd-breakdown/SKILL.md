---
name: tdd-breakdown
description: Iterative requirement breakdown for TDD workflow. Breaks down features into atomic requirements, generates specifications, and creates TDD test strategy documents.
---

# TDD Breakdown Skill

Supporting skill for iterative requirement breakdown in the feature development workflow. This skill is called by `/feature-dev` during Phase 3.5 (Requirements Breakdown) and Phase 4.5 (TDD Strategy Generation).

---

## Phase 3.5: Requirements Breakdown

### Goal
Break down feature requests into atomic, independently testable requirements.

### Process

1. **Generate initial requirements** from user input and clarifying questions
2. **Iterative breakdown loop (3-5 passes)**:
   - For each requirement, ask: "Can this be split into smaller, independently testable units?"
   - Break down until atomic (single function, single decision point, single file)
   - Stop when requirements seem "ridiculously small"
3. **Generate `.claude/docs/REQUIREMENTS.md`** with:
   - Numbered REQ-001, REQ-002, etc.
   - User story format for each
   - Acceptance criteria (binary, measurable)
   - Dependencies between requirements
   - Priority (Must-have / Should-have / Nice-to-have)

### Atomic Requirement Indicators

A requirement is atomic when:
- Can be implemented in a single function or small set of functions
- Has clear, binary acceptance criteria (pass/fail)
- Independent of other requirements (minimal dependencies)
- Testable in isolation

### Example Breakdown

**Initial**: "Add user authentication"

**Pass 1**:
- REQ-001: User registration
- REQ-002: User login
- REQ-003: Password reset

**Pass 2** (breaking REQ-001):
- REQ-001: Validate email format
- REQ-002: Validate password strength
- REQ-003: Hash password with bcrypt
- REQ-004: Store user in database
- REQ-005: Return user session token

**Pass 3** (breaking REQ-002):
- REQ-006: Verify email exists
- REQ-007: Verify password matches hash
- REQ-008: Generate session token
- REQ-009: Return session token

**Result**: 9 atomic requirements, each testable independently

---

## Phase 4.5: TDD Strategy Generation

### Goal
Generate comprehensive test case mapping for all requirements before implementation.

### Process

1. **For each REQ-XXX**, generate SPEC-XXX using existing template
2. **Generate `.claude/docs/SPECIFICATIONS.md`** containing all specs
3. **Generate `.claude/docs/TDD-STRATEGY.md`** with:
   - Test case for every acceptance criterion
   - Happy path tests
   - Sad path/edge case tests
   - Integration tests
   - Test fixtures needed

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

## Document Generation Order

**CRITICAL**: Complete ALL documents before any implementation

1. Generate complete `REQUIREMENTS.md` (all requirements broken down atomically)
2. Generate complete `SPECIFICATIONS.md` (all specs from requirements)
3. Generate complete `TDD-STRATEGY.md` (all test cases mapped)
4. **THEN** begin implementation following TDD loop

---

## TDD Loop (For Phase 5 Implementation)

For each SPEC-XXX in dependency order:

1. **Read test cases** from TDD-STRATEGY.md for this spec
2. **Write failing test** (RED) - create test file with test case
3. **Run test**, confirm it fails
4. **Write minimal implementation** to make test pass
5. **Run test**, confirm it passes (GREEN)
6. **Refactor** if needed (REFACTOR)
7. **Run `quality-gate.sh`**
8. **Commit** if gate passes

---

## Quick Reference

### Requirements Template Location
`.claude/docs/templates/REQUIREMENTS-TEMPLATE.md`

### TDD Strategy Template Location
`.claude/docs/templates/TDD-STRATEGY-TEMPLATE.md`

### Spec Template Location
`.claude/docs/templates/SPEC-TEMPLATE.md`

### Output Files
- `.claude/docs/REQUIREMENTS.md`
- `.claude/docs/SPECIFICATIONS.md`
- `.claude/docs/TDD-STRATEGY.md`

---

## Critical Rules

**ALWAYS:**
- Break down requirements to atomic units (single function, single decision point)
- Generate ALL documents before implementation starts
- Include happy path, sad path, and edge cases for each requirement
- Map test cases to acceptance criteria

**NEVER:**
- Start implementation before all three documents are complete
- Skip the iterative breakdown loop
- Create requirements that depend on multiple other requirements

---

## Verification Checklist

Before proceeding to Phase 5 (Implementation):
- [ ] `REQUIREMENTS.md` exists with all requirements numbered
- [ ] Each requirement has user story format
- [ ] Each requirement has binary acceptance criteria
- [ ] Each requirement is atomic (single function)
- [ ] `SPECIFICATIONS.md` exists with SPEC-XXX for each REQ-XXX
- [ ] `TDD-STRATEGY.md` exists with TEST-XXX-XXX for each acceptance criterion
- [ ] Dependencies between requirements are documented
- [ ] Implementation order based on dependencies is defined

---

*End of TDD-BREAKDOWN skill*
