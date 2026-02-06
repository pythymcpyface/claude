---
description: Guided feature development with codebase understanding and architecture focus
argument-hint: Optional feature description
---

# Feature Development

You are helping a developer implement a new feature. Follow a systematic approach: understand the codebase deeply, identify and ask about all underspecified details, design elegant architectures, then implement.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Ask specific, concrete questions rather than making assumptions. Wait for user answers before proceeding with implementation. Ask questions early (after understanding the codebase, before designing architecture).
- **Understand before acting**: Read and comprehend existing code patterns first
- **Read files identified by agents**: When launching agents, ask them to return lists of the most important files to read. After agents complete, read those files to build detailed context before proceeding.
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code
- **Use TodoWrite**: Track all progress throughout

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

Initial request: $ARGUMENTS

**Actions**:
1. Create todo list with all phases
2. If feature unclear, ask user for:
   - What problem are they solving?
   - What should the feature do?
   - Any constraints or requirements?
3. Summarize understanding and confirm with user

---

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns at both high and low levels

**Actions**:
1. Launch 2-3 code-explorer agents in parallel. Each agent should:
   - Trace through the code comprehensively and focus on getting a comprehensive understanding of abstractions, architecture and flow of control
   - Target a different aspect of the codebase (eg. similar features, high level understanding, architectural understanding, user experience, etc)
   - Include a list of 5-10 key files to read

   **Example agent prompts**:
   - "Find features similar to [feature] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [feature area], tracing through the code comprehensively"
   - "Analyze the current implementation of [existing feature/area], tracing through the code comprehensively"
   - "Identify UI patterns, testing approaches, or extension points relevant to [feature]"

2. Once the agents return, please read all files identified by agents to build deep understanding
3. Present comprehensive summary of findings and patterns discovered

---

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing

**CRITICAL**: This is one of the most important phases. DO NOT SKIP.

**Actions**:
1. Review the codebase findings and original feature request
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance needs
3. **Present all questions to the user in a clear, organized list**
4. **Wait for answers before proceeding to architecture design**

If the user says "whatever you think is best", provide your recommendation and get explicit confirmation.

---

## Phase 3.5: Requirements Breakdown

**Goal**: Generate complete REQUIREMENTS.md with atomic requirements

**CRITICAL**: Complete all requirements work before any specifications

**Actions**:
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

**Atomic Requirement Indicators**:
- Can be implemented in a single function or small set of functions
- Has clear, binary acceptance criteria (pass/fail)
- Independent of other requirements (minimal dependencies)
- Testable in isolation

**Template**: Use `.claude/docs/templates/REQUIREMENTS-TEMPLATE.md`

---

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches with different trade-offs

**Actions**:
1. Launch 2-3 code-architect agents in parallel with different focuses: minimal changes (smallest change, maximum reuse), clean architecture (maintainability, elegant abstractions), or pragmatic balance (speed + quality)
2. Review all approaches and form your opinion on which fits best for this specific task (consider: small fix vs large feature, urgency, complexity, team context)
3. Present to user: brief summary of each approach, trade-offs comparison, **your recommendation with reasoning**, concrete implementation differences
4. **Ask user which approach they prefer**

---

## Phase 4.5: TDD Strategy Generation

**Goal**: Generate complete SPECIFICATIONS.md and TDD-STRATEGY.md

**CRITICAL**: Complete all specs and test planning before implementation

**Actions**:
1. **For each REQ-XXX**, generate SPEC-XXX using the existing template
2. **Generate `.claude/docs/SPECIFICATIONS.md`** containing all specs
3. **Generate `.claude/docs/TDD-STRATEGY.md`** with:
   - Test case for every acceptance criterion
   - Happy path tests
   - Sad path/edge case tests
   - Integration tests
   - Test fixtures needed

**Coverage Targets**:
- **Unit tests**: Each acceptance criterion gets at least one test
- **Edge cases**: Minimum 2-3 per requirement
- **Integration tests**: For requirement dependencies
- **Coverage goal**: >80% on business logic

**Templates**:
- Specifications: `.claude/docs/templates/SPEC-TEMPLATE.md`
- TDD Strategy: `.claude/docs/templates/TDD-STRATEGY-TEMPLATE.md`

**Document Generation Order**:
1. Complete `REQUIREMENTS.md` (all requirements broken down)
2. Complete `SPECIFICATIONS.md` (all specs from requirements)
3. Complete `TDD-STRATEGY.md` (all test cases mapped)
4. **THEN** begin implementation

---

## Phase 5: Implementation (Strict TDD)

**Goal**: Build the feature following Red-Green-Refactor loop

**DO NOT START WITHOUT USER APPROVAL**

**CRITICAL**: Only starts after ALL documents (REQUIREMENTS.md, SPECIFICATIONS.md, TDD-STRATEGY.md) are complete

**TDD Loop for each SPEC-XXX (in dependency order)**:
1. **Read test cases** from TDD-STRATEGY.md for this spec
2. **Write failing test** (RED) - create test file with test case
3. **Run test**, confirm it fails with expected error
4. **Write minimal implementation** to make test pass
5. **Run test**, confirm it passes (GREEN)
6. **Refactor** if needed (REFACTOR)
7. **Run `.claude/scripts/tdd-gate.sh`** to verify TDD compliance
8. **Run `.claude/scripts/quality-gate.sh`** to verify code quality
9. **Commit** if gates pass

**Actions**:
1. Wait for explicit user approval
2. Read all relevant files identified in previous phases
3. Read REQUIREMENTS.md, SPECIFICATIONS.md, and TDD-STRATEGY.md
4. For each SPEC-XXX, follow TDD loop above
5. Follow codebase conventions strictly
6. Write clean, well-documented code
7. Update todos as you progress

---

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, easy to read, and functionally correct

**Actions**:
1. Launch 3 code-reviewer agents in parallel with different focuses: simplicity/DRY/elegance, bugs/functional correctness, project conventions/abstractions
2. Consolidate findings and identify highest severity issues that you recommend fixing
3. **Present findings to user and ask what they want to do** (fix now, fix later, or proceed as-is)
4. Address issues based on user decision

---

## Phase 7: Summary

**Goal**: Document what was accomplished

**Actions**:
1. Mark all todos complete
2. Summarize:
   - What was built
   - Key decisions made
   - Files modified
   - Documents generated (REQUIREMENTS.md, SPECIFICATIONS.md, TDD-STRATEGY.md)
   - Suggested next steps

---

## Document Artifacts

This workflow generates three planning documents before implementation:

1. **`.claude/docs/REQUIREMENTS.md`** - Atomic requirements (REQ-001, REQ-002, etc.)
2. **`.claude/docs/SPECIFICATIONS.md`** - Technical specifications (SPEC-001, SPEC-002, etc.)
3. **`.claude/docs/TDD-STRATEGY.md`** - Test case mapping (TEST-XXX-XXX)

These documents provide complete visibility into scope before coding begins.

---
