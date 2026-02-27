---
name: production-readiness-review
description: Comprehensive production readiness orchestration. Runs all 21 review skills sequentially across 5 phases to provide a complete pre-production assessment. Use PROACTIVELY before production releases, major deployments, or quarterly audits.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Production Readiness Review - Orchestration Skill

## Purpose

Execute a comprehensive pre-production review by running all 21 specialized review skills in an optimized 5-phase sequence. This skill aggregates results and produces a detailed readiness report with scores, blockers, and recommendations.

## When to Use

- Before production releases
- Before major deployments
- Quarterly security/compliance audits
- Pre-launch verification
- Post-refactoring validation

## Execution Modes

| Mode | Flag | Description |
|------|------|-------------|
| Full | (default) | Run all 21 reviews across 5 phases |
| Phase | `--phase <name>` | Run only a specific phase |
| Skip | `--skip <reviews>` | Skip specific reviews |

## Phase Structure

```
PHASE 1: FOUNDATION (Weight: 35%)
  1. code-quality-review        # SOLID, linting, types
  2. security-review            # OWASP, auth, encryption
  3. dependency-security-scan   # CVE scanning
  4. secrets-management-review  # No hardcoded secrets
  5. git-hygiene-review         # No sensitive files

PHASE 2: FUNCTIONAL (Weight: 30%)
  6. testing-review             # Coverage, E2E, load
  7. api-readiness-review       # Versioning, rate limiting
  8. database-review            # Migrations, indexing
  9. performance-review         # Response times, scalability
  10. error-resilience-review   # Circuit breaker, fallbacks

PHASE 3: OPERATIONAL (Weight: 20%)
  11. devops-review             # CI/CD, rollback, IaC
  12. observability-review      # Logging, metrics, tracing
  13. disaster-recovery-review  # Backup, RPO/RTO
  14. feature-flag-review       # Gradual rollout, kill switches

PHASE 4: COMPLIANCE (Weight: 10%)
  15. compliance-review         # GDPR, data minimization
  16. accessibility-review      # WCAG 2.1 AA
  17. i18n-l10n-review          # Internationalization
  18. browser-compatibility-review  # Cross-browser

PHASE 5: POLISH (Weight: 5%)
  19. ui-ux-review              # Responsive, states
  20. seo-review                # Meta, structured data
  21. documentation-review      # Runbooks, API docs
```

## Workflow

### Step 1: Project Detection

Analyze the project to determine:
- Primary language/framework
- Key directories
- Existing configuration files
- Applicable reviews (skip non-applicable)

```bash
# Detect project type
ls -la package.json requirements.txt go.mod Cargo.toml 2>/dev/null

# Detect key directories
ls -d src/ lib/ app/ tests/ __tests__/ test/ spec/ 2>/dev/null

# Detect CI/CD
ls -la .github/workflows/ .gitlab-ci.yml Jenkinsfile 2>/dev/null
```

### Step 2: Execute Phase 1 - Foundation

Run foundational reviews that block other issues:

1. **code-quality-review**: Execute `/code-quality-review`
   - Collect: score, issues (critical/high/medium/low)

2. **security-review**: Execute `/security-review`
   - Collect: score, vulnerabilities, recommendations

3. **dependency-security-scan**: Execute `/dependency-security-scan`
   - Collect: CVEs, outdated packages

4. **secrets-management-review**: Execute `/secrets-management-review`
   - Collect: exposed secrets, rotation status

5. **git-hygiene-review**: Execute `/git-hygiene-review`
   - Collect: sensitive files, commit message quality

### Step 3: Execute Phase 2 - Functional

Run functional reviews for core features:

6. **testing-review**: Execute `/testing-review`
7. **api-readiness-review**: Execute `/api-readiness-review`
8. **database-review**: Execute `/database-review`
9. **performance-review**: Execute `/performance-review`
10. **error-resilience-review**: Execute `/error-resilience-review`

### Step 4: Execute Phase 3 - Operational

Run operational reviews for infrastructure:

11. **devops-review**: Execute `/devops-review`
12. **observability-review**: Execute `/observability-review`
13. **disaster-recovery-review**: Execute `/disaster-recovery-review`
14. **feature-flag-review**: Execute `/feature-flag-review`

