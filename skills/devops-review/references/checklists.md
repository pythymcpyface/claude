# devops-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for devops-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's deployment stack to apply appropriate checks:

```bash
# Detect CI/CD platform
ls -la .github/workflows/ 2>/dev/null && echo "GitHub Actions detected"
ls -la .gitlab-ci.yml 2>/dev/null && echo "GitLab CI detected"
ls -la Jenkinsfile 2>/dev/null && echo "Jenkins detected"
ls -la .circleci/ 2>/dev/null && echo "CircleCI detected"

# Detect containerization
ls -la Dockerfile docker-compose*.yml 2>/dev/null && echo "Docker detected"

# Detect Kubernetes
find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion:\|kind:" 2>/dev/null | head -5

# Detect cloud platforms
grep -r "aws\|gcp\|azure\|terraform\|cloudformation" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

### Phase 2: DevOps Checklist

Run all checks and compile results:

#### 1. Rollback Strategy Review

| Check | Pattern | Status |
|-------|---------|--------|
| Rollback mechanism | Automated rollback on failure | Required |
| Blue-green/canary | Progressive deployment strategy | Recommended |
| Feature flags | Ability to disable features without rollback | Recommended |
| Version tagging | Git SHA or semantic version in deployments | Required |
| Database migrations | Backward-compatible migrations | Required |
| Rollback testing | Rollback procedure tested | Recommended |

**Search Patterns:**
```bash
# Find deployment configurations
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l "deployment\|rollout\|strategy" 2>/dev/null

# Check for rollback mechanisms
grep -r "rollback\|undo\|revert" --include="*.yml" --include="*.yaml" --include="*.sh" 2>/dev/null

# Find feature flag implementations
grep -r "feature.*flag\|featureFlag\|FEATURE_\|FLAG_" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null

# Check deployment strategies
grep -r "blue.*green\|canary\|rolling.*update\|maxSurge\|maxUnavailable" --include="*.yml" --include="*.yaml" 2>/dev/null
```

#### 2. Environment Parity Review

| Check | Pattern | Status |
|-------|---------|--------|
| Config management | Environment variables or config files | Required |
| Secrets management | No hardcoded secrets, vault/k8s secrets | Required |
| Infrastructure as Code | Terraform, CloudFormation, Pulumi | Recommended |
| Same container images | Identical images across environments | Required |
| Database parity | Same DB engine/version in all environments | Required |
| Feature parity | Same feature flags/config in all environments | Recommended |

**Search Patterns:**
```bash
# Find environment configurations
find . -name ".env*" -o -name "*.env" 2>/dev/null | head -10
find . -name "config*.yml" -o -name "config*.yaml" -o -name "config*.json" 2>/dev/null | head -10

# Check for hardcoded secrets
grep -rE "password\s*=\s*['\"]|secret\s*=\s*['\"]|api_key\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find secrets management
grep -r "secrets\|vault\|aws.*secrets\|azure.*keyvault" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for environment-specific configs
grep -r "NODE_ENV\|APP_ENV\|ENVIRONMENT\|STAGE" --include="*.yml" --include="*.yaml" --include="*.sh" 2>/dev/null | head -10
```

#### 3. CI/CD Pipeline Review (GitHub Actions)

| Check | Pattern | Status |
|-------|---------|--------|
| Build stage | Automated build on PR/push | Required |
| Test stage | Automated tests in pipeline | Required |
| Security scan | SAST/DAST/dependency scanning | Required |
| Lint/format | Code quality checks | Required |
| Artifact storage | Build artifacts preserved | Required |
| Deployment gates | Manual approval for production | Recommended |
| Parallel jobs | Optimized for speed | Recommended |
| Caching | Dependency caching enabled | Required |

**Search Patterns:**
```bash
# List GitHub Actions workflows
ls -la .github/workflows/ 2>/dev/null

# Find build/test stages
grep -r "build\|test\|lint" .github/workflows/ 2>/dev/null | head -20

# Check for security scanning
grep -r "security\|snyk\|dependabot\|codeql\|sast" .github/workflows/ 2>/dev/null | head -10

# Find deployment workflows
grep -r "deploy\|release" .github/workflows/ 2>/dev/null | head -10

