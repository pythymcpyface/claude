# Autonomous Development Flow

**Context:** Hospital software development with zero tolerance for bugs. You are the Senior Engineer. Junior developers will implement from your specifications. Any failure means lives are at risk and jobs are lost.

**Goal:** Create specifications so detailed and atomic that implementation is mechanical and cannot fail.

---

## Overview: The Planning Phases

Before any code is written, the following phases must be completed **using Opus** for maximum quality:

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: Initial Requirements Gathering                          │
│   - User input, domain exploration, stakeholder needs           │
├─────────────────────────────────────────────────────────────────┤
│ Phase 2: Project Plan Document (v1)                             │
│   - High-level architecture, technology stack, timeline         │
├─────────────────────────────────────────────────────────────────┤
│ Phase 3: Specification Breakdown (ITERATIVE)                    │
│   - Break down requirements until atomic                        │
│   - Repeat 3-5 times until no further breakdown possible       │
├─────────────────────────────────────────────────────────────────┤
│ Phase 4: Risks & Mitigations Document                          │
│   - Clinical risks, technical risks, operational risks          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 5: Project Plan Update (v2)                               │
│   - Incorporate risks, adjust roadmap, add contingency          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 6: Junior-Developer Roadmap                               │
│   - Step-by-step instructions that cannot be misinterpreted     │
├─────────────────────────────────────────────────────────────────┤
│ Phase 7: Final Specification Review                            │
│   - One more breakdown pass with updated project context        │
├─────────────────────────────────────────────────────────────────┤
│ Phase 8: TDD Master Document                                   │
│   - Test cases for every single specification                  │
├─────────────────────────────────────────────────────────────────┤
│ Phase 9: Ralph Loop Implementation                             │
│   - Execute using detailed specifications and TDD document      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Initial Requirements Gathering

### 1.1 User Input Session

Claude should ask the user:

```
Please describe the software system to be built. Include:

1. **Clinical Context**: Which hospital department? What clinical workflow?
2. **Users**: Who will use this? (doctors, nurses, admins, patients)
3. **Data**: What patient/clinical data is involved?
4. **Integration**: Existing systems to integrate with? (EHR, HL7, FHIR)
5. **Compliance**: HIPAA, FDA, Joint Commission requirements?
6. **Constraints**: Technology restrictions, budget, timeline, team size
7. **Success Definition**: What does "done" look like specifically?
```

### 1.2 Domain Exploration

Using Opus, explore:

```markdown
As a Senior Software Engineer specializing in healthcare systems:

1. Analyze the user's requirements for clinical safety implications
2. Identify ALL stakeholders (patients, clinicians, IT, compliance, legal)
3. Map the clinical workflow step-by-step
4. Identify critical failure points and their consequences
5. Research relevant healthcare standards (HL7 FHIR, HIPAA, IHE profiles)
6. List similar systems and their known failure modes

Output a comprehensive domain analysis document.
```

---

## Phase 2: Project Plan Document (v1)

### 2.1 Create `.claude/docs/PROJECT-PLAN.md`

