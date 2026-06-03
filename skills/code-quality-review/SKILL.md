---
name: code-quality-review
description: Production readiness review for Code Quality. Reviews SOLID principles compliance, linting standards, code review readiness, redundant code detection, and type safety. Use PROACTIVELY before production releases, after refactoring, or when adding significant new features.
paths:
  - "**/*.{ts,tsx,js,jsx,py,rb,go,rs,java,kt,swift}"
  - "**/.eslintrc*"
  - "**/.prettierrc*"
  - "**/tsconfig.json"
  - "**/pyproject.toml"
  - "**/.rubocop.yml"
  - "**/biome.json"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Code Quality Review Skill

Production readiness code review focused on Code Quality & Maintainability. Ensures code is ready for production with proper SOLID principles, linting, code review processes, minimal redundancy, and strong type safety.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "refactor", "cleanup", "quality", "lint", "type", "solid", "maintain"
- Large code changes (>500 lines modified)
- New modules or services created
- Before major version releases
- After significant refactoring
- When adding complex business logic
- Before code review submission
- When onboarding new team members

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Stack Detection
- Phase 2: Code Quality Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| SOLID Principles | 30% |
| Linting Standards | 20% |
| Code Review Readiness | 25% |
| Redundant Code | 10% |
| Type Safety | 15% |

---

## Integration with Other Reviews

This skill complements:
- `/security-review` - For security vulnerabilities in code
- `/observability-check` - For logging and monitoring
- `/api-readiness-review` - For API design quality
- `/performance-review` - For performance-related code issues
- `/test-coverage` - For test quality and coverage
