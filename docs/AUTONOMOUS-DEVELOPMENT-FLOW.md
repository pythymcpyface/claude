# Autonomous Development Flow

**Context:** You are the Senior Engineer creating detailed specifications for implementation by junior developers.

**Goal:** Create specifications so detailed and atomic that implementation is mechanical and cannot fail.

---

## Flow Trigger: Documentation Generation vs Implementation Planning

**IMPORTANT: Distinguish between documentation generation and implementation planning.**

### /start-project = Documentation Generation ONLY

When `/start-project` is invoked:
- **DO NOT enter Plan Mode**
- Read existing research/feasibility documents
- Generate `.claude/docs/*.md` planning documents
- Present summary and STOP
- NO implementation plans
- NO code generation

### Implementation Planning = Enter Plan Mode

**ONLY enter Plan Mode when:**
- User explicitly asks to plan implementation of a specification
- User asks to "implement" or "build" a specific feature
- `/feature-dev` or `/bug-fix` commands are invoked

**IMPORTANT:** /start-project generates documentation, NOT implementation plans.

---

## Documentation Generation Flow

When `/start-project` is invoked, follow these steps:

1. Read existing research/feasibility documents in the project
2. Generate `.claude/CLAUDE.md` with project context
3. Create `.claude/docs/` directory if it doesn't exist
4. Proceed through Phases 2-8.5 to generate ALL planning documents

**⚠️ ABSOLUTE STOP POINT AFTER PHASE 8.5**
- Phase 8.5 (Planning Validation) is the END of autonomous planning
- DO NOT proceed to Phase 0 (Environment Setup) automatically
- DO NOT proceed to Phase 9 (Ralph Loop) automatically
- DO NOT create source files (src/, tests/, etc.)
- DO NOT create config files (tsconfig.json, jest.config.js, etc.)
- DO NOT install dependencies (npm install, yarn, pnpm, etc.)
- DO NOT run build commands (npm run build, tsc, etc.)
- DO NOT run test commands (npm test, jest, etc.)
- DO NOT run setup-env.sh - USER must do this manually
- DO NOT start /ralph-loop - USER must do this manually
- PRESENT SUMMARY AND STOP - WAIT for user to proceed

**The ONLY files created during this flow are:**
- `.claude/CLAUDE.md`
- `.claude/docs/*.md` (planning documents only)
- `.claude/scripts/*.sh` (setup and validation scripts only, NOT executed)

This happens automatically - no additional user prompt required for documentation generation.

---

## Overview: The Planning Phases

Before any code is written, the following phases must be completed **using Opus** for maximum quality:

```
┌─────────────────────────────────────────────────────────────────┐
│ AUTONOMOUS PLANNING PHASE (Complete Automatic Execution)      │
├─────────────────────────────────────────────────────────────────┤
│ Phase 1: Initial Requirements Gathering (In Plan Mode)         │
│   - User input via AskUserQuestion, domain exploration         │
├─────────────────────────────────────────────────────────────────┤
│ Phase 2: Project Plan Document (v1) (In Plan Mode)          │
│   - High-level architecture, technology stack, timeline         │
├─────────────────────────────────────────────────────────────────┤
│ PLAN MODE EXIT → AUTOMATIC: Generate Project Documentation     │
│   - Create .claude/CLAUDE.md, PROJECT-PLAN.md, etc.       │
├─────────────────────────────────────────────────────────────────┤
│ Phase 3: Specification Breakdown (ITERATIVE, 3-5 times)     │
│   - Break down requirements until atomic                        │
│   - Generate DEPENDENCY-GRAPH.md from spec dependencies       │
│   - Specifications must be SO SMALL they seem ridiculous     │
├─────────────────────────────────────────────────────────────────┤
│ Phase 4: Risks & Mitigations Document                      │
│   - Technical, operational, security, project risks           │
├─────────────────────────────────────────────────────────────────┤
│ Phase 5: Project Plan Update (v2)                           │
│   - Incorporate risks, adjust roadmap, add contingency       │
├─────────────────────────────────────────────────────────────────┤
│ Phase 6: Junior-Developer Roadmap with CHECKPOINTS           │
│   - Step-by-step instructions with user review checkpoints    │
│   - Generate PARALLEL-GROUPS.md for concurrent implementation│
├─────────────────────────────────────────────────────────────────┤
│ Phase 7: Final Specification Review                          │
│   - One more breakdown pass with complete context             │
│   - Identify CRITICAL-PATH specs (blocks others)             │
├─────────────────────────────────────────────────────────────────┤
│ Phase 8: TDD Master Document                               │
│   - Test cases for every single specification                │
│   - Generate TEST-FIXTURES.md with test data                │
│   - Generate INTEGRATION-TESTS.md for cross-spec tests      │
├─────────────────────────────────────────────────────────────────┤
│ Phase 8.5: Planning Validation                               │
│   - Validate all documents are complete and consistent        │
│   - Check all specs have tests, dependencies resolve        │
│   - Present summary to user for approval                     │
├─────────────────────────────────────────────────────────────────┤
│ ⚠️ DOCUMENTATION COMPLETE - ABSOLUTE STOP POINT ⚠️          │
│                                                               │
│ Planning phase complete. NO automatic continuation.               │
│ User must manually proceed to implementation phases.             │
└─────────────────────────────────────────────────────────────────┘

                    [User must manually continue]

┌─────────────────────────────────────────────────────────────────┐
│ OPTIONAL MANUAL IMPLEMENTATION PHASE                           │
│ (Requires explicit user commands to start)                      │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0: Environment Setup (Manual: bash .claude/scripts/...) │
│   - Run setup-env.sh to initialize project structure           │
│   - Install dependencies, create directories                    │
├─────────────────────────────────────────────────────────────────┤
│ Phase 9: Ralph Loop Implementation (Manual: /ralph-loop)     │
│   - Execute with CHECKPOINTS for user review                   │
│   - Generate PROGRESS.md with live status                       │
│   - Resume capability via --resume-from flag                    │
│   - Quality gates before each commit                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Read Existing Research Documents

**Note:** /start-project reads existing research/feasibility documents, it does NOT gather requirements via AskUserQuestion.

### 1.1 Discover Research Documents

```bash
# Find research/feasibility documents
Glob -pattern "*.md" -path .
Grep -pattern "research|feasibility|requirements" -glob "*.md" -i
```

### 1.2 Read and Extract Requirements

Read discovered documents and extract:
- System context and function
- User roles and workflows
- Data requirements
- Integration requirements
- Compliance requirements
- Technical constraints
- Success criteria

### 1.3 Clarification (If Needed)

If research documents are incomplete, use `AskUserQuestion` to gather missing information:

```
Please describe the software system to be built. Include:

