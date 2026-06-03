---
name: git-hygiene-review
description: Production readiness review for Git Hygiene. Reviews sensitive files ignored, commit messages, branch strategy, and secrets management. Use PROACTIVELY before production releases, when setting up new repositories, or establishing team workflows.
paths:
  - "**/.gitignore"
  - "**/.gitattributes"
  - "**/.github/**"
  - "**/CODEOWNERS"
  - "**/.git-blame-ignore-revs"
  - "**/.husky/**"
  - "**/.pre-commit-config.yaml"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# Git Hygiene Review Skill

Production readiness code review focused on Git Hygiene & Repository Best Practices. Ensures code is ready for production with proper .gitignore configuration, clean commit history, structured branching strategy, and no secrets in the repository.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "gitignore", "commit", "branch", "merge", "workflow", "ci", "cd"
- New repository initialization
- Before first production release
- Setting up team workflows
- Onboarding new team members
- After security incidents
- When establishing contribution guidelines
- Before major version releases
- When merging long-lived feature branches

---

## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Repository Detection
- Phase 2: Git Hygiene Checklist
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
| Sensitive Files Ignored | 25% |
| Commit Messages | 25% |
| Branch Strategy | 25% |
| No Secrets in Repository | 25% |

---

## Integration with Other Reviews

This skill complements:
- `/secrets-management-review` - For detailed secret handling and vault integration
- `/devops-review` - For CI/CD pipeline security and deployment workflows
- `/security-review` - For comprehensive security audit including repository access
- `/code-quality-review` - For code quality in commit messages and documentation
- `/api-readiness-review` - For API key management and security
