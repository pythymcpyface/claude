---
description: Comprehensive project documentation generation. ALWAYS runs complete /spec-workflow first (Phase 0) for exhaustive specifications, then generates all planning documentation. Does NOT write code.
argument-hint: Feature description for specification workflow
---

# Start Project - COMPREHENSIVE DOCUMENTATION GENERATION

## ⛔ THIS COMMAND DOES NOT WRITE CODE ⛔

**PURPOSE**: Generate comprehensive project documentation starting with exhaustive specifications (via mandatory /spec-workflow execution), then synthesizing into complete planning documents.

**OUTPUT**: `.claude/docs/$BRANCH/` directory with complete markdown documentation.

**STOPPING POINT**: After all documentation generation is complete.

**WHAT THIS COMMAND DOES:**
- ✅ **ALWAYS** run complete `/spec-workflow` (Phase 0) - 4 phases mandatory
- ✅ Synthesize spec-workflow outputs into comprehensive project documentation
- ✅ Generate `.claude/docs/$BRANCH/*.md` planning documents (13 files)
- ✅ Generate `.claude/scripts/*.sh` helper scripts (3 files, not executed)
- ✅ Iterate specifications 3-5 times until atomic
- ✅ Generate dependency graphs, parallel groups, critical paths
- ✅ Create complete test strategies and fixtures

**WHAT THIS COMMAND DOES NOT DO:**
- ❌ Write ANY application code
- ❌ Create ANY source files (src/, tests/, config files, etc.)
- ❌ Run ANY setup commands
- ❌ Install ANY dependencies
- ❌ Execute ANY scripts (except mkdir for directories)

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│              COMPREHENSIVE DOCUMENTATION WORKFLOW                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 0: MANDATORY Specification Workflow (4 phases)           │
│      │                                                           │
│      ├─► Phase 1: User Journey Analysis (exhaustive)            │
│      ├─► Phase 2: Requirements Extraction (EARS, atomic)        │
│      ├─► Phase 3: TDD Strategy (Gherkin, scenarios)             │
│      └─► Phase 4: Traceability Verification (100% coverage)     │
│                           │                                      │
│                           ▼                                      │
│                  ⛔ HARD STOP: Approve Specs                     │
│                           │                                      │
│                           ▼                                      │
│  Phase 1-5: Synthesize into Project Documentation               │
│      │                                                           │
│      ├─► Read spec-workflow outputs                             │
│      ├─► Generate 13 documentation files                        │
│      ├─► Iterate specifications (3-5 times until atomic)        │
│      ├─► Generate dependency graphs & critical paths            │
│      └─► Generate test strategies & fixtures                    │
│                           │                                      │
│                           ▼                                      │
│                  ⛔ HARD STOP: Approve Plan                      │
│                           │                                      │
│                           ▼                                      │
│                    Begin Implementation                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: MANDATORY Specification Workflow

**CRITICAL**: This phase is **ALWAYS EXECUTED** - no skipping, no conditionals.

### 0.1 Setup Documentation Directory

```bash
# Get current branch name (sanitized for directory use)
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-zA-Z0-9]/-/g' || echo "main")
DOCS_DIR=".claude/docs/$BRANCH"

# Create documentation directory
mkdir -p "$DOCS_DIR"
mkdir -p "$DOCS_DIR/features"
```

### 0.2 Execute Complete 4-Phase Specification Workflow

**Run ALL 4 phases** - this is the foundation for all subsequent documentation:

#### Phase 0.1: User Journey Analysis

**Goal**: Map EVERY possible path through the feature with exhaustive detail.

**Actions**:
1. **Role Discovery**: Identify ALL user roles
   - Primary users (end users, customers)
   - Secondary users (admins, moderators)
   - System actors (workers, schedulers)
   - API consumers (mobile apps, integrations)

2. **Goal Extraction**: For each role, enumerate goals
   - What does this role want to accomplish?
   - What are success/failure criteria?

3. **Entry Point Mapping**: Document all entry points
   - UI routes
   - API endpoints
   - Events/webhooks
   - CLI commands

4. **Path Enumeration**: For each (role, goal, entry):
   - Happy path (ideal flow)
   - ALL decision branches
   - ALL error states with recovery
   - ALL loop-back paths

5. **Edge Case Discovery**:
   - Empty/null/undefined inputs
   - Maximum boundaries
   - Concurrent operations
   - State conflicts
   - Permission violations