1. **Context**: What function does this support? What workflow?
2. **Users**: Who will use this? (roles, access levels, external systems)
3. **Data**: What data is involved? (sensitivity, volume, retention)
4. **Integration**: Existing systems to integrate with? (APIs, databases, messaging)
5. **Compliance**: Regulatory requirements? (industry standards, internal policies)
6. **Constraints**: Technology restrictions, budget, timeline, team size
7. **Success Definition**: What does "done" look like specifically?
```

### 1.2 Domain Exploration

Using Opus, explore:

```markdown
As a Senior Software Engineer:

1. Analyze the user's requirements for system impact implications
2. Identify ALL stakeholders (end users, operations, compliance, legal, leadership)
3. Map the workflow step-by-step
4. Identify failure points and their consequences
5. Research relevant standards and regulatory requirements
6. List similar systems and their known failure modes

Output a comprehensive domain analysis document.
```

---

## Phase 1 Complete: Generate Project CLAUDE.md

After reading all research documents, **AUTOMATICALLY generate** the project-specific CLAUDE.md file.

### 1.1 Create `.claude/CLAUDE.md` IMMEDIATELY After Plan Mode Exit

This file MUST be created as the FIRST action after plan mode completes. It should contain:

```markdown
# Project: [Project Name from PROJECT-PLAN.md]

## Project Context
[Brief description from PROJECT-PLAN.md Executive Summary]

## Stack
- **Language**: [from PROJECT-PLAN.md Technology Stack section]
- **Frameworks**: [from PROJECT-PLAN.md Technology Stack section]
- **Database/ORM**: [if applicable - from PROJECT-PLAN.md]
- **Testing**: [from PROJECT-PLAN.md Development Approach]

## Key Directories
- Source: [to be determined based on stack]
- Tests: [to be determined based on stack]
- Documentation: docs/

## Project Documentation References
- `.claude/docs/PROJECT-PLAN.md` - Complete project context
- `.claude/docs/SPECIFICATIONS.md` - Atomic specifications
- `.claude/docs/RISKS-AND-MITIGATIONS.md` - Risk analysis
- `.claude/docs/IMPLEMENTATION-ROADMAP.md` - Step-by-step implementation guide
- `.claude/docs/TDD-MASTER-DOCUMENT.md` - All test cases
- `.claude/docs/TEST-FIXTURES.md` - Test data fixtures
- `.claude/docs/INTEGRATION-TESTS.md` - Cross-specification tests
- `.claude/docs/DEPENDENCY-GRAPH.md` - Specification dependencies
- `.claude/docs/PARALLEL-GROUPS.md` - Parallel execution groups
- `.claude/docs/CRITICAL-PATH.md` - Implementation priority
- `.claude/docs/GIT-STRATEGY.md` - Git workflow and conventions

## Development Standards
- Follow specifications exactly - no deviations
- All tests must pass before committing
- TDD approach: write tests first, then implementation
- When in doubt, consult the project documentation