```markdown
# Project Plan: [Project Name]

**Version:** 1.0
**Status:** Draft
**Last Updated:** [DATE]

## 1. Executive Summary

[One paragraph overview for hospital leadership]

## 2. Clinical Context

### 2.1 Department/Service Line
- Department: [specify]
- Primary Workflow: [describe]
- Patient Population: [describe]

### 2.2 Current State (As-Is)
- Current process: [detailed description]
- Pain points: [list with clinical impact]
- Safety concerns: [list]

### 2.3 Future State (To-Be)
- Proposed solution: [description]
- Clinical benefits: [specific outcomes]
- Safety improvements: [specific]

## 3. Requirements Summary

### 3.1 Functional Requirements
[High-level list from Phase 1]

### 3.2 Non-Functional Requirements
- Performance: [specific metrics]
- Reliability: [uptime, data loss tolerance]
- Security: [HIPAA, encryption, audit]
- Usability: [workflow integration, training needs]
- Scalability: [concurrent users, data volume]
- Maintainability: [documentation, testing]

### 3.3 Regulatory & Compliance
- HIPAA requirements: [list]
- FDA classification (if applicable): [specify]
- Joint Commission standards: [relevant standards]
- Local regulations: [state-specific]

## 4. Technical Approach

### 4.1 Architecture
- Architecture style: [monolith, microservices, event-driven]
- Data storage: [database, caching, backup]
- Integration patterns: [APIs, messaging, file transfers]

### 4.2 Technology Stack
- Backend: [languages, frameworks]
- Frontend: [if applicable]
- Database: [primary, replication, backup]
- Infrastructure: [cloud, on-premise, hybrid]

### 4.3 Development Approach
- Methodology: [agile, waterfall, hybrid]
- Team structure: [roles, responsibilities]
- Development lifecycle: [envs, gates, approvals]

## 5. High-Level Roadmap

### 5.1 Phases
- Phase 1: [description, duration, deliverables]
- Phase 2: [description, duration, deliverables]
- ...

### 5.2 Timeline
- Start date: [estimate]
- Key milestones: [list with dates]
- Go-live target: [estimate]

## 6. Resource Requirements

### 6.1 Team
- Senior Engineer: [you, full-time]
- Junior Developers: [number, experience level]
- QA/Testing: [resources]
- DevOps: [resources]
- Clinical SME: [availability]

### 6.2 Infrastructure
- Development: [environments]
- Testing: [environments]
- Staging: [environments]
- Production: [requirements]

## 7. Risk Summary (High-Level)
[Identified risks at project level - detailed risks in Phase 4]

## 8. Success Criteria

### 8.1 Clinical Success
- [Specific patient outcome improvements]
- [Workflow efficiency gains]

### 8.2 Technical Success
- [Performance metrics]
- [Reliability metrics]
- [Security compliance]

## 9. Assumptions & Constraints

### Assumptions:
[list]

### Constraints:
[list - technical, budget, timeline, regulatory]
```

---

## Phase 3: Specification Breakdown (ITERATIVE)

This is the **most critical phase**. Repeat 3-5 times until specifications are atomic.

### 3.1 First Pass: Functional Requirements Breakdown

Create `.claude/docs/SPECIFICATIONS.md`:

```markdown
# Functional Specifications

## Iteration 1 - First Breakdown

[Break down each requirement from PROJECT-PLAN.md into smaller pieces]

Example transformation:
- "User authentication" becomes:
  - 1.1 Login with username/password
  - 1.2 Password reset workflow
  - 1.3 Session management
  - 1.4 Role-based access control
  - 1.5 Audit logging for auth events
```

### 3.2 Second Pass: Atomic Specification

Using Opus, analyze each specification and ask:

```markdown
For each specification item:

1. **Atomicity Check**: Can this be split into independently testable units?
2. **Dependency Analysis**: What must exist before this can be implemented?
3. **Edge Cases**: What are all possible inputs/states?
4. **Error Conditions**: How can this fail? What should happen?
5. **Integration Points**: What other systems/components does this touch?
6. **Data Impact**: What data is read/written? What are validation rules?
7. **Performance**: Response time requirements? Concurrency considerations?
8. **Security**: Who can access? What auditing is required?
9. **Clinical Safety**: What are failure modes? What are clinical consequences?

If ANY answer reveals complexity, SPLIT the specification further.
```

### 3.3 Third Pass: Junior-Developer Clarity Check

Transform each atomic specification into:

