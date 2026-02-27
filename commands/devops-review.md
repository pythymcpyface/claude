---
description: Production readiness review for Infrastructure & DevOps. Reviews rollback strategy, environment parity, and CI/CD pipelines before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# DevOps Review Command

Run a comprehensive production readiness review focused on Infrastructure & DevOps.

## Purpose

Review code before production release to ensure:
- Automated rollback strategy on deployment failures
- Environment parity (dev/staging/prod consistency)
- Secure CI/CD pipelines with proper gates
- Deployment safety (health checks, resource limits)
- Monitoring and alerting for deployments

## Workflow

### 1. Load the DevOps Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/devops-review/SKILL.md
```

### 2. Detect Project Stack

Identify the CI/CD and deployment technology:
```bash
# CI/CD detection
ls -la .github/workflows/ 2>/dev/null && echo "GitHub Actions"
ls -la .gitlab-ci.yml 2>/dev/null && echo "GitLab CI"
ls -la Jenkinsfile 2>/dev/null && echo "Jenkins"

# Container detection
ls -la Dockerfile docker-compose*.yml 2>/dev/null && echo "Docker"

# Kubernetes detection
find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion:\|kind:" 2>/dev/null | head -5
```

### 3. Run DevOps Checks

Execute all checks in parallel:

**Rollback Strategy:**
```bash
grep -r "rollback\|undo\|rollout.*undo" --include="*.yml" --include="*.yaml" --include="*.sh" 2>/dev/null | head -20
grep -r "blue.*green\|canary\|rolling.*update\|maxSurge\|maxUnavailable" --include="*.yml" --include="*.yaml" 2>/dev/null | head -20
grep -r "feature.*flag\|featureFlag\|FEATURE_" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Environment Parity:**
```bash
# Find configs
find . -name ".env*" -o -name "*.env" -o -name "config*.yml" 2>/dev/null | head -10

# Check for hardcoded secrets
grep -rE "password\s*=\s*['\"]|secret\s*=\s*['\"]|api_key\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.yml" 2>/dev/null | head -10

# Check secrets management
grep -r "secrets\|vault\|aws.*secrets" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10
```

**CI/CD Pipeline:**
```bash
# List workflows
ls -la .github/workflows/ 2>/dev/null

# Find build/test/lint
grep -r "build\|test\|lint" .github/workflows/ 2>/dev/null | head -20

# Check security scanning
grep -r "security\|snyk\|trivy\|codeql\|sast" .github/workflows/ 2>/dev/null | head -10

# Check caching
grep -r "cache\|actions/cache" .github/workflows/ 2>/dev/null | head -10
```

**Deployment Safety:**
```bash
# Health checks
grep -r "livenessProbe\|readinessProbe\|startupProbe" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Resource limits
grep -r "resources:\|limits:\|requests:" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Graceful shutdown
grep -r "SIGTERM\|graceful\|terminationGracePeriod" --include="*.yml" --include="*.yaml" --include="*.ts" --include="*.js" 2>/dev/null | head -10
```

**Monitoring:**
```bash
# Notifications
grep -r "slack\|teams\|pagerduty\|webhook" .github/workflows/ 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Rollback, Parity, CI/CD, Safety, Monitoring)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must fix before production
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/devops-review
```

## When to Use

- Before production deployments
- When modifying CI/CD pipelines
- When changing deployment configurations
- After Dockerfile or Kubernetes manifest changes
- During release planning
- Before major version releases

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For logging, metrics, tracing
- `/quality-check` - For lint, types, tests
- `/security-review` - For security vulnerabilities
- `/review-pr` - For comprehensive PR review
