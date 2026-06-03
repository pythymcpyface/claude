---
name: dependency-security-scan
description: Production readiness review for dependency security. Scans for known vulnerabilities (CVEs) in npm, pip, go mod, and cargo dependencies. 84% of breaches originate from vulnerable dependencies. Use PROACTIVELY before production releases.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Dependency Security Scan Skill

Production readiness review focused on dependency vulnerability scanning. Ensures dependencies are free of known security vulnerabilities before production release.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "release", "production", "deploy", "dependencies", "upgrade", "update"
- package.json, package-lock.json, or yarn.lock is modified
- requirements.txt, Pipfile, or pyproject.toml is modified
- go.mod or go.sum is modified
- Cargo.toml or Cargo.lock is modified
- Before any production release
- During security audits
- Scheduled weekly/monthly security scans

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Ecosystem Detection
- Phase 2: Vulnerability Scanning Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production (no HIGH/CRITICAL) |
| 70-89 | NEEDS WORK | MEDIUM vulnerabilities, review recommended |
| 50-69 | AT RISK | HIGH vulnerabilities, fix before release |
| 0-49 | BLOCK | CRITICAL vulnerabilities or no scanning |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Vulnerability Scanning | 40% |
| Outdated Dependencies | 20% |
| License Compliance | 15% |
| Automated Updates | 15% |
| CI Integration | 10% |

### Blocking Conditions

The review will **BLOCK** production release if:
- Any CRITICAL vulnerability is found
- Any HIGH vulnerability is found
- No vulnerability scanning is configured

---

## Integration with Other Reviews

This skill complements:
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For logging and monitoring
- `/security-review` - For application security
- `/quality-check` - For code quality

---

