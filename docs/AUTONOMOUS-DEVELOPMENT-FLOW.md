# Autonomous Development Flow

This document describes the complete workflow for autonomous TDD development using Ralph Loop. Claude should read and follow this document step-by-step.

---

## Overview

This flow enables Claude to autonomously:
1. Generate project specification and roadmap
2. Set up project structure
3. Implement features using strict TDD
4. Track progress in documents
5. Follow git strategy
6. Notify user when complete

---

## Phase 0: Permissions Check (FIRST)

Before starting, Claude must verify autonomous operation is enabled:

### Check Current Settings

```bash
cat ~/.claude/settings.local.json | grep -i dangerouslySkipPermissions
```

### If Not Found or False

Claude should:
1. Inform user: "Autonomous permissions not enabled. I'll update settings now."
2. Update the file:
```bash
# Backup current settings
cp ~/.claude/settings.local.json ~/.claude/settings.local.json.backup

# Add autonomous permissions
jq '.dangerouslySkipPermissions = true' ~/.claude/settings.local.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.local.json
```
3. **CRITICAL:** Tell user:
```
⚠️ SETTINGS UPDATED - SESSION RESTART REQUIRED

I've enabled dangerouslySkipPermissions for autonomous operation.

Please restart this Claude Code session for changes to take effect:
1. Exit this session
2. Start a new session
3. Tell me: "Continue with AUTONOMOUS-DEVELOPMENT-FLOW"
```

### If Already Enabled

Proceed to Phase 1.

---

## Phase 1: Initial Setup

Claude should execute these commands in order:

### 1.1 Create Project Structure

```bash
mkdir -p .claude/docs
mkdir -p .claude/hooks
mkdir -p src tests
```

### 1.2 Create Tracking Documents

Create `.claude/docs/SPECIFICATION.md`:

```markdown
# Project Specification

## Overview
[To be generated based on user requirements]

## Requirements
[To be generated based on user requirements]

## Success Criteria
- All requirements implemented
- All tests passing
- Code reviewed and approved
```

Create `.claude/docs/ROADMAP.md`:

```markdown
# Implementation Roadmap

## Phase 1: Foundation
- [ ] Project initialization
- [ ] Test framework setup
- [ ] Basic project structure
- [ ] Git workflow configured

## Phase 2: Core Features
- [ ] [Feature A - to be defined]
- [ ] [Feature B - to be defined]

## Phase 3: Polish & Completion
- [ ] Error handling
- [ ] Edge cases covered
- [ ] Documentation
- [ ] All tests passing
```

Create `.claude/docs/PROGRESS.md`:

```markdown
# Development Progress

**Started:** [DATE]
**Current Phase:** Foundation

## Phase 1: Foundation
- [ ] Project initialization
- [ ] Test framework setup
- [ ] Basic project structure
- [ ] Git workflow configured

## Phase 2: Core Features
- [ ] [Feature A]
- [ ] [Feature B]

## Phase 3: Polish & Completion
- [ ] Error handling
- [ ] Edge cases covered
- [ ] Documentation
- [ ] All tests passing
```

Create `.claude/docs/GIT-STRATEGY.md`:

```markdown
# Git Strategy

## Branch Strategy
- Main branch: `main`
- Feature branches: `feature/phase-{N}-{description}`
- Never commit to main directly

## Commit Conventions
- `feat:` - New feature
- `fix:` - Bug fix
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `docs:` - Documentation changes
- `chore:` - Build/config changes

## Commit Rules
1. Commit after each passing test
2. Never commit broken tests
3. Push after each phase completion
4. Use clear, descriptive messages

## Phase Completion Checklist
- [ ] All phase tests passing
- [ ] Code reviewed (use /review-pr)
- [ ] Progress document updated
- [ ] Branch pushed to remote
```

### 1.3 Initialize Git

```bash
git init
git add .
git commit -m "chore: initialize project structure"
```

---

## Phase 2: Requirements Gathering

Before starting Ralph Loop, Claude must:

1. **Ask user for project requirements**
   - What is the project?
   - What are the core features?
   - Any specific technologies?
   - Any constraints?

2. **Generate specification** based on user input
   - Update `SPECIFICATION.md` with detailed requirements
   - Break down into implementable items

3. **Create detailed roadmap**
   - Update `ROADMAP.md` with specific phases
   - Each phase should be completable in ~10-20 iterations

4. **Confirm with user**
   - Show specification
   - Show roadmap
   - Get approval before proceeding

---

## Phase 3: Configure Ralph Loop

### 3.1 Enable Stop Hook

Ensure `.claude/hooks/ralph-stop-hook.sh` exists and is executable:

```bash
# Copy from ~/.claude/hooks/ralph-stop-hook.sh if needed
cp ~/.claude/hooks/ralph-stop-hook.sh .claude/hooks/ralph-stop-hook.sh
chmod +x .claude/hooks/ralph-stop-hook.sh
```

### 3.2 Enable Autonomous Permissions

Claude will update settings to enable autonomous operation:

```bash
# Add to ~/.claude/settings.local.json:
cat >> ~/.claude/settings.local.json << 'EOF'
{
  "dangerouslySkipPermissions": true
}
EOF

# NOTE: This requires a session restart to take effect.
# Claude will prompt the user to restart after this change.
```

**Important:** If `dangerouslySkipPermissions` is not enabled, Ralph Loop will require manual approval for each tool use, breaking the autonomous flow.

---

## Phase 4: Start Ralph Loop

Use the following prompt template. Claude should fill in bracketed sections based on the project:

