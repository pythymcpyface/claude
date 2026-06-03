---
name: secrets-management-review
description: Production readiness review for Secrets Management. Reviews 12-Factor compliance, vault integration, environment variable security, secret rotation, and secrets storage. Use PROACTIVELY before production releases, when setting up CI/CD pipelines, or configuring external service integrations.
paths:
  - "**/.env*"
  - "**/secrets/**"
  - "**/vault/**"
  - "**/*.{tf,tfvars}"
  - "**/k8s/**/*secret*"
  - "**/.github/workflows/**"
  - "**/config/**"
  - "**/*.config.{ts,js,py}"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Secrets Management Review Skill

Production readiness code review focused on Secrets Management & Configuration Security. Ensures code is ready for production with proper 12-Factor app compliance, vault integration, environment variable security, secret rotation capabilities, and secure storage practices.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "secret", "credential", "api key", "token", "password", "vault", "env", "environment", "config"
- New external service integrations (AWS, Stripe, Twilio, SendGrid, etc.)
- CI/CD pipeline configuration changes
- Docker/kubernetes configuration files added/modified
- Authentication or authorization code changes
- Database connection configuration
- New environment variables introduced
- Before major version releases involving external dependencies

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
- Phase 2: Secrets Management Checklist
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
| 12-Factor Compliance | 25% |
| Vault Integration | 20% |
| Env Var Security | 20% |
| Secret Rotation | 15% |
| Secret Storage | 15% |
| Third-Party Secrets | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging and monitoring of secret access
- `/devops-review` - For CI/CD secret injection and deployment
- `/api-readiness-review` - For API key management
- `/security-review` - For comprehensive security audit
- `/quality-check` - For code quality in secret handling
