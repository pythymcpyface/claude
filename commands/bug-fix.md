---
description: Guided bug resolution with reproduction, root cause analysis, and test-first fixes
argument-hint: Bug description or report
---

# Bug Fix

You are helping a developer resolve a bug. Follow a systematic approach: understand the bug, reproduce it, find the root cause, plan a minimal fix, and implement with tests.

## Core Principles

- **Reproduce before fixing**: Always create a failing test that demonstrates the bug
- **Find root cause**: Understand WHY the bug occurs, not just WHERE
- **Minimal changes**: Fix only what's needed - no refactoring or "while I'm here" changes
- **Test-first**: Write the reproduction test first, confirm it fails, then fix
- **Read deeply**: When launching agents, read the files they identify before proceeding
- **Branch-per-fix**: All work happens on a fix branch named after the bug
- **Use TodoWrite**: Track all progress throughout

---

## Phase 0: Worktree Setup

**Goal**: Create a git worktree for isolated bug fix development

### Pre-Flight: Orphaned Worktree Cleanup

**Before creating a new worktree**, check for and clean up any orphaned worktrees from previous incomplete sessions:

```bash
# List all worktrees and check for orphans
git worktree list

# Check for worktrees that no longer exist on disk or are stale
git worktree prune -v

# For any remaining worktrees, check if they're orphaned
for wt_path in $(git worktree list | tail -n +2 | awk '{print $1}'); do
  if [ ! -d "$wt_path" ]; then
    echo "Orphaned worktree reference: $wt_path"
    git worktree remove "$wt_path" --force 2>/dev/null || true
  fi
done
```

**If orphaned worktrees are found**, present them to the user with options:
1. Clean up all orphaned worktrees
2. Review each one individually
3. Skip cleanup (not recommended)

**Actions**:

### Branch Naming Convention (MANDATORY)

Follow industry-standard git branch naming conventions:

| Type | Pattern | Example |
|------|---------|---------|
| **Bugfix** | `bugfix/<description>` | `bugfix/login-timeout` |
| **Bugfix + Issue** | `bugfix/<issue-id>-<description>` | `bugfix/GH-789-login-crash` |
| **Hotfix** | `hotfix/<description>` | `hotfix/security-patch` |
| **Hotfix + Issue** | `hotfix/<issue-id>-<description>` | `hotfix/JIRA-123-critical-fix` |

**Branch Naming Rules**:
1. Use lowercase letters only
2. Use hyphens `-` to separate words in description
3. Use slashes `/` to separate type prefix
4. Keep total length under 50 characters
5. Never use spaces or special characters (`~ ^ : * ? [ ] @`)
6. Include issue tracker ID when available (JIRA-XXX, GH-XXX)
7. Use `bugfix/` for non-critical bugs, `hotfix/` for production-critical

**Actions**:
1. **Generate branch name** following conventions above:
   - Determine severity: `bugfix/` (normal) or `hotfix/` (critical/production)
   - Create kebab-case description (max 40 chars after prefix)
   - Include issue ID if provided
   - **Example transformations**:
     - "Login crashes when email is null" → `bugfix/login-null-email`
     - "Fix GH-789: Payment timeout on mobile" → `bugfix/GH-789-payment-timeout`
     - "Critical: Security vulnerability in API" → `hotfix/api-security-vuln`

2. Ask user to confirm or modify the branch name

3. **Create a git worktree** (isolated working directory):
   ```bash
   # Determine worktree path (sibling to current repo)
   # Note: Sanitize slashes to avoid nested directories
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_NAME=$(basename "$REPO_ROOT")
   WORKTREE_PATH="../${REPO_NAME}-$(echo $BRANCH_NAME | sed 's/\//-/g')"

   # Create worktree with new branch
   git worktree add "$WORKTREE_PATH" -b $BRANCH_NAME

   # Create session marker for worktree isolation
   echo "{\"branch\":\"$BRANCH_NAME\",\"created\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"pid\":$$}" > "$WORKTREE_PATH/.worktree-session"
   ```