## Quality Gates
- No TypeScript errors (if applicable)
- No lint warnings
- Test coverage >80% on business logic
- Code review before merge

---

*Auto-generated from planning documents. Edit to add project-specific notes.*
```

### 1.2 Automatic Generation (MANDATORY)

**CRITICAL: These actions happen IMMEDIATELY and AUTOMATICALLY after reading research documents.**

Execute these steps AUTOMATICALLY without waiting for user input:

```markdown
# AUTOMATIC Post-Plan Mode Actions (Execute Immediately)

## Step 1: Create Directory Structure
```bash
mkdir -p .claude/docs
mkdir -p .claude/scripts
```

## Step 2: Generate .claude/CLAUDE.md IMMEDIATELY
[Using the template in section 1.1 above, populate with gathered information from plan mode]

## Step 3: Generate .claude/docs/PROJECT-PLAN.md
[Using the template in Phase 2, populate with gathered information from plan mode]

## Step 4: Confirm to User
"Project CLAUDE.md and initial PROJECT-PLAN.md created. Ready to proceed with Phase 3: Specification Breakdown."
```

**DO NOT WAIT for user confirmation. Execute these steps automatically.**

### 1.3 CLAUDE.md Content Based on Research Documents

The CLAUDE.md MUST be generated based on:
- Project name from research documents
- Technology stack from research documents
- All references to planning documents (updated as each is created)

**Important:** The CLAUDE.md is created AUTOMATICALLY after reading research documents and should be updated as each subsequent phase completes to include references to all planning documents.

---

## Phase 2: Project Plan Document (v1)

**Note:** Generate from information extracted from research documents.

### 2.1 Create `.claude/docs/PROJECT-PLAN.md`

```markdown
# Project Plan: [Project Name]

**Version:** 1.0
**Status:** Draft
**Last Updated:** [DATE]

## 1. Executive Summary

[One paragraph overview for stakeholders]

## 2. System Context

### 2.1 Function/Service Area
- Area: [specify]
- Primary Workflow: [describe]
- Impact Scope: [who/what is affected]

### 2.2 Current State (As-Is)
- Current process: [detailed description]
- Pain points: [list with impact]
- Risk concerns: [list]

### 2.3 Future State (To-Be)
- Proposed solution: [description]
- Benefits: [specific outcomes]
- Reliability improvements: [specific]

## 3. Requirements Summary

### 3.1 Functional Requirements
[High-level list from Phase 1]

### 3.2 Non-Functional Requirements
- Performance: [specific metrics]
- Reliability: [uptime, data loss tolerance]
- Security: [encryption, audit, access control]
- Usability: [workflow integration, training needs]
- Scalability: [concurrent users, data volume]
- Maintainability: [documentation, testing]

### 3.3 Regulatory & Compliance
- Regulatory requirements: [HIPAA, SOC2, etc.]
- Industry standards: [relevant standards]
- Internal policies: [organization-specific]
- Local regulations: [jurisdiction-specific]

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
- Subject Matter Expert: [availability]

### 6.2 Infrastructure
- Development: [environments]
- Testing: [environments]
- Staging: [environments]
- Production: [requirements]

## 7. Risk Summary (High-Level)
[Identified risks at project level - detailed risks in Phase 4]

## 8. Success Criteria

### 8.1 Success Metrics
- [Specific outcome improvements]
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

This is the **most important phase**. Specifications must be broken down until they are so small that they seem ridiculous. A specification should be implementable in 15-30 minutes by a competent developer.

**Repeat 5-7 times** until NO FURTHER BREAKDOWN IS POSSIBLE. When you think a specification is atomic, ask: "Can this be split?" If yes, split it. Ask again. Repeat until the answer is NO.

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
9. **Safety**: What are failure modes? What are consequences?

If ANY answer reveals complexity, SPLIT the specification further.
```

### 3.3 Third Pass: Junior-Developer Clarity Check

Transform each atomic specification into:

```markdown
## Specification ID: [XX.YY.ZZZ]

### User Story
As a [user role],
I want to [action],
So that [benefit].

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
- Data sensitivity: [classification level]
- Encryption: [at rest, in transit]
- Audit logging: [what, when, who]

**Safety & Reliability:**
- Failure mode: [what can go wrong]
- Consequence: [severity]
- Safeguards: [prevention, detection, mitigation]
- Fallback behavior: [what happens on failure]

**Testing Requirements:**
- Unit tests: [number, coverage]
- Integration tests: [scenarios]
- E2E tests: [key workflows]
- Performance tests: [scenarios]

**Dependencies:**
- Requires: [specifications]
- Required by: [specifications]

**Implementation Notes for Junior Developers:**
- [Specific guidance on common mistakes]
- [Specific guidance on system considerations]
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
   - What's the worst outcome if this is wrong?
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

## 1. System Risks

