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
- **Branch-per-feature**: All work happens on a feature branch named after the work being done

---

## Phase 0: Worktree Setup

**Goal**: Create a git worktree for isolated feature development

**Actions**:
1. Generate a branch name from the feature description (use kebab-case, max 50 chars)
2. Ask user to confirm or modify the branch name
3. **Create a git worktree** (isolated working directory):
   ```bash
   # Determine worktree path (sibling to current repo)
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_NAME=$(basename "$REPO_ROOT")
   WORKTREE_PATH="../${REPO_NAME}-${BRANCH_NAME}"

   # Create worktree with new branch
   git worktree add "$WORKTREE_PATH" -b $BRANCH_NAME
   ```
4. **Store variables for later use**:
   - `$BRANCH_NAME` - for documentation naming
   - `$WORKTREE_PATH` - for worktree location
   - `$MAIN_REPO_PATH` - for returning to main repo ($REPO_ROOT)
5. **Note the worktree location** for reference:
   - Worktree created at: `$WORKTREE_PATH`
   - Continue working in the current session (no session restart needed)

**Example**:
- Feature: "Add user authentication with OAuth"
- Branch name: `add-user-auth-oauth`
- Worktree path: `../myproject-add-user-auth-oauth`
- Documentation directory: `.claude/docs/$BRANCH_NAME/`

**Benefits of Worktrees**:
- Isolated context window for this feature
- Main repo remains untouched for parallel work
- No stash needed when switching tasks
- Each Claude instance has clean state
- Enables parallel agent instances on different features

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

**Workflow Options**:

### Option A: Comprehensive Specification Workflow (Recommended for complex features)

Use `/spec-workflow` for exhaustive specification:
1. **Invoke spec-workflow**:
   ```
   /spec-workflow [feature description]
   ```
2. **This generates**:
   - `USER-JOURNEYS.md` - Exhaustive journey analysis
   - `REQUIREMENTS.md` - EARS-formatted requirements
   - `TDD-STRATEGY.md` - Gherkin/BDD specifications
   - `TRACEABILITY-MATRIX.md` - Bidirectional traceability
   - `features/*.feature` - Executable Gherkin files
3. **Skip to Phase 4** after spec-workflow completes

### Option B: Standard Requirements Breakdown

**Actions**:
1. **Generate initial requirements** from user input and clarifying questions
2. **Iterative breakdown loop (3-5 passes)**:
   - For each requirement, ask: "Can this be split into smaller, independently testable units?"
   - Break down until atomic (single function, single decision point, single file)
   - Stop when requirements seem "ridiculously small"
3. **Generate `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`** with:
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
**Output**: `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`

**Recommendation**: Use Option A (spec-workflow) for:
- Complex features with multiple user roles
- Features requiring exhaustive test coverage
- Projects with compliance requirements
- Features with security implications

---

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches with different trade-offs

**Actions**:
1. Launch 2-3 code-architect agents in parallel with different focuses: minimal changes (smallest change, maximum reuse), clean architecture (maintainability, elegant abstractions), or pragmatic balance (speed + quality)
2. Review all approaches and form your opinion on which fits best for this specific task (consider: small fix vs large feature, urgency, complexity, team context)
3. Present to user: brief summary of each approach, trade-offs comparison, **your recommendation with reasoning**, concrete implementation differences
4. **Ask user which approach they prefer**

---

## Phase 4.5: Architecture Validation

**Goal**: Validate the chosen architecture against codebase patterns and best practices

**CRITICAL**: Ensure architecture aligns with existing conventions before proceeding

**Actions**:
1. **Review the chosen architecture** from Phase 4 against codebase patterns
2. **Verify design pattern alignment**:
   - Matches existing architectural patterns
   - Uses established naming conventions
   - Follows module organization standards
   - Compatible with existing error handling
3. **Validate SOLID principles**:
   - Single Responsibility: Each component has one job
   - Open/Closed: Extensible without modification
   - Liskov Substitution: Subtypes are substitutable
   - Interface Segregation: Focused interfaces
   - Dependency Inversion: Depend on abstractions
4. **Check integration points**:
   - External dependencies identified and justified
   - Internal dependencies documented
   - API boundaries clearly defined
5. **Validate error handling strategy** for the proposed design
6. **Create ADR** (Architecture Decision Record) if this is a significant architectural decision
7. **Document findings** in `.claude/docs/$BRANCH_NAME/ARCHITECTURE-VALIDATION.md`
8. **Present validation to user** with any concerns or adjustments needed

**Template**: `.claude/docs/templates/ARCHITECTURE-VALIDATION.md`
**Output**: `.claude/docs/$BRANCH_NAME/ARCHITECTURE-VALIDATION.md`

---

## Phase 4.6: TDD Strategy Generation

**Goal**: Generate complete SPECIFICATIONS.md and TDD-STRATEGY.md

**CRITICAL**: Complete all specs and test planning before implementation

**Actions**:
1. **For each REQ-XXX**, generate SPEC-XXX using the existing template
2. **Generate `.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md`** containing all specs
3. **Generate `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`** with:
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
**Outputs**:
- `.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md`
- `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`

**Document Generation Order**:
1. Complete `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md` (all requirements broken down)
2. Complete `.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md` (all specs from requirements)
3. Complete `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md` (all test cases mapped)
4. **THEN** stop and present documentation summary

---

# ⛔ DOCUMENTATION COMPLETE - STOP POINT ⛔

**Planning Phase Complete.** All documentation has been generated:
- `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`
- `.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md`
- `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`

**DO NOT proceed to implementation automatically.**

Present the documentation summary to the user and **WAIT** for explicit approval before continuing to Phase 5.

