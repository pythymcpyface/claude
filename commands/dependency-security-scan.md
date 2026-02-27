---
description: Production readiness review for dependency security. Scans for known vulnerabilities (CVEs) in npm, pip, go mod, and cargo dependencies. 84% of breaches originate from vulnerable dependencies.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Dependency Security Scan Command

Run a comprehensive dependency vulnerability scan before production release.

## Purpose

Review dependencies for security vulnerabilities to ensure:
- No known CRITICAL or HIGH vulnerabilities (CVEs)
- Dependencies are actively maintained and up-to-date
- License compliance is verified
- Automated update tooling (Dependabot/Renovate) is configured
- Vulnerability scanning is integrated into CI/CD

## The Critical Importance

**84% of data breaches originate from vulnerable dependencies.** Supply chain attacks are increasing, and outdated packages are a primary attack vector. This command ensures your dependencies are secure before production release.

## Workflow

### 1. Load the Dependency Security Scan Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/dependency-security-scan/SKILL.md
```

### 2. Detect Package Ecosystems

Identify which dependency managers are used:

```bash
# JavaScript/TypeScript
ls -la package.json package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null && echo "npm/yarn detected"

# Python
ls -la requirements.txt Pipfile pyproject.toml poetry.lock 2>/dev/null && echo "Python detected"

# Go
ls -la go.mod go.sum 2>/dev/null && echo "Go detected"

# Rust
ls -la Cargo.toml Cargo.lock 2>/dev/null && echo "Rust detected"
```

### 3. Run Vulnerability Scans

Execute vulnerability scans for each detected ecosystem:

**JavaScript/TypeScript (npm/yarn):**
```bash
# Check for lock file
ls -la package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null

# Run npm audit
npm audit --json 2>/dev/null | head -100

# Check for audit in CI
grep -r "npm audit\|yarn audit" .github/workflows/ --include="*.yml" 2>/dev/null

# Check for Dependabot/Renovate
ls -la .github/dependabot.yml 2>/dev/null
grep -r "renovate" .github/ --include="*.json" --include="*.yml" 2>/dev/null | head -10

# Check outdated packages
npm outdated --json 2>/dev/null | head -50
```

**Python (pip/poetry):**
```bash
# Check for requirements files
ls -la requirements.txt requirements*.txt Pipfile pyproject.toml poetry.lock 2>/dev/null

# Check if pip-audit or safety is available
which pip-audit 2>/dev/null && pip-audit --version
which safety 2>/dev/null && safety --version

# Run pip-audit (if installed)
pip-audit --format json 2>/dev/null | head -100 || echo "pip-audit not installed"

# Check for pinned versions
head -20 requirements.txt 2>/dev/null | grep -E "^[a-zA-Z].*==" || echo "Versions not pinned"

# Check for audit in CI
grep -r "pip-audit\|safety check" .github/workflows/ --include="*.yml" 2>/dev/null
```

**Go (go mod):**
```bash
# Check for go.mod
ls -la go.mod go.sum 2>/dev/null

# Check Go version
go version 2>/dev/null
head -5 go.mod 2>/dev/null

# Check if govulncheck is available
which govulncheck 2>/dev/null && govulncheck -version

# Run govulncheck (if installed)
govulncheck ./... 2>&1 | head -50 || echo "govulncheck not installed"

# Check for audit in CI
grep -r "govulncheck" .github/workflows/ --include="*.yml" 2>/dev/null
```

**Rust (cargo):**
```bash
# Check for Cargo files
ls -la Cargo.toml Cargo.lock 2>/dev/null

# Check if cargo audit is available
cargo audit --version 2>/dev/null

# Run cargo audit (if installed)
cargo audit 2>&1 | head -50 || echo "cargo-audit not installed"

# Check for audit in CI
grep -r "cargo audit" .github/workflows/ --include="*.yml" 2>/dev/null
```

**License Compliance:**
```bash
# Check for license file
ls -la LICENSE LICENSE.md 2>/dev/null

# Check for problematic licenses (if license-checker available)
npx license-checker --json 2>/dev/null | grep -i "GPL\|AGPL" | head -20
```

**Automated Updates:**
```bash
# Check for Dependabot
ls -la .github/dependabot.yml 2>/dev/null
cat .github/dependabot.yml 2>/dev/null

# Check for Renovate
ls -la renovate.json renovate.json5 .github/renovate.json 2>/dev/null
```

### 4. Analyze and Score

Based on the skill checklist:
- Count vulnerabilities by severity (CRITICAL, HIGH, MEDIUM, LOW)
- Score each category (Vulnerabilities, Outdated, License, Updates, CI)
- Calculate overall score
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | No HIGH/CRITICAL vulnerabilities |
| 70-89 | NEEDS WORK | MEDIUM vulnerabilities only |
| 50-69 | AT RISK | HIGH vulnerabilities found |
| 0-49 | BLOCK | CRITICAL vulnerabilities or no scanning |

### 5. Generate Report

Output the formatted report with:
- Executive summary with vulnerability counts
- Overall score and blocking status
- Checklist results (PASS/FAIL/WARN/N/A for each item)
- Vulnerability details (CVE, severity, fix version)
- Gap analysis with specific recommendations
- Remediation commands for quick fixes

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Fix all CRITICAL vulnerabilities
2. [HIGH] Fix all HIGH vulnerabilities
3. [HIGH] Add vulnerability scanning to CI

**Short-term (Within 1 week):**
4. [MEDIUM] Configure Dependabot/Renovate
5. [MEDIUM] Update outdated packages

**Long-term:**
6. [LOW] Review license compliance
7. [LOW] Set up SBOM generation

## Usage

```
/dependency-security-scan
```

## When to Use

- Before any production release
- When dependencies are added or updated
- During security audits
- As part of PR review process
- Scheduled weekly/monthly security scans
- After security incident investigation

## Blocking Conditions

This command will **recommend blocking** production release if:
- Any CRITICAL vulnerability is found
- Any HIGH vulnerability is found
- No vulnerability scanning is configured

## Integration with Other Commands

Run alongside other production readiness checks:
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For logging and monitoring
- `/quality-check` - For lint, types, tests
- `/security-review` - For application security

## Example Output

```
═══════════════════════════════════════════════════════════════
     DEPENDENCY SECURITY SCAN REPORT
═══════════════════════════════════════════════════════════════
Project: my-application
Ecosystems: npm, pip
Date: 2026-02-27

OVERALL SCORE: 45/100 [BLOCK]

───────────────────────────────────────────────────────────────
              EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Vulnerabilities Found:
  CRITICAL: 1  (Must fix before production)
  HIGH:     2  (Must fix before production)
  MEDIUM:   3  (Should fix soon)
  LOW:      5  (Review when possible)

Outdated Packages: 12
License Issues: 1

RECOMMENDATION: DO NOT RELEASE TO PRODUCTION

Run with --fix flag for automated remediation suggestions.
═══════════════════════════════════════════════════════════════
```