4. **Store variables for later use**:
   - `$BRANCH_NAME` - for documentation naming
   - `$WORKTREE_PATH` - for worktree location

5. **Note the worktree location** for reference:
   - Worktree created at: `$WORKTREE_PATH`
   - Session marker created: `.worktree-session`
   - Continue working in the current session (no session restart needed)

**Example**:
- Bug: "Login crashes when email is null"
- Branch name: `bugfix/login-null-email`
- Worktree path: `../myproject-bugfix-login-null-email`
- Documentation directory: `.claude/docs/$BRANCH_NAME/`

### Worktree Session Isolation

The `.worktree-session` marker file ensures new Claude sessions detect active worktrees:
- New sessions starting in main repo will see worktree status
- New sessions will NOT interfere with active worktree work
- User can start fresh work on main branch while worktree is active

**Benefits of Worktrees**:
- Isolated context window for this bug fix
- Main repo remains untouched for parallel work
- No stash needed when switching tasks
- Each Claude instance has clean state

---

## Phase 1: Bug Report

**Goal**: Document the bug comprehensively

**Input**: User's bug description ($ARGUMENTS)

**Actions**:
1. Create todo list with all phases
2. Ask clarifying questions to understand the bug:
   - What is the expected behavior?
   - What is actually happening?
   - How can this be reproduced? (steps, URL, data)
   - What is the severity/impact? (CRITICAL/HIGH/MEDIUM/LOW)
   - Any error messages, logs, or screenshots?
   - When did this start happening?
   - Is it intermittent or consistent?

3. Document using BUG-REPORT-TEMPLATE.md:
   - Save as `.claude/docs/$BRANCH_NAME/BUG-REPORT.md`
   - Include all gathered information

**Template**: `.claude/docs/templates/BUG-REPORT-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/BUG-REPORT.md`

---

## Phase 2: Bug Reproduction

**Goal**: Reproduce the bug before attempting to fix it

**CRITICAL**: Do not proceed until the bug is reproduced

**Actions**:
1. **Attempt to reproduce** using steps from bug report:
   - Follow the exact steps provided
   - Use the same data/inputs if specified
   - Check for error messages, logs, console output

2. **If reproducible**:
   - Document confirmation: "Bug reproduced successfully"
   - Note any deviations from expected reproduction steps
   - Proceed to step 3

3. **If not reproducible**:
   - Ask user for:
     - More specific steps
     - Environment details (browser, version, configuration)
     - Sample data or inputs
     - Screenshots or recordings
   - Retry reproduction with additional information

4. **Create reproduction test** (failing):
   - Write a test that captures the bug behavior
   - Test should FAIL with current code
   - Test should PASS after fix is applied
   - Name test clearly: `BUG-XXX: [brief description]`

5. **Run the test** to confirm it fails:
   - Document: "Reproduction test fails as expected"
   - If test passes, the bug isn't being reproduced correctly

**Example Test**:
```javascript
describe('BUG-001: Login crashes when email is null', () => {
  it('should handle null email gracefully', () => {
    // Arrange
    const credentials = { email: null, password: 'test123' };

    // Act
    const result = () => login(credentials);

    // Assert - should throw ValidationError, not crash
    expect(result).toThrow(ValidationError);
  });
});
```

---

## Phase 3: Root Cause Analysis

**Goal**: Find WHY the bug occurs, not just WHERE

**CRITICAL**: Understanding root cause prevents similar bugs and ensures correct fix

**Actions**:
1. **Launch 2-3 exploration agents in parallel**:

   **Agent 1 - Trace the bug manifestation:**
   - "Trace through the code to understand how this bug manifests. Follow the execution path from user action through the code to where the error occurs. Identify key decision points and data transformations."

   **Agent 2 - Find related correct handling:**
   - "Find similar code in the codebase that handles this case correctly. Look for patterns, guards, or validations that prevent this type of bug. Identify why this code works but the buggy code doesn't."

   **Agent 3 - Find similar potential bugs:**
   - "Search the codebase for similar patterns that might have the same bug. Look for code using similar functions, data types, or execution paths. List locations that should be reviewed."

