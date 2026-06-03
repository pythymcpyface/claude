# Feature Dev — Phase Reference

Detailed actions, scripts, and stop-points for every phase of the feature-dev workflow. Read the section corresponding to your current phase.

---

## Phase 0: Worktree Setup

**Goal**: Create a git worktree for isolated feature development.

### Pre-flight: Orphaned worktree cleanup

Before creating a new worktree, clean up orphans from previous incomplete sessions:

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
| Feature | `feature/<description>` | `feature/user-auth-oauth` |
| Feature + Issue | `feature/<issue-id>-<description>` | `feature/JIRA-123-oauth` |
| Bugfix | `bugfix/<description>` | `bugfix/login-timeout` |
| Hotfix | `hotfix/<description>` | `hotfix/security-patch` |
| Release | `release/v<version>` | `release/v2.1.0` |
| Docs | `docs/<description>` | `docs/api-reference` |
| Refactor | `refactor/<description>` | `refactor/auth-module` |
| Test | `test/<description>` | `test/integration-coverage` |
| Chore | `chore/<description>` | `chore/update-deps` |

Rules:
1. Lowercase only
2. Hyphens to separate words; slash separates type prefix
3. Total length under 50 characters
4. No spaces or special characters (`~ ^ : * ? [ ] @`)
5. Include issue tracker ID when available

Example transformations:
- "Add user authentication with OAuth" → `feature/user-auth-oauth`
- "Fix JIRA-456: Login timeout on mobile" → `bugfix/JIRA-456-login-timeout`
- "Critical security patch for API" → `hotfix/api-security-patch`

### Actions

