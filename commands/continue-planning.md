---
description: Resume autonomous development planning from where it left off
argument-hint: Optional phase to continue from
---

# Continue Planning - Resume Autonomous Development

## Overview

Resumes the autonomous development planning process from where it was interrupted. Reads PROGRESS.md to determine current state and continues from that phase.

---

## Step 1: Determine Current State

Read `.claude/docs/PROGRESS.md` to see what was last completed.

If PROGRESS.md doesn't exist, check for completed documents:

```bash
# Check what documents exist
ls -la .claude/docs/

# Run validation to see what's missing
bash .claude/scripts/validate-planning.sh
```

---

## Step 2: Resume from Appropriate Phase

### If No Documents Exist
Start fresh with `/start-project`

### If CLAUDE.md and PROJECT-PLAN.md exist but SPECIFICATIONS.md is missing/empty
Continue from **Phase 3: Specification Breakdown**
1. Read existing PROJECT-PLAN.md
2. Generate initial SPECIFICATIONS.md
3. Iterate 3-5 times until atomic

### If SPECIFICATIONS.md exists but needs more iteration
Continue **Phase 3 Iteration**
1. Read current SPECIFICATIONS.md
2. Challenge each specification
3. Update with more granular specs
4. Repeat until atomic

### If SPECIFICATIONS.md is complete but supporting documents missing
Continue from **Phase 7: Generate Supporting Documents**
1. Generate DEPENDENCY-GRAPH.md
2. Generate PARALLEL-GROUPS.md
3. Generate CRITICAL-PATH.md
4. Generate TEST-FIXTURES.md
5. Generate INTEGRATION-TESTS.md
6. Generate RISKS-AND-MITIGATIONS.md
7. Update PROJECT-PLAN.md to v2
8. Generate IMPLEMENTATION-ROADMAP.md
9. Generate TDD-MASTER-DOCUMENT.md

### If all documents exist but validation not run
Continue from **Phase 8.5: Validation**
1. Run validate-planning.sh
2. Fix any issues
3. Present summary

---

## Step 3: Update Progress

As you complete each phase, update PROGRESS.md with:
- Phase completed
- Documents generated
- Current status

---

## Step 4: Present Current State

When done, show:

```markdown
## Planning Resumed - Current State

### Completed:
[List completed phases/documents]

### Remaining:
[List remaining phases/documents]

### Next Step:
[What to do next]
```

---

## Quick Resume Commands

| If you... | Then... |
|-----------|----------|
| Haven't started | Use `/start-project` |
| Just started planning | Continue requirements gathering |
| Have specs, need iteration | Continue spec breakdown |
| Have all docs, need validation | Run validation script |
| Planning complete | Run `setup-env.sh` then `/ralph-loop` |

---

## Reference

Complete flow: `.claude/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md`
