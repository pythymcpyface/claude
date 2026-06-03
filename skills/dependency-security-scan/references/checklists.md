# dependency-security-scan — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for dependency-security-scan. SKILL.md routes here when running the review workflow.


### Phase 1: Ecosystem Detection

Detect the project's package ecosystems:

```bash
# Detect JavaScript/TypeScript
ls -la package.json package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null && echo "npm/yarn detected"

# Detect Python
ls -la requirements.txt Pipfile pyproject.toml poetry.lock 2>/dev/null && echo "Python detected"

# Detect Go
ls -la go.mod go.sum 2>/dev/null && echo "Go detected"

# Detect Rust
ls -la Cargo.toml Cargo.lock 2>/dev/null && echo "Rust detected"
```

### Phase 2: Vulnerability Scanning Checklist

Run vulnerability scans for each detected ecosystem:

#### 1. JavaScript/TypeScript (npm/yarn)

| Check | Pattern | Status |
|-------|---------|--------|
| npm audit run | No CRITICAL or HIGH vulnerabilities | Required |
| Lock file present | package-lock.json or yarn.lock exists | Required |
| Outdated packages | No packages >1 year old | Recommended |
| Audit in CI | npm audit in CI pipeline | Required |
| Dependabot/Renovate | Automated dependency updates | Recommended |

**Scan Commands:**
```bash
# Check for lock file
ls -la package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null

# Run npm audit
npm audit --json 2>/dev/null | head -100

# Check for audit in CI
grep -r "npm audit\|yarn audit" .github/workflows/ --include="*.yml" 2>/dev/null

# Check for Dependabot
ls -la .github/dependabot.yml 2>/dev/null
grep -r "renovate" .github/ --include="*.json" --include="*.yml" 2>/dev/null

# Check package ages (approximate)
npm outdated --json 2>/dev/null | head -50
```

#### 2. Python (pip/poetry)

| Check | Pattern | Status |
|-------|---------|--------|
| pip-audit/safety run | No CRITICAL or HIGH vulnerabilities | Required |
| Requirements pinned | Exact versions in requirements.txt | Required |
| Virtual environment | Dependencies in isolated environment | Recommended |
| Audit in CI | pip-audit/safety in CI pipeline | Required |
| Dependabot/Renovate | Automated dependency updates | Recommended |

**Scan Commands:**
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

#### 3. Go (go mod)

| Check | Pattern | Status |
|-------|---------|--------|
| govulncheck run | No CRITICAL or HIGH vulnerabilities | Required |
| go.sum present | Checksums verified | Required |
| Go version | Go version supported | Required |
| Audit in CI | govulncheck in CI pipeline | Required |
| Dependabot/Renovate | Automated dependency updates | Recommended |

**Scan Commands:**
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

#### 4. Rust (cargo)

| Check | Pattern | Status |
|-------|---------|--------|
| cargo audit run | No CRITICAL or HIGH vulnerabilities | Required |
| Cargo.lock present | Lock file committed | Required |
| Audit in CI | cargo audit in CI pipeline | Required |
| Dependabot/Renovate | Automated dependency updates | Recommended |

**Scan Commands:**
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

#### 5. License Compliance

| Check | Pattern | Status |
|-------|---------|--------|
| License check | No GPL/AGPL in commercial projects | Recommended |
| License file | LICENSE file present | Recommended |
| Dependency licenses | All dependency licenses reviewed | Recommended |

**Scan Commands:**
```bash
# Check for license file
ls -la LICENSE LICENSE.md 2>/dev/null

# Check for license checking tools
which license-checker npx 2>/dev/null

# npm license check (if available)
npx license-checker --json 2>/dev/null | head -50 || echo "License checker not run"
```

#### 6. Automated Updates

| Check | Pattern | Status |
|-------|---------|--------|
| Dependabot | .github/dependabot.yml exists | Recommended |
| Renovate | Renovate bot configured | Recommended |
| Update schedule | Weekly or daily updates | Recommended |
| Grouped updates | Related updates grouped | Recommended |

