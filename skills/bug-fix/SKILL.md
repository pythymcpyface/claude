---
name: bug-fix
description: Guided bug resolution workflow with reproduction-first testing, root cause analysis, minimal fixes, and verification. Use PROACTIVELY when the user reports a bug, asks to fix broken behavior, or investigates incorrect output.
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, Task, AskUserQuestion
---

# Bug Fix

Systematic bug resolution: understand, reproduce, find root cause, plan minimal fix, implement test-first.

This SKILL.md is a router. Detailed phase content lives in `references/phases.md` — read the relevant section when entering each phase.

## Core Principles

- **Reproduce before fixing** — always create a failing test that demonstrates the bug.
- **Find root cause** — understand WHY, not just WHERE.
- **Minimal changes** — fix only what's needed; no refactoring or "while I'm here" changes.
- **Test-first** — reproduction test first, confirm it fails, then fix.
- **Read deeply** — when launching agents, read the files they identify.
- **Branch-per-fix** — work happens on a fix branch named after the bug.
- **Use TodoWrite** to track progress.

---

## Workflow Overview

| Phase | Goal | Stop-point? |
|-------|------|-------------|
| 0 — Worktree Setup | Create isolated git worktree | — |
| 1 — Bug Report | Document bug comprehensively (severity, repro, expected/actual) | — |
| 2 — Bug Reproduction | Reproduce + create failing test | Don't proceed until reproduced |
| 3 — Root Cause Analysis | Parallel agents trace manifestation, find correct handling, find similar bugs | — |
| 4 — Fix Planning | Design minimal, safe fix; document risks | Wait for user approval |
| 4.5 — Spec Workflow (MANDATORY) | Run all 4 phases of `/spec-workflow` for the fix | **STOP — user approves specs** |
| 5 — Implementation (Test-First) | RED → GREEN → regression tests → quality/security gates → commit | Manual continuation only |
| 6 — Verification | Manual test, check for similar bugs, code review | — |
| 7 — Summary and Merge | Merge fix branch, clean up worktree | — |

Read `references/phases.md` for complete actions, scripts, templates, and stop-point messaging for each phase.

---

## Document Artifacts

Generated in `.claude/docs/$BRANCH_NAME/`:

**Phases 1-4:**
- `BUG-REPORT.md` — severity, steps to reproduce, expected vs actual
- `ROOT-CAUSE.md` — investigation steps; WHY the bug occurs
- `FIX-PLAN.md` — minimal change strategy, tests, risk assessment

**Phase 4.5 (`/spec-workflow`):**
- `USER-JOURNEYS.md`, `REQUIREMENTS.md` (with EARS Unwanted patterns), `TDD-STRATEGY.md`
- `TRACEABILITY-MATRIX.md`, `VERIFICATION-REPORT.md`, `features/bug-*.feature`

**Bug-fix supporting docs:**
- `BUG-SPECIFICATION.md` (EARS, includes root cause, mapped to code locations)
- `REGRESSION-TESTS.md` (comprehensive suite for the bug + edge cases)
- `TEST-FIXTURES.md`, `FIX-IMPLEMENTATION-GUIDE.md`

The `.claude/docs/$BRANCH_NAME/` directory is added to `.gitignore` at end of Phase 7.

Project-level docs (PROJECT-PLAN, GIT-STRATEGY, etc.) are NOT generated for individual bug fixes — those belong to `/start-project`.

---

## Branch Naming Convention

Use `bugfix/` for normal bugs, `hotfix/` for production-critical:

| Type | Pattern | Example |
|------|---------|---------|
| bugfix | `bugfix/<description>` | `bugfix/login-timeout` |
| bugfix + issue | `bugfix/<issue>-<description>` | `bugfix/GH-789-login-crash` |
| hotfix | `hotfix/<description>` | `hotfix/security-patch` |
| hotfix + issue | `hotfix/<issue>-<description>` | `hotfix/JIRA-123-critical-fix` |

Rules: lowercase, hyphens to separate words, slash separates type, ≤50 chars total, no special chars (`~ ^ : * ? [ ] @`), include issue ID when available.

Full naming guidance and example transformations are in `references/phases.md` (Phase 0).

---

## Bug Fix vs Feature Development

| Aspect | feature-dev | bug-fix |
|--------|-------------|---------|
| Scope | New functionality | Surgical fixes to existing code |
| Branch | `feature/...` | `bugfix/...` or `hotfix/...` |
| Documentation | REQUIREMENTS, SPECIFICATIONS, TDD-STRATEGY | BUG-REPORT, ROOT-CAUSE, FIX-PLAN, BUG-SPECIFICATION |
| Exploration | Patterns for new feature | Trace bug manifestation + root cause |
| Architecture | Design new | Minimal change to existing |
| Testing | TDD for new code | Reproduction test + regression tests |

---

## Integration

- Uses `/spec-workflow` for Phase 4.5
- Calls `.claude/scripts/{quality-gate,security-gate}.sh` during Phase 5
- Spawns parallel sub-agents for root cause analysis (Phase 3)
- Templates in `.claude/docs/templates/{BUG-REPORT,ROOT-CAUSE,FIX-PLAN}-TEMPLATE.md`