```markdown
## Specification ID: [XX.YY.ZZZ]

### User Story
As a [clinician role],
I want to [action],
So that [clinical benefit].

### Acceptance Criteria
1. [Specific criterion]
2. [Specific criterion]
3. [Specific criterion]

### Functional Specification

**Input:**
- Data format: [exact spec]
- Validation rules: [complete list]
- Required fields: [list]
- Optional fields: [list]
- Constraints: [ranges, patterns]

**Processing:**
- Step 1: [exact algorithm]
- Step 2: [exact algorithm]
- ...
- Decision points: [exact conditions]

**Output:**
- Data format: [exact spec]
- Success response: [exact structure]
- Error responses: [complete list with conditions]

**Database Operations:**
- Tables accessed: [list]
- Read operations: [exact queries]
- Write operations: [exact operations]
- Transactions: [scope and isolation]

**API Contract:**
- Endpoint: [method, path]
- Request: [headers, body schema]
- Response: [all status codes, body schemas]
- Authentication: [required]
- Rate limiting: [specify]

**Error Handling:**
- Error condition 1: [trigger, response, logging, alerting]
- Error condition 2: [trigger, response, logging, alerting]
- ...

**Edge Cases:**
- Edge case 1: [description, handling]
- Edge case 2: [description, handling]
- ...

**Performance Requirements:**
- Response time: [p50, p95, p99]
- Throughput: [requests per second]
- Concurrent users: [number]

**Security Requirements:**
- Authorization: [who can access]
- Data sensitivity: [PHI level]
- Encryption: [at rest, in transit]
- Audit logging: [what, when, who]

**Clinical Safety:**
- Failure mode: [what can go wrong]
- Clinical consequence: [severity]
- Safeguards: [prevention, detection, mitigation]
- Fallback behavior: [what happens on failure]

**Testing Requirements:**
- Unit tests: [number, coverage]
- Integration tests: [scenarios]
- E2E tests: [clinical workflows]
- Performance tests: [scenarios]

**Dependencies:**
- Requires: [specifications]
- Required by: [specifications]

**Implementation Notes for Junior Developers:**
- [Specific guidance on common mistakes]
- [Specific guidance on clinical considerations]
- [Specific guidance on testing approach]
```

### 3.4 Fourth & Fifth Pass: Question Everything

Using Opus, challenge every specification:

```markdown
Review each specification and challenge:

1. **Is this truly atomic?**
   - Can a junior developer implement this independently?
   - Can this be tested independently?
   - Does this have multiple responsibilities?

2. **Is this complete?**
   - What assumptions are implicit?
   - What hasn't been specified?
   - What would a junior developer ask?

3. **Is this unambiguous?**
   - Could this be interpreted multiple ways?
   - Are there vague terms like "appropriate", "reasonable", "as needed"?
   - Are all data types and constraints explicit?

4. **Is this safe?**
   - What's the worst clinical outcome if this is wrong?
   - Have all failure modes been addressed?
   - Are there race conditions? Timing issues? Edge cases?

5. **Is this testable?**
   - Can I write a test that proves this works?
   - Can I write a test that proves this handles all errors?
   - Can I write a test for every edge case?

If ANY answer is "no", REWRITE or SPLIT the specification.
```

---

## Phase 4: Risks & Mitigations Document

### 4.1 Create `.claude/docs/RISKS-AND-MITIGATIONS.md`

```markdown
# Risks & Mitigations

**Version:** 1.0
**Last Updated:** [DATE]

## 1. Clinical Risks

### 1.1 Patient Safety Risks

| Risk ID | Risk | Probability | Impact | Severity | Mitigation | Owner | Status |
|---------|------|-------------|--------|----------|------------|-------|--------|
| C-001 | [Description] | [Low/Med/High] | [1-5] | [PxDxS] | [Actions] | [Who] | [Open/Mitigated] |

**Severity Calculation:**
- PxDxS = Probability × Detection × Severity
- Critical: PxDxS ≥ 100
- High: 50 ≤ PxDxS < 100
- Medium: 10 ≤ PxDxS < 50
- Low: PxDxS < 10

### 1.2 Clinical Workflow Risks

[Analyze how the system integrates into clinical workflows]

### 1.3 Data Integrity Risks

[Analyze risks to data accuracy, completeness, consistency]

## 2. Technical Risks

### 2.1 Architecture Risks

[Single points of failure, scalability limits, complexity]

### 2.2 Implementation Risks

[Knowledge gaps, complexity, coordination]

### 2.3 Technology Risks

[Dependencies, obsolescence, vendor lock-in]

## 3. Operational Risks

### 3.1 Deployment Risks

[Downtime, rollback, data migration]

### 3.2 Maintenance Risks

[Support burden, knowledge transfer, updates]

### 3.3 Performance Risks

[Load handling, response times, resource exhaustion]

## 4. Security & Compliance Risks

### 4.1 HIPAA Violation Risks

[Unauthorized access, data breach, audit failures]

### 4.2 Regulatory Compliance Risks

[FDA, Joint Commission, state regulations]

## 5. Project Risks

### 5.1 Timeline Risks

[Dependencies, unknowns, coordination overhead]

### 5.2 Resource Risks

[Team availability, skill gaps, turnover]

### 5.3 Scope Risks

[Scope creep, requirement changes]

## 6. Mitigation Strategies

### 6.1 Technical Mitigations

[Architecture decisions, patterns, practices]

### 6.2 Process Mitigations

[Reviews, testing, approvals]

### 6.3 Contingency Plans

[What to do when risks materialize]
```

