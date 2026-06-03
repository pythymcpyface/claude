# Bug Fix — Phase Reference

Detailed actions, scripts, and stop-points for every phase of the bug-fix workflow. Read the section corresponding to your current phase.

---

## Phase 0: Worktree Setup

**Goal**: Create a git worktree for isolated bug fix development.

### Pre-flight: Orphaned worktree cleanup

```bash
git worktree list
git worktree prune -v

for wt_path in $(git worktree list | tail -n +2 | awk '{print $1}'); do
  if [ ! -d "$wt_path" ]; then
    echo "Orphaned worktree reference: $wt_path"
    git worktree remove "$wt_path" --force 2>/dev/null || true
  fi
done
```

If orphans found, ask user:
1. Clean up all orphaned worktrees
2. Review each individually
3. Skip cleanup (not recommended)

### Branch naming convention (mandatory)

| Type | Pattern | Example |
|------|---------|---------|
| Bugfix | `bugfix/<description>` | `bugfix/login-timeout` |
| Bugfix + Issue | `bugfix/<issue-id>-<description>` | `bugfix/GH-789-login-crash` |
| Hotfix | `hotfix/<description>` | `hotfix/security-patch` |
| Hotfix + Issue | `hotfix/<issue-id>-<description>` | `hotfix/JIRA-123-critical-fix` |

Rules:
1. Lowercase only
2. Hyphens between words; slash separates type prefix
3. ≤ 50 characters total
4. No spaces or `~ ^ : * ? [ ] @`
5. Include issue ID when available
6. `bugfix/` for non-critical, `hotfix/` for production-critical

### Actions