6. **Generate Mermaid diagrams**:
   - Flowcharts for paths
   - Sequence diagrams for interactions
   - State diagrams for transitions

**Output**: `$DOCS_DIR/USER-JOURNEYS.md`

#### Phase 0.2: Requirements Extraction (EARS)

**Goal**: Convert journeys to atomic EARS-formatted requirements.

**EARS Patterns**:
- **Ubiquitous**: The [system] shall [response]
- **Event-Driven**: When [trigger], the [system] shall [response]
- **State-Driven**: While [state], the [system] shall [response]
- **Optional**: Where [feature], the [system] shall [response]
- **Unwanted**: The [system] shall not [behavior]

**Actions**:
1. **Convert journey steps** to requirements using EARS patterns
2. **Atomic Decomposition Loop** (3-5 iterations):
   - Can this be implemented in a single function?
   - Can this be split into smaller, testable units?
   - Split until "ridiculously small"
3. **Build dependency graph**
4. **Assign priorities** (Must-have, Should-have, Nice-to-have)
5. **Assign test IDs** (TEST-XXX-YYY)

**Output**: `$DOCS_DIR/REQUIREMENTS.md`

#### Phase 0.3: TDD Strategy Generation (Gherkin)

**Goal**: Create executable Gherkin specifications.

**Actions**:
1. **Group requirements** by feature area
2. **Create feature files** for each group
3. **Generate scenarios**:
   - Happy path: One per acceptance criterion
   - Sad path: Error conditions
   - Edge cases: Boundary values
   - Security: Credential protection
4. **Create scenario outlines** for data-driven tests
5. **Map step definitions** to reusable code
6. **Define test fixtures** and mocks

**Outputs**:
- `$DOCS_DIR/TDD-STRATEGY.md`
- `$DOCS_DIR/features/*.feature`

#### Phase 0.4: Traceability Verification

**Goal**: Ensure bidirectional traceability with no orphans.

**Actions**:
1. **Build traceability graph**: Journey → Requirement → Test
2. **Check forward trace**: Every journey has requirements, every requirement has tests
3. **Check backward trace**: Every test maps to requirement, every requirement to journey
4. **Calculate coverage** by layer, priority, and type
5. **Generate verification report** with gaps and recommendations

**Outputs**:
- `$DOCS_DIR/TRACEABILITY-MATRIX.md`
- `$DOCS_DIR/VERIFICATION-REPORT.md`

### 0.3 Present Specification Summary and Wait for Approval

```markdown
## Specification Workflow Complete (Phase 0)

### Documents Generated:
- ✅ USER-JOURNEYS.md ([N] journeys, [N] steps)
- ✅ REQUIREMENTS.md ([N] atomic requirements)
- ✅ TDD-STRATEGY.md ([N] test scenarios)
- ✅ features/*.feature ([N] feature files)
- ✅ TRACEABILITY-MATRIX.md
- ✅ VERIFICATION-REPORT.md

### Statistics:
- Roles: [N]
- Journeys: [N]
- Requirements: [N] (Must-have: [N], Should-have: [N])
- Test Scenarios: [N]
- Coverage: [N]%

### Verification Status: [PASS/BLOCKED]

---

## ⛔ STOP - User Approve Specs Before Continuing

Review the generated specifications above.

**Type "continue" or "approve" to proceed with comprehensive project documentation generation.**
```

**WAIT for user confirmation** before continuing to Phase 1.

---

## Phase 1: Read Specification Outputs

### 1.1 Read All spec-workflow Outputs

```bash
# Read all specification documents
Read "$DOCS_DIR/USER-JOURNEYS.md"
Read "$DOCS_DIR/REQUIREMENTS.md"
Read "$DOCS_DIR/TDD-STRATEGY.md"
Read "$DOCS_DIR/TRACEABILITY-MATRIX.md"
Read "$DOCS_DIR/VERIFICATION-REPORT.md"

# Read all feature files
for feature in "$DOCS_DIR/features/"*.feature; do
  Read "$feature"
done
```

### 1.2 Extract Key Information