---

## Phase 5: Project Plan Update (v2)

### 5.1 Update `.claude/docs/PROJECT-PLAN.md`

Incorporating insights from:
- Detailed specifications (Phase 3)
- Risk analysis (Phase 4)

Changes to make:
1. Adjust roadmap based on specification complexity
2. Add risk mitigation activities to timeline
3. Add contingency buffers for high-risk items
4. Update team structure based on skill requirements
5. Update technology choices based on non-functional requirements
6. Add specific gates and reviews for clinical safety

### 5.2 Add "Junior Developer Guidance" Section

```markdown
## 10. Guidance for Junior Developers

### 10.1 Safety-First Mindset
- Every line of code affects patient care
- When in doubt, ASK before implementing
- Never make assumptions about clinical workflows

### 10.2 Development Standards
- All code must be reviewed before merge
- All tests must pass before commit
- All specifications must be implemented exactly
- No deviations without explicit approval

### 10.3 What To Do When...

| Situation | Action |
|-----------|--------|
| Specification unclear | Stop, ask Senior Engineer |
| Specification seems wrong | Stop, flag the issue |
| Test is failing | Don't proceed, investigate |
| Not sure about clinical impact | Stop, ask Clinical SME |
| Found a bug | Report immediately, don't fix without approval |
| Need to make an assumption | Don't. Get clarification |

### 10.4 Decision Rights
- Junior Developer: Can implement exactly as specified
- Junior Developer: CAN'T change specifications
- Junior Developer: CAN'T skip tests
- Junior Developer: CAN'T merge without review
- Senior Engineer: All decisions not explicitly delegated
```

---

## Phase 6: Junior-Developer Roadmap

### 6.1 Create `.claude/docs/IMPLEMENTATION-ROADMAP.md`

This document must be so detailed that a junior developer **cannot fail** if they follow it.