2. **Read all files identified by agents**

3. **Analyze findings**:
   - What is the exact condition that triggers the bug?
   - What assumption in the code is violated?
   - What missing check or validation causes the failure?
   - Is there a deeper design issue?

4. **Document using ROOT-CAUSE-TEMPLATE.md**:
   - Save as `.claude/docs/$BRANCH_NAME/ROOT-CAUSE.md`
   - Include investigation steps
   - Clearly state the root cause (WHY, not just WHERE)
   - List related code that may have similar issues

**Template**: `.claude/docs/templates/ROOT-CAUSE-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/ROOT-CAUSE.md`

---

## Phase 4: Fix Planning

**Goal**: Design minimal, safe fix

**Actions**:
1. **Identify smallest change** that fixes root cause:
   - Prefer adding validation/guards over large refactors
   - Change only what's necessary to fix this bug
   - Avoid "while I'm here" changes

2. **Consider edge cases**:
   - What inputs could still cause problems after this fix?
   - Are there similar cases that need the same fix?
   - Could this fix introduce new bugs?

3. **Identify regression risk**:
   - What code depends on the current behavior?
   - Could this fix break working functionality?
   - What tests should be run to verify?

4. **Document using FIX-PLAN-TEMPLATE.md**:
   - Save as `.claude/docs/$BRANCH_NAME/FIX-PLAN.md`
   - Describe the minimal fix approach
   - List files to modify
   - Document tests to add
   - Include rollback plan

5. **Ask user to confirm** the fix approach:
   - Present the planned fix clearly
   - Explain why this approach
   - Highlight any risks
   - Get explicit approval before implementing

**Template**: `.claude/docs/templates/FIX-PLAN-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/FIX-PLAN.md`

---

## Phase 4.5: Specification Workflow (MANDATORY)

**Goal**: Generate comprehensive bug fix specifications using /spec-workflow

**CRITICAL**: This phase is MANDATORY - always run complete spec-workflow for every bug fix

### Execute Complete Specification Workflow

**ALWAYS run all 4 phases of /spec-workflow**:

1. **Phase 1: User Journey Analysis**
   - Map the journey where the bug occurs
   - Document expected vs actual behavior
   - Identify all affected paths and edge cases
   - Generate Mermaid diagrams showing bug manifestation

2. **Phase 2: Requirements Extraction (EARS)**
   - Convert bug fix into EARS-formatted requirements
   - Use "Unwanted" pattern for buggy behavior
   - Use appropriate pattern for correct behavior
   - Atomic decomposition (3-5 iterations)
   - Build dependency graph

3. **Phase 3: TDD Strategy Generation (Gherkin)**
   - Create regression test scenarios
   - Tag with `@regression @BUG-XXX`
   - Generate scenarios (reproduction, edge cases, related bugs)
   - Map step definitions
   - Define test fixtures

4. **Phase 4: Traceability Verification**
   - Ensure bidirectional traceability
   - Link bug to affected journeys/requirements
   - Verify 100% regression test coverage
   - Generate verification report

### Documents Generated

The spec-workflow will generate in `.claude/docs/$BRANCH_NAME/`:
- ✅ `USER-JOURNEYS.md` - Journey analysis showing bug manifestation
- ✅ `REQUIREMENTS.md` - EARS-formatted fix requirements (with Unwanted patterns)
- ✅ `TDD-STRATEGY.md` - Gherkin regression test specifications
- ✅ `TRACEABILITY-MATRIX.md` - Bidirectional traceability
- ✅ `VERIFICATION-REPORT.md` - Quality assurance
- ✅ `features/bug-*.feature` - Executable regression test files

