# Start Project — Document Templates

Markdown templates for every document generated in Phases 2–4. Substitute `[bracketed]` placeholders with values synthesised from spec-workflow outputs.

Sections in this file (use heading anchors):

- [CLAUDE.md](#claudemd)
- [PROJECT-PLAN.md](#project-planmd)
- [GIT-STRATEGY.md](#git-strategymd)
- [SPECIFICATIONS.md](#specificationsmd)
- [DEPENDENCY-GRAPH.md](#dependency-graphmd)
- [PARALLEL-GROUPS.md](#parallel-groupsmd)
- [CRITICAL-PATH.md](#critical-pathmd)
- [TEST-FIXTURES.md](#test-fixturesmd)
- [INTEGRATION-TESTS.md](#integration-testsmd)
- [RISKS-AND-MITIGATIONS.md](#risks-and-mitigationsmd)
- [IMPLEMENTATION-ROADMAP.md](#implementation-roadmapmd)
- [TDD-MASTER-DOCUMENT.md](#tdd-master-documentmd)

---

## CLAUDE.md

Generate at `.claude/CLAUDE.md`.

```markdown
# Project: [Project Name]

## Project Context
[Brief description from USER-JOURNEYS.md]

## Stack
- **Language**: [from requirements]
- **Frameworks**: [from requirements]
- **Database/ORM**: [if applicable]
- **Testing**: [from TDD-STRATEGY.md]

## Key Directories
- Source: [to be determined during implementation]
- Tests: [to be determined during implementation]

## Project Documentation References
- `.claude/docs/$BRANCH/USER-JOURNEYS.md` - Exhaustive user journey analysis
- `.claude/docs/$BRANCH/REQUIREMENTS.md` - EARS-formatted atomic requirements
- `.claude/docs/$BRANCH/TDD-STRATEGY.md` - Gherkin test specifications
- `.claude/docs/$BRANCH/TRACEABILITY-MATRIX.md` - Bidirectional traceability
- `.claude/docs/$BRANCH/PROJECT-PLAN.md` - Complete project context
- `.claude/docs/$BRANCH/SPECIFICATIONS.md` - Atomic specifications
- `.claude/docs/$BRANCH/RISKS-AND-MITIGATIONS.md` - Risk analysis
- `.claude/docs/$BRANCH/IMPLEMENTATION-ROADMAP.md` - Step-by-step guide with checkpoints
- `.claude/docs/$BRANCH/TDD-MASTER-DOCUMENT.md` - All test cases
- `.claude/docs/$BRANCH/TEST-FIXTURES.md` - Test data fixtures
- `.claude/docs/$BRANCH/INTEGRATION-TESTS.md` - Cross-specification tests
- `.claude/docs/$BRANCH/DEPENDENCY-GRAPH.md` - Specification dependencies
- `.claude/docs/$BRANCH/PARALLEL-GROUPS.md` - Parallel execution groups
- `.claude/docs/$BRANCH/CRITICAL-PATH.md` - Implementation priority
- `.claude/docs/$BRANCH/GIT-STRATEGY.md` - Git workflow and conventions

## Development Standards
- Follow specifications exactly
- TDD approach: tests first, implementation after
- All tests must pass before committing
- EARS-formatted requirements guide all development

## Quality Gates
- No TypeScript errors (if applicable)
- No lint warnings
- Test coverage >80% on business logic
- All Gherkin scenarios passing
- Code review before merge

---

*Auto-generated from comprehensive specification workflow.*
```

---

## PROJECT-PLAN.md

```markdown
# Project Plan

## Executive Summary
[Synthesized from USER-JOURNEYS.md and REQUIREMENTS.md]

## System Context

### Function
[What the system does — from USER-JOURNEYS.md roles and goals]

### Current State
[Baseline — from requirements]

### Future State
[Target state after implementation — from requirements]

## Requirements Summary

### Functional Requirements
[From REQUIREMENTS.md — Must-have items]

### Non-Functional Requirements
[Performance, security, reliability from REQUIREMENTS.md]

### Compliance Requirements
[Any regulatory or standards requirements from REQUIREMENTS.md]

## Technical Approach

### Architecture
[High-level architecture from requirements and journeys]

### Tech Stack
[Languages, frameworks, databases from requirements]

### Development Approach
- Specification-driven development (EARS format)
- Test-driven development (Gherkin/BDD)
- Atomic specification implementation
- Continuous traceability verification

## High-Level Roadmap

### Phase 1: Foundation
[Critical path specifications from dependency analysis]

### Phase 2: Core Features
[Must-have requirements]

### Phase 3: Enhancement
[Should-have requirements]

### Phase 4: Polish
[Nice-to-have requirements]

## Resource Requirements

### Development
- [Estimated from specification count and complexity]

### Testing
- [From TDD-STRATEGY.md test count]

### Documentation
- [Already complete from this workflow]

## Risk Summary
[High-level risks identified during journey and requirement analysis]

## Success Criteria
[From REQUIREMENTS.md acceptance criteria and TRACEABILITY-MATRIX.md coverage]

## Assumptions & Constraints
[From requirements and journey analysis]
```

---

## GIT-STRATEGY.md

Document branching model, commit conventions, workflow per specification, commit rules, code review process, release management, emergency procedures, git hooks, progress tracking, repository hygiene, and safety reminders. Tailor to the project's tech stack identified in spec-workflow outputs. Reference the project-level Git rules in `.claude/rules/` if they exist.

---

## SPECIFICATIONS.md

```markdown
# Atomic Specifications

## SPEC-001: [Title from REQ-001]

### User Story
[From REQUIREMENTS.md]

### Acceptance Criteria
[From REQUIREMENTS.md]

### Functional Specification

#### Input
[What data/events trigger this]

#### Processing
[What the system does]

#### Output
[What the system produces]

#### Database
[Any data persistence]

#### API
[Any external interfaces]

#### Error Handling
[How errors are managed]

#### Edge Cases
[Boundary conditions from USER-JOURNEYS.md]

### Performance Requirements
[Response time, throughput]

### Security Requirements
[Authentication, authorization, data protection]

### Safety & Reliability
[Failure modes, recovery]

### Testing Requirements
[From TDD-STRATEGY.md]

### Dependencies
- **Requires**: [List of SPEC-XXX this depends on]
- **Required by**: [List of SPEC-XXX that depend on this]
```

Repeat for every requirement in `REQUIREMENTS.md`. Iterate 3–5 passes (see `phases.md` Phase 3).

---

## DEPENDENCY-GRAPH.md

```markdown
# Specification Dependency Graph

## Complete Graph

\`\`\`
SPEC-001: Project Setup
    ↓
SPEC-002: Core Types (depends on: SPEC-001)
    ↓
SPEC-003: Database Schema (depends on: SPEC-002)
    ├─► SPEC-004: User Model (depends on: SPEC-003)
    ├─► SPEC-005: Session Model (depends on: SPEC-003)
    └─► SPEC-006: Audit Model (depends on: SPEC-003)
\`\`\`

## Dependency Matrix

| Spec | Depends On | Required By | Depth |
|------|------------|-------------|-------|
| SPEC-001 | - | SPEC-002 | 0 |
| SPEC-002 | SPEC-001 | SPEC-003 | 1 |
| SPEC-003 | SPEC-002 | SPEC-004, SPEC-005, SPEC-006 | 2 |
```

---

## PARALLEL-GROUPS.md

```markdown
# Parallel Execution Groups

## Group 1: Foundation (Sequential)
- SPEC-001: Project Setup
- SPEC-002: Core Types
- SPEC-003: Database Schema

**Reason**: Each depends on the previous

## Group 2: Data Models (Parallel)
- SPEC-004: User Model
- SPEC-005: Session Model
- SPEC-006: Audit Model

**Dependencies**: All depend on SPEC-003
**Can run in parallel**: Yes
**Estimated time savings**: 60%

## Group 3: Business Logic (Parallel)
[Continue for all parallel groups]
```

---

## CRITICAL-PATH.md

```markdown
# Critical Path Analysis

## Critical Path (Implement First)

1. **SPEC-001: Project Setup**
   - Blocks: ALL other specifications
   - Dependents: 47 specs
   - Priority: CRITICAL

2. **SPEC-002: Core Types**
   - Blocks: 45 specs
   - Dependents: SPEC-003 through SPEC-047
   - Priority: CRITICAL

3. **SPEC-003: Database Schema**
   - Blocks: 42 specs
   - Dependents: All data models and business logic
   - Priority: CRITICAL

## High-Impact Specifications

[Specs that block many others but aren't on critical path]

## Leaf Specifications (Implement Last)

- SPEC-047: Logging (blocks: 0 specs)
- SPEC-046: Metrics (blocks: 0 specs)
- SPEC-045: Documentation (blocks: 0 specs)

**Reason**: Nothing depends on these, can be done anytime
```

---

## TEST-FIXTURES.md

```markdown
# Test Data Fixtures

## Valid User Fixtures

\`\`\`json
{
  "validUser1": {
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "Test User"
  },
  "validUser2": {
    "email": "admin@example.com",
    "password": "AdminPass456!",
    "name": "Admin User",
    "role": "admin"
  }
}
\`\`\`

## Invalid User Fixtures

\`\`\`json
{
  "invalidEmail": {
    "email": "not-an-email",
    "password": "SecurePass123!",
    "name": "Test User"
  },
  "weakPassword": {
    "email": "user@example.com",
    "password": "123",
    "name": "Test User"
  },
  "nullEmail": {
    "email": null,
    "password": "SecurePass123!",
    "name": "Test User"
  }
}
\`\`\`

[Continue for all test scenarios from TDD-STRATEGY.md]
```

---

## INTEGRATION-TESTS.md

```markdown
# Integration Test Matrix

## IT-001: Complete User Registration Flow

**Specifications**: SPEC-004 (User Model), SPEC-007 (Registration), SPEC-008 (Email Verification)

**Test Steps**:
1. POST /api/register with valid user data
2. Verify user created in database
3. Verify verification email sent
4. GET /api/verify with token
5. Verify user status updated to "verified"

**Expected Result**: User can log in after verification

**Gherkin Reference**: features/user-registration.feature

## IT-002: Authentication Flow

[Continue for all critical workflows from USER-JOURNEYS.md]
```

---

## RISKS-AND-MITIGATIONS.md

```markdown
# Risks and Mitigations

## System Risks

### RISK-001: Database Schema Changes
**Severity**: HIGH
**Probability**: MEDIUM
**Impact**: Breaking changes to data models
**Mitigation**:
- Use database migrations (SPEC-003)
- Version all schema changes
- Maintain backward compatibility for 2 versions
**Contingency**: Rollback scripts in place

## Technical Risks

### RISK-002: Third-Party API Failures
**Severity**: MEDIUM
**Probability**: HIGH
**Impact**: Service degradation
**Mitigation**:
- Implement circuit breakers (SPEC-015)
- Add retry logic with exponential backoff
- Cache responses where possible
**Contingency**: Graceful degradation mode

[Continue for all identified risks]
```

After Phase 4, update `PROJECT-PLAN.md` to v2 with insights from the dependency graph (critical path), risk analysis (mitigation activities), parallel groups (resource optimisation), and test strategy (quality gates).

---

## IMPLEMENTATION-ROADMAP.md

```markdown
# Implementation Roadmap

## Pre-Implementation Checklist

- [ ] All specifications reviewed and approved
- [ ] Development environment set up
- [ ] Git repository initialized
- [ ] CI/CD pipeline configured
- [ ] Test framework installed
- [ ] Quality gates configured

## Phase 1: Foundation (Critical Path)

### Checkpoint 1.1: Project Setup (SPEC-001)
**Duration**: 1 hour
**Steps**:
1. Initialize project structure
2. Configure build tools
3. Set up linting and formatting
4. Configure test framework
5. Create initial .gitignore

**Verification**:
- [ ] `npm test` runs successfully
- [ ] `npm run lint` passes
- [ ] `npm run build` completes

**Tests**: TEST-001-001 through TEST-001-005

### Checkpoint 1.2: Core Types (SPEC-002)
**Duration**: 2 hours
**Dependencies**: SPEC-001
**Steps**:
1. Define base types
2. Create type utilities
3. Add type tests
4. Document type system

**Verification**:
- [ ] All types compile without errors
- [ ] Type tests pass
- [ ] Documentation generated

**Tests**: TEST-002-001 through TEST-002-010

[Continue for all specifications in dependency order]

## Phase 2: Parallel Development

### Group 2.1: Data Models (Parallel)
**Specifications**: SPEC-004, SPEC-005, SPEC-006
**Duration**: 4 hours (parallel) / 12 hours (sequential)
**Dependencies**: SPEC-003

[Continue for all parallel groups]

## Phase 3: Integration

### Checkpoint 3.1: Integration Tests
**Duration**: 3 hours
**Steps**:
1. Run all integration tests from INTEGRATION-TESTS.md
2. Verify end-to-end workflows
3. Performance testing
4. Security testing

**Verification**:
- [ ] All integration tests pass
- [ ] Performance meets requirements
- [ ] Security scan passes

## Phase 4: Final Verification

### Checkpoint 4.1: Complete Traceability
**Steps**:
1. Verify all requirements implemented
2. Verify all tests passing
3. Verify 100% traceability (TRACEABILITY-MATRIX.md)
4. Run quality gates

**Verification**:
- [ ] All SPEC-XXX implemented
- [ ] All TEST-XXX-YYY passing
- [ ] Coverage >80%
- [ ] No orphaned requirements or tests

## Code Review Checklist

For each specification:
- [ ] Follows EARS requirements exactly
- [ ] All acceptance criteria met
- [ ] All Gherkin scenarios passing
- [ ] Error handling comprehensive
- [ ] Security requirements met
- [ ] Performance requirements met
- [ ] Documentation complete
```

---

## TDD-MASTER-DOCUMENT.md

```markdown
# TDD Master Document

## Test Organization

\`\`\`
tests/
├── unit/
│   ├── spec-001/
│   │   ├── test-001-001.test.ts
│   │   └── test-001-002.test.ts
│   ├── spec-002/
│   └── ...
├── integration/
│   ├── it-001-user-registration.test.ts
│   └── ...
└── e2e/
    ├── user-flows.test.ts
    └── ...
\`\`\`

## Test Template

\`\`\`typescript
describe('SPEC-XXX: [Specification Title]', () => {
  describe('TEST-XXX-001: [Test Description]', () => {
    it('[Gherkin scenario title]', () => {
      // Given [precondition from Gherkin]

      // When [action from Gherkin]

      // Then [expected outcome from Gherkin]
    });
  });
});
\`\`\`

## Test Specifications by Specification ID

### SPEC-001: Project Setup

#### TEST-001-001: Verify Project Structure
**Gherkin Reference**: features/project-setup.feature:5
**Type**: Unit
**Priority**: Must-have

\`\`\`typescript
describe('TEST-001-001: Verify Project Structure', () => {
  it('should have all required directories', () => {
    // Given a new project
    const projectRoot = process.cwd();

    // When checking directory structure
    const requiredDirs = ['src', 'tests', 'docs'];

    // Then all directories should exist
    requiredDirs.forEach(dir => {
      expect(fs.existsSync(path.join(projectRoot, dir))).toBe(true);
    });
  });
});
\`\`\`

[Continue for all test cases from TDD-STRATEGY.md]

## Complete Test Matrix

| Spec | Test ID | Type | Priority | Gherkin | Status |
|------|---------|------|----------|---------|--------|
| SPEC-001 | TEST-001-001 | Unit | Must | features/project-setup.feature:5 | Pending |
| SPEC-001 | TEST-001-002 | Unit | Must | features/project-setup.feature:12 | Pending |
[Continue for all tests]

## Test Data Strategy

[From TEST-FIXTURES.md]

## Performance Test Specifications

[From TDD-STRATEGY.md performance scenarios]

## Security Test Specifications

[From TDD-STRATEGY.md security scenarios]
```