# Check for caching
grep -r "cache\|actions/cache" .github/workflows/ 2>/dev/null | head -10
```

#### 4. Deployment Safety Review

| Check | Pattern | Status |
|-------|---------|--------|
| Health checks | Liveness/readiness probes | Required |
| Graceful shutdown | SIGTERM handling | Required |
| Resource limits | CPU/memory limits defined | Required |
| Pod disruption budgets | PDB for high availability | Recommended |
| Traffic shifting | Gradual traffic increase | Recommended |
| Rollback triggers | Auto-rollback on error rate spike | Recommended |

**Search Patterns:**
```bash
# Find health check configurations
grep -r "livenessProbe\|readinessProbe\|startupProbe" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Check for resource limits
grep -r "resources:\|limits:\|requests:" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Find PDB configurations
grep -r "PodDisruptionBudget\|minAvailable\|maxUnavailable" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Check for graceful shutdown
grep -r "SIGTERM\|graceful\|shutdown\|terminationGracePeriod" --include="*.yml" --include="*.yaml" --include="*.ts" --include="*.js" --include="*.go" 2>/dev/null | head -10
```

#### 5. Monitoring & Alerting Review

| Check | Pattern | Status |
|-------|---------|--------|
| Deployment notifications | Slack/Teams/PagerDuty alerts | Required |
| Pipeline notifications | CI/CD failure alerts | Required |
| Deployment metrics | Success rate, duration tracking | Recommended |
| Rollback alerts | Notification on automatic rollback | Required |

**Search Patterns:**
```bash
# Find notification configurations
grep -r "slack\|teams\|pagerduty\|discord\|webhook" .github/workflows/ 2>/dev/null | head -10

# Check for deployment status checks
grep -r "status\|success\|failure" .github/workflows/ 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific DevOps gap
2. **Why it matters**: Impact on production operations
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         DEVOPS PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
CI/CD: [detected platform]
Container: [Docker/Kubernetes/None]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

ROLLBACK STRATEGY
  [PASS] Version tagging in deployments
  [FAIL] No automated rollback mechanism
  [WARN] Feature flags not implemented
  [PASS] Database migrations backward-compatible

ENVIRONMENT PARITY
  [PASS] Environment variables for config
  [FAIL] Hardcoded secrets detected
  [WARN] Dev/staging use different DB versions
  [PASS] Same container images across environments

CI/CD PIPELINE
  [PASS] Build and test stages
  [FAIL] No security scanning in pipeline
  [PASS] Dependency caching enabled
  [WARN] No deployment gates for production

DEPLOYMENT SAFETY
  [PASS] Health checks configured
  [FAIL] No resource limits defined
  [WARN] No pod disruption budgets
  [PASS] Graceful shutdown implemented

MONITORING
  [FAIL] No deployment notifications
  [WARN] No rollback alerting

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Automated Rollback Mechanism
  Impact: Manual rollback is slow and error-prone during incidents
  Fix: Add rollback step triggered on deployment failure
  File: .github/workflows/deploy.yml

  jobs:
    deploy:
      steps:
        - name: Deploy
          id: deploy
          run: kubectl apply -f k8s/

        - name: Verify Deployment
          run: |
            kubectl rollout status deployment/app --timeout=300s

        - name: Rollback on Failure
          if: failure()
          run: |
            kubectl rollout undo deployment/app
            echo "::error::Deployment failed, rolled back"

[HIGH] Hardcoded Secrets Detected
  Impact: Security vulnerability, secrets exposed in git history
  Fix: Use GitHub Secrets or external secrets manager
  File: config/database.yml

  # Before (BAD):
  database:
    password: "super_secret_password"

  # After (GOOD):
  database:
    password: ${{ secrets.DATABASE_PASSWORD }}

[HIGH] No Security Scanning in CI Pipeline
  Impact: Vulnerabilities may reach production
  Fix: Add SAST and dependency scanning
  File: .github/workflows/ci.yml

  jobs:
    security:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4

        - name: Run Trivy vulnerability scanner
          uses: aquasecurity/trivy-action@master
          with:
            scan-type: 'fs'
            ignore-unfixed: true

        - name: Run CodeQL Analysis
          uses: github/codeql-action/analyze@v3

[MEDIUM] No Resource Limits in Kubernetes
  Impact: Pods can consume unlimited resources, causing node failures
  Fix: Add resource requests and limits
  File: k8s/deployment.yml

  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement automated rollback mechanism
2. [HIGH] Remove all hardcoded secrets, use secrets manager
3. [HIGH] Add security scanning to CI pipeline
4. [MEDIUM] Add resource limits to Kubernetes manifests
5. [MEDIUM] Configure deployment notifications

After Production:
1. Implement feature flags for safer rollouts
2. Add canary deployment strategy
3. Set up pod disruption budgets
4. Configure rollback alerting

═══════════════════════════════════════════════════════════════
```

---