### Additional Bug Fix Documentation

After spec-workflow completes, generate bug-specific supporting documents:

1. **`.claude/docs/$BRANCH_NAME/BUG-SPECIFICATION.md`**
   - Transform REQUIREMENTS.md into detailed bug specifications
   - Document expected vs actual behavior using EARS
   - Include root cause analysis from Phase 3
   - Map to affected code locations

2. **`.claude/docs/$BRANCH_NAME/REGRESSION-TESTS.md`**
   - Extract from TDD-STRATEGY.md
   - Comprehensive regression test suite
   - Tests for the specific bug condition
   - Tests for related edge cases
   - Tests to prevent similar bugs

3. **`.claude/docs/$BRANCH_NAME/TEST-FIXTURES.md`**
   - Test data that triggers the bug
   - Valid data for regression tests
   - Edge case data
   - Reusable fixtures for all test scenarios

4. **`.claude/docs/$BRANCH_NAME/FIX-IMPLEMENTATION-GUIDE.md`**
   - Step-by-step fix implementation guide
   - Minimal change approach
   - Verification checkpoints
   - Rollback plan

**Note**: Project-level documents (PROJECT-PLAN.md, GIT-STRATEGY.md, DEPENDENCY-GRAPH.md, PARALLEL-GROUPS.md, CRITICAL-PATH.md) are NOT generated for individual bug fixes - these are only created by /start-project for new projects.

### Present Specification Summary

After spec-workflow and supporting docs are complete:

```markdown
## Bug Fix Specification Complete

### Documents Generated:
- ✅ USER-JOURNEYS.md (showing bug manifestation)
- ✅ REQUIREMENTS.md ([N] fix requirements with Unwanted patterns)
- ✅ TDD-STRATEGY.md ([N] regression test scenarios)
- ✅ features/bug-*.feature ([N] regression test files)
- ✅ TRACEABILITY-MATRIX.md (100% coverage)
- ✅ VERIFICATION-REPORT.md
- ✅ BUG-SPECIFICATION.md (detailed bug analysis)
- ✅ REGRESSION-TESTS.md (comprehensive test suite)
- ✅ TEST-FIXTURES.md (test data)
- ✅ FIX-IMPLEMENTATION-GUIDE.md (step-by-step guide)

### Statistics:
- Affected Journeys: [N]
- Fix Requirements: [N]
- Regression Tests: [N]
- Coverage: 100%

---

## ⛔ STOP - User Approve Specs Before Implementation

Review the generated specifications above.

**Type "continue" or "approve" to proceed to Phase 5 (Implementation).**
```

**WAIT for user confirmation** before continuing to Phase 5

---

## Phase 5: Implementation (Test-First)

**Goal**: Fix with validated solution

**CRITICAL**: DO NOT START without user approval of fix plan

**Actions**:

1. **Write reproduction test** (if not already done in Phase 2)
2. **Run test** - confirm it fails (RED)
3. **Write minimal fix** - only the changes needed
4. **Run test** - confirm it passes (GREEN)
5. **Add regression tests** for related edge cases
6. **Run all tests** - confirm no regressions
7. **Run quality gate**:
   ```bash
   bash .claude/scripts/quality-gate.sh
   ```
8. **Run security gate** if relevant (user input, auth, etc.):
   ```bash
   bash .claude/scripts/security-gate.sh
   ```
9. **Commit** if gates pass:
   ```bash
   git add .
   git commit -m "fix: $BRANCH_NAME"
   ```

**Example Fix Pattern**:
```javascript
// Before (buggy)
function login(credentials) {
  if (credentials.email.length > 0) { // Crashes if email is null
    // ...
  }
}

// After (fixed)
function login(credentials) {
  if (credentials.email?.length > 0) { // Safe navigation
    // ...
  }
}
```

---

## Phase 6: Verification

**Goal**: Ensure fix is complete and safe