```bash
/ralph-loop "
You are an autonomous TDD developer. Follow this workflow exactly.

# REFERENCE DOCUMENTS
Always read these documents to understand state:
- .claude/docs/SPECIFICATION.md - Requirements
- .claude/docs/ROADMAP.md - Phased implementation plan
- .claude/docs/PROGRESS.md - Current progress (update as you go)
- .claude/docs/GIT-STRATEGY.md - Git workflow rules

# TDD WORKFLOW (STRICT - NEVER DEVIATE)
For each specification item:

1. READ PROGRESS.md
   - Find first unchecked [ ] item
   - This is your current task

2. WRITE FAILING TEST
   - Write ONE test for the current task
   - Test should be specific and fail clearly

3. RUN TESTS
   - Command: [npm test | pytest | cargo test | etc.]
   - Confirm test FAILS (red)
   - If test passes unexpectedly, rewrite it

4. WRITE MINIMAL CODE
   - Write MINIMAL code to make test pass
   - Do not add extra features
   - Focus on the specific test requirement

5. RUN TESTS AGAIN
   - Command: [npm test | pytest | cargo test | etc.]
   - Confirm test PASSES (green)

6. REFACTOR (if needed)
   - Improve code without changing behavior
   - Run tests again to confirm still passing

7. UPDATE PROGRESS.md
   - Change [ ] to [x] for completed item
   - Add note: ✅ [task] - completed on [date]

8. GIT COMMIT
   - Use conventional commit format
   - Examples:
     * feat: add user authentication
     * test: add login validation tests
     * fix: handle null pointer in user service
     * refactor: extract validation logic
   - Command: git add . && git commit -m \"[message]\"

9. REPEAT FROM STEP 1

# PHASE COMPLETION
When all items in a phase are complete:

1. RUN ALL TESTS
   - Confirm everything passes
   - Fix any failures

2. QUALITY CHECK
   - Run: /review-pr code tests
   - Address any critical issues found

3. UPDATE DOCUMENTS
   - Update PROGRESS.md: ## Phase N Complete ✅
   - Note completion date

4. GIT PUSH
   - Push branch to remote
   - Command: git push -u origin feature/phase-{N}-{name}

5. MOVE TO NEXT PHASE
   - Read next phase from ROADMAP.md
   - Continue from TDD Workflow Step 1

# TOOLS AVAILABLE
Use these when needed:
- /review-pr - Comprehensive PR review (code, tests, errors)
- code-explorer agent - Understand existing codebase
- code-architect agent - Design guidance
- code-reviewer agent - Code quality review
- code-simplifier agent - Improve code clarity

# IMPORTANT RULES
1. NEVER skip the test step
2. NEVER commit broken tests
3. ALWAYS update PROGRESS.md after each completion
4. ALWAYS follow git commit conventions
5. If blocked, note the issue in PROGRESS.md and move to next item
6. If test framework doesn't exist, set it up first

# COMPLETION
Output <promise>PROJECT_COMPLETE</promise> ONLY when:
- ALL phases from ROADMAP.md are complete
- ALL tests pass (run final test suite)
- PROGRESS.md shows 100% completion
- All code has been reviewed

Begin now with the first unchecked item in PROGRESS.md (Phase 1).
" --max-iterations 100
```

---

## Phase 5: Monitor Progress (User)

While Ralph Loop runs, user can monitor in separate terminals:

```bash
# Watch progress
watch -n 2 cat .claude/docs/PROGRESS.md

# Watch iterations
watch -n 5 "head -10 .claude/ralph-loop.local.md"

# Watch git history
watch -n 2 "git log --oneline -5"

# Watch test results
watch -n 2 "npm test"  # or equivalent
```

---

## Phase 6: Completion

When Claude outputs `<promise>PROJECT_COMPLETE</promise>`:

1. Stop hook will detect and exit loop
2. User sees completion message
3. Review:
   - `.claude/docs/PROGRESS.md` - All items marked complete
   - `git log` - Clean commit history
   - Test results - All passing

4. Merge to main:
```bash
git checkout main
git merge feature/phase-final
git push origin main
```

---

## Quick Reference Commands

```bash
# Start autonomous development
/ralph-loop "[see Phase 4 for full prompt]" --max-iterations 100

# Cancel loop manually
/cancel-ralph

# Check progress
cat .claude/docs/PROGRESS.md

# Review code quality
/review-pr

# Check token usage
/usage

# See iteration count
grep '^iteration:' .claude/ralph-loop.local.md
```

---

## Troubleshooting

### Loop stops unexpectedly
- Check `.claude/ralph-loop.local.md` exists
- Check stop hook is configured in settings.json
- Restart with `/ralph-loop` prompt

### Tests failing consistently
- Check test framework is properly configured
- Review PROGRESS.md for blocked items
- Consider adjusting specification

### Git conflicts
- Use `/clean-gone` to clean up branches
- Reset to last working commit
- Continue from next specification item

### Token usage high
- Reduce `--max-iterations`
- Break into smaller phases
- Run `/usage` to monitor

---

## Example Output

### PROGRESS.md (During Development)

```markdown
# Development Progress

**Started:** 2025-02-02T10:00:00Z
**Current Phase:** Core Features

## Phase 1: Foundation ✅
- [x] Project initialization - completed 2025-02-02T10:05:00Z
- [x] Test framework setup - completed 2025-02-02T10:15:00Z
- [x] Basic project structure - completed 2025-02-02T10:20:00Z
- [x] Git workflow configured - completed 2025-02-02T10:25:00Z

## Phase 2: Core Features (IN PROGRESS)
- [x] User model - completed 2025-02-02T10:30:00Z
- [x] User authentication - completed 2025-02-02T10:45:00Z
- [ ] User profile management
- [ ] Admin dashboard
```

### Git Log

```
a1b2c3d feat: add user authentication
e5f6g7h test: add login validation tests
i8j9k0l chore: configure jest
```

---

**Remember:** Claude should read this entire document and follow it step-by-step when setting up autonomous development.