### 1.1 Failure Risks

| Risk ID | Risk | Probability | Impact | Severity | Mitigation | Owner | Status |
|---------|------|-------------|--------|----------|------------|-------|--------|
| S-001 | [Description] | [Low/Med/High] | [1-5] | [PxDxS] | [Actions] | [Who] | [Open/Mitigated] |

**Severity Calculation:**
- PxDxS = Probability × Detection × Severity
- Critical: PxDxS ≥ 100
- High: 50 ≤ PxDxS < 100
- Medium: 10 ≤ PxDxS < 50
- Low: PxDxS < 10

### 1.2 Workflow Integration Risks

[Analyze how the system integrates into existing workflows]

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
6. Add specific gates and reviews for quality and safety

### 5.2 Add "Junior Developer Guidance" Section

```markdown
## 10. Guidance for Junior Developers

### 10.1 Development Mindset
- When in doubt, ASK before implementing
- Never make assumptions about workflows
- Follow specifications exactly

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
| Not sure about system impact | Stop, ask Senior Engineer |
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
**Important:** Follow exactly. Do not deviate.

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
- [ ] I understand the system context and requirements
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
   - Add JSDoc comments explaining purpose and usage
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

3. **E2E Tests** (Required for key workflows):
   - Test complete end-to-end scenarios
   - Test error recovery
   - Test performance under load

## Code Review Checklist

Before marking any item complete:

- [ ] Code follows specifications exactly
- [ ] All tests pass
- [ ] No TypeScript errors
- [ ] No ESLint warnings
- [ ] Safety and reliability reviewed
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

3. **Is this testable to production standards?**
   - Can we prove this works in all scenarios?
   - Can we demonstrate reliability and safety?

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
**Coverage:** 100% of business logic code paths, 80% overall minimum

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
    ├── workflows/
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

  describe('Safety & Reliability', () => {
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

  describe('Safety & Reliability', () => {
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
describe('Workflow: Create Note', () => {
  it('should allow user to create note', async () => {
    // Simulate user login
    // Navigate to target
    // Create note
    // Verify note appears in record
  });

  it('should allow creation during active session', async () => {
    // Simulate active session
    // Create note
    // Verify note linked to session
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
- Business logic code paths: 100%
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

### Test Scenarios

```typescript
// tests/fixtures/test-scenarios.ts
export const testScenarios = {
  keyOperation: {
    // Complete context
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

**Important:** Tests should run in this order for workflow validation:

1. Unit Tests (fast, isolated)
2. Integration Tests (database, API)
3. Security Tests (authorization, injection)
4. Performance Tests (load, stress)
5. E2E Tests (end-to-end workflows)

**No specification is complete until ALL its tests pass.**
```

---

## Phase 8.5: Planning Validation (NEW)

Before proceeding to Ralph Loop, validate that all planning is complete and consistent.

### 8.5.1 Validation Checklist

Run through this checklist before presenting to user:

```markdown
# Planning Validation Checklist

## Document Completeness
- [ ] `.claude/CLAUDE.md` exists with project context
- [ ] `.claude/docs/PROJECT-PLAN.md` (v2) exists
- [ ] `.claude/docs/SPECIFICATIONS.md` exists with atomic specs
- [ ] `.claude/docs/RISKS-AND-MITIGATIONS.md` exists
- [ ] `.claude/docs/IMPLEMENTATION-ROADMAP.md` exists
- [ ] `.claude/docs/TDD-MASTER-DOCUMENT.md` exists
- [ ] `.claude/docs/GIT-STRATEGY.md` exists
- [ ] `.claude/docs/TEST-FIXTURES.md` exists
- [ ] `.claude/docs/INTEGRATION-TESTS.md` exists
- [ ] `.claude/docs/DEPENDENCY-GRAPH.md` exists
- [ ] `.claude/docs/PARALLEL-GROUPS.md` exists
- [ ] `.claude/docs/CRITICAL-PATH.md` exists

## Specification Validation
- [ ] Each SPEC-XXX has corresponding test section in TDD-MASTER-DOCUMENT.md
- [ ] All "Requires" dependencies reference valid specification IDs
- [ ] All "Required by" dependencies reference valid specification IDs
- [ ] No circular dependencies exist
- [ ] Each specification has time estimate (15-30 min target)
- [ ] Each specification has measurable acceptance criteria
- [ ] Each specification has explicit error handling

## Roadmap Validation
- [ ] All specifications from SPECIFICATIONS.md appear in IMPLEMENTATION-ROADMAP.md
- [ ] Checkpoints are defined at logical boundaries
- [ ] Quality gates are specified for each checkpoint
- [ ] Test requirements are specified for each specification

## Risk Validation
- [ ] All identified risks have mitigation strategies
- [ ] All mitigations have assigned owners/responsibilities
- [ ] High-severity risks have contingency plans
- [ ] Risk probability × impact × detection (PxDxD) is calculated

## Test Validation
- [ ] All specifications have unit tests specified
- [ ] Integration tests cover cross-specification workflows
- [ ] Security tests specified for sensitive data operations
- [ ] Performance tests specified for critical paths
- [ ] Test fixtures exist for valid and invalid inputs

## User Approval Required
Before proceeding to Phase 0, present summary to user and wait for explicit approval.
```

### 8.5.2 Dependency Validation Script

Create `.claude/scripts/validate-planning.sh`:

```bash
#!/bin/bash
# Validate planning document completeness

BASE_DIR=".claude/docs"
ERRORS=0

# Check all documents exist
for doc in CLAUDE.md PROJECT-PLAN.md SPECIFICATIONS.md RISKS-AND-MITIGATIONS.md \
           IMPLEMENTATION-ROADMAP.md TDD-MASTER-DOCUMENT.md GIT-STRATEGY.md \
           TEST-FIXTURES.md INTEGRATION-TESTS.md DEPENDENCY-GRAPH.md \
           PARALLEL-GROUPS.md CRITICAL-PATH.md; do
  if [ ! -f "$BASE_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check specification references
if [ -f "$BASE_DIR/SPECIFICATIONS.md" ]; then
  SPEC_IDS=$(grep -oE 'SPEC-[0-9]+' "$BASE_DIR/SPECIFICATIONS.md" | sort -u)
  for spec in $SPEC_IDS; do
    if ! grep -q "$spec" "$BASE_DIR/TDD-MASTER-DOCUMENT.md"; then
      echo "⚠️  $spec has no tests in TDD-MASTER-DOCUMENT.md"
    fi
  done
fi

if [ $ERRORS -eq 0 ]; then
  echo "✅ All validation checks passed"
  exit 0
else
  echo "❌ Found $ERRORS errors"
  exit 1
fi
```

---

## Supporting Planning Documents

### Dependency Graph

Create `.claude/docs/DEPENDENCY-GRAPH.md`:

```markdown
# Specification Dependency Graph

Visual representation of specification dependencies.

## Format
```
SPEC-001: Project Setup (no dependencies)
    ↓
SPEC-002: Core Types (depends on: SPEC-001)
    ↓
SPEC-003: Database Schema (depends on: SPEC-002)
    ├─→ SPEC-004: Note Creation API (depends on: SPEC-002, SPEC-003)
    ├─→ SPEC-005: Note List API (depends on: SPEC-002, SPEC-003)
    └─→ SPEC-006: Note Update API (depends on: SPEC-002, SPEC-003)
```

## Complete Dependency Graph

[Generate graph based on SPECIFICATIONS.md dependencies]

## Dependency Rules
- No circular dependencies allowed
- Leaf specifications (nothing depends on them) implemented last
- Critical path specifications implemented first
```

### Parallel Execution Groups

Create `.claude/docs/PARALLEL-GROUPS.md`:

```markdown
# Parallel Execution Groups

Specifications that can be implemented concurrently because they share identical dependencies.

## Group A: Foundation
Specifications: [List]
Can run in parallel: Yes
Dependencies: None

## Group B: Core Features
Specifications: [List]
Can run in parallel: Yes
Dependencies: Group A

## Sequential Requirements
[Specifications that must run sequentially due to shared resources]
```

### Critical Path Identification

Create `.claude/docs/CRITICAL-PATH.md`:

```markdown
# Critical Path Specifications

Specifications that block the maximum number of other specifications.

## Critical Path (Implement First)
1. **SPEC-001**: Project Setup
   - Blocks: All other specifications
   - Priority: P0

2. **SPEC-002**: Core Types
   - Blocks: 15 specifications
   - Priority: P0

3. **SPEC-003**: Error Handling
   - Blocks: 12 specifications
   - Priority: P0

## Leaf Specifications (Implement Last)
- **SPEC-047**: Logging (optional, nothing depends on it)
- **SPEC-046**: Analytics (optional)
- **SPEC-045**: Metrics reporting

## Priority Levels
- **P0**: Critical path - blocks 5+ specifications
- **P1**: High priority - blocks 2-4 specifications
- **P2**: Normal priority - blocks 1 specification
- **P3**: Low priority - leaf specification
```

### Test Data Fixtures

Create `.claude/docs/TEST-FIXTURES.md`:

```markdown
# Test Data Fixtures

Reusable test data for all specifications.

## Valid Fixtures

### Note Fixtures
\`\`\`json
{
  "minimalNote": {"title": "Test Note"},
  "fullNote": {
    "title": "Complete Note",
    "content": "This is full content",
    "tags": ["important", "work"]
  },
  "maxLengthNote": {
    "title": "...200 chars...",
    "content": "...5000 chars..."
  }
}
\`\`\`

### User Fixtures
\`\`\`json
{
  "validUser": {
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "Test User"
  }
}
\`\`\`

## Invalid Fixtures (for error testing)

### Invalid Notes
\`\`\`json
{
  "noTitle": {"content": "No title provided"},
  "oversizeTitle": {"title": "...201 chars..."},
  "oversizeContent": {"title": "Valid", "content": "...5001 chars..."}
}
\`\`\`

### Invalid Users
\`\`\`json
{
  "noEmail": {"password": "Pass123!"},
  "invalidEmail": {"email": "not-an-email", "password": "Pass123!"},
  "weakPassword": {"email": "user@example.com", "password": "weak"}
}
\`\`\`
```

### Integration Test Matrix

Create `.claude/docs/INTEGRATION-TESTS.md`:

```markdown
# Integration Test Matrix

Tests that span multiple specifications to verify end-to-end workflows.

## IT-001: Complete Note Lifecycle
**Specifications:** SPEC-004 (create), SPEC-005 (read), SPEC-006 (update), SPEC-007 (delete)

**Test:**
1. Create note via SPEC-004 endpoint
2. Read note via SPEC-005 endpoint
3. Verify data matches
4. Update note via SPEC-006 endpoint
5. Verify update persisted
6. Delete note via SPEC-007 endpoint
7. Verify note no longer accessible

**Expected Result:** Note successfully created, read, updated, deleted

## IT-002: Authenticated User Workflow
**Specifications:** SPEC-010 (login), SPEC-011 (session), SPEC-004 (create note)

**Test:**
1. Login via SPEC-010 endpoint
2. Receive session token via SPEC-011
3. Create note using session token
4. Verify note owned by authenticated user
5. Attempt to access another user's note
6. Verify access denied

**Expected Result:** User can only access their own data

## Integration Test Coverage Matrix

| Workflow | Specifications | Status |
|----------|---------------|--------|
| Note CRUD | SPEC-004, 005, 006, 007 | ✅ Covered |
| User Authentication | SPEC-010, 011, 012 | ✅ Covered |
| [More workflows] | [specs] | [status] |
```

### Progress Dashboard Template

Create `.claude/docs/PROGRESS.md` (template):

```markdown
# Implementation Progress

**Last Updated:** [DATE]
**Current Phase:** [Foundation / Core Features / Integration / Polish]
**Overall Progress:** ██░░░░░░░░░░ 10%

## Statistics
- Total Specifications: 47
- Completed: 5 (10%)
- In Progress: 1
- Not Started: 41
- Tests Passing: 5/5 (100%)
- Tests Failing: 0
- ETA: [calculated from completed specs]

## Completed Specifications
- [x] SPEC-001: Project Setup ✓ (committed 2025-02-02 14:23)
- [x] SPEC-002: Core Types ✓ (committed 2025-02-02 14:45)
- [x] SPEC-003: Error Handling ✓ (committed 2025-02-02 15:12)
- [x] SPEC-004: Database Schema ✓ (committed 2025-02-02 15:45)
- [x] SPEC-005: Note Creation API ✓ (committed 2025-02-02 16:30)

## In Progress
- [ ] SPEC-006: Note List API
  - Status: Tests passing, implementation in progress
  - Estimated completion: 30 min

## Not Started
- [ ] SPEC-007 through SPEC-047

## Upcoming Checkpoint
**Checkpoint 1: Foundation Complete**
Target: SPEC-001 through SPEC-010
Current: SPEC-006 (5/10 complete)
ETA: 2.5 hours

## Quality Gate Status
- All tests passing: ✅
- No TypeScript errors: ✅
- No lint warnings: ✅
- Coverage >80%: ✅ (82%)

## Next Actions
1. Complete SPEC-006: Note List API
2. Run integration tests
3. Commit and move to SPEC-007
```

### Ralph Loop Resume State

Create `.claude/docs/RALPH-STATE.md` (template):

```markdown
# Ralph Loop State

**Last Updated:** [DATE]

## Current Position
**Last Completed:** SPEC-XXX
**Next Up:** SPEC-[XXX+1]: [Specification Title]

## Artifacts Created
[Track files created for completed specifications]

## Tests Status
- ✅ SPEC-XXX tests passing
- ✅ All previous tests still passing
- ⏳ SPEC-[XXX+1] tests not yet written

## Resume Command
\`\`\`bash
/ralph-loop "--resume-from=SPEC-[XXX+1]"
\`\`\`

## Notes
[Any issues encountered, decisions made, etc.]
```

---

# MANUAL IMPLEMENTATION PHASE

**IMPORTANT:** The following phases require explicit user commands to execute. They are NOT part of the autonomous planning flow.

---

## Phase 0: Environment Setup

Before starting Ralph Loop, run environment setup to initialize the project structure.

### 0.1 Create Setup Script

Create `.claude/scripts/setup-env.sh`:

```bash
#!/bin/bash
# Environment Setup Script
# Run before starting Ralph Loop implementation

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"

echo "🔧 Setting up project environment..."

# Read project configuration for tech stack
if [ -f "$CLAUDE_DIR/docs/PROJECT-PLAN.md" ]; then
  # Detect stack from project plan
  echo "📖 Reading project configuration..."
else
  echo "⚠️  PROJECT-PLAN.md not found. Using defaults."
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$PROJECT_DIR/src"/{api,models,services,utils,middleware}
mkdir -p "$PROJECT_DIR/tests"/{unit,integration,e2e}
mkdir -p "$PROJECT_DIR/docs"
mkdir -p "$PROJECT_DIR/config"

# Initialize package.json if not exists
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  echo "📦 Initializing package.json..."
  cd "$PROJECT_DIR"
  npm init -y
fi

# Install dependencies
echo "📥 Installing dependencies..."
npm install --silent --no-audit --no-fund

# Create config files from templates
echo "⚙️  Creating configuration files..."

# TypeScript config
if [ ! -f "$PROJECT_DIR/tsconfig.json" ]; then
  cat > "$PROJECT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
fi

# Jest config
if [ ! -f "$PROJECT_DIR/jest.config.js" ]; then
  cat > "$PROJECT_DIR/jest.config.js" << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.interface.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
EOF
fi

# ESLint config
if [ ! -f "$PROJECT_DIR/.eslintrc.js" ]; then
  cat > "$PROJECT_DIR/.eslintrc.js" << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module'
  },
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
EOF
fi

# .gitignore
if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
  cat > "$PROJECT_DIR/.gitignore" << 'EOF'
node_modules/
dist/
coverage/
.env
*.log
.DS_Store
 claude/
EOF
fi

# Create PROGRESS.md if not exists
if [ ! -f "$CLAUDE_DIR/docs/PROGRESS.md" ]; then
  cat > "$CLAUDE_DIR/docs/PROGRESS.md" << 'EOF'
# Implementation Progress

**Last Updated:** [DATE]

## Statistics
- Total Specifications: [from SPECIFICATIONS.md]
- Completed: 0
- In Progress: 0
- Not Started: [total]

## Completed Specifications
None yet.

## In Progress
None yet.

## Not Started
All specifications.

---
Environment ready. Run `/ralph-loop` to begin implementation.
EOF
fi

echo "✅ Environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review generated configuration files"
echo "  2. Run tests: npm test"
echo "  3. Start Ralph Loop: /ralph-loop"
```

### 0.2 Run Setup Script

```bash
bash .claude/scripts/setup-env.sh
```

### 0.3 Verify Setup

```bash
# Verify directories exist
ls -la src/ tests/

# Run tests (should pass with 0 tests)
npm test

# Verify TypeScript compiles
npx tsc --noEmit
```

---

## Phase 9: Ralph Loop Implementation (UPDATED)

### 9.1 The Final Ralph Loop Prompt

Once all planning documents are complete and verified, start Ralph Loop:

```bash
/ralph-loop "
You are implementing a software system from detailed specifications.

# MANDATORY READING (Read in order)
1. .claude/docs/PROJECT-PLAN.md - Complete project context
2. .claude/docs/SPECIFICATIONS.md - Every atomic specification
3. .claude/docs/RISKS-AND-MITIGATIONS.md - Every risk
4. .claude/docs/IMPLEMENTATION-ROADMAP.md - Step-by-step instructions
5. .claude/docs/TDD-MASTER-DOCUMENT.md - Every test case
6. .claude/docs/TEST-FIXTURES.md - Test data fixtures
7. .claude/docs/INTEGRATION-TESTS.md - Cross-specification tests
8. .claude/docs/DEPENDENCY-GRAPH.md - Specification dependencies
9. .claude/docs/PARALLEL-GROUPS.md - Parallel execution groups
10. .claude/docs/CRITICAL-PATH.md - Implementation priority

# RESUME CAPABILITY

If interrupted, check .claude/docs/RALPH-STATE.md for resume position.
Use --resume-from flag to continue from specific specification.

# CHECKPOINT SYSTEM

Before each checkpoint defined in IMPLEMENTATION-ROADMAP.md:
1. Pause implementation
2. Present checkpoint summary to user
3. Wait for user approval to continue
4. Update checkpoint status in PROGRESS.md

# STRICT TDD PROCESS (Never Deviate)

For EACH specification in IMPLEMENTATION-ROADMAP.md order (respecting CRITICAL-PATH.md):

## Step 1: Read Specification
- Read the complete specification from SPECIFICATIONS.md
- Read corresponding tests from TDD-MASTER-DOCUMENT.md
- Check DEPENDENCY-GRAPH.md for prerequisite specs
- Understand ALL acceptance criteria

## Step 2: Write Failing Tests
- Use test fixtures from TEST-FIXTURES.md
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

## Step 6: Run Quality Gates
- Run: bash .claude/scripts/quality-gate.sh
- If quality gate fails, STOP and fix
- Do not proceed until all gates pass

## Step 7: Safety Review
- Read the code you just wrote
- Ask: What could go wrong?
- Ask: What are the consequences if this fails?
- If any concern exists, address it NOW

## Step 8: Update Progress
- Update .claude/docs/PROGRESS.md with:
  - Mark specification complete
  - Update progress percentage
  - Note time taken
  - Any issues encountered
- Update .claude/docs/RALPH-STATE.md with current position

## Step 9: Git Commit
- Run quality gate script one more time
- git add .
- git commit -m \\"feat(spec-SPEC-ID): [specification title]\\"
- Never commit broken tests

## Step 10: Check for Checkpoint
- Check if next specification is a checkpoint
- If checkpoint, PAUSE and present summary
- Wait for user approval

## Step 11: Repeat
- Move to next specification in IMPLEMENTATION-ROADMAP.md
- Repeat from Step 1

# AFTER ALL SPECIFICATIONS COMPLETE

## Step 11: Generate Project Documentation
Before outputting completion promise, generate comprehensive project documentation:

### 11.1 Create README.md
```markdown
# [Project Name]

[One-line description]

## Overview
[What this system does and why it matters]

## Installation
\`\`\`bash
[Installation commands]
\`\`\`

## Usage
\`\`\`bash
[Usage examples]
\`\`\`

## API Documentation
[If applicable - endpoints, request/response formats]

## Testing
\`\`\`bash
npm test
\`\`\`

## Development
- Stack: [list technologies]
- Project Structure: [brief description]

## License
[Specify license]
```

### 11.2 Create CONTRIBUTING.md (if open source)
### 11.3 Create CHANGELOG.md with version history
### 11.4 Create API.md if REST API (document all endpoints)
### 11.5 Create docs/ folder for additional documentation

Documentation MUST be:
- Clear and concise
- Include examples
- Accurate (matches actual implementation)
- Professional quality

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
6. ALWAYS consider quality and safety first
7. ALWAYS write tests before code
8. ALWAYS verify all tests pass before committing

# COMPLETION
Output <promise>SYSTEM_COMPLETE</promise> ONLY when:
- ALL specifications from SPECIFICATIONS.md are implemented
- ALL tests from TDD-MASTER-DOCUMENT.md pass
- PROGRESS.md shows 100% completion
- Code review passes with no critical issues
- Quality verified
- Project documentation generated (README.md, API docs, etc.)

Begin with the first specification in IMPLEMENTATION-ROADMAP.md (Phase 1, Foundation).
" --max-iterations 200
```

---

## Summary: Document Structure

After completing all phases, your project will have:

```
.claude/
├── CLAUDE.md                    # Project-specific context
├── scripts/
│   ├── setup-env.sh             # Environment setup script
│   ├── quality-gate.sh          # Quality gate verification
│   └── validate-planning.sh     # Planning validation script
└── docs/
    ├── PROJECT-PLAN.md          # Complete project context (v2)
    ├── SPECIFICATIONS.md        # Atomic, complete specifications
    ├── RISKS-AND-MITIGATIONS.md # All risks and mitigations
    ├── IMPLEMENTATION-ROADMAP.md # Step-by-step guide with checkpoints
    ├── TDD-MASTER-DOCUMENT.md   # Every test case for every spec
    ├── TEST-FIXTURES.md         # Test data fixtures
    ├── INTEGRATION-TESTS.md     # Cross-specification tests
    ├── DEPENDENCY-GRAPH.md      # Specification dependencies
    ├── PARALLEL-GROUPS.md       # Parallel execution groups
    ├── CRITICAL-PATH.md         # Implementation priority
    ├── GIT-STRATEGY.md          # Git workflow and conventions
    ├── PROGRESS.md              # Live progress tracking
    └── RALPH-STATE.md           # Resume state tracking

# Scripts (created during setup)
.claude/scripts/
├── setup-env.sh                 # Run before Ralph Loop
├── quality-gate.sh              # Run before each commit
└── validate-planning.sh         # Run before Ralph Loop

# Project Documentation (generated at end of Ralph Loop)
├── README.md                    # Project overview, installation, usage
├── CONTRIBUTING.md              # Contribution guidelines (if applicable)
├── CHANGELOG.md                 # Version history
├── API.md                       # API documentation (if REST API)
└── docs/                        # Additional documentation
```

**Each document links to others. Each specification references risks. Each test references specifications.**

**The result: Junior developers can implement without failure because every decision is made, every risk is mitigated, and every test is specified. The project is fully documented and ready for production use.**

---

**Remember:** You are the Senior Engineer. Take the time to plan thoroughly. Quality specifications enable quality implementation.