**Actions**:
1. **Manual testing**:
   - Test the fixed behavior manually
   - Verify edge cases work correctly
   - Check related functionality isn't broken

2. **Check for similar bugs**:
   - Review locations from ROOT-CAUSE.md
   - Test similar patterns for the same issue
   - Document any additional bugs found

3. **Code review**:
   - Is the fix simple and clear?
   - Does it solve the root cause?
   - Are there unintended side effects?
   - Is the test coverage adequate?

4. **Present findings to user**:
   - Bug is fixed
   - Tests pass
   - No regressions found
   - Any similar bugs identified
   - Ready to merge

---

## Phase 7: Summary and Merge

**Goal**: Document what was accomplished, merge the fix, and clean up worktree

**Actions**:
1. **Mark all todos complete**
2. **Commit any remaining changes**:
   ```bash
   git add .
   git commit -m "fix: $BRANCH_NAME - complete fix with tests" || echo "Nothing to commit"
   ```
3. **Add documentation directory to .gitignore** (in worktree):
   ```bash
   echo ".claude/docs/$BRANCH_NAME/" >> .gitignore
   git add .gitignore
   git commit -m "chore: add bug docs to gitignore" || echo "Nothing to commit"
   ```
4. **Return to main repo and merge**:
   ```bash
   # Navigate to main repo
   cd $MAIN_REPO_PATH

   # Pull latest changes
   git pull --no-rebase

   # Merge the fix branch
   git merge --no-ff $BRANCH_NAME -m "fix: $BRANCH_NAME"
   ```
5. **Push to remote**:
   ```bash
   git push origin main
   ```
6. **Clean up worktree**:
   ```bash
   # Remove the worktree
   git worktree remove $WORKTREE_PATH

   # Optionally delete the fix branch
   git branch -d $BRANCH_NAME

   # Prune any stale worktree references
   git worktree prune
   ```
7. **Summarize**:
   - Bug that was fixed
   - Root cause identified
   - Files changed
   - Tests added
   - Documents generated (BUG-REPORT.md, ROOT-CAUSE.md, FIX-PLAN.md, BUG-SPECIFICATION.md)
   - Similar bugs found (if any)
   - Regression tests created
   - Worktree cleaned up

**Note**: The user can keep the worktree for further work by skipping step 6.

---

## Document Artifacts

This workflow generates planning documents before implementation:

1. **`.claude/docs/$BRANCH_NAME/BUG-REPORT.md`** - Bug documentation (severity, steps to reproduce, expected vs actual)
2. **`.claude/docs/$BRANCH_NAME/ROOT-CAUSE.md`** - Root cause analysis (investigation steps, WHY the bug occurs)
3. **`.claude/docs/$BRANCH_NAME/FIX-PLAN.md`** - Fix strategy (minimal change, tests, risk assessment)
4. **`.claude/docs/$BRANCH_NAME/BUG-SPECIFICATION.md`** - EARS-formatted bug specification with regression tests

The documentation directory is added to `.gitignore` at the end of the workflow.

---

## Bug Fix vs Feature Development

| Aspect | feature-dev | bug-fix |
|--------|-------------|---------|
| Scope | New functionality | Surgical fixes to existing code |
| Branch naming | `feature/...` | `fix/...` |
| Worktree naming | `../project-feature-xxx` | `../project-fix-xxx` |
| Documentation | REQUIREMENTS.md, SPECIFICATIONS.md, TDD-STRATEGY.md | BUG-REPORT.md, ROOT-CAUSE.md, FIX-PLAN.md, BUG-SPECIFICATION.md |
| Exploration | Understanding patterns for new feature | Tracing bug manifestation and root cause |
| Architecture | Design new architecture | Minimal change to existing code |
| Testing | TDD for new code | Reproduction test + regression tests |
| Specification | spec-workflow (optional) | EARS-formatted bug spec (recommended) |

---

*End of bug-fix command*