1. Generate branch name (severity → bugfix/hotfix; kebab-case description ≤ 40 chars; include issue ID).
2. Ask user to confirm or modify.
3. Create worktree:

   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_NAME=$(basename "$REPO_ROOT")
   WORKTREE_PATH="../${REPO_NAME}-$(echo $BRANCH_NAME | sed 's/\//-/g')"

   git worktree add "$WORKTREE_PATH" -b $BRANCH_NAME

   echo "{\"branch\":\"$BRANCH_NAME\",\"created\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"pid\":$$}" \
     > "$WORKTREE_PATH/.worktree-session"
   ```

4. Store: `$BRANCH_NAME`, `$WORKTREE_PATH`, `$MAIN_REPO_PATH`.

Example transformations:
- "Login crashes when email is null" → `bugfix/login-null-email`
- "Fix GH-789: Payment timeout on mobile" → `bugfix/GH-789-payment-timeout`
- "Critical: Security vulnerability in API" → `hotfix/api-security-vuln`

### Worktree session isolation

The `.worktree-session` marker:
- Lets new Claude sessions detect active worktrees
- Prevents interference with active worktree work
- Allows fresh work on main while worktree is active

**Benefits**: isolated context window per fix; main repo untouched; no stash; clean state.

---

## Phase 1: Bug Report

**Goal**: Document the bug comprehensively.

Input: user's bug description (`$ARGUMENTS`).

Actions:
1. Create todo list with all phases.
2. Ask clarifying questions:
   - Expected behavior?
   - Actual behavior?
   - Reproduction steps (steps, URL, data)?
   - Severity/impact (CRITICAL/HIGH/MEDIUM/LOW)?
   - Error messages, logs, screenshots?
   - When did this start?
   - Intermittent or consistent?
3. Document using `BUG-REPORT-TEMPLATE.md`. Save to `.claude/docs/$BRANCH_NAME/BUG-REPORT.md`.

**Template**: `.claude/docs/templates/BUG-REPORT-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/BUG-REPORT.md`

---

## Phase 2: Bug Reproduction

**Goal**: Reproduce the bug before attempting to fix.

**CRITICAL** — do not proceed until the bug is reproduced.

Actions:
1. Attempt to reproduce using bug-report steps. Follow exactly; same data; check error messages, logs, console.
2. **If reproducible**: document confirmation; note any deviations; proceed.
3. **If not reproducible**: ask user for more specific steps, environment details (browser, version, config), sample data, screenshots/recordings. Retry.
4. Create reproduction test (failing):
   - Captures the bug behavior
   - Test FAILS with current code
   - Test PASSES after fix
   - Name: `BUG-XXX: [brief description]`
5. Run the test; confirm it fails. If it passes, the bug isn't being reproduced correctly.

Example:

```javascript
describe('BUG-001: Login crashes when email is null', () => {
  it('should handle null email gracefully', () => {
    const credentials = { email: null, password: 'test123' };

    const result = () => login(credentials);

    expect(result).toThrow(ValidationError);
  });
});
```

---

## Phase 3: Root Cause Analysis

**Goal**: Find WHY the bug occurs, not just WHERE.

**CRITICAL** — understanding root cause prevents similar bugs and ensures the correct fix.

### Actions

1. Launch 2-3 exploration agents in parallel:

   **Agent 1 — Trace the bug manifestation**: "Trace through the code to understand how this bug manifests. Follow the execution path from user action through the code to where the error occurs. Identify key decision points and data transformations."

   **Agent 2 — Find related correct handling**: "Find similar code in the codebase that handles this case correctly. Look for patterns, guards, or validations that prevent this type of bug. Identify why this code works but the buggy code doesn't."

   **Agent 3 — Find similar potential bugs**: "Search the codebase for similar patterns that might have the same bug. Look for code using similar functions, data types, or execution paths. List locations that should be reviewed."

2. Read all files identified by agents.

3. Analyze findings:
   - Exact condition that triggers the bug?
   - What assumption in the code is violated?
   - What missing check or validation causes the failure?
   - Deeper design issue?

4. Document using `ROOT-CAUSE-TEMPLATE.md`:
   - Investigation steps
   - State the root cause (WHY, not just WHERE)
   - Related code that may have similar issues

**Template**: `.claude/docs/templates/ROOT-CAUSE-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/ROOT-CAUSE.md`

---

## Phase 4: Fix Planning

**Goal**: Design minimal, safe fix.

Actions:
1. Identify smallest change that fixes root cause:
   - Prefer adding validation/guards over large refactors
   - Change only what's necessary
   - Avoid "while I'm here" changes
2. Consider edge cases: what other inputs could still cause problems? Similar cases need the same fix? Could this introduce new bugs?
3. Identify regression risk: code depending on current behavior? Could fix break working functionality? Tests to run?
4. Document using `FIX-PLAN-TEMPLATE.md`. Save to `.claude/docs/$BRANCH_NAME/FIX-PLAN.md`. Include minimal-fix approach, files to modify, tests to add, rollback plan.
5. Ask user to confirm approach: present clearly, explain why, highlight risks, get explicit approval.

**Template**: `.claude/docs/templates/FIX-PLAN-TEMPLATE.md`
**Output**: `.claude/docs/$BRANCH_NAME/FIX-PLAN.md`

---

## Phase 4.5: Specification Workflow (MANDATORY)

**Goal**: Generate comprehensive bug fix specifications via `/spec-workflow`.

Run all 4 phases:

1. **User Journey Analysis** — map journey where bug occurs; expected vs actual; affected paths and edge cases; Mermaid diagrams of bug manifestation.
2. **Requirements Extraction (EARS)** — convert fix to EARS requirements; use **Unwanted** pattern for buggy behavior; appropriate pattern for correct behavior; atomic decomposition (3-5 iterations); dependency graph.
3. **TDD Strategy (Gherkin)** — regression test scenarios; tag `@regression @BUG-XXX`; reproduction/edge/related-bug scenarios; step definitions; fixtures.
4. **Traceability Verification** — bidirectional traceability; link bug to journeys/requirements; 100% regression coverage; verification report.

Generated in `.claude/docs/$BRANCH_NAME/`:
- `USER-JOURNEYS.md` (showing bug manifestation)
- `REQUIREMENTS.md` (EARS Unwanted patterns)
- `TDD-STRATEGY.md`
- `TRACEABILITY-MATRIX.md`, `VERIFICATION-REPORT.md`
- `features/bug-*.feature` (executable regression tests)

After `/spec-workflow` completes, generate bug-specific docs:

1. `BUG-SPECIFICATION.md` — transform REQUIREMENTS into detailed bug specs; expected vs actual using EARS; root cause from Phase 3; mapped to code locations.
2. `REGRESSION-TESTS.md` — comprehensive suite; specific bug condition; edge cases; tests preventing similar bugs.
3. `TEST-FIXTURES.md` — data triggering the bug; valid regression data; edge cases; reusable fixtures.
4. `FIX-IMPLEMENTATION-GUIDE.md` — step-by-step; minimal change; verification checkpoints; rollback plan.

> Project-level docs (PROJECT-PLAN, GIT-STRATEGY, etc.) NOT generated here — those belong to `/start-project`.

### Stop-point: present summary

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

**Wait for user confirmation** before continuing to Phase 5.

---

## Phase 5: Implementation (Test-First)

**Goal**: Fix with validated solution.

**CRITICAL** — do NOT start without user approval of fix plan.

Actions:
1. Write reproduction test (if not done in Phase 2).
2. Run test — confirm fails (RED).
3. Write minimal fix — only the changes needed.
4. Run test — confirm passes (GREEN).
5. Add regression tests for related edge cases.
6. Run all tests — confirm no regressions.
7. Run quality gate:

   ```bash
   bash .claude/scripts/quality-gate.sh
   ```

8. Run security gate if relevant (user input, auth, etc.):

   ```bash
   bash .claude/scripts/security-gate.sh
   ```

9. Commit if gates pass:

   ```bash
   git add .
   git commit -m "fix: $BRANCH_NAME"
   ```

Example fix pattern:

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

**Goal**: Ensure fix is complete and safe.

Actions:
1. Manual testing: test fixed behavior, verify edge cases, check related functionality not broken.
2. Check for similar bugs: review locations from `ROOT-CAUSE.md`; test similar patterns; document any additional bugs found.
3. Code review:
   - Is the fix simple and clear?
   - Does it solve the root cause?
   - Unintended side effects?
   - Test coverage adequate?
4. Present findings to user: bug fixed; tests pass; no regressions; similar bugs identified; ready to merge.

---

## Phase 7: Summary and Merge

**Goal**: Document, merge, clean up worktree.

Actions:

1. Mark all todos complete.
2. Commit any remaining changes:

   ```bash
   git add .
   git commit -m "fix: $BRANCH_NAME - complete fix with tests" || echo "Nothing to commit"
   ```

3. Add documentation directory to `.gitignore`:

   ```bash
   echo ".claude/docs/$BRANCH_NAME/" >> .gitignore
   git add .gitignore
   git commit -m "chore: add bug docs to gitignore" || echo "Nothing to commit"
   ```

4. Return to main repo and merge:

   ```bash
   cd $MAIN_REPO_PATH
   git pull --no-rebase
   git merge --no-ff $BRANCH_NAME -m "fix: $BRANCH_NAME"
   ```

5. Push:

   ```bash
   git push origin main
   ```

6. Clean up worktree:

   ```bash
   git worktree remove $WORKTREE_PATH
   git branch -d $BRANCH_NAME
   git worktree prune
   ```

7. Summarize: bug fixed, root cause identified, files changed, tests added, documents generated, similar bugs found (if any), regression tests created, worktree cleaned up.

> The user can keep the worktree by skipping step 6.