### Step 5: Execute Phase 4 - Compliance

Run compliance reviews for regulations:

15. **compliance-review**: Execute `/compliance-review`
16. **accessibility-review**: Execute `/accessibility-review`
17. **i18n-l10n-review**: Execute `/i18n-l10n-review`
18. **browser-compatibility-review**: Execute `/browser-compatibility-review`

### Step 6: Execute Phase 5 - Polish

Run polish reviews for user experience:

19. **ui-ux-review**: Execute `/ui-ux-review`
20. **seo-review**: Execute `/seo-review`
21. **documentation-review**: Execute `/documentation-review`

### Step 7: Aggregate Results

Calculate overall score using weighted average:

```
Overall Score = (Phase1_Score * 0.35) +
                (Phase2_Score * 0.30) +
                (Phase3_Score * 0.20) +
                (Phase4_Score * 0.10) +
                (Phase5_Score * 0.05)
```

Phase scores are averages of review scores within the phase.

### Step 8: Generate Report

Create comprehensive report at `./.claude/docs/PRODUCTION-READINESS-REPORT.md`

## Score Interpretation

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | READY | Clear to deploy |
| 75-89 | CONDITIONAL | Fix blockers first |
| 60-74 | NOT READY | Multiple issues to address |
| <60 | BLOCKED | Critical issues prevent deployment |

## Issue Severity Classification

| Level | Criteria | Blocking? |
|-------|----------|-----------|
| CRITICAL | Security vulnerabilities, data loss risk | YES |
| HIGH | Performance degradation, compliance failures | YES |
| MEDIUM | Code quality issues, missing tests | NO |
| LOW | Documentation gaps, minor UX issues | NO |

## Report Template

```
═══════════════════════════════════════════════════════════════════════════
              PRODUCTION READINESS COMPREHENSIVE REPORT
═══════════════════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected]
Reviews Run: X/21
Total Duration: [time]
Date: [timestamp]

────────────────────────────────────────────────────────────────────────────
                        OVERALL SCORE: [X/100]
────────────────────────────────────────────────────────────────────────────
  [PASS]  X reviews passed
  [WARN]  X reviews have warnings
  [FAIL]  X reviews have failures
  [SKIP]  X reviews skipped (not applicable)

────────────────────────────────────────────────────────────────────────────
                         SCORES BY PHASE
────────────────────────────────────────────────────────────────────────────

PHASE 1: FOUNDATION (Weight: 35%)
  [Review results with visual score bars]
  PHASE SCORE: X/100

PHASE 2: FUNCTIONAL (Weight: 30%)
  [Review results with visual score bars]
  PHASE SCORE: X/100

[... continue for all phases ...]

────────────────────────────────────────────────────────────────────────────
                    CRITICAL BLOCKERS (Must Fix)
────────────────────────────────────────────────────────────────────────────
[List of critical issues]

────────────────────────────────────────────────────────────────────────────
                    HIGH PRIORITY (Should Fix)
────────────────────────────────────────────────────────────────────────────
[List of high priority issues]

────────────────────────────────────────────────────────────────────────────
                    MEDIUM PRIORITY (Nice to Have)
────────────────────────────────────────────────────────────────────────────
[List of medium priority issues]

────────────────────────────────────────────────────────────────────────────
                    RELEASE RECOMMENDATION
────────────────────────────────────────────────────────────────────────────
[GO / CONDITIONAL GO / NO GO with specific requirements]
```

## Error Handling

- **Review Failure**: Continue to next review, mark as FAILED
- **Skill Not Found**: Skip and mark as SKIPPED, note in report
- **Timeout**: After 5 minutes per review, mark as TIMEOUT
- **Partial Execution**: Support resuming from last completed review

## Usage Examples

```
# Full review
/production-readiness-review

# Only foundation phase
/production-readiness-review --phase foundation

# Skip time-consuming reviews
/production-readiness-review --skip performance-review,load-testing

# Resume interrupted review
/production-readiness-review --resume
```

## Notes

- Each individual review skill runs its own specialized checks
- This orchestration skill coordinates and aggregates results
- Reviews within a phase are independent but phases are sequential
- Report is saved for compliance documentation
