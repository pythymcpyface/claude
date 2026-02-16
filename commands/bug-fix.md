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

## Phase 0: Branch Setup

**Goal**: Create and checkout a fix branch

**Actions**:
1. Generate a branch name from the bug description (use kebab-case, max 50 chars)
2. Prefix with `fix/` (e.g., `fix/login-null-pointer`, `fix/payment-validation-failure`)
3. Ask user to confirm or modify the branch name
4. Create and checkout the branch: `git checkout -b <branch-name>`
5. **Store branch name as variable** `$BRANCH_NAME` for documentation naming

**Example**:
- Bug: "Login crashes when email is null"
- Branch name: `fix/login-null-pointer`
- Documentation directory: `.claude/docs/$BRANCH_NAME/`

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

**Goal**: Document what was accomplished and merge the fix

**Actions**:
1. **Mark all todos complete**
2. **Add documentation directory to .gitignore**:
   ```bash
   echo ".claude/docs/$BRANCH_NAME/" >> .gitignore
   ```
3. **Commit the .gitignore change** if modified
4. **Merge the fix branch to main**:
   ```bash
   git checkout main
   git pull --no-rebase
   git merge --no-ff $BRANCH_NAME -m "fix: $BRANCH_NAME"
   ```
5. **Push to remote**:
   ```bash
   git push origin main
   ```
6. **Optionally delete the fix branch**:
   ```bash
   git branch -d $BRANCH_NAME
   ```
7. **Summarize**:
   - Bug that was fixed
   - Root cause identified
   - Files changed
   - Tests added
   - Documents generated
   - Similar bugs found (if any)

---

## Document Artifacts

This workflow generates three planning documents before implementation:

1. **`.claude/docs/$BRANCH_NAME/BUG-REPORT.md`** - Bug documentation (severity, steps to reproduce, expected vs actual)
2. **`.claude/docs/$BRANCH_NAME/ROOT-CAUSE.md`** - Root cause analysis (investigation steps, WHY the bug occurs)
3. **`.claude/docs/$BRANCH_NAME/FIX-PLAN.md`** - Fix strategy (minimal change, tests, risk assessment)

The documentation directory is added to `.gitignore` at the end of the workflow.

---

## Bug Fix vs Feature Development

| Aspect | feature-dev | bug-fix |
|--------|-------------|---------|
| Scope | New functionality | Surgical fixes to existing code |
| Branch naming | `feature/...` | `fix/...` |
| Documentation | REQUIREMENTS.md, SPECIFICATIONS.md, TDD-STRATEGY.md | BUG-REPORT.md, ROOT-CAUSE.md, FIX-PLAN.md |
| Exploration | Understanding patterns for new feature | Tracing bug manifestation and root cause |
| Architecture | Design new architecture | Minimal change to existing code |
| Testing | TDD for new code | Reproduction test + regression tests |

---

*End of bug-fix command*
