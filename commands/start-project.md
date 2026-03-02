---
description: Generate planning documentation ONLY. Reads research/feasibility docs, outputs .claude/docs/*.md files. Does NOT write code or create implementation plans.
argument-hint: Project context (optional - reads existing research/feasibility docs or auto-runs /spec-workflow)
---

# Start Project - DOCUMENTATION GENERATION ONLY

## ⛔ THIS COMMAND DOES NOT WRITE CODE ⛔

**PURPOSE**: Generate planning documentation from specifications and research documents.
**OUTPUT**: `.claude/docs/$BRANCH/` directory with markdown files only.
**STOPPING POINT**: After documentation generation is complete.

**WHAT THIS COMMAND DOES:**
- ✅ Auto-run `/spec-workflow` if no specs exist (Phase 0)
- ✅ Read existing spec-workflow outputs or research/feasibility documents
- ✅ Synthesize specs into project documentation
- ✅ Generate `.claude/docs/$BRANCH/*.md` planning documents
- ✅ Generate `.claude/scripts/*.sh` helper scripts (not executed)

**WHAT THIS COMMAND DOES NOT DO:**
- ❌ Write ANY application code
- ❌ Create ANY implementation plans
- ❌ Create ANY source files (src/, tests/, config files, etc.)
- ❌ Run ANY setup commands
- ❌ Install ANY dependencies
- ❌ Execute ANY scripts

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROJECT INITIALIZATION FLOW                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 0: Check for Existing Specifications                      │
│      │                                                           │
│      ├─► Specs exist? ─► Read & Synthesize ─┐                   │
│      │                                       │                   │
│      └─► No specs? ─► Auto-run /spec-workflow │                  │
│                           │                   │                   │
│                           ▼                   │                   │
│                  ⛔ HARD STOP: Approve Specs   │                   │
│                           │                   │                   │
│                           └───────────────────┘                   │
│                                  │                               │
│                                  ▼                               │
│  Step 1-5: Generate Project Documentation                       │
│                                  │                               │
│                                  ▼                               │
│                    ⛔ HARD STOP: Approve Plan                    │
│                                  │                               │
│                                  ▼                               │
│                         /ralph-loop                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step 0: Check for Existing Specifications

### 0.1 Detect Branch and Spec Directory

```bash
# Get current branch name (sanitized for directory use)
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-zA-Z0-9]/-/g' || echo "main")
DOCS_DIR=".claude/docs/$BRANCH"

# Check for existing spec-workflow outputs
ls "$DOCS_DIR/REQUIREMENTS.md" 2>/dev/null
```

### 0.2 Decision Point

**If specs exist** (`$DOCS_DIR/REQUIREMENTS.md` found):
- Read existing spec-workflow outputs
- Skip to Step 1 for synthesis

**If no specs exist**:
- Proceed to 0.3 to auto-run spec-workflow

### 0.3 Auto-Run spec-workflow (If No Specs)

If no specifications exist, run the spec-workflow to generate them:

1. **Determine context source**:
   - Use argument provided to `/start-project` if available
   - Otherwise, search for research/feasibility documents
   - If neither, prompt user for feature description

2. **Run spec-workflow**:
   ```
   Execute the full 4-phase spec-workflow:
   - Phase 1: User Journey Analysis
   - Phase 2: Requirements Extraction (EARS)
   - Phase 3: TDD Strategy Generation (Gherkin)
   - Phase 4: Traceability Verification
   ```

3. **Present specs for approval**:
   ```markdown
   ## Specification Workflow Complete

   ### Documents Generated:
   - ✅ USER-JOURNEYS.md
   - ✅ REQUIREMENTS.md
   - ✅ TDD-STRATEGY.md
   - ✅ TRACEABILITY-MATRIX.md

   ---

   ## ⛔ STOP - User Approve Specs Before Continuing

   Review the generated specifications above.

   **Type "continue" or "approve" to proceed with project documentation generation.**
   ```

4. **Wait for user confirmation** before continuing to Step 1.

---

## Step 1: Read Input Sources

### 1.1 Read spec-workflow Outputs (Preferred)

If specs exist from Step 0 or were just generated:

```bash
# Read spec-workflow outputs
Read "$DOCS_DIR/USER-JOURNEYS.md"
Read "$DOCS_DIR/REQUIREMENTS.md"
Read "$DOCS_DIR/TDD-STRATEGY.md"
Read "$DOCS_DIR/TRACEABILITY-MATRIX.md"
```

Extract from these files:
- **USER-JOURNEYS.md** → Roles, goals, entry points, paths
- **REQUIREMENTS.md** → EARS-formatted atomic requirements
- **TDD-STRATEGY.md** → Gherkin scenarios and test IDs
- **TRACEABILITY-MATRIX.md** → Coverage verification

### 1.2 Fall Back to Research Documents (If No Specs)

If running spec-workflow was skipped and no specs exist:

```bash
# Find research/feasibility documents
Glob -pattern "*.md" -path .
Grep -pattern "research|feasibility|requirements" -glob "*.md" -i
```

Read any discovered research, feasibility, or requirements documents.

---

## Step 2: Generate All Documentation

### 2.1 Create Directory Structure

```bash
mkdir -p .claude/docs .claude/scripts
```

### 2.2 Generate `.claude/CLAUDE.md`

```markdown
# Project: [Project Name]

## Project Context
[Brief description]

## Stack
- **Language**: [from requirements]
- **Frameworks**: [from requirements]
- **Database/ORM**: [if applicable]
- **Testing**: [from requirements]

## Key Directories
- Source: [to be determined]
- Tests: [to be determined]

## Project Documentation References
- `.claude/docs/PROJECT-PLAN.md` - Complete project context
- `.claude/docs/SPECIFICATIONS.md` - Atomic specifications
- `.claude/docs/RISKS-AND-MITIGATIONS.md` - Risk analysis
- `.claude/docs/IMPLEMENTATION-ROADMAP.md` - Step-by-step guide with checkpoints
- `.claude/docs/TDD-MASTER-DOCUMENT.md` - All test cases
- `.claude/docs/TEST-FIXTURES.md` - Test data fixtures
- `.claude/docs/INTEGRATION-TESTS.md` - Cross-specification tests
- `.claude/docs/DEPENDENCY-GRAPH.md` - Specification dependencies
- `.claude/docs/PARALLEL-GROUPS.md` - Parallel execution groups
- `.claude/docs/CRITICAL-PATH.md` - Implementation priority
- `.claude/docs/GIT-STRATEGY.md` - Git workflow and conventions

## Development Standards
- Follow specifications exactly
- TDD approach: tests first, implementation after
- All tests must pass before committing

## Quality Gates
- No TypeScript errors (if applicable)
- No lint warnings
- Test coverage >80% on business logic
- Code review before merge

---

*Auto-generated from planning documents.*
```

### 2.3 Generate `.claude/docs/PROJECT-PLAN.md`

Use template from AUTONOMOUS-DEVELOPMENT-FLOW.md Phase 2:
- Executive Summary
- System Context (function, current state, future state)
- Requirements Summary (functional, non-functional, compliance)
- Technical Approach (architecture, tech stack, development approach)
- High-Level Roadmap
- Resource Requirements
- Risk Summary (high-level)
- Success Criteria
- Assumptions & Constraints

### 2.4 Generate `.claude/docs/GIT-STRATEGY.md`

```markdown
# Git Strategy

## Branching Model

### Primary Branches
- `main` - Production-ready code, always deployable
- `develop` - Integration branch for feature aggregation (optional)

### Feature Branches
- `feat/spec-XXX` - One branch per specification
  - Create from: `main` (or `develop` if using)
  - Merge back to: `main` (or `develop`)
  - Naming: `feat/spec-XXX` where XXX matches specification ID
  - Lifecycle: Short-lived (hours to days)

### Hotfix Branches
- `hotfix/description` - Emergency production fixes
  - Create from: `main`
  - Merge back to: `main` AND `develop`
  - Lifecycle: Critical path, expedited review

### Support Branches (if needed)
- `release/vX.Y.Z` - Release preparation
- `bugfix/description` - Non-critical bug fixes

## Commit Convention

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat(spec-XXX)` - New feature implementation
- `fix(spec-XXX)` - Bug fix for specification
- `docs` - Documentation only
- `refactor` - Code refactoring (no behavior change)
- `test` - Adding or updating tests
- `chore` - Build process, dependencies, tooling
- `perf` - Performance improvement
- `style` - Code style (formatting, semicolons, etc.)

### Subject Rules
- Use imperative mood ("add" not "added" or "adds")
- Lowercase first letter
- No period at end
- Limit to 72 characters
- Reference spec ID: `feat(spec-001): add user authentication`

### Body Rules (optional but recommended)
- Wrap at 72 characters
- Explain WHAT and WHY (not HOW)
- Reference specification requirements

### Footer Rules
- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: <description>`

### Examples
```
feat(spec-003): implement JWT token validation

Add token validation middleware to protect API endpoints.
Validates signature, expiration, and issuer.

Closes #45
```

```
fix(spec-007): handle null values in user profile

Fixed null pointer when user profile lacks optional fields.
Added defensive checks and default values.
```

## Workflow Per Specification

### 1. Start Specification
```bash
# Create feature branch
git checkout main
git pull origin main
git checkout -b feat/spec-XXX
```

### 2. Development
```bash
# Frequent small commits while working
git add .
git commit -m "wip(spec-XXX: description)"
```

### 3. Before Final Commit
```bash
# Run quality gates
bash .claude/scripts/quality-gate.sh

# Update progress tracking
# Edit .claude/docs/PROGRESS.md
```

### 4. Final Commit
```bash
# Stage all changes
git add .

# Conventional commit format
git commit -m "feat(spec-XXX): [specification title]

- Implemented requirement X
- Added tests for edge cases Y
- Verified integration with Z

All tests passing. Quality gates passed.
"
```

### 5. Merge to Main
```bash
# Return to main
git checkout main
git pull origin main

# Merge with squash (for clean history)
git merge --squash feat/spec-XXX
git commit -m "feat(spec-XXX): [specification title]"

# OR merge commit (for preserving context)
git merge feat-spec-XXX --no-ff

# Push to remote
git push origin main

# Delete feature branch
git branch -d feat/spec-XXX
```

## Commit Rules

### ALWAYS
- ✅ Run tests before commit
- ✅ Run quality-gate.sh before commit
- ✅ Keep commits atomic (one logical change)
- ✅ Write clear commit messages
- ✅ Reference specification ID

### NEVER
- ❌ Commit broken tests
- ❌ Commit with lint errors
- ❌ Commit with TypeScript errors
- ❌ Commit unrelated changes together
- ❌ Commit generated files (dist/, build/, .next/)
- ❌ Commit secrets or API keys
- ❌ Use `git commit --amend` on pushed commits
- ❌ Force push to main

## Code Review Process

### Before Requesting Review
- [ ] All tests pass locally
- [ ] Quality gate script passes
- [ ] Self-review completed
- [ ] Code follows project conventions
- [ ] Documentation updated (if applicable)

### Review Criteria
- Specification requirements met
- Test coverage adequate
- Error handling comprehensive
- Security considerations addressed
- Performance acceptable
- Code is maintainable

### After Review
- Address all feedback
- Run tests again
- Update commit with `--fixup` or new commit
- Request re-review if significant changes

## Release Management

### Versioning
- Follow Semantic Versioning: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Pre-Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Smoke tests passed
- [ ] Rollback plan documented

### Tagging
```bash
# Annotated tag
git tag -a v1.2.3 -m "Release v1.2.3: description"
git push origin v1.2.3
```

## Emergency Procedures

### Hotfix Workflow
```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-issue

# 2. Apply fix
# ... make changes ...

# 3. Test and commit
git commit -m "hotfix: resolve critical production issue"

# 4. Merge to main
git checkout main
git merge hotfix/critical-issue
git push origin main

# 5. Tag release
git tag -a v1.2.4 -m "Hotfix v1.2.4"
git push origin v1.2.4

# 6. Merge to develop (if using)
git checkout develop
git merge hotfix/critical-issue

# 7. Delete hotfix branch
git branch -d hotfix/critical-issue
```

### Rollback Procedure
```bash
# Identify last good commit
git log --oneline | head -10

# Revert to last good state
git revert HEAD
git push origin main

# OR reset (use with caution)
git reset --hard <commit-hash>
git push --force origin main  # DANGEROUS
```

## Git Hooks (Optional)

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
bash .claude/scripts/quality-gate.sh
if [ $? -ne 0 ]; then
  echo "❌ Quality gate failed. Commit aborted."
  exit 1
fi
```

### Pre-push Hook
```bash
#!/bin/bash
# .git/hooks/pre-push
# Run full test suite before push
npm test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Push aborted."
  exit 1
fi
```

## Progress Tracking

Update `.claude/docs/PROGRESS.md` after each completed specification:

```markdown
# Implementation Progress

## Completed Specifications
- [x] SPEC-001: Project Setup ✓ (committed 2025-02-12 14:23)
- [x] SPEC-002: Core Types ✓ (committed 2025-02-12 14:45)
- [x] SPEC-003: Error Handling ✓ (committed 2025-02-12 15:12)

## In Progress
- [ ] SPEC-004: Database Schema (branch: feat/spec-004)

## Not Started
- [ ] SPEC-005: User Authentication API
- [ ] SPEC-006: Session Management
```

## Repository Hygiene

### .gitignore Requirements
```
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
.next/
out/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# AI
.claude/memories/

# Logs
*.log
logs/

# Coverage
coverage/
.nyc_output/

# Temporary
*.tmp
.cache/
```

### Branch Cleanup
```bash
# Delete merged local branches
git branch --merged | grep -v "main\|develop" | xargs git branch -d

# Delete stale remote branches
git remote prune origin
```

## Safety Reminders

1. **Never force push to main/develop**
2. **Never commit broken tests**
3. **Never commit secrets**
4. **Always pull before push**
5. **Always review git diff before commit**
6. **Always write meaningful commit messages**
7. **Keep branches short-lived**
8. **Merge frequently to reduce conflicts**
```

### 2.5 Generate Initial `.claude/docs/SPECIFICATIONS.md`

Break down requirements into specifications. Each specification must include:
- Specification ID (e.g., SPEC-001)
- User Story
- Acceptance Criteria
- Functional Specification (Input, Processing, Output, Database, API, Error Handling, Edge Cases)
- Performance Requirements
- Security Requirements
- Safety & Reliability
- Testing Requirements
- Dependencies (Requires/Required by)

**Start with first pass breakdown.**

---

## Step 3: Iterate Specifications Until Atomic (3-5 times)

For each iteration:

### 3.1 Read Current Specifications
```bash
Read .claude/docs/SPECIFICATIONS.md
```

### 3.2 Challenge Each Specification

For each specification, ask:
1. **Atomicity**: Can this be split?
2. **Dependencies**: What must exist first?
3. **Edge Cases**: ALL possible inputs/states?
4. **Error Conditions**: How can this fail?
5. **Integration Points**: What other systems?
6. **Data Impact**: Validation rules?
7. **Performance**: Response time?
8. **Security**: Who can access?
9. **Safety**: Failure modes?

If ANY answer reveals complexity, **SPLIT**.

### 3.3 Update Specifications
Use `Edit` to update SPECIFICATIONS.md with more granular specs.

### 3.4 Track Iterations
Use `TodoWrite` to track breakdown iterations.

### 3.5 Stop When
- Specifications are SO SMALL they seem ridiculous
- Each spec implementable in 15-30 minutes
- NO FURTHER BREAKDOWN IS POSSIBLE

---

## Step 4: Generate Supporting Documents

### 4.1 Generate `.claude/docs/DEPENDENCY-GRAPH.md`

Parse all specifications and create dependency graph:

```markdown
# Specification Dependency Graph

## Complete Graph
[Generate based on Requires/Required by from specs]

## Format Example
SPEC-001: Project Setup (no dependencies)
    ↓
SPEC-002: Core Types (depends on: SPEC-001)
    ↓
SPEC-003: Database Schema (depends on: SPEC-002)
```

### 4.2 Generate `.claude/docs/PARALLEL-GROUPS.md`

Identify specifications with identical dependencies that can run in parallel:

```markdown
# Parallel Execution Groups

## Group A: [Foundation]
Specifications: SPEC-004, SPEC-005, SPEC-006
Can run in parallel: Yes
Dependencies: SPEC-002, SPEC-003
```

### 4.3 Generate `.claude/docs/CRITICAL-PATH.md`

Identify specifications that block the most other specs:

```markdown
# Critical Path Specifications

## Critical Path (Implement First)
1. SPEC-001: Project Setup (blocks: all)
2. SPEC-002: Core Types (blocks: 15 specs)
3. SPEC-003: Error Handling (blocks: 12 specs)

## Leaf Specifications (Implement Last)
- SPEC-047: Logging (nothing depends on it)
```

### 4.4 Generate `.claude/docs/TEST-FIXTURES.md`

Create test data fixtures for valid and invalid inputs:

```markdown
# Test Data Fixtures

## Valid Fixtures
[JSON fixtures for valid inputs]

## Invalid Fixtures
[JSON fixtures for error testing]
```

### 4.5 Generate `.claude/docs/INTEGRATION-TESTS.md`

Create integration tests that span multiple specifications:

```markdown
# Integration Test Matrix

## IT-001: [Workflow Name]
**Specifications:** [list]
**Test:** [steps]
**Expected Result:** [outcome]
```

### 4.6 Generate `.claude/docs/RISKS-AND-MITIGATIONS.md`

Use template from AUTONOMOUS-DEVELOPMENT-FLOW.md Phase 4:
- System Risks
- Technical Risks
- Operational Risks
- Security & Compliance Risks
- Project Risks
- Mitigation Strategies

### 4.7 Update `.claude/docs/PROJECT-PLAN.md` to v2

Incorporate:
- Insights from specifications
- Risk mitigation activities
- Contingency buffers
- Quality gates

### 4.8 Generate `.claude/docs/IMPLEMENTATION-ROADMAP.md`

Create step-by-step instructions from AUTONOMOUS-DEVELOPMENT-FLOW.md Phase 6:
- Pre-implementation checklist
- Phase-by-phase implementation steps
- **Checkpoint definitions** (user review points)
- Verification steps
- Testing requirements
- Code review checklist

### 4.9 Generate `.claude/docs/TDD-MASTER-DOCUMENT.md`

Create complete test specifications from AUTONOMOUS-DEVELOPMENT-FLOW.md Phase 8:
- Test organization structure
- Test template for each specification
- Test specifications by specification ID
- Complete test matrix
- Test data strategy
- Performance test specifications
- Security test specifications

---

## Step 5: Generate Scripts

### 5.1 Create `.claude/scripts/quality-gate.sh`

```bash
#!/bin/bash
# Quality Gate Verification
# Run before each commit during Ralph Loop

echo "🔍 Running Quality Gates..."

# 1. Tests
npm test --silent 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Tests failing"
  exit 1
fi

# 2. TypeScript
npx tsc --noEmit 2>&1 | head -10
if [ $? -ne 0 ]; then
  echo "❌ TypeScript errors"
  exit 1
fi

# 3. Lint
npm run lint 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Lint errors"
  exit 1
fi

# 4. Coverage
npm run test:coverage 2>&1 | grep -E "Lines|Statements|Branches|Functions"

echo "✅ All quality gates passed"
exit 0
```

### 5.2 Create `.claude/scripts/validate-planning.sh`

```bash
#!/bin/bash
# Planning Document Validation

BASE_DIR=".claude/docs"
ERRORS=0

for doc in CLAUDE.md PROJECT-PLAN.md SPECIFICATIONS.md RISKS-AND-MITIGATIONS.md \
           IMPLEMENTATION-ROADMAP.md TDD-MASTER-DOCUMENT.md GIT-STRATEGY.md \
           TEST-FIXTURES.md INTEGRATION-TESTS.md DEPENDENCY-GRAPH.md \
           PARALLEL-GROUPS.md CRITICAL-PATH.md; do
  if [ ! -f "$BASE_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -eq 0 ]; then
  echo "✅ All planning documents validated"
  exit 0
else
  echo "❌ Found $ERRORS missing documents"
  exit 1
fi
```

### 5.3 Create `.claude/scripts/setup-env.sh`

Use the full script from AUTONOMOUS-DEVELOPMENT-FLOW.md Phase 0.

---

## Step 6: Validate All Documentation

### 6.1 Run Validation Script
```bash
bash .claude/scripts/validate-planning.sh
```

### 6.2 Manual Validation Checklist

- [ ] All documents exist
- [ ] Each SPEC-XXX has corresponding tests in TDD-MASTER-DOCUMENT.md
- [ ] All dependencies resolve (no broken references)
- [ ] No circular dependencies
- [ ] Each spec has time estimate
- [ ] All risks have mitigations
- [ ] Checkpoints defined in roadmap
- [ ] Integration tests cover critical workflows

### 6.3 If Validation Fails

Fix issues and re-validate until all checks pass.

---

## Step 7: Present Summary to User (THEN HARD STOP)

After validation passes, present this summary to the user, then **ABSOLUTELY STOP. NO MORE ACTIONS.**

```markdown
## Documentation Generation Complete

### Documents Generated (13):
- ✅ `.claude/CLAUDE.md` - Project configuration
- ✅ `.claude/docs/PROJECT-PLAN.md` (v2) - Complete project context
- ✅ `.claude/docs/SPECIFICATIONS.md` - [N] atomic specifications
- ✅ `.claude/docs/RISKS-AND-MITIGATIONS.md` - Risk analysis
- ✅ `.claude/docs/IMPLEMENTATION-ROADMAP.md` - Step-by-step with checkpoints
- ✅ `.claude/docs/TDD-MASTER-DOCUMENT.md` - All test cases
- ✅ `.claude/docs/TEST-FIXTURES.md` - Test data fixtures
- ✅ `.claude/docs/INTEGRATION-TESTS.md` - Cross-specification tests
- ✅ `.claude/docs/DEPENDENCY-GRAPH.md` - Specification dependencies
- ✅ `.claude/docs/PARALLEL-GROUPS.md` - Parallel execution groups
- ✅ `.claude/docs/CRITICAL-PATH.md` - Implementation priority
- ✅ `.claude/docs/GIT-STRATEGY.md` - Git workflow

### Scripts Generated (3):
- ✅ `.claude/scripts/setup-env.sh` - Environment setup
- ✅ `.claude/scripts/quality-gate.sh` - Quality verification
- ✅ `.claude/scripts/validate-planning.sh` - Planning validation

### Statistics:
- Total Specifications: [N]
- Critical Path Specs: [N]
- Parallel Groups: [N]
- Total Test Cases: [N]
- Integration Tests: [N]

### Validation: ✅ PASSED

---

## DOCUMENTATION GENERATION COMPLETE

The /start-project command is now COMPLETE. NO further actions will be taken.

**Your documentation is ready for review.**

### Next Steps (YOU must do these manually):

**Step 1: Review the Planning**
- Read `.claude/docs/SPECIFICATIONS.md` to review specifications
- Read `.claude/docs/IMPLEMENTATION-ROADMAP.md` to see the plan
- Read `.claude/docs/DEPENDENCY-GRAPH.md` to see dependencies

**Step 2: Environment Setup (when ready)**
```bash
bash .claude/scripts/setup-env.sh
```

**Step 3: Start Implementation (when ready)**
```bash
/ralph-loop
```

**Alternative: For comprehensive specification** (recommended for complex projects):
```bash
/spec-workflow [feature description]
```
This generates exhaustive specifications with user journeys, EARS requirements, Gherkin tests, and traceability verification.

**THIS COMMAND WILL NOT CONTINUE AUTOMATICALLY.**
**You must explicitly run the commands above when you are ready.**

---

## Critical Rules

1. **DO NOT enter Plan Mode** - this is documentation generation, not implementation planning
2. **Complete ALL documentation files** before finishing
3. **Iterate specifications 3-5 times** - don't stop too soon
4. **Specifications must be RIDICULOUSLY small** - when in doubt, split
5. **Every spec needs tests** in TDD-MASTER-DOCUMENT.md
6. **Validate all documents** before presenting summary
7. **NEVER create implementation plans** - only generate documentation
8. **NEVER write code** - only markdown files

---

## ⛔ ABSOLUTE STOP - END OF COMMAND ⛔

**After presenting the documentation summary, this command is COMPLETE.**

**DO NOT:**
- ❌ Create any implementation plans
- ❌ Create any source files (src/, tests/, config files, etc.)
- ❌ Install any dependencies (npm install, yarn, pnpm, etc.)
- ❌ Run any build commands
- ❌ Run any test commands
- ❌ Execute ANY bash commands except mkdir for .claude directories

**THIS COMMAND GENERATES DOCUMENTATION ONLY.**
**User must run `/ralph-loop` when ready to begin implementation.**

---

## Next Steps (for user)

When ready to implement:
1. Review generated documentation in `.claude/docs/`
2. Run `bash .claude/scripts/setup-env.sh` to set up environment
3. Run `/ralph-loop` to begin implementation
