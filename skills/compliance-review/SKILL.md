---
name: compliance-review
description: Production readiness review for Compliance (GDPR, Data Minimization, Retention). Reviews data protection, privacy controls, consent management, data retention policies, and regulatory compliance. Use PROACTIVELY before production releases, when handling personal data, or implementing data-intensive features.
paths:
  - "**/privacy/**"
  - "**/consent/**"
  - "**/gdpr/**"
  - "**/compliance/**"
  - "**/audit/**"
  - "**/retention/**"
  - "**/data-deletion/**"
  - "**/users/**"
  - "**/profile/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Compliance Review Skill

Production readiness code review focused on Data Compliance & Privacy. Ensures code is ready for production with proper GDPR compliance, data minimization practices, retention policy enforcement, and regulatory requirements.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "personal data", "PII", "GDPR", "privacy", "consent", "retention", "data subject", "right to be forgotten", "CCPA", "HIPAA"
- User data collection or storage features added
- Authentication and user profile functionality
- Database schemas with personal information
- Data export or deletion features
- Third-party data sharing integrations
- Marketing, analytics, or tracking implementations
- Before major version releases involving user data

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
- Phase 2: Compliance Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant compliance risks, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| GDPR Core Requirements | 15% |
| Data Minimization | 20% |
| Consent Management | 20% |
| Data Subject Rights | 20% |
| Data Retention | 15% |
| Data Security | 5% |
| Third-Party Sharing | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/secrets-management-review` - For securing API keys and credentials
- `/observability-check` - For audit logging and monitoring
- `/api-readiness-review` - For API data exposure
- `/security-review` - For data encryption and access controls
