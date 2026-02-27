---
description: Production readiness review for Secrets Management. Reviews 12-Factor compliance, vault integration, environment variable security, secret rotation, and secrets storage before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Secrets Management Review Command

Run a comprehensive production readiness review focused on secrets management and configuration security.

## Purpose

Review secrets management before production release to ensure:
- 12-Factor app compliance (config in environment)
- No hardcoded secrets in source code
- Proper vault or secret manager integration
- Secure environment variable handling
- Secret rotation policies and automation
- Secure storage and transmission of secrets

## Workflow

### 1. Load the Secrets Management Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/secrets-management-review/SKILL.md
```

### 2. Detect Secret Management Stack

Identify the secret management technology and patterns:
```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect secret management libraries
grep -r "vault\|dotenv\|config\|secrets\|credentials" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Detect cloud provider secret managers
grep -r "aws-sdk\|@aws-sdk\|SecretsManager\|KeyVault\|SecretManager" package.json requirements.txt go.mod 2>/dev/null
```

### 3. Run Secrets Management Checks

Execute all checks in parallel:

**12-Factor Compliance:**
```bash
# Find hardcoded secrets
grep -rE "(api[_-]?key|apikey|secret[_-]?key|password|token)[\"']?\s*[:=]\s*[\"'][^\"']{8,}[\"']" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find AWS keys
grep -rE "AKIA[0-9A-Z]{16}" --include="*" 2>/dev/null | head -10

# Find private keys
grep -rE "-----BEGIN.*PRIVATE KEY-----" --include="*" 2>/dev/null | head -10

# Find connection strings with credentials
grep -rE "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Check .env files in gitignore
grep -r "^\.env" .gitignore 2>/dev/null
```

**Vault Integration:**
```bash
# Find vault client imports
grep -r "node-vault\|hvac\|vault\|HashiCorp" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find AWS Secrets Manager
grep -r "SecretsManager\|GetSecretValue\|secretsmanager" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find Kubernetes secrets
grep -r "secretKeyRef\|valueFrom.*secret" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10
```

**Environment Variable Security:**
```bash
# Find potential secret logging
grep -r "console\.log.*env\|logger\..*env\|print.*environ" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find frontend secret exposure
grep -rE "NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*PASSWORD\|NEXT_PUBLIC_.*TOKEN" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | head -10
```

**Secret Storage:**
```bash
# Find secrets in Docker files
grep -rE "ENV.*PASSWORD|ENV.*SECRET|ENV.*KEY|ENV.*TOKEN" --include="Dockerfile*" 2>/dev/null | head -10

# Find hardcoded secrets in CI/CD
grep -rE "password:|secret:|api_key:|token:" --include="*.yml" --include="*.yaml" .github .gitlab-ci.yml 2>/dev/null | head -10

# Find unencrypted secret files
find . -name "*.pem" -o -name "*.key" 2>/dev/null | grep -v node_modules | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (12-Factor, Vault, Env Var Security, Rotation, Storage, Third-Party)
- Calculate overall score (weighted)
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All required checks pass |
| 70-89 | NEEDS WORK | Minor gaps, mostly complete |
| 50-69 | AT RISK | Significant gaps found |
| 0-49 | BLOCK | Critical gaps, do not release |

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Remove all hardcoded secrets from source code
2. [CRITICAL] Rotate any exposed secrets immediately
3. [CRITICAL] Remove secrets from Dockerfiles and CI configs
4. [HIGH] Integrate vault or cloud secret manager
5. [HIGH] Add environment variable validation at startup

**Short-term (Within 1 week):**
6. [HIGH] Document all environment variables
7. [HIGH] Create secret rotation policy
8. [MEDIUM] Set up secret scanning in CI/CD
9. [MEDIUM] Configure IP restrictions for API keys

**Long-term:**
10. [MEDIUM] Implement automated secret rotation
11. [MEDIUM] Add secret access audit logging
12. [LOW] Create emergency rotation runbook

## Usage

```
/secrets-management-review
```

## When to Use

- Before releasing to production
- When setting up CI/CD pipelines
- When configuring external service integrations
- When adding new environment variables
- When modifying authentication code
- During security audits
- Before major version releases

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For logging and monitoring of secret access
- `/devops-review` - For CI/CD secret injection and deployment
- `/api-readiness-review` - For API key management
- `/security-review` - For comprehensive security audit
- `/quality-check` - For code quality in secret handling