```markdown
# Implementation Roadmap

**Audience:** Junior Developers
**Purpose:** Step-by-step implementation instructions
**Critical:** Follow exactly. Do not deviate.

## How to Use This Document

1. **Read the entire roadmap before starting**
2. **Implement specifications in order** - dependencies are pre-calculated
3. **Follow each instruction exactly**
4. **Complete all tests before proceeding**
5. **Mark each item complete when done**

## Pre-Implementation Checklist

- [ ] I have read the PROJECT-PLAN.md
- [ ] I have read the SPECIFICATIONS.md
- [ ] I have read the RISKS-AND-MITIGATIONS.md
- [ ] I understand the clinical context
- [ ] I have set up my development environment
- [ ] I can run the test suite successfully

---

## Phase 1: Foundation (Week 1-2)

### 1.1 Project Setup

**Specification Reference:** SPEC-001

**Steps:**
1. Create repository structure:
   ```
   mkdir -p src/{api,models,services,utils}
   mkdir -p tests/{unit,integration,e2e}
   mkdir -p docs
   ```

2. Initialize package.json:
   ```bash
   npm init -y
   npm install --save-dev typescript @types/node jest ts-jest @types/jest
   npm install fastify @fastify/type-provider-typebox
   ```

3. Configure TypeScript:
   - Create tsconfig.json with strict: true
   - Enable all strict checking options
   - Set target to ES2022
   - Set module to NodeNext

4. Configure Jest:
   - Setup test environment
   - Configure coverage thresholds (80% minimum)
   - Setup test reporters

**Verification:**
- [ ] `npm test` runs successfully (0 tests is ok)
- [ ] `npm run build` compiles without errors
- [ ] TypeScript reports no errors

**DO NOT PROCEED UNTIL ALL CHECKS PASS**

### 1.2 Core Types & Interfaces

**Specification Reference:** SPEC-002, SPEC-003

**Steps:**
1. Create `src/models/types.ts` with exactly these interfaces:
   ```typescript
   [Provide complete, ready-to-copy code]
   ```

2. For each interface:
   - Add JSDoc comments explaining clinical relevance
   - Add validation schemas
   - Add TypeScript strict types

**Verification:**
- [ ] `npm run build` succeeds
- [ ] No TypeScript errors
- [ ] Interfaces match specifications exactly

### 1.3 Error Handling Framework

**Specification Reference:** SPEC-004

**Steps:**
1. Create `src/utils/errors.ts` with error classes:
   ```typescript
   [Provide complete error hierarchy]
   ```

2. Create error handling middleware:
   ```typescript
   [Provide complete middleware code]
   ```

**Verification:**
- [ ] All error types are defined
- [ ] Error handler is tested
- [ ] Errors are logged appropriately

---

## Phase 2: Core Features (Week 3-6)

[Continue with extremely detailed steps for each phase...]

---

## Testing Requirements for Each Specification

For EVERY specification implementation:

1. **Unit Tests** (Required):
   - Test all functions/methods
   - Test all error conditions
   - Test edge cases
   - Minimum 80% code coverage

2. **Integration Tests** (Required):
   - Test component interactions
   - Test database operations
   - Test API endpoints

3. **E2E Tests** (Required for clinical workflows):
   - Test complete clinical scenarios
   - Test error recovery
   - Test performance under load

## Code Review Checklist

Before marking any item complete:

- [ ] Code follows specifications exactly
- [ ] All tests pass
- [ ] No TypeScript errors
- [ ] No ESLint warnings
- [ ] Clinical safety reviewed
- [ ] Security reviewed
- [ ] Performance reviewed
- [ ] Documentation complete

## Sign-Off Required

Each phase requires:
- [ ] Self-review complete
- [ ] Peer review complete (if applicable)
- [ ] Senior Engineer approval
- [ ] Tests passing
- [ ] Documentation updated
```

---

## Phase 7: Final Specification Review

### 7.1 One More Breakdown Pass

Now that the project plan is complete and risks are understood, review specifications ONE MORE TIME:

```markdown
For each specification, considering the complete project context:

1. **Does this specification account for all identified risks?**
   - Are mitigations implemented?
   - Are edge cases covered?

2. **Can a junior developer implement this without questions?**
   - Is everything specified?
   - Are all decisions made?

3. **Is this testable to hospital standards?**
   - Can we prove this works in all scenarios?
   - Can we demonstrate safety?

4. **Is this compatible with the overall architecture?**
   - Does it integrate correctly?
   - Are dependencies satisfied?

If ANY answer is "no", UPDATE or SPLIT the specification.
```

---

## Phase 8: TDD Master Document

### 8.1 Create `.claude/docs/TDD-MASTER-DOCUMENT.md`

This document contains **every test case** for **every specification**.

```markdown
# Test-Driven Development Master Document

**Purpose:** Complete test specification for all functional requirements
**Standard:** Every specification must have corresponding tests
**Coverage:** 100% of clinical code paths, 80% overall minimum

## Test Organization

```
tests/
├── unit/
│   ├── models/
│   ├── services/
│   ├── api/
│   └── utils/
├── integration/
│   ├── database/
│   ├── api/
│   └── services/
└── e2e/
    ├── clinical-workflows/
    ├── error-scenarios/
    └── performance/
