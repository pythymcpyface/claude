# dependency-security-scan — Implementation Patterns

Reusable code snippets and configuration templates for dependency-security-scan. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### npm Audit in CI (GitHub Actions)

```yaml
# .github/workflows/security.yml
name: Dependency Security

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  npm-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Run npm audit
        run: npm audit --audit-level=high
        continue-on-error: false

      - name: Run Trivy scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
```

### Python pip-audit in CI

```yaml
# .github/workflows/security.yml
jobs:
  pip-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pip-audit safety

      - name: Run pip-audit
        run: pip-audit --format=json --output=pip-audit.json

      - name: Run safety check
        run: safety check --json --output safety.json

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: security-reports
          path: '*.json'
```

### Go govulncheck in CI

```yaml
# .github/workflows/security.yml
jobs:
  go-vuln:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.21'

      - name: Install govulncheck
        run: go install golang.org/x/vuln/cmd/govulncheck@latest

      - name: Run govulncheck
        run: govulncheck ./...
```

### Rust cargo audit in CI

```yaml
# .github/workflows/security.yml
jobs:
  cargo-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Rust
        uses: actions-rust-lang/setup-rust-toolchain@v1

      - name: Install cargo-audit
        run: cargo install cargo-audit

      - name: Run cargo audit
        run: cargo audit
```

### Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  # npm
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    groups:
      production-dependencies:
        dependency-type: "production"
      development-dependencies:
        dependency-type: "development"

  # Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"

  # Go
  - package-ecosystem: "go"
    directory: "/"
    schedule:
      interval: "weekly"

  # Rust
  - package-ecosystem: "cargo"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Renovate Configuration

```json
// renovate.json
{
  "extends": ["config:recommended"],
  "schedule": ["every weekend"],
  "packageRules": [
    {
      "matchUpdateTypes": ["minor", "patch"],
      "groupName": "non-major dependencies",
      "groupSlug": "all-minor-patch"
    },
    {
      "matchUpdateTypes": ["major"],
      "groupName": null,
      "labels": ["major-update"]
    }
  ],
  "vulnerabilityAlerts": {
    "enabled": true
  }
}
```

---

## Tool Installation

```bash
# Node.js
npm install -g npm-check-updates  # For checking updates

# Python
pip install pip-audit safety pip-licenses

# Go
go install golang.org/x/vuln/cmd/govulncheck@latest

# Rust
cargo install cargo-audit
```

---

