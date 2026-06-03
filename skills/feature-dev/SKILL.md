---
name: feature-dev
description: Guided feature development workflow with codebase understanding, spec generation, architecture design, TDD implementation, and quality reviews. Use PROACTIVELY when the user asks to add a new feature, implement functionality, or build a new capability.
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, Task, AskUserQuestion
---

# Feature Development

Systematic feature development: understand the codebase, ask clarifying questions, design architecture, then implement with TDD.

This SKILL.md is a router. Detailed phase content lives in `references/phases.md` — read the relevant section when entering each phase.

## Core Principles

- **Ask clarifying questions early** (after exploration, before architecture). Don't assume — ask. Wait for answers before proceeding.
- **Understand before acting** — read existing code patterns first.
- **Read agent-identified files** — when you launch agents, ask them to return key files; read them after agents complete.
- **Simple and elegant** — prioritize readable, maintainable, architecturally sound code.
- **Use TodoWrite** to track progress.
- **Branch-per-feature** — all work on a feature branch named after the work.

---

## Workflow Overview

| Phase | Goal | Stop-point? |
|-------|------|-------------|
| 0 — Worktree Setup | Create isolated git worktree for this feature | — |
| 1 — Discovery | Understand what to build | — |
| 2 — Codebase Exploration | Map relevant code with parallel `code-explorer` agents | — |
| 3 — Clarifying Questions | Resolve ambiguities | Wait for answers |
| 3.5 — Spec Workflow (MANDATORY) | Run all 4 phases of `/spec-workflow` + supporting docs | **STOP — user approves specs** |
| 4 — Architecture Design | Parallel `code-architect` agents propose 2-3 approaches | Wait for choice |
| 4.5 — Architecture Validation | Validate against codebase patterns and SOLID | — |
| 4.6 — Verify Documentation | Confirm all docs in `.claude/docs/$BRANCH_NAME/` | **STOP — user approves implementation** |
| 5 — Implementation (TDD) | Strict Red-Green-Refactor per SPEC-XXX | Manual continuation only |
| 6 — Quality Review | 3 parallel `code-reviewer` agents | — |
| 6.2 — UX Review | WCAG 2.1 AA, mobile, accessibility, edge cases | — |
| 6.5 — Security Review | OWASP Top 10, secrets, validation, error handling | All HIGH issues fixed |
| 7 — Summary and Merge | Merge feature branch, clean up worktree | — |

Read `references/phases.md` for complete actions, scripts, templates, and stop-point messaging for each phase.

---

## Document Artifacts

Generated in `.claude/docs/$BRANCH_NAME/` during Phase 3.5 and 4.5:

**From `/spec-workflow`:**
- `USER-JOURNEYS.md`, `REQUIREMENTS.md`, `TDD-STRATEGY.md`, `TRACEABILITY-MATRIX.md`, `VERIFICATION-REPORT.md`, `features/*.feature`

**Feature-specific:**
- `SPECIFICATIONS.md` (atomic, iterated 3-5 times)
- `TEST-FIXTURES.md`, `INTEGRATION-TESTS.md`, `IMPLEMENTATION-ROADMAP.md`
- `ARCHITECTURE-VALIDATION.md` (Phase 4.5)
- `UX-REVIEW.md`, `SECURITY-REVIEW.md` (Phases 6.2, 6.5, if applicable)

The `.claude/docs/$BRANCH_NAME/` directory is added to `.gitignore` at the end of Phase 7, keeping planning docs local while preserving the branch-per-feature history.

Project-level docs (PROJECT-PLAN, GIT-STRATEGY, DEPENDENCY-GRAPH, PARALLEL-GROUPS, CRITICAL-PATH) are NOT generated for individual features — those belong to `/start-project`.

---

## Branch Naming Convention

Lowercase, hyphenated, prefixed by type, ≤50 chars. Examples:

| Type | Example |
|------|---------|
| feature | `feature/user-auth-oauth` |
| feature + issue | `feature/JIRA-123-oauth` |
| bugfix | `bugfix/login-timeout` |
| hotfix | `hotfix/api-security-patch` |
| refactor | `refactor/auth-module` |

Full naming rules and example transformations are in `references/phases.md` (Phase 0).

---

## Integration

- Uses `/spec-workflow` skill for Phase 3.5 (4-phase spec generation)
- Uses `/ui-ux` for design intelligence (Phase 6.2)
- Calls `.claude/scripts/{tdd-gate,quality-gate,security-gate}.sh` during Phases 5 and 6.5
- Spawns parallel sub-agents: `code-explorer` (Phase 2), `code-architect` (Phase 4), `code-reviewer` (Phase 6)