```

## Test Template

For each specification, use this template:

```typescript
describe('SPEC-[ID]: [Specification Title]', () => {
  describe('Acceptance Criteria', () => {
    it('AC1: [First acceptance criterion]', () => {
      // Arrange
      // Act
      // Assert
    });

    it('AC2: [Second acceptance criterion]', () => {
      // ...
    });
  });

  describe('Happy Path', () => {
    it('should [expected behavior] with valid input', () => {
      // Test case
    });
  });

  describe('Error Conditions', () => {
    it('should handle [error condition]', () => {
      // Test case
    });

    it('should log and alert on [critical error]', () => {
      // Test case
    });
  });

  describe('Edge Cases', () => {
    it('should handle [edge case]', () => {
      // Test case
    });
  });

  describe('Clinical Safety', () => {
    it('should not corrupt data on failure', () => {
      // Test case
    });

    it('should maintain audit trail', () => {
      // Test case
    });
  });

  describe('Security', () => {
    it('should reject unauthorized access', () => {
      // Test case
    });

    it('should log all access', () => {
      // Test case
    });
  });

  describe('Performance', () => {
    it('should respond within [SLA]', () => {
      // Test case with performance assertion
    });
  });
});
```

---

## Test Specifications by Specification

### SPEC-001: Project Setup

**Unit Tests:**
```typescript
describe('Configuration', () => {
  it('should load environment variables', () => {
    // Test
  });

  it('should validate required environment variables', () => {
    // Test
  });

  it('should fail with clear error on missing required config', () => {
    // Test
  });
});
```

### SPEC-002: Core Types

**Unit Tests:**
```typescript
describe('Note Model', () => {
  describe('Validation', () => {
    it('should accept valid note', () => {
      // Test
    });

    it('should reject note with title > 200 chars', () => {
      // Test with 201 character title
      // Assert validation error
    });

    it('should reject note with content > 5000 chars', () => {
      // Test with 5001 character content
      // Assert validation error
    });

    it('should reject note without title', () => {
      // Test with empty title
      // Assert validation error
    });

    it('should accept note without content (optional)', () => {
      // Test with null content
      // Assert valid
    });
  });

  describe('Edge Cases', () => {
    it('should handle unicode characters', () => {
      // Test with emojis, international text
    });

    it('should handle special characters', () => {
      // Test with HTML, SQL injection attempts
    });

    it('should handle whitespace-only input', () => {
      // Test with spaces, tabs, newlines
    });
  });

  describe('Clinical Safety', () => {
    it('should preserve data integrity', () => {
      // Test round-trip serialization
    });

    it('should sanitize malicious input', () => {
      // Test XSS, injection attempts
    });
  });
});
```

### SPEC-003: Note Creation API

**Unit Tests:**
```typescript
describe('POST /notes', () => {
  describe('Authentication', () => {
    it('should reject request without auth token', () => {
      // Test
    });

    it('should reject request with invalid token', () => {
      // Test
    });

    it('should accept request with valid token', () => {
      // Test
    });
  });

  describe('Validation', () => {
    it('should reject missing title', () => {
      // Test
    });

    it('should reject oversized title', () => {
      // Test
    });

    it('should reject oversized content', () => {
      // Test
    });

    it('should accept valid note', () => {
      // Test
    });
  });

  describe('Processing', () => {
    it('should generate unique ID', () => {
      // Test two consecutive creates, verify IDs differ
    });

    it('should set created timestamp', () => {
      // Test timestamp is set and reasonable
    });

    it('should associate with authenticated user', () => {
      // Test user ID is captured
    });
  });

  describe('Response', () => {
    it('should return 201 on success', () => {
      // Test
    });

    it('should return created note in response', () => {
      // Test response structure
    });

    it('should return 400 on validation error', () => {
      // Test
    });

    it('should return 401 on auth failure', () => {
      // Test
    });

    it('should return 500 on database error', () => {
      // Test with mocked DB failure
    });
  });

  describe('Audit Logging', () => {
    it('should log note creation event', () => {
      // Test audit log is written
    });

    it('should include user ID in log', () => {
      // Test
    });

    it('should include timestamp in log', () => {
      // Test
    });

    it('should include note ID in log', () => {
      // Test
    });
  });
});
```

**Integration Tests:**
```typescript
describe('POST /notes Integration', () => {
  it('should persist note to database', async () => {
    // Create note via API
    // Query database directly
    // Assert note exists with correct data
  });

  it('should handle concurrent note creation', async () => {
    // Create 100 notes concurrently
    // Assert all succeed
    // Assert all IDs are unique
  });

  it('should rollback on error', async () => {
    // Test with database error mid-transaction
    // Assert no partial data written
  });
});
```

**E2E Tests:**
```typescript
describe('Clinical Workflow: Create Note', () => {
  it('should allow clinician to create patient note', async () => {
    // Simulate clinician login
    // Navigate to patient
    // Create note
    // Verify note appears in patient record
  });

  it('should allow creation during active patient encounter', async () => {
    // Simulate active encounter
    // Create note
    // Verify note linked to encounter
  });
});
```

---

## Complete Test Matrix

| Spec ID | Specification | Unit Tests | Integration Tests | E2E Tests | Performance Tests | Security Tests |
|---------|--------------|------------|-------------------|-----------|-------------------|----------------|
| SPEC-001 | Project Setup | 5 | 2 | 0 | 0 | 0 |
| SPEC-002 | Core Types | 15 | 3 | 0 | 0 | 5 |
| SPEC-003 | Note Creation | 20 | 5 | 2 | 1 | 3 |
| ... | ... | ... | ... | ... | ... | ... |

**Total Test Count:** [Calculate total]

**Minimum Coverage Targets:**
- Clinical code paths: 100%
- All code: 80%
- Security-critical code: 100%

---

## Test Data Strategy

### Test Data Fixtures

```typescript
// tests/fixtures/notes.ts
export const validNotes = {
  minimal: { title: 'Test Note' },
  withContent: { title: 'Test Note', content: 'Test Content' },
  maxLength: {
    title: 'X'.repeat(200),
    content: 'X'.repeat(5000)
  },
  // ... more fixtures
};