**Scan Commands:**
```bash
# Check for Dependabot
ls -la .github/dependabot.yml 2>/dev/null
cat .github/dependabot.yml 2>/dev/null

# Check for Renovate
ls -la renovate.json renovate.json5 .github/renovate.json 2>/dev/null
grep -r "renovate" .github/ --include="*.json" --include="*.yml" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific security gap
2. **Why it matters**: Impact on production security
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
     DEPENDENCY SECURITY SCAN REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Ecosystems: [npm, pip, go, cargo]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
              EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Vulnerabilities Found:
  CRITICAL: [X]  (Must fix before production)
  HIGH:     [X]  (Must fix before production)
  MEDIUM:   [X]  (Should fix soon)
  LOW:      [X]  (Review when possible)

Outdated Packages: [X]
License Issues: [X]

───────────────────────────────────────────────────────────────
              CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

NPM/YARN (JavaScript)
  [PASS] npm audit - No vulnerabilities
  [FAIL] No lock file found
  [WARN] 5 packages outdated >1 year
  [FAIL] No audit in CI pipeline
  [WARN] Dependabot not configured

PYTHON (pip/poetry)
  [FAIL] CRITICAL vulnerability: requests 2.25.0 (CVE-2023-XXXX)
  [PASS] Requirements pinned with exact versions
  [PASS] pip-audit in CI pipeline
  [WARN] Safety not installed

GO (go mod)
  [PASS] govulncheck - No vulnerabilities
  [PASS] go.sum present
  [PASS] govulncheck in CI pipeline

RUST (cargo)
  [N/A] No Rust dependencies

LICENSE COMPLIANCE
  [PASS] LICENSE file present
  [WARN] GPL-3.0 dependency detected (lodash-es)

AUTOMATED UPDATES
  [FAIL] No Dependabot or Renovate configuration

───────────────────────────────────────────────────────────────
              VULNERABILITY DETAILS
───────────────────────────────────────────────────────────────

[CRITICAL] requests 2.25.0 - CVE-2023-32681
  Severity: CRITICAL (CVSS 9.8)
  Description: Unintended leak of Proxy-Authorization header
  Fixed in: 2.31.0
  Fix: pip install requests>=2.31.0

[HIGH] lodash 4.17.15 - CVE-2021-23337
  Severity: HIGH (CVSS 7.2)
  Description: Command Injection in template
  Fixed in: 4.17.21
  Fix: npm update lodash

───────────────────────────────────────────────────────────────
              GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] CRITICAL Vulnerability in requests
  Impact: Active exploitation possible, data breach risk
  Fix: Update to requests>=2.31.0 immediately
  File: requirements.txt

  # Before (BAD):
  requests==2.25.0

  # After (GOOD):
  requests>=2.31.0

[HIGH] No npm Audit in CI Pipeline
  Impact: Vulnerabilities may reach production undetected
  Fix: Add audit step to CI workflow
  File: .github/workflows/ci.yml

  jobs:
    security:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - run: npm ci
        - run: npm audit --audit-level=high

[MEDIUM] Dependabot Not Configured
  Impact: Manual dependency updates are error-prone
  Fix: Enable Dependabot for automated updates
  File: .github/dependabot.yml

  version: 2
  updates:
    - package-ecosystem: "npm"
      directory: "/"
      schedule:
        interval: "weekly"
      open-pull-requests-limit: 10

───────────────────────────────────────────────────────────────
              REMEDIATION PLAN
───────────────────────────────────────────────────────────────

Immediate Actions (Before Production):
1. [CRITICAL] Update requests to 2.31.0
2. [HIGH] Update lodash to 4.17.21
3. [HIGH] Add npm audit to CI pipeline

Short-term (Within 1 Week):
4. [MEDIUM] Configure Dependabot for all ecosystems
5. [MEDIUM] Review and update outdated packages

Automation Commands:
  npm:    npm audit fix && npm update
  pip:    pip-audit --fix && pip install -U requests
  go:     go get -u ./... && go mod tidy

═══════════════════════════════════════════════════════════════
```

---

