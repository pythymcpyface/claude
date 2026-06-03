---
name: start-project
description: Comprehensive project documentation generation. ALWAYS runs the complete /spec-workflow (Phase 0) for exhaustive specifications, then synthesizes them into 11 project planning documents and 3 helper scripts. Does NOT write application code. Use PROACTIVELY at the start of a new project, or when a user asks to "start a project", "scaffold docs", "generate planning docs", or "set up specs and roadmap".
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Start Project Skill

Comprehensive project documentation generation. This skill produces a complete `.claude/docs/$BRANCH/` planning bundle plus root `CLAUDE.md` and helper scripts.

This SKILL.md is a router. Detailed content lives in `references/`:

| You need… | Read |
|---|---|
| Phase-by-phase actions, stop-points, validation steps | `references/phases.md` |
| Markdown templates for all 11 generated documents | `references/templates.md` |
| Helper script templates (quality-gate, validate-planning, setup-env) | `references/scripts.md` |

---

## ⛔ THIS SKILL DOES NOT WRITE APPLICATION CODE ⛔

**Purpose**: Generate exhaustive project planning documentation from a feature description.

**Output**:
- `.claude/docs/$BRANCH/` — 17 markdown files (6 spec-workflow + 11 project docs)
- `.claude/scripts/` — 3 helper bash scripts (not executed)
- Root `.claude/CLAUDE.md` — project configuration

**Stopping point**: After Phase 7 summary. The skill HARD STOPS — no implementation begins automatically.

### Allowed
- ✅ Run complete `/spec-workflow` (4 phases)
- ✅ Generate 17 markdown documentation files
- ✅ Generate 3 helper bash scripts
- ✅ Iterate specifications 3–5 times until atomic
- ✅ Generate dependency graphs, parallel groups, critical paths
- ✅ Run `mkdir` for `.claude/docs/` and `.claude/scripts/`

### Forbidden
- ❌ Write ANY application code (src/, tests/, config files)
- ❌ Install ANY dependencies (npm/yarn/pnpm/cargo/pip/go)
- ❌ Execute ANY generated scripts
- ❌ Run any build/test commands
- ❌ Begin implementation automatically

---

## Workflow Overview

| Phase | Goal | Stop point |
|---|---|---|
| 0 — Spec Workflow (MANDATORY) | Run all 4 phases of `/spec-workflow` | **STOP — user approves specs** |
| 1 — Read Spec Outputs | Read all 6 spec-workflow documents | — |
| 2 — Core Documentation | Generate `CLAUDE.md`, `PROJECT-PLAN.md`, `GIT-STRATEGY.md` | — |
| 3 — Atomic Specifications | Iterate `SPECIFICATIONS.md` 3–5 times until ridiculously small | — |
| 4 — Supporting Docs | Generate `DEPENDENCY-GRAPH`, `PARALLEL-GROUPS`, `CRITICAL-PATH`, `TEST-FIXTURES`, `INTEGRATION-TESTS`, `RISKS-AND-MITIGATIONS`, `IMPLEMENTATION-ROADMAP`, `TDD-MASTER-DOCUMENT` | — |
| 5 — Helper Scripts | Generate 3 bash scripts in `.claude/scripts/` | — |
| 6 — Validation | Run `validate-planning.sh`; verify all 17 docs exist | — |
| 7 — Summary | Present full summary | **⛔ HARD STOP** |

See `references/phases.md` for full per-phase actions, prompts, and stop-point templates.

---

## Document Artifacts

Generated in `.claude/docs/$BRANCH/`:

**From `/spec-workflow` (Phase 0)** — 6 docs:
- `USER-JOURNEYS.md`, `REQUIREMENTS.md`, `TDD-STRATEGY.md`
- `features/*.feature` (Gherkin)
- `TRACEABILITY-MATRIX.md`, `VERIFICATION-REPORT.md`

**From Phases 2–4** — 11 docs:
- `PROJECT-PLAN.md`, `SPECIFICATIONS.md`, `GIT-STRATEGY.md`
- `DEPENDENCY-GRAPH.md`, `PARALLEL-GROUPS.md`, `CRITICAL-PATH.md`
- `TEST-FIXTURES.md`, `INTEGRATION-TESTS.md`, `TDD-MASTER-DOCUMENT.md`
- `RISKS-AND-MITIGATIONS.md`, `IMPLEMENTATION-ROADMAP.md`

**Root**: `.claude/CLAUDE.md`

**Scripts** (in `.claude/scripts/`): `quality-gate.sh`, `validate-planning.sh`, `setup-env.sh`

Templates for every document live in `references/templates.md`. Templates for the three scripts live in `references/scripts.md`.

---

## Critical Rules

1. **ALWAYS run complete spec-workflow** — Phase 0 is mandatory, no skipping.
2. **Complete ALL 17 documentation files** before finishing.
3. **Iterate specifications 3–5 times** — don't stop too soon.
4. **Specifications must be RIDICULOUSLY small** — when in doubt, split.
5. **Every spec needs tests** in `TDD-MASTER-DOCUMENT.md`.
6. **Every test maps to Gherkin** in `features/*.feature`.
7. **Validate all documents** before presenting summary.
8. **NEVER write code** — only markdown files and bash scripts.
9. **NEVER execute scripts** — only generate them.
10. **100% traceability required** — Journey → Requirement → Spec → Test.

---

## Integration

- **Calls** `/spec-workflow` (mandatory Phase 0).
- **Called by** `/feature-dev` (Phase 3.5) for project-scope documentation. Individual feature work uses `/feature-dev` directly; `/start-project` is for greenfield or whole-project planning.
- **Relationship with `/bug-fix`**: bug-fix generates fix-scoped docs only. Project-level planning belongs here.

---

## ⛔ Hard Stop

After Phase 7 summary, this skill is COMPLETE. The user must explicitly begin implementation. See `references/phases.md` Phase 7 for the exact stop-point template and forbidden-actions list.
