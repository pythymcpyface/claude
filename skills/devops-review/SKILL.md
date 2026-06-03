---
name: devops-review
description: Production readiness review for Infrastructure & DevOps. Reviews rollback strategy, environment parity, and CI/CD pipelines before production release. Use PROACTIVELY before deployments, when creating release workflows, or modifying deployment configurations.
paths:
  - "**/.github/workflows/**"
  - "**/.gitlab-ci*"
  - "**/Dockerfile*"
  - "**/docker-compose*.{yml,yaml}"
  - "**/k8s/**"
  - "**/kubernetes/**"
  - "**/*.{tf,tfvars}"
  - "**/terraform/**"
  - "**/ansible/**"
  - "**/Jenkinsfile"
  - "**/circleci/**"
  - "**/buildkite/**"
  - "**/helm/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# DevOps Review Skill

Production readiness code review focused on Infrastructure & DevOps. Ensures code is ready for production with proper rollback strategy, environment parity, and CI/CD pipelines.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "deploy", "release", "production", "ci", "pipeline"
- GitHub Actions workflow files are modified
- Dockerfile or docker-compose files are changed
- Kubernetes manifests are updated
- Environment configuration changes
- Release branch creation
- Before major version releases

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
- Phase 2: DevOps Checklist
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
| Rollback Strategy | 25% |
| Environment Parity | 25% |
| CI/CD Pipeline | 25% |
| Deployment Safety | 15% |
| Monitoring | 10% |

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging, metrics, tracing
- `/security-review` - For application security
- `/quality-check` - For code quality
- `/review-pr` - For comprehensive PR review
