# Production Readiness Review - Execution Order

## Phase Definitions

### PHASE 1: FOUNDATION
**Weight:** 35%
**Rationale:** Foundational issues in code quality and security block or invalidate other reviews. These must pass first.

| Order | Review Skill | Focus Areas | Applicability |
|-------|--------------|-------------|---------------|
| 1 | `code-quality-review` | SOLID principles, linting, type safety, dead code | All projects |
| 2 | `security-review` | OWASP Top 10, authentication, encryption, input validation | All projects |
| 3 | `dependency-security-scan` | CVE scanning, known vulnerabilities, outdated packages | All projects with dependencies |
| 4 | `secrets-management-review` | Hardcoded secrets, environment variables, secret rotation | All projects |
| 5 | `git-hygiene-review` | Sensitive files in history, commit message quality, branch protection | All git projects |

**Phase Pass Criteria:**
- No CRITICAL security vulnerabilities
- No hardcoded secrets in codebase
- Code quality score >= 70

---

### PHASE 2: FUNCTIONAL
**Weight:** 30%
**Rationale:** Core functionality must work correctly. These reviews validate the application does what it's supposed to do.

| Order | Review Skill | Focus Areas | Applicability |
|-------|--------------|-------------|---------------|
| 6 | `testing-review` | Unit coverage >80%, integration tests, E2E, load tests | All projects |
| 7 | `api-readiness-review` | Versioning, rate limiting, documentation, error responses | API projects |
| 8 | `database-review` | Migration scripts, indexing, query optimization, backup integrity | Projects with databases |
| 9 | `performance-review` | Response times <500ms, load testing 2-3x peak, caching | All projects |
| 10 | `error-resilience-review` | Circuit breakers, retry strategies, graceful degradation | All projects |

**Phase Pass Criteria:**
- Test coverage >= 80%
- No untested critical paths
- Error handling for all external dependencies

---

### PHASE 3: OPERATIONAL
**Weight:** 20%
**Rationale:** Infrastructure and operational readiness ensures the system can be deployed, monitored, and recovered.

| Order | Review Skill | Focus Areas | Applicability |
|-------|--------------|-------------|---------------|
| 11 | `devops-review` | CI/CD pipelines, rollback strategy, infrastructure as code | All projects |
| 12 | `observability-review` | Logging, metrics, distributed tracing, alerting, SLOs | All projects |
| 13 | `disaster-recovery-review` | Backup strategy (3-2-1-1-0), RPO/RTO tested, failover procedures | Production systems |
| 14 | `feature-flag-review` | Gradual rollout, kill switches, safety mechanisms | Projects with feature flags |

**Phase Pass Criteria:**
- CI/CD pipeline exists with rollback
- Monitoring and alerting configured
- Backup strategy documented

---

### PHASE 4: COMPLIANCE
**Weight:** 10%
**Rationale:** Regulatory and accessibility requirements. May be legally mandated depending on jurisdiction and user base.

| Order | Review Skill | Focus Areas | Applicability |
|-------|--------------|-------------|---------------|
| 15 | `compliance-review` | GDPR, CCPA, data minimization, retention policies, consent | Projects handling personal data |
| 16 | `accessibility-review` | WCAG 2.1 AA, keyboard navigation, screen readers, color contrast | Web applications |
| 17 | `i18n-l10n-review` | RTL support, locale formatting, translation completeness | International products |
| 18 | `browser-compatibility-review` | Cross-browser support, responsive design, progressive enhancement | Web applications |

**Phase Pass Criteria:**
- No WCAG failures for target compliance level
- Data handling compliant with applicable regulations
- Supported browsers documented and tested

---

### PHASE 5: POLISH
**Weight:** 5%
**Rationale:** User experience and discoverability. Important but not blocking for core functionality.

| Order | Review Skill | Focus Areas | Applicability |
|-------|--------------|-------------|---------------|
| 19 | `ui-ux-review` | Responsive design, loading states, error messages, empty states | User-facing applications |
| 20 | `seo-review` | Meta tags, structured data, Core Web Vitals, LLM optimization | Public web applications |
| 21 | `documentation-review` | Runbooks, architecture diagrams, API docs, on-call guides | All projects |

**Phase Pass Criteria:**
- Critical user flows documented
- On-call runbook exists
- API documentation up to date

---

## Weight Justification

| Phase | Weight | Reasoning |
|-------|--------|-----------|
| Foundation | 35% | Security and code quality are non-negotiable |
| Functional | 30% | Core functionality must work correctly |
| Operational | 20% | Operations critical for production but can be improved post-launch |
| Compliance | 10% | Depends on jurisdiction and user base |
| Polish | 5% | Important for success but not blocking |

---

## Skip Conditions

Reviews should be skipped when:

| Review | Skip Conditions |
|--------|-----------------|
| `api-readiness-review` | No API endpoints |
| `database-review` | No database usage |
| `feature-flag-review` | No feature flags implemented |
| `i18n-l10n-review` | Single-language product with no international users |
| `seo-review` | Non-public application (internal tools, authenticated apps) |
| `accessibility-review` | Non-web application (CLI tools, backend services) |
| `browser-compatibility-review` | Non-web application |

---

## Parallel Execution

Within each phase, reviews CAN be run in parallel since they are independent.

Between phases, reviews MUST be sequential since later phases depend on earlier phase results.

```
Phase 1: [code-quality] [security] [deps] [secrets] [git]  <- parallel
          ↓ wait for all to complete
Phase 2: [testing] [api] [database] [performance] [error]  <- parallel
          ↓ wait for all to complete
Phase 3: [devops] [observability] [dr] [feature-flags]     <- parallel
          ↓ wait for all to complete
Phase 4: [compliance] [accessibility] [i18n] [browser]     <- parallel
          ↓ wait for all to complete
Phase 5: [ui-ux] [seo] [documentation]                      <- parallel
```

---

## Resume Support

If review is interrupted, store state in:
```
./.claude/docs/.production-readiness-state.json
```

Format:
```json
{
  "started": "2026-02-27T19:00:00Z",
  "completed_phases": ["foundation", "functional"],
  "current_phase": "operational",
  "completed_reviews": [
    "code-quality-review",
    "security-review",
    "..."
  ],
  "results": {
    "code-quality-review": { "score": 92, "status": "pass" },
    "..."
  }
}
```
