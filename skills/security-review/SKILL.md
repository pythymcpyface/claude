---
name: security-review
description: Production readiness review for Security. Reviews input validation, authentication, encryption, security headers, dependency scanning, and secrets management before production release. Use PROACTIVELY before releasing to production, when implementing authentication, handling user input, or configuring API security.
paths:
  - "**/auth/**"
  - "**/security/**"
  - "**/middleware/**"
  - "**/*.api.ts"
  - "**/*.api.js"
  - "**/api/**/*.{ts,js,py,rb,go}"
  - "**/login*"
  - "**/session*"
  - "**/jwt*"
  - "**/oauth*"
  - "**/crypto*"
  - "**/password*"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Security Review Skill

Production readiness code review focused on Application Security. Ensures code is ready for production with comprehensive protection against OWASP Top 10 and common security vulnerabilities.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "auth", "security", "login", "password", "token", "api", "encrypt", "secret", "input", "validate"
- Authentication/authorization features added
- User input handling implemented
- API endpoints created or modified
- Database operations added
- File upload functionality added
- Payment/financial features implemented
- Third-party integrations added
- Before production releases

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
- Phase 2: Security Checklist
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
| Input Validation | 15% |
| Authentication | 20% |
| Authorization | 15% |
| Encryption & Cryptography | 15% |
| Security Headers | 10% |
| Dependency Scanning | 10% |
| Secrets Management | 10% |
| OWASP Top 10 Coverage | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/dependency-security-scan` - For detailed dependency vulnerabilities
- `/secrets-management-review` - For comprehensive secrets audit
- `/api-readiness-review` - For API security patterns
- `/compliance-review` - For data protection compliance
- `/error-resilience-review` - For secure error handling