export const invalidNotes = {
  noTitle: { content: 'No title' },
  oversizeTitle: { title: 'X'.repeat(201) },
  oversizeContent: { title: 'Valid', content: 'X'.repeat(5001) },
  // ... more fixtures
};
```

### Clinical Scenarios

```typescript
// tests/fixtures/clinical-scenarios.ts
export const clinicalScenarios = {
  emergencyAdmission: {
    // Complete patient context
    // Workflow steps
    // Expected outcomes
  },
  // ... more scenarios
};
```

---

## Performance Test Specifications

For each API endpoint:

```typescript
describe('Performance: POST /notes', () => {
  it('should respond within 100ms at p50', async () => {
    // Test with 100 requests
    // Assert median < 100ms
  });

  it('should respond within 500ms at p95', async () => {
    // Test with 1000 requests
    // Assert 95th percentile < 500ms
  });

  it('should handle 100 concurrent requests', async () => {
    // Test concurrent load
    // Assert all succeed
    // Assert no data corruption
  });
});
```

---

## Security Test Specifications

For each specification touching sensitive data:

```typescript
describe('Security: Note Access', () => {
  it('should prevent accessing another user\\'s notes', () => {
    // Create note as user A
    // Attempt access as user B
    // Assert 403 Forbidden
  });

  it('should prevent SQL injection in note content', () => {
    // Attempt SQL injection
    // Assert content stored as-is, not executed
  });

  it('should sanitize XSS in note content', () => {
    // Attempt XSS injection
    // Assert content is escaped on retrieval
  });

  it('should log all access attempts', () => {
    // Access note
    // Verify audit log entry
  });

  it('should log all unauthorized attempts', () => {
    // Attempt unauthorized access
    // Verify security log entry
  });
});
```

---

## Test Execution Order

**Critical:** Tests must run in this order for clinical workflow validation:

1. Unit Tests (fast, isolated)
2. Integration Tests (database, API)
3. Security Tests (authorization, injection)
4. Performance Tests (load, stress)
5. E2E Tests (clinical workflows)

**No specification is complete until ALL its tests pass.**
```

---

## Phase 9: Ralph Loop Implementation

### 9.1 The Final Ralph Loop Prompt

Once all planning documents are complete and verified, start Ralph Loop:

```bash
/ralph-loop "
You are implementing a hospital software system with ZERO tolerance for bugs.

# CRITICAL CONTEXT
- Hospital setting: Patient lives depend on correct code
- You are the Senior Engineer
- Junior developers will implement from your specifications
- Any bug means people die and families lose their livelihood

# MANDATORY READING (Read in order)
1. .claude/docs/PROJECT-PLAN.md - Complete project context
2. .claude/docs/SPECIFICATIONS.md - Every atomic specification
3. .claude/docs/RISKS-AND-MITIGATIONS.md - Every risk
4. .claude/docs/IMPLEMENTATION-ROADMAP.md - Step-by-step instructions
5. .claude/docs/TDD-MASTER-DOCUMENT.md - Every test case

# STRICT TDD PROCESS (Never Deviate)

For EACH specification in IMPLEMENTATION-ROADMAP.md order:

## Step 1: Read Specification
- Read the complete specification from SPECIFICATIONS.md
- Read corresponding tests from TDD-MASTER-DOCUMENT.md
- Understand ALL acceptance criteria

## Step 2: Write Failing Tests
- Write ALL tests for this specification
- Run tests: npm test
- Verify tests FAIL (red)
- If tests pass, you wrote them wrong - fix them

## Step 3: Read Related Code
- Read all files this specification depends on
- Understand existing patterns
- Maintain consistency

## Step 4: Implement Specification
- Write MINIMAL code to pass tests
- Follow specification EXACTLY
- No extra features
- No shortcuts

## Step 5: Verify Tests Pass
- Run tests: npm test
- Verify ALL tests pass (green)
- If any fail, fix the code (not the tests)

## Step 6: Clinical Safety Review
- Read the code you just wrote
- Ask: What could go wrong?
- Ask: What are the clinical consequences?
- If any safety concern exists, address it NOW

## Step 7: Code Quality Checks
- Run: npm run lint
- Run: npm run type-check
- Fix any issues

## Step 8: Update Progress
- Update .claude/docs/PROGRESS.md
- Mark specification complete
- Note any issues encountered

## Step 9: Git Commit
- git add .
- git commit -m \\"feat(spec-SPEC-ID): [specification title]\\"
- Never commit broken tests

## Step 10: Repeat
- Move to next specification in IMPLEMENTATION-ROADMAP.md
- Repeat from Step 1

# QUALITY GATES

## Before Moving to Next Phase:
1. ALL tests pass (npm test)
2. No TypeScript errors
3. No lint warnings
4. Code review (use /review-pr code tests errors)
5. Performance tests pass
6. Security tests pass

## If Any Quality Gate Fails:
1. STOP
2. Identify the failure
3. Fix the issue
4. Verify all tests still pass
5. Only then continue

# TOOLS AVAILABLE
- /review-pr code tests - Comprehensive review
- code-explorer agent - Understand existing code
- code-simplifier agent - Improve code quality
- code-reviewer agent - Final quality check

# ABSOLUTE RULES
1. NEVER skip tests
2. NEVER commit broken code
3. NEVER deviate from specifications
4. NEVER guess - if unsure, note it in PROGRESS.md
5. NEVER implement features not in specifications
6. ALWAYS consider clinical safety first
7. ALWAYS write tests before code
8. ALWAYS verify all tests pass before committing

# COMPLETION
Output <promise>HOSPITAL_SYSTEM_COMPLETE</promise> ONLY when:
- ALL specifications from SPECIFICATIONS.md are implemented
- ALL tests from TDD-MASTER-DOCUMENT.md pass
- PROGRESS.md shows 100% completion
- Code review passes with no critical issues
- Clinical safety verified

Begin with the first specification in IMPLEMENTATION-ROADMAP.md (Phase 1, Foundation).
" --max-iterations 200
```

---

## Summary: Document Structure

After completing all phases, your project will have:

```
.claude/docs/
├── PROJECT-PLAN.md              # Complete project context (v2)
├── SPECIFICATIONS.md            # Atomic, complete specifications
├── RISKS-AND-MITIGATIONS.md     # All risks and mitigations
├── IMPLEMENTATION-ROADMAP.md    # Junior-proof step-by-step guide
├── TDD-MASTER-DOCUMENT.md       # Every test case for every spec
└── PROGRESS.md                  # Tracking (created during Ralph Loop)
```

**Each document links to others. Each specification references risks. Each test references specifications.**

**The result: Junior developers can implement without failure because every decision is made, every risk is mitigated, and every test is specified.**

---

**Remember:** You are the Senior Engineer. The hospital and your team depend on you. Take the time to plan thoroughly. Lives depend on it.
