---
name: testing-review
description: Production readiness review for Testing. Reviews unit test coverage >80%, integration tests, E2E tests, regression tests, load tests, security tests, test quality, and TDD/BDD practices before production release. Use PROACTIVELY before releasing to production, when adding new features, or modifying critical business logic.
paths:
  - "**/*.test.{ts,tsx,js,jsx,py,rb,go}"
  - "**/*.spec.{ts,tsx,js,jsx,py,rb,go}"
  - "**/__tests__/**"
  - "**/test/**"
  - "**/tests/**"
  - "**/e2e/**"
  - "**/cypress/**"
  - "**/playwright/**"
  - "**/jest.config.*"
  - "**/vitest.config.*"
  - "**/pytest.ini"
  - "**/conftest.py"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Testing Review Skill

Production readiness code review focused on Testing Strategy & Coverage. Ensures code is ready for production with comprehensive test coverage across all dimensions: unit, integration, E2E, regression, load, and security testing.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "test", "testing", "coverage", "unit", "e2e", "spec", "tdd", "bdd"
- New features or business logic added
- Critical path modifications
- Before major version releases
- CI/CD pipeline changes affecting tests
- Bug fixes (regression test needed)
- API contract changes
- Database schema migrations
- Authentication/authorization changes

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
- Phase 2: Testing Checklist
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
| Unit Test Coverage | 20% |
| Integration Tests | 15% |
| E2E Tests | 15% |
| Regression Tests | 10% |
| Load/Performance Tests | 10% |
| Security Tests | 10% |
| Test Quality | 10% |
| TDD/BDD Practices | 10% |

---

## Integration with Other Reviews

This skill complements:
- `/security-review` - For security vulnerabilities
- `/performance-review` - For performance under load
- `/devops-review` - For CI/CD pipeline configuration
- `/quality-check` - For code quality validation
