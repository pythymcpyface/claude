---
name: spec-workflow
description: Comprehensive specification workflow with user journey analysis, EARS requirements extraction, Gherkin/BDD generation, and bidirectional traceability verification.
---

# Specification Workflow Skill

Master orchestration skill for comprehensive specification generation. Coordinates four phases of analysis to produce exhaustive, testable specifications.

---

## Overview

This skill implements a 4-phase specification workflow:

1. **Phase 1: User Journey Analysis** - Map every possible path through the application
2. **Phase 2: Requirements Extraction** - Convert journeys to atomic EARS-formatted requirements
3. **Phase 3: TDD Strategy Generation** - Create executable Gherkin/BDD specifications
4. **Phase 4: Cross-Check Verification** - Ensure bidirectional traceability

---

## When to Use

Invoke this skill when:
- Starting a new feature implementation
- Documenting existing functionality
- Creating comprehensive test coverage
- Ensuring requirement traceability
- Debugging specification gaps

---

## Phase 1: User Journey Analysis

**Agent**: `journey-analyzer`

**Purpose**: Map EVERY possible path through the application with exhaustive detail.

**Steps**:
1. **Role Discovery**: List ALL user roles (primary, secondary, admin, system, API consumers)
2. **Goal Extraction**: For each role, enumerate ALL goals with success criteria
3. **Entry Point Mapping**: UI routes, API endpoints, Events, Integrations, CLI commands
4. **Path Enumeration**: For each (role, goal, entry) combination:
   - Happy path (ideal flow)
   - ALL decision branches (if/else at each step)
   - ALL error states and recovery paths
   - ALL loop-back paths (retry, undo, restart)
5. **Edge Case Discovery**:
   - Empty/null/undefined inputs
   - Maximum boundaries (length, count, size)
   - Concurrent operations
   - State conflicts
   - Permission violations

**Output Files**:
- `USER-JOURNEYS.md`
- `JOURNEY-MAP.mermaid`
- `ROLE-MATRIX.md`

**Template**: `.claude/docs/templates/USER-JOURNEY-TEMPLATE.md`

---

## Phase 2: Requirements Extraction

**Agent**: `requirements-extractor`

**Purpose**: Convert journeys to atomic EARS-formatted requirements.

**EARS Patterns**:
| Pattern | Format | Use When |
|---------|--------|----------|
| Ubiquitous | The [system] shall [response] | Always applies |
| Event-Driven | When [trigger], the [system] shall [response] | Triggered by event |
| State-Driven | While [state], the [system] shall [response] | Conditional on state |
| Optional | Where [feature], the [system] shall [response] | Feature is optional |
| Unwanted | The [system] shall not [behavior] | Preventing behavior |

**Steps**:
1. Convert each journey step to requirement(s)
2. Convert each decision point to conditional requirements
3. Convert each error state to error handling requirements
4. Convert each edge case to boundary requirements
5. **Atomic Decomposition Loop** (3-5 passes): Split until single-function
6. Build dependency graph

**Output Files**:
- `REQUIREMENTS.md` (EARS format)
- `REQUIREMENT-DEPENDENCIES.mermaid`
- `REQUIREMENT-MATRIX.md`

**Template**: `.claude/docs/templates/REQUIREMENTS-TEMPLATE-V2.md`

---

## Phase 3: TDD Strategy Generation

**Agent**: `gherkin-generator`

**Purpose**: Create executable Gherkin specifications.

**EARS to Gherkin Mapping**:
| EARS Pattern | Gherkin Mapping |
|--------------|-----------------|
| Ubiquitous | `Given` (precondition) + `Then` (expected) |
| Event-Driven | `When` (trigger) + `Then` (response) |
| State-Driven | `Given` (state) + `When` + `Then` |
| Optional | `Given` (feature enabled) + `When/Then` |
| Unwanted | `When` (condition) + `Then` (should not) |

**Steps**:
1. Create feature files by requirement group
2. Generate scenarios for each acceptance criterion
3. Happy path, sad path, edge case coverage
4. Map test IDs to requirement IDs
5. Define test fixtures and mocks

**Output Files**:
- `TDD-STRATEGY.md`
- `features/*.feature`
- `STEP-DEFINITIONS.md`

**Template**: `.claude/docs/templates/TDD-STRATEGY-TEMPLATE-V2.md`

---

## Phase 4: Cross-Check Verification

**Agent**: `traceability-verifier`

**Purpose**: Ensure bidirectional traceability and no orphaned artifacts.

**Verification Checks**:
1. **Forward**: Journey → Requirement → Test
2. **Backward**: Test → Requirement → Journey
3. **Orphan Detection**:
   - Journeys without requirements
   - Requirements without tests
   - Tests without requirements
4. **Coverage Analysis**: Percentage coverage per layer

**Output Files**:
- `TRACEABILITY-MATRIX.md`
- `VERIFICATION-REPORT.md`

**Template**: `.claude/docs/templates/TRACEABILITY-MATRIX-TEMPLATE.md`

---

## Quality Gates

| Phase | Gate |
|-------|------|
| Phase 1 | All roles, goals, paths documented |
| Phase 2 | All EARS patterns valid, atomic requirements |
| Phase 3 | All ACs have Gherkin scenarios |
| Phase 4 | 100% traceability, no orphans |

---

## Integration Points

### With /feature-dev
Add after Phase 3 (Clarifying Questions):
- Invoke `/spec-workflow` to generate comprehensive specs
- User approves before proceeding to architecture

### With /bug-fix
Add after Phase 3 (Root Cause Analysis):
- Generate BUG-SPECIFICATION.md using EARS
- Create regression test Gherkin scenarios
- Map to original journey if applicable

---

## Quick Reference

### Output Directory Structure
```
.claude/docs/$BRANCH_NAME/
├── USER-JOURNEYS.md
├── JOURNEY-MAP.mermaid
├── ROLE-MATRIX.md
├── REQUIREMENTS.md
├── REQUIREMENT-DEPENDENCIES.mermaid
├── REQUIREMENT-MATRIX.md
├── TDD-STRATEGY.md
├── TRACEABILITY-MATRIX.md
├── VERIFICATION-REPORT.md
└── features/
    ├── auth.feature
    └── ...
```

### Templates Location
- `.claude/docs/templates/USER-JOURNEY-TEMPLATE.md`
- `.claude/docs/templates/REQUIREMENTS-TEMPLATE-V2.md`
- `.claude/docs/templates/TDD-STRATEGY-TEMPLATE-V2.md`
- `.claude/docs/templates/FEATURE-TEMPLATE.md`
- `.claude/docs/templates/TRACEABILITY-MATRIX-TEMPLATE.md`
- `.claude/docs/templates/BUG-SPECIFICATION-TEMPLATE.md`

---

## Critical Rules

**ALWAYS:**
- Complete all 4 phases before implementation
- Use valid EARS syntax for requirements
- Map every test to a requirement
- Include happy, sad, and edge case tests
- Verify bidirectional traceability

**NEVER:**
- Skip phases
- Create requirements without journey context
- Write tests without requirement IDs
- Leave orphans in traceability matrix
- Proceed to implementation with <100% coverage

---

*End of SPEC-WORKFLOW skill*
