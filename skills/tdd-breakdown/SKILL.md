---
name: tdd-breakdown
description: DEPRECATED - Use spec-workflow skill instead. This skill is superseded by the comprehensive spec-workflow (4-phase) approach.
deprecated: true
replacement: spec-workflow
---

# ⚠️ DEPRECATED: Use spec-workflow Instead

**This skill has been deprecated and should no longer be used.**

## Replacement

Use the comprehensive `spec-workflow` skill instead, which includes all functionality of this skill plus:

- **Phase 1**: User journey analysis (exhaustive path mapping)
- **Phase 2**: EARS-formatted requirements extraction (atomic decomposition)
- **Phase 3**: TDD strategy with Gherkin scenarios
- **Phase 4**: Traceability verification (100% coverage)

## Migration Guide

### Old Approach (tdd-breakdown)
```
/feature-dev → Phase 3.5: Requirements Breakdown (tdd-breakdown)
            → Phase 4.5: TDD Strategy (tdd-breakdown)
```

### New Approach (spec-workflow)
```
/feature-dev → Phase 3.5: Complete Specification Workflow (spec-workflow)
            → Includes: User Journeys + EARS Requirements + TDD Strategy + Traceability
```

## Why Deprecated?

1. **Incomplete**: tdd-breakdown only covered requirements and TDD, missing user journeys and traceability
2. **No EARS**: Lacked industry-standard EARS requirement formatting
3. **No Gherkin**: Missing BDD/Gherkin scenario generation
4. **Redundant**: spec-workflow already mandatory in start-project, feature-dev, bug-fix
5. **Maintenance**: Consolidating to single comprehensive workflow reduces complexity

## See Also

- `skills/spec-workflow/skill.md` - Full 4-phase specification workflow
- `commands/start-project.md` - Uses spec-workflow as Phase 0
- `commands/feature-dev.md` - Uses spec-workflow in Phase 3.5
- `commands/bug-fix.md` - Uses spec-workflow in Phase 4.5

---

# Original Documentation (For Reference Only)

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

*End of DEPRECATED TDD-BREAKDOWN skill - Use spec-workflow instead*