From the specification documents, extract:
- **USER-JOURNEYS.md** → Roles, goals, entry points, all paths
- **REQUIREMENTS.md** → EARS-formatted atomic requirements with dependencies
- **TDD-STRATEGY.md** → Gherkin scenarios, test IDs, fixtures
- **TRACEABILITY-MATRIX.md** → Coverage verification, gaps
- **features/*.feature** → Executable Gherkin specifications

---

## Phase 2: Generate Core Documentation

### 2.1 Create Directory Structure

```bash
mkdir -p .claude/docs .claude/scripts
```

### 2.2 Generate `.claude/CLAUDE.md`

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

### 2.3 Generate `.claude/docs/$BRANCH/PROJECT-PLAN.md`

Synthesize from spec-workflow outputs:

```markdown
# Project Plan

## Executive Summary
[Synthesized from USER-JOURNEYS.md and REQUIREMENTS.md]

## System Context

### Function
[What the system does - from USER-JOURNEYS.md roles and goals]

### Current State
[Baseline - from requirements]

### Future State
[Target state after implementation - from requirements]

## Requirements Summary

### Functional Requirements
[From REQUIREMENTS.md - Must-have items]

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

### 2.4 Generate `.claude/docs/$BRANCH/GIT-STRATEGY.md`

[Full Git Strategy document as shown in previous version - includes branching model, commit conventions, workflow per specification, commit rules, code review process, release management, emergency procedures, git hooks, progress tracking, repository hygiene, and safety reminders]

---

## Phase 3: Generate Atomic Specifications (Iterate 3-5 Times)

### 3.1 Initial Specification Generation

Transform REQUIREMENTS.md into detailed SPECIFICATIONS.md:

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

### 3.2 Iterative Refinement (3-5 passes)

For each iteration:

1. **Read current SPECIFICATIONS.md**
2. **Challenge each specification**:
   - Can this be split into smaller units?
   - Are all edge cases from USER-JOURNEYS.md covered?
   - Are all error conditions from TDD-STRATEGY.md addressed?
   - Can this be implemented in 15-30 minutes?
3. **Split specifications** that are too complex
4. **Update dependencies** after splitting
5. **Track iteration count**

### 3.3 Stop Criteria

Stop iterating when:
- Specifications are "ridiculously small"
- Each spec is a single function or small set of functions
- No further meaningful decomposition is possible
- All edge cases from journeys are covered
- All test scenarios from TDD-STRATEGY.md are mapped

---

## Phase 4: Generate Supporting Documentation

### 4.1 Generate `.claude/docs/$BRANCH/DEPENDENCY-GRAPH.md`

Parse SPECIFICATIONS.md dependencies:

```markdown
# Specification Dependency Graph

## Complete Graph

```
SPEC-001: Project Setup
    ↓
SPEC-002: Core Types (depends on: SPEC-001)
    ↓
SPEC-003: Database Schema (depends on: SPEC-002)
    ├─► SPEC-004: User Model (depends on: SPEC-003)
    ├─► SPEC-005: Session Model (depends on: SPEC-003)
    └─► SPEC-006: Audit Model (depends on: SPEC-003)
```

## Dependency Matrix

| Spec | Depends On | Required By | Depth |
|------|------------|-------------|-------|
| SPEC-001 | - | SPEC-002 | 0 |
| SPEC-002 | SPEC-001 | SPEC-003 | 1 |
| SPEC-003 | SPEC-002 | SPEC-004, SPEC-005, SPEC-006 | 2 |
```

### 4.2 Generate `.claude/docs/$BRANCH/PARALLEL-GROUPS.md`

Identify specifications with identical dependencies:

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

### 4.3 Generate `.claude/docs/$BRANCH/CRITICAL-PATH.md`

Identify blocking specifications:

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

### 4.4 Generate `.claude/docs/$BRANCH/TEST-FIXTURES.md`

Extract from TDD-STRATEGY.md and create reusable fixtures:

```markdown
# Test Data Fixtures

## Valid User Fixtures

```json
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
```

## Invalid User Fixtures

```json
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
```

[Continue for all test scenarios from TDD-STRATEGY.md]
```

### 4.5 Generate `.claude/docs/$BRANCH/INTEGRATION-TESTS.md`

Create integration tests spanning multiple specifications:

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

### 4.6 Generate `.claude/docs/$BRANCH/RISKS-AND-MITIGATIONS.md`

Synthesize risks from all specification documents:

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

### 4.7 Update `.claude/docs/$BRANCH/PROJECT-PLAN.md` to v2

Incorporate insights from:
- Dependency graph (critical path)
- Risk analysis (mitigation activities)
- Parallel groups (resource optimization)
- Test strategy (quality gates)

### 4.8 Generate `.claude/docs/$BRANCH/IMPLEMENTATION-ROADMAP.md`

Create step-by-step implementation guide:

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

### 4.9 Generate `.claude/docs/$BRANCH/TDD-MASTER-DOCUMENT.md`

Consolidate all test specifications:

```markdown
# TDD Master Document

## Test Organization

```
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
```

## Test Template

```typescript
describe('SPEC-XXX: [Specification Title]', () => {
  describe('TEST-XXX-001: [Test Description]', () => {
    it('[Gherkin scenario title]', () => {
      // Given [precondition from Gherkin]
      
      // When [action from Gherkin]
      
      // Then [expected outcome from Gherkin]
    });
  });
});
```

## Test Specifications by Specification ID

### SPEC-001: Project Setup

#### TEST-001-001: Verify Project Structure
**Gherkin Reference**: features/project-setup.feature:5
**Type**: Unit
**Priority**: Must-have

```typescript
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
```

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

---

## Phase 5: Generate Helper Scripts

### 5.1 Create `.claude/scripts/quality-gate.sh`

```bash
#!/bin/bash
# Quality Gate Verification
# Run before each commit

echo "🔍 Running Quality Gates..."

# 1. Tests
npm test --silent 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Tests failing"
  exit 1
fi

# 2. TypeScript (if applicable)
if [ -f "tsconfig.json" ]; then
  npx tsc --noEmit 2>&1 | head -10
  if [ $? -ne 0 ]; then
    echo "❌ TypeScript errors"
    exit 1
  fi
fi

# 3. Lint
npm run lint 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Lint errors"
  exit 1
fi

# 4. Coverage
npm run test:coverage 2>&1 | grep -E "Lines|Statements|Branches|Functions"

echo "✅ All quality gates passed"
exit 0
```

### 5.2 Create `.claude/scripts/validate-planning.sh`

```bash
#!/bin/bash
# Planning Document Validation

BASE_DIR=".claude/docs"
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-zA-Z0-9]/-/g' || echo "main")
DOCS_DIR="$BASE_DIR/$BRANCH"
ERRORS=0

echo "🔍 Validating planning documents in $DOCS_DIR..."

# Spec-workflow outputs (Phase 0)
for doc in USER-JOURNEYS.md REQUIREMENTS.md TDD-STRATEGY.md \
           TRACEABILITY-MATRIX.md VERIFICATION-REPORT.md; do
  if [ ! -f "$DOCS_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

# Project documentation (Phases 1-5)
for doc in PROJECT-PLAN.md SPECIFICATIONS.md RISKS-AND-MITIGATIONS.md \
           IMPLEMENTATION-ROADMAP.md TDD-MASTER-DOCUMENT.md GIT-STRATEGY.md \
           TEST-FIXTURES.md INTEGRATION-TESTS.md DEPENDENCY-GRAPH.md \
           PARALLEL-GROUPS.md CRITICAL-PATH.md; do
  if [ ! -f "$DOCS_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

# Root documentation
if [ ! -f "$BASE_DIR/../CLAUDE.md" ]; then
  echo "❌ Missing: CLAUDE.md"
  ERRORS=$((ERRORS + 1))
fi

# Feature files
if [ ! -d "$DOCS_DIR/features" ]; then
  echo "❌ Missing: features/ directory"
  ERRORS=$((ERRORS + 1))
else
  FEATURE_COUNT=$(ls -1 "$DOCS_DIR/features/"*.feature 2>/dev/null | wc -l)
  if [ $FEATURE_COUNT -eq 0 ]; then
    echo "⚠️  Warning: No feature files found"
  else
    echo "✅ Found $FEATURE_COUNT feature files"
  fi
fi

if [ $ERRORS -eq 0 ]; then
  echo "✅ All planning documents validated"
  exit 0
else
  echo "❌ Found $ERRORS missing documents"
  exit 1
fi
```

### 5.3 Create `.claude/scripts/setup-env.sh`

```bash
#!/bin/bash
# Environment Setup Script
# Run this manually after documentation is approved

set -e

echo "🚀 Setting up development environment..."

# Detect project type
if [ -f "package.json" ]; then
  echo "📦 Node.js project detected"
  
  # Install dependencies
  if command -v pnpm &> /dev/null; then
    echo "   Using pnpm..."
    pnpm install
  elif command -v yarn &> /dev/null; then
    echo "   Using yarn..."
    yarn install
  else
    echo "   Using npm..."
    npm install
  fi
  
  # Run initial build
  if grep -q '"build"' package.json; then
    echo "   Running initial build..."
    npm run build
  fi
  
  # Run tests to verify setup
  echo "   Running tests..."
  npm test
  
elif [ -f "Cargo.toml" ]; then
  echo "🦀 Rust project detected"
  cargo build
  cargo test
  
elif [ -f "go.mod" ]; then
  echo "🐹 Go project detected"
  go mod download
  go build ./...
  go test ./...
  
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  echo "🐍 Python project detected"
  
  # Create virtual environment
  python3 -m venv venv
  source venv/bin/activate
  
  # Install dependencies
  if [ -f "pyproject.toml" ]; then
    pip install -e .
  elif [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
  fi
  
  # Run tests
  pytest
  
else
  echo "⚠️  Unknown project type"
  echo "   Please set up your environment manually"
  exit 1
fi

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "Next steps:"
echo "   1. Review documentation in .claude/docs/"
echo "   2. Begin implementation following the roadmap"
echo "   3. Run quality gates before each commit: bash .claude/scripts/quality-gate.sh"
```

---

## Phase 6: Validate All Documentation

### 6.1 Run Validation Script

```bash
bash .claude/scripts/validate-planning.sh
```

### 6.2 Manual Validation Checklist

- [ ] All 16 documents exist (6 from spec-workflow + 10 from project docs)
- [ ] Each SPEC-XXX has corresponding tests in TDD-MASTER-DOCUMENT.md
- [ ] Each TEST-XXX-YYY maps to Gherkin scenario in features/*.feature
- [ ] All dependencies in DEPENDENCY-GRAPH.md resolve (no broken references)
- [ ] No circular dependencies
- [ ] Each spec has time estimate in IMPLEMENTATION-ROADMAP.md
- [ ] All risks have mitigations in RISKS-AND-MITIGATIONS.md
- [ ] Checkpoints defined in IMPLEMENTATION-ROADMAP.md
- [ ] Integration tests cover critical workflows from USER-JOURNEYS.md
- [ ] TRACEABILITY-MATRIX.md shows 100% coverage
- [ ] All Gherkin scenarios have corresponding test specifications

### 6.3 If Validation Fails

Fix issues and re-validate until all checks pass.

---

## Phase 7: Present Complete Summary (THEN HARD STOP)

After validation passes, present this summary to the user, then **ABSOLUTELY STOP. NO MORE ACTIONS.**

```markdown
## COMPREHENSIVE DOCUMENTATION GENERATION COMPLETE

### Phase 0: Specification Workflow (6 documents)
- ✅ `.claude/docs/$BRANCH/USER-JOURNEYS.md` - [N] journeys, [N] steps
- ✅ `.claude/docs/$BRANCH/REQUIREMENTS.md` - [N] atomic EARS requirements
- ✅ `.claude/docs/$BRANCH/TDD-STRATEGY.md` - [N] test scenarios
- ✅ `.claude/docs/$BRANCH/features/*.feature` - [N] Gherkin feature files
- ✅ `.claude/docs/$BRANCH/TRACEABILITY-MATRIX.md` - 100% coverage verification
- ✅ `.claude/docs/$BRANCH/VERIFICATION-REPORT.md` - Quality assurance

### Phase 1-5: Project Documentation (11 documents)
- ✅ `.claude/CLAUDE.md` - Project configuration
- ✅ `.claude/docs/$BRANCH/PROJECT-PLAN.md` (v2) - Complete project context
- ✅ `.claude/docs/$BRANCH/SPECIFICATIONS.md` - [N] atomic specifications
- ✅ `.claude/docs/$BRANCH/RISKS-AND-MITIGATIONS.md` - Risk analysis
- ✅ `.claude/docs/$BRANCH/IMPLEMENTATION-ROADMAP.md` - Step-by-step with checkpoints
- ✅ `.claude/docs/$BRANCH/TDD-MASTER-DOCUMENT.md` - All test cases
- ✅ `.claude/docs/$BRANCH/TEST-FIXTURES.md` - Test data fixtures
- ✅ `.claude/docs/$BRANCH/INTEGRATION-TESTS.md` - Cross-specification tests
- ✅ `.claude/docs/$BRANCH/DEPENDENCY-GRAPH.md` - Specification dependencies
- ✅ `.claude/docs/$BRANCH/PARALLEL-GROUPS.md` - Parallel execution groups
- ✅ `.claude/docs/$BRANCH/CRITICAL-PATH.md` - Implementation priority
- ✅ `.claude/docs/$BRANCH/GIT-STRATEGY.md` - Git workflow

### Helper Scripts (3 files)
- ✅ `.claude/scripts/setup-env.sh` - Environment setup
- ✅ `.claude/scripts/quality-gate.sh` - Quality verification
- ✅ `.claude/scripts/validate-planning.sh` - Planning validation

### Statistics:
- **Total Documents**: 17 (6 spec-workflow + 11 project docs)
- **Total Scripts**: 3
- **Specification Iterations**: [N] passes
- **Total Specifications**: [N]
- **Critical Path Specs**: [N]
- **Parallel Groups**: [N]
- **Total Test Cases**: [N]
- **Integration Tests**: [N]
- **Gherkin Scenarios**: [N]
- **User Journeys**: [N]
- **EARS Requirements**: [N]
- **Traceability Coverage**: 100%

### Validation: ✅ PASSED

---

## ⛔ DOCUMENTATION GENERATION COMPLETE ⛔

The /start-project command is now COMPLETE. NO further actions will be taken.

**Your comprehensive documentation is ready for review.**

### Next Steps (YOU must do these manually):

**Step 1: Review the Complete Documentation**
- Read `.claude/docs/$BRANCH/USER-JOURNEYS.md` for exhaustive user journey analysis
- Read `.claude/docs/$BRANCH/REQUIREMENTS.md` for EARS-formatted requirements
- Read `.claude/docs/$BRANCH/SPECIFICATIONS.md` for atomic specifications
- Read `.claude/docs/$BRANCH/IMPLEMENTATION-ROADMAP.md` for the implementation plan
- Read `.claude/docs/$BRANCH/DEPENDENCY-GRAPH.md` for dependencies
- Review all Gherkin scenarios in `.claude/docs/$BRANCH/features/`

**Step 2: Environment Setup (when ready)**
```bash
bash .claude/scripts/setup-env.sh
```

**Step 3: Begin Implementation (when ready)**
Follow the IMPLEMENTATION-ROADMAP.md step-by-step:
- Start with critical path specifications
- Implement in dependency order
- Run quality gates before each commit
- Follow TDD approach (tests first)
- Verify against Gherkin scenarios

**THIS COMMAND WILL NOT CONTINUE AUTOMATICALLY.**
**You must explicitly begin implementation when you are ready.**
```

---

## Critical Rules

1. **ALWAYS run complete spec-workflow** - Phase 0 is mandatory, no skipping
2. **Complete ALL 17 documentation files** before finishing
3. **Iterate specifications 3-5 times** - don't stop too soon
4. **Specifications must be RIDICULOUSLY small** - when in doubt, split
5. **Every spec needs tests** in TDD-MASTER-DOCUMENT.md
6. **Every test maps to Gherkin** in features/*.feature
7. **Validate all documents** before presenting summary
8. **NEVER write code** - only markdown files and bash scripts
9. **NEVER execute scripts** - only generate them
10. **100% traceability required** - Journey → Requirement → Spec → Test

---

## ⛔ ABSOLUTE STOP - END OF COMMAND ⛔

**After presenting the documentation summary, this command is COMPLETE.**

**DO NOT:**
- ❌ Create any source files (src/, tests/, config files, etc.)
- ❌ Install any dependencies (npm install, yarn, pnpm, etc.)
- ❌ Run any build commands
- ❌ Run any test commands
- ❌ Execute ANY bash commands except mkdir for .claude directories
- ❌ Begin implementation automatically

**THIS COMMAND GENERATES COMPREHENSIVE DOCUMENTATION ONLY.**
**User must begin implementation manually, following the generated roadmap.**

---

## Integration with Other Commands

### Called by /feature-dev
After Phase 3 (Clarifying Questions), /feature-dev can call /start-project to generate comprehensive documentation before architecture design.

### Standalone Usage
Run `/start-project [feature description]` to generate complete documentation from scratch.

### Relationship with /spec-workflow
/start-project ALWAYS runs /spec-workflow as Phase 0. You can also run /spec-workflow standalone if you only need specifications without the full project documentation.

---

*End of start-project command*