1. Generate branch name (default type `feature`; kebab-case description ≤ 40 chars after prefix; include issue ID if provided).
2. Ask user to confirm or modify the branch name.
3. Create the worktree (sibling to current repo):

   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_NAME=$(basename "$REPO_ROOT")
   WORKTREE_PATH="../${REPO_NAME}-$(echo $BRANCH_NAME | sed 's/\//-/g')"

   git worktree add "$WORKTREE_PATH" -b $BRANCH_NAME

   echo "{\"branch\":\"$BRANCH_NAME\",\"created\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"pid\":$$}" \
     > "$WORKTREE_PATH/.worktree-session"
   ```

4. Store for later use: `$BRANCH_NAME`, `$WORKTREE_PATH`, `$MAIN_REPO_PATH` (= `$REPO_ROOT`).

### Worktree session isolation

The `.worktree-session` marker:
- Lets new Claude sessions detect active worktrees
- Prevents interference with active worktree work
- Allows fresh work on main while worktree is active

**Benefits**: isolated context window per feature; main repo untouched for parallel work; no stash needed; clean state per Claude instance; enables parallel agents.

---

## Phase 1: Discovery

**Goal**: Understand what to build.

Initial request: `$ARGUMENTS`

Actions:
1. Create todo list with all phases.
2. If feature unclear, ask user: what problem? what should it do? any constraints?
3. Summarize understanding and confirm with user.

---

## Phase 2: Codebase Exploration

**Goal**: Understand relevant code at high and low levels.

Actions:
1. Launch 2-3 `code-explorer` agents in parallel. Each:
   - Traces code comprehensively, focusing on abstractions, architecture, and control flow
   - Targets a different aspect (similar features, high-level design, UX, extension points)
   - Returns 5-10 key files to read

   Example prompts:
   - "Find features similar to [X] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [area]"
   - "Analyze the current implementation of [existing feature]"
   - "Identify UI patterns, testing approaches, or extension points relevant to [feature]"

2. Read all files identified by agents to build deep understanding.
3. Present comprehensive summary of findings and patterns.

---

## Phase 3: Clarifying Questions

**Goal**: Resolve all ambiguities before designing.

**CRITICAL — do not skip.**

Actions:
1. Review codebase findings + original request.
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance.
3. Present all questions to the user in a clear, organized list.
4. Wait for answers before proceeding.

If user says "whatever you think is best", give your recommendation and get explicit confirmation.

---

## Phase 3.5: Specification Workflow (MANDATORY)

**Goal**: Generate comprehensive feature specifications via `/spec-workflow`.

Run all 4 phases:

1. **User Journey Analysis** — map all paths, roles, goals, entry points, edge cases, error states. Mermaid diagrams.
2. **Requirements Extraction (EARS)** — convert journeys to EARS-formatted requirements; atomic decomposition (3-5 iterations); dependency graph; priorities; test IDs.
3. **TDD Strategy (Gherkin)** — executable Gherkin specs; happy/sad/edge/security scenarios; step definitions; fixtures.
4. **Traceability Verification** — bidirectional traceability; 100% coverage; verification report.

Generated in `.claude/docs/$BRANCH_NAME/`:
- `USER-JOURNEYS.md`, `REQUIREMENTS.md`, `TDD-STRATEGY.md`
- `TRACEABILITY-MATRIX.md`, `VERIFICATION-REPORT.md`
- `features/*.feature`

After `/spec-workflow` completes, generate feature-specific docs:

1. `SPECIFICATIONS.md` — transform REQUIREMENTS.md into atomic specs (User Story, Acceptance Criteria, Functional Spec, Performance, Security, Testing, Dependencies). Iterate 3-5 times.
2. `TEST-FIXTURES.md` — valid/invalid test data, reusable fixtures.
3. `INTEGRATION-TESTS.md` — cross-spec tests, critical workflows, end-to-end scenarios.
4. `IMPLEMENTATION-ROADMAP.md` — step-by-step implementation guide, checkpoints, dependencies.

> Project-level docs (`PROJECT-PLAN.md`, `GIT-STRATEGY.md`, `DEPENDENCY-GRAPH.md`, `PARALLEL-GROUPS.md`, `CRITICAL-PATH.md`) are NOT generated here — those belong to `/start-project`.

### Stop-point: present summary

```markdown
## Feature Specification Complete

### Documents Generated:
- ✅ USER-JOURNEYS.md ([N] journeys, [N] steps)
- ✅ REQUIREMENTS.md ([N] atomic requirements)
- ✅ TDD-STRATEGY.md ([N] test scenarios)
- ✅ features/*.feature ([N] feature files)
- ✅ TRACEABILITY-MATRIX.md (100% coverage)
- ✅ VERIFICATION-REPORT.md
- ✅ SPECIFICATIONS.md ([N] atomic specs)
- ✅ TEST-FIXTURES.md
- ✅ INTEGRATION-TESTS.md
- ✅ IMPLEMENTATION-ROADMAP.md

### Statistics:
- Roles: [N]
- Journeys: [N]
- Requirements: [N] (Must-have: [N], Should-have: [N])
- Specifications: [N]
- Test Scenarios: [N]
- Coverage: 100%

---

## ⛔ STOP - User Approve Specs Before Architecture Design

Review the generated specifications above.

**Type "continue" or "approve" to proceed to Phase 4 (Architecture Design).**
```

**Wait for user confirmation** before continuing to Phase 4.

---

## Phase 4: Architecture Design

**Goal**: Multiple implementation approaches with different trade-offs.

Actions:
1. Launch 2-3 `code-architect` agents in parallel with different focuses:
   - Minimal changes (smallest change, maximum reuse)
   - Clean architecture (maintainability, elegant abstractions)
   - Pragmatic balance (speed + quality)
2. Form your opinion on which fits best (consider: small fix vs large feature, urgency, complexity, team context).
3. Present to user: brief summary of each approach, trade-offs, **your recommendation with reasoning**, concrete implementation differences.
4. Ask user which approach they prefer.

---

## Phase 4.5: Architecture Validation

**Goal**: Validate the chosen architecture against codebase patterns and best practices.

**CRITICAL** — ensure alignment with existing conventions before proceeding.

Actions:
1. Review chosen architecture against codebase patterns.
2. Verify design pattern alignment: existing patterns, naming conventions, module organization, error handling.
3. Validate SOLID principles:
   - Single Responsibility — each component has one job
   - Open/Closed — extensible without modification
   - Liskov Substitution — subtypes substitutable
   - Interface Segregation — focused interfaces
   - Dependency Inversion — depend on abstractions
4. Check integration points: external/internal dependencies justified and documented; API boundaries defined.
5. Validate error handling strategy.
6. Create ADR (Architecture Decision Record) if significant.
7. Document in `.claude/docs/$BRANCH_NAME/ARCHITECTURE-VALIDATION.md`.
8. Present validation to user with concerns/adjustments.

**Template**: `.claude/docs/templates/ARCHITECTURE-VALIDATION.md`
**Output**: `.claude/docs/$BRANCH_NAME/ARCHITECTURE-VALIDATION.md`

---

## Phase 4.6: Verify Documentation Complete

**Goal**: Confirm all spec documents are ready for implementation.

Verify all docs exist in `.claude/docs/$BRANCH_NAME/`:
- [ ] USER-JOURNEYS.md
- [ ] REQUIREMENTS.md
- [ ] TDD-STRATEGY.md
- [ ] TRACEABILITY-MATRIX.md
- [ ] VERIFICATION-REPORT.md
- [ ] features/*.feature
- [ ] SPECIFICATIONS.md
- [ ] TEST-FIXTURES.md
- [ ] INTEGRATION-TESTS.md
- [ ] IMPLEMENTATION-ROADMAP.md

### Stop-point: present summary

```markdown
## Feature Documentation Complete

### All Documents Verified:
- ✅ USER-JOURNEYS.md - Exhaustive journey analysis
- ✅ REQUIREMENTS.md - EARS-formatted atomic requirements
- ✅ TDD-STRATEGY.md - Gherkin/BDD specifications
- ✅ TRACEABILITY-MATRIX.md - 100% coverage verification
- ✅ VERIFICATION-REPORT.md - Quality assurance
- ✅ features/*.feature - Executable Gherkin files
- ✅ SPECIFICATIONS.md - Atomic specifications (iterated 3-5 times)
- ✅ TEST-FIXTURES.md - Test data fixtures
- ✅ INTEGRATION-TESTS.md - Cross-specification tests
- ✅ IMPLEMENTATION-ROADMAP.md - Step-by-step guide

### Ready for Implementation
All planning and specification work is complete.

---

## ⛔ DOCUMENTATION COMPLETE - STOP POINT ⛔

**Planning Phase Complete.** All documentation has been generated and verified.

**DO NOT proceed to implementation automatically.**

Present the documentation summary and **WAIT** for explicit approval before continuing to Phase 5.

The user must explicitly request implementation to proceed.
```

---

## Phase 5: Implementation (Strict TDD)

**⚠️ Manual continuation only — do not start automatically.**

**Goal**: Build the feature following Red-Green-Refactor.

Requires explicit user approval. Only starts after all docs (`REQUIREMENTS.md`, `SPECIFICATIONS.md`, `TDD-STRATEGY.md`) are complete.

### TDD loop for each SPEC-XXX (in dependency order)

1. Read test cases from `.claude/docs/$BRANCH_NAME/TDD-STRATEGY.md` for this spec.
2. Write failing test (RED) — create test file with test case.
3. Run test, confirm it fails with expected error.
4. Write minimal implementation to make test pass.
5. Run test, confirm it passes (GREEN).
6. Refactor if needed (REFACTOR).
7. Run `.claude/scripts/tdd-gate.sh` to verify TDD compliance.
8. Run `.claude/scripts/quality-gate.sh` to verify code quality.
9. Commit if gates pass.

### Actions

1. Wait for explicit user approval.
2. Read all relevant files identified in previous phases.
3. Read `REQUIREMENTS.md`, `SPECIFICATIONS.md`, `TDD-STRATEGY.md`.
4. For each SPEC-XXX, follow TDD loop above.
5. Follow codebase conventions strictly.
6. Write clean, well-documented code.
7. Update todos as you progress.

---

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, readable, and functionally correct.

Actions:
1. Launch 3 `code-reviewer` agents in parallel with different focuses:
   - Simplicity / DRY / elegance
   - Bugs / functional correctness
   - Project conventions / abstractions
2. Consolidate findings; identify highest-severity issues to recommend fixing.
3. Present findings to user; ask what they want to do (fix now, fix later, proceed as-is).
4. Address based on user decision.

---

## Phase 6.2: UX Review

**Goal**: Validate UX quality (usability, accessibility, workflow).

Use `/ui-ux` for design intelligence, patterns, and tool recommendations.

Actions:
1. Review UX checklist: `.claude/docs/templates/UX-CHECKLIST.md`.
2. Verify user workflow: intuitive task completion, clear navigation, helpful error messages.
3. Check accessibility (WCAG 2.1 AA): contrast ratios, keyboard navigation, screen reader support, form labels.
4. Validate mobile responsiveness: touch targets ≥ 44×44px, small-screen layout, no horizontal scrolling.
5. Review edge cases: empty states with guidance, loading feedback, long content handled gracefully.
6. Document in `.claude/docs/$BRANCH_NAME/UX-REVIEW.md` if applicable.
7. Present findings with severity levels.

**Template**: `.claude/docs/templates/UX-CHECKLIST.md`

---

## Phase 6.5: Security Review

**Goal**: Verify security requirements before merging.

**CRITICAL** — security vulnerabilities must be addressed before merge.

Actions:
1. Run security gate: `bash .claude/scripts/security-gate.sh`.
2. Review security checklist: `.claude/docs/templates/SECURITY-CHECKLIST.md`.
3. Verify OWASP Top 10 coverage:
   - A01 Broken Access Control
   - A02 Cryptographic Failures
   - A03 Injection (SQL, XSS, Command)
   - A04 Insecure Design
   - A05 Security Misconfiguration
   - A06 Vulnerable Components
   - A07 Authentication Failures
   - A08 Data Integrity Failures
   - A09 Logging Failures
   - A10 Server-Side Request Forgery
4. Check for:
   - Hardcoded secrets (none allowed)
   - Input validation on all user input
   - Output encoding (XSS prevention)
   - Parameterized queries
   - Proper error handling (no information leakage)
5. Document in `.claude/docs/$BRANCH_NAME/SECURITY-REVIEW.md` if applicable.
6. Present findings with severity (HIGH/MEDIUM/LOW).
7. Address all HIGH severity issues before proceeding.

**Template**: `.claude/docs/templates/SECURITY-CHECKLIST.md`
**Script**: `.claude/scripts/security-gate.sh`

---

## Phase 7: Summary and Merge

**Goal**: Document what was accomplished, merge feature branch, clean up worktree.

Actions:

1. Mark all todos complete.
2. Commit any remaining changes:

   ```bash
   git add .
   git commit -m "feat: complete $BRANCH_NAME" || echo "Nothing to commit"
   ```

3. Add documentation directory to `.gitignore` (in worktree):

   ```bash
   echo ".claude/docs/$BRANCH_NAME/" >> .gitignore
   git add .gitignore
   git commit -m "chore: add feature docs to gitignore" || echo "Nothing to commit"
   ```

4. Return to main repo and merge:

   ```bash
   cd $MAIN_REPO_PATH
   git pull --no-rebase
   git merge --no-ff $BRANCH_NAME -m "feat: complete $BRANCH_NAME"
   ```

5. Push to remote:

   ```bash
   git push origin main
   ```

6. Clean up worktree:

   ```bash
   git worktree remove $WORKTREE_PATH
   git branch -d $BRANCH_NAME
   git worktree prune
   ```

7. Summarize: what was built, key decisions, files modified, documents generated, suggested next steps, worktree cleaned up.

> The user can keep the worktree by skipping step 6.