The user must explicitly request implementation to proceed.

---

## Phase 5: Implementation (Strict TDD)

**⚠️ MANUAL CONTINUATION ONLY - DO NOT START AUTOMATICALLY ⚠️**

**Goal**: Build the feature following Red-Green-Refactor loop

**REQUIRES EXPLICIT USER APPROVAL BEFORE STARTING**

This phase ONLY begins when the user explicitly requests implementation to proceed after reviewing all documentation.

**CRITICAL**: Only starts after ALL documents ($BRANCH_NAME/REQUIREMENTS.md, $BRANCH_NAME/SPECIFICATIONS.md, $BRANCH_NAME/TDD-STRATEGY.md) are complete

**TDD Loop for each SPEC-XXX (in dependency order)**:
1. **Read test cases** from `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md` for this spec
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
3. Read `.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`, `.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md`, and `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`
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

## Phase 6.2: UX Review

**Goal**: Validate user experience quality including usability, accessibility, and workflow validation

**Design Assistance**: Use `/ui-ux` command for design intelligence, patterns, and tool recommendations

**Actions**:
1. **Review UX checklist**: Use `.claude/docs/templates/UX-CHECKLIST.md`
2. **Verify user workflow**:
   - Task completion is intuitive
   - Navigation is clear and predictable
   - Error messages are helpful and actionable
3. **Check accessibility** (WCAG 2.1 AA):
   - Color contrast ratios meet standards
   - Keyboard navigation works
   - Screen reader support is adequate
   - Form inputs have proper labels
4. **Validate mobile responsiveness**:
   - Touch targets are at least 44x44 pixels
   - Layout works on small screens
   - No horizontal scrolling
5. **Review edge cases**:
   - Empty states have helpful guidance
   - Loading states provide feedback
   - Long text/content is handled gracefully
6. **Document findings** in `.claude/docs/$BRANCH_NAME/UX-REVIEW.md` if applicable
7. **Present findings to user** with severity levels

**Template**: `.claude/docs/templates/UX-CHECKLIST.md`

---

## Phase 6.5: Security Review

**Goal**: Verify security requirements are met before merging

**CRITICAL**: Security vulnerabilities must be addressed before merge

**Actions**:
1. **Run security gate**: `bash .claude/scripts/security-gate.sh`
2. **Review security checklist**: Use `.claude/docs/templates/SECURITY-CHECKLIST.md`
3. **Verify OWASP Top 10 coverage**:
   - A01: Broken Access Control
   - A02: Cryptographic Failures
   - A03: Injection (SQL, XSS, Command)
   - A04: Insecure Design
   - A05: Security Misconfiguration
   - A06: Vulnerable Components
   - A07: Authentication Failures
   - A08: Data Integrity Failures
   - A09: Logging Failures
   - A10: Server-Side Request Forgery
4. **Check for**:
   - Hardcoded secrets (none allowed)
   - Input validation on all user input
   - Output encoding to prevent XSS
   - Parameterized queries for database access
   - Proper error handling (no information leakage)
5. **Document security decisions** in `.claude/docs/$BRANCH_NAME/SECURITY-REVIEW.md` if applicable
6. **Present findings to user** with severity levels (HIGH/MEDIUM/LOW)
7. **Address all HIGH severity issues** before proceeding

**Template**: `.claude/docs/templates/SECURITY-CHECKLIST.md`
**Script**: `.claude/scripts/security-gate.sh`

---

## Phase 7: Summary and Merge

**Goal**: Document what was accomplished, merge the feature branch, and clean up worktree

**Actions**:
1. **Mark all todos complete**
2. **Commit any remaining changes**:
   ```bash
   git add .
   git commit -m "feat: complete $BRANCH_NAME" || echo "Nothing to commit"
   ```
3. **Add documentation directory to .gitignore** (in worktree):
   ```bash
   echo ".claude/docs/$BRANCH_NAME/" >> .gitignore
   git add .gitignore
   git commit -m "chore: add feature docs to gitignore" || echo "Nothing to commit"
   ```
4. **Return to main repo and merge**:
   ```bash
   # Navigate to main repo
   cd $MAIN_REPO_PATH

   # Pull latest changes
   git pull --no-rebase

   # Merge the feature branch
   git merge --no-ff $BRANCH_NAME -m "feat: complete $BRANCH_NAME"
   ```
5. **Push to remote**:
   ```bash
   git push origin main
   ```
6. **Clean up worktree**:
   ```bash
   # Remove the worktree
   git worktree remove $WORKTREE_PATH

   # Optionally delete the feature branch
   git branch -d $BRANCH_NAME

   # Prune any stale worktree references
   git worktree prune
   ```
7. **Summarize**:
   - What was built
   - Key decisions made
   - Files modified
   - Documents generated ($BRANCH_NAME/REQUIREMENTS.md, $BRANCH_NAME/SPECIFICATIONS.md, $BRANCH_NAME/TDD-STRATEGY.md)
   - Suggested next steps
   - Worktree cleaned up

**Note**: The user can keep the worktree for further work by skipping step 6.

---

## Document Artifacts

This workflow generates three planning documents before implementation, named after the feature branch:

1. **`.claude/docs/$BRANCH_NAME/REQUIREMENTS.md`** - Atomic requirements (REQ-001, REQ-002, etc.)
2. **`.claude/docs/$BRANCH_NAME/SPECIFICATIONS.md`** - Technical specifications (SPEC-001, SPEC-002, etc.)
3. **`.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md`** - Test case mapping (TEST-XXX-XXX)

The documentation directory is added to `.gitignore` at the end of the workflow, keeping planning documents local but preserving the branch-per-feature workflow in git history.

---
