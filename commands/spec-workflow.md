---
description: Comprehensive specification workflow with user journey analysis, EARS requirements extraction, Gherkin/BDD generation, and bidirectional traceability verification
argument-hint: Feature description for specification
---

# Specification Workflow

Generate comprehensive specifications from feature description through a 4-phase workflow: user journey analysis, EARS requirements extraction, Gherkin/BDD generation, and traceability verification.

---

## Overview

This command orchestrates the complete specification workflow:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Phase 1       │    │   Phase 2       │    │   Phase 3       │    │   Phase 4       │
│  User Journey   │───▶│  Requirements   │───▶│  TDD Strategy   │───▶│  Verification   │
│   Analysis      │    │   Extraction    │    │   Generation    │    │   & Trace       │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## Prerequisites

Before starting, ensure:
- Feature description is clear
- Documentation directory exists: `.claude/docs/$BRANCH_NAME/`
- If part of `/feature-dev`, branch is already set up

---

## Phase 1: User Journey Analysis

**Goal**: Map EVERY possible path through the feature with exhaustive detail.

**Actions**:

1. **Create todo list** with all phases

2. **Role Discovery**: Identify ALL user roles
   - Primary users (end users, customers)
   - Secondary users (admins, moderators)
   - System actors (workers, schedulers)
   - API consumers (mobile apps, integrations)

3. **Goal Extraction**: For each role, enumerate goals
   - What does this role want to accomplish?
   - What are success/failure criteria?

4. **Entry Point Mapping**: Document all entry points
   - UI routes
   - API endpoints
   - Events/webhooks
   - CLI commands

5. **Path Enumeration**: For each (role, goal, entry):
   - Happy path (ideal flow)
   - ALL decision branches
   - ALL error states with recovery
   - ALL loop-back paths

6. **Edge Case Discovery**:
   - Empty/null/undefined inputs
   - Maximum boundaries
   - Concurrent operations
   - State conflicts
   - Permission violations

7. **Generate Mermaid diagrams**:
   - Flowcharts for paths
   - Sequence diagrams for interactions
   - State diagrams for transitions

**Output**: `.claude/docs/$BRANCH_NAME/USER-JOURNEYS.md`

**Template**: `.claude/docs/templates/USER-JOURNEY-TEMPLATE.md`

---

## Phase 2: Requirements Extraction

**Goal**: Convert journeys to atomic EARS-formatted requirements.

**EARS Patterns**:

| Pattern | Format | Use When |
|---------|--------|----------|
| Ubiquitous | The [system] shall [response] | Always applies |
| Event-Driven | When [trigger], the [system] shall [response] | Triggered by event |
| State-Driven | While [state], the [system] shall [response] | Conditional on state |
| Optional | Where [feature], the [system] shall [response] | Feature is optional |
| Unwanted | The [system] shall not [behavior] | Preventing behavior |

**Actions**:

1. **Convert journey steps** to requirements:
   - Happy path → Ubiquitous
   - Decision points → State-Driven
   - Triggers → Event-Driven
   - Error prevention → Unwanted

2. **Atomic Decomposition Loop** (3-5 iterations):
   ```
   For each requirement:
     - Can this be implemented in a single function?
     - Can this be split into smaller, testable units?
     - Split until "ridiculously small"
   ```

3. **Build dependency graph**:
   - What must exist first?
   - What depends on this?

4. **Assign priorities**:
   - Must-have: Core functionality
   - Should-have: Important but has workaround
   - Nice-to-have: Enhancement

5. **Assign test IDs**: `TEST-XXX-YYY`

**Output**: `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`

**Template**: `.claude/docs/templates/REQUIREMENTS-TEMPLATE-V2.md`

---

## Phase 3: TDD Strategy Generation

**Goal**: Create executable Gherkin specifications.

**EARS to Gherkin Mapping**:

| EARS Pattern | Gherkin Structure |
|--------------|-------------------|
| Ubiquitous | `Given` + `Then` |
| Event-Driven | `When` + `Then` |
| State-Driven | `Given` + `When` + `Then` |
| Optional | `Given` feature enabled |
| Unwanted | `When` + `Then` should NOT |

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
- `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`
- `.claude/docs/$BRANCH_NAME/features/*.feature`

**Template**: `.claude/docs/templates/TDD-STRATEGY-TEMPLATE-V2.md`

---

## Phase 4: Cross-Check Verification

**Goal**: Ensure bidirectional traceability with no orphans.

**Verification Checks**:

1. **Forward Trace**: Journey → Requirement → Test
2. **Backward Trace**: Test → Requirement → Journey
3. **Orphan Detection**: Unlinked artifacts
4. **Coverage Analysis**: Percentage at each layer

**Actions**:

1. **Build traceability graph**:
   ```
   JOURNEY-001 → REQ-001 → TEST-001-001
   ```

2. **Check forward trace**:
   - Every journey step has requirement?
   - Every requirement has tests?

3. **Check backward trace**:
   - Every test maps to requirement?
   - Every requirement maps to journey?

4. **Calculate coverage**:
   - By layer (journey, requirement, test)
   - By priority (must-have, should-have)
   - By type (happy, sad, edge)

5. **Generate verification report** with:
   - Gaps identified
   - Orphans detected
   - Recommendations

**Outputs**:
- `.claude/docs/$BRANCH_NAME/TRACEABILITY-MATRIX.md`
- `.claude/docs/$BRANCH_NAME/VERIFICATION-REPORT.md`

**Template**: `.claude/docs/templates/TRACEABILITY-MATRIX-TEMPLATE.md`

---

## Quality Gates

| Phase | Gate | Action if Failed |
|-------|------|------------------|
| Phase 1 | All roles/goals/paths documented | Complete analysis |
| Phase 2 | All EARS valid, atomic requirements | Continue decomposition |
| Phase 3 | All ACs have Gherkin scenarios | Add missing scenarios |
| Phase 4 | 100% traceability, no orphans | Fix gaps before implementation |

---

## Output Summary

After all phases complete, present:

```markdown
## Specification Workflow Complete

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
[List any gaps or issues]

---

## STOP - User Approval Required

Review the generated specifications before proceeding.

**Next Steps**:
1. Review `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`
2. Review `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`
3. Verify traceability in `TRACEABILITY-MATRIX.md`
4. Request implementation when ready
```

---

## Integration Notes

### Called by /feature-dev
Add after Phase 3 (Clarifying Questions):
```
Phase 3.5: Run /spec-workflow
- User approves specs before architecture design
```

### Called by /bug-fix
Add after Phase 3 (Root Cause Analysis):
```
Phase 3.5: Bug Specification
- Generate BUG-SPECIFICATION.md
- Create regression tests
```

---

## Critical Rules

**ALWAYS:**
- Complete all 4 phases before implementation
- Use valid EARS syntax
- Map every test to requirement
- Include happy, sad, and edge cases
- Verify traceability

**NEVER:**
- Skip phases
- Create requirements without journey context
- Leave orphans in traceability matrix
- Proceed with <100% must-have coverage

---

*End of spec-workflow command*
