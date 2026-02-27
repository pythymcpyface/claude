---
description: Comprehensive production readiness orchestration. Runs all 21 review skills sequentially across 5 phases to provide a complete pre-production assessment. Use PROACTIVELY before production releases, major deployments, or quarterly audits.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Production Readiness Review Command

Run a comprehensive pre-production review by executing all 21 specialized review skills in an optimized 5-phase sequence.

## Purpose

Execute a complete production readiness assessment that covers:
- **Foundation**: Code quality, security, dependencies, secrets, git hygiene
- **Functional**: Testing, API, database, performance, error resilience
- **Operational**: DevOps, observability, disaster recovery, feature flags
- **Compliance**: GDPR, accessibility, internationalization, browser compatibility
- **Polish**: UI/UX, SEO, documentation

## Workflow

### 1. Load the Orchestration Skill

Read the skill definition to understand the full execution plan:

```
Read: skills/production-readiness-review/SKILL.md
Read: skills/production-readiness-review/references/execution-order.md
```

### 2. Detect Project Context

Identify the project stack and applicable reviews:
```bash
# Detect project type
ls -la package.json requirements.txt go.mod Cargo.toml pom.xml build.gradle 2>/dev/null

# Detect key directories
ls -d src/ lib/ app/ api/ tests/ __tests__/ test/ spec/ cypress/ playwright/ 2>/dev/null

# Detect CI/CD
ls -la .github/workflows/ .gitlab-ci.yml Jenkinsfile azure-pipelines.yml 2>/dev/null

# Detect database
grep -r "prisma\|sequelize\|typeorm\|mongoose\|knex\|sqlalchemy" --include="*.json" --include="*.toml" 2>/dev/null | head -5

# Detect feature flags
grep -r "launchdarkly\|unleash\|flagsmith\|optimizely" --include="*.json" --include="*.toml" 2>/dev/null | head -5
```

### 3. Execute Phase 1 - Foundation (Weight: 35%)

Run foundational reviews sequentially:

1. `/code-quality-review` - SOLID principles, linting, type safety
2. `/security-review` - OWASP Top 10, authentication, encryption
3. `/dependency-security-scan` - CVE scanning, known vulnerabilities
4. `/secrets-management-review` - No hardcoded secrets, rotation status
5. `/git-hygiene-review` - Sensitive files, commit quality

Collect scores and issues from each review.

### 4. Execute Phase 2 - Functional (Weight: 30%)

Run functional reviews:

6. `/testing-review` - Coverage >80%, E2E, load tests
7. `/api-readiness-review` - Versioning, rate limiting (if API)
8. `/database-review` - Migrations, indexing (if database)
9. `/performance-review` - Response times, caching
10. `/error-resilience-review` - Circuit breakers, fallbacks

### 5. Execute Phase 3 - Operational (Weight: 20%)

Run operational reviews:

11. `/devops-review` - CI/CD, rollback strategy
12. `/observability-review` - Logging, metrics, tracing
13. `/disaster-recovery-review` - Backup, RPO/RTO
14. `/feature-flag-review` - Gradual rollout, kill switches (if applicable)

### 6. Execute Phase 4 - Compliance (Weight: 10%)

Run compliance reviews:

15. `/compliance-review` - GDPR, data minimization
16. `/accessibility-review` - WCAG 2.1 AA (if web app)
17. `/i18n-l10n-review` - Internationalization (if applicable)
18. `/browser-compatibility-review` - Cross-browser support (if web app)

### 7. Execute Phase 5 - Polish (Weight: 5%)

Run polish reviews:

19. `/ui-ux-review` - Responsive, loading states (if user-facing)
20. `/seo-review` - Meta tags, structured data (if public)
21. `/documentation-review` - Runbooks, API docs

### 8. Aggregate Results

Calculate weighted overall score:
```
Overall = (Phase1 * 0.35) + (Phase2 * 0.30) + (Phase3 * 0.20) + (Phase4 * 0.10) + (Phase5 * 0.05)
```

### 9. Generate Comprehensive Report

Create report at `./.claude/docs/PRODUCTION-READINESS-REPORT.md`:

```markdown
═══════════════════════════════════════════════════════════════════════════
              PRODUCTION READINESS COMPREHENSIVE REPORT
═══════════════════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected]
Reviews Run: X/21
Date: [timestamp]

────────────────────────────────────────────────────────────────────────────
                        OVERALL SCORE: [X/100]
────────────────────────────────────────────────────────────────────────────
  [PASS]  X reviews passed
  [WARN]  X reviews have warnings
  [FAIL]  X reviews have failures
  [SKIP]  X reviews skipped

────────────────────────────────────────────────────────────────────────────
                         SCORES BY PHASE
────────────────────────────────────────────────────────────────────────────

PHASE 1: FOUNDATION (35%)
  code-quality-review        [PASS] 92/100 ████████████████████░
  security-review            [WARN] 78/100 ████████████████░░░░░
  ...
  PHASE SCORE: 91/100

[Continue for all phases]

────────────────────────────────────────────────────────────────────────────
                    CRITICAL BLOCKERS (Must Fix)
────────────────────────────────────────────────────────────────────────────
1. [performance-review] API response times exceed 500ms threshold
2. [disaster-recovery-review] No backup restoration tested

────────────────────────────────────────────────────────────────────────────
                    HIGH PRIORITY (Should Fix)
────────────────────────────────────────────────────────────────────────────
3. [security-review] CORS allows all origins
4. [testing-review] Coverage at 65% (target: 80%)

────────────────────────────────────────────────────────────────────────────
                    RELEASE RECOMMENDATION
────────────────────────────────────────────────────────────────────────────
STATUS: [GO / CONDITIONAL GO / NO GO]

[Specific requirements and post-launch action items]
═══════════════════════════════════════════════════════════════════════════
```

## Usage

```
# Full review (all 21 skills)
/production-readiness-review

# Only foundation phase
/production-readiness-review --phase foundation

# Skip time-consuming reviews
/production-readiness-review --skip performance-review,load-testing

# Resume interrupted review
/production-readiness-review --resume
```

## Score Interpretation

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | READY | Clear to deploy |
| 75-89 | CONDITIONAL | Fix blockers first |
| 60-74 | NOT READY | Multiple issues |
| <60 | BLOCKED | Critical issues |

## When to Use

- Before production releases
- Before major deployments
- Quarterly security/compliance audits
- Pre-launch verification
- Post-refactoring validation
- M&A technical due diligence

## Integration with Individual Reviews

This command orchestrates all individual review skills. You can also run specific reviews:

- `/security-review` - Deep security analysis only
- `/testing-review` - Testing coverage only
- `/performance-review` - Performance analysis only
- `/compliance-review` - Regulatory compliance only

## Notes

- Each individual review skill has its own specialized checks
- This command coordinates and aggregates results
- Reviews are skipped automatically when not applicable
- Report is saved for compliance documentation
