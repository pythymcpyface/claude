---
description: Production readiness review for Testing. Reviews unit test coverage >80%, integration tests, E2E tests, regression tests, load tests, security tests, test quality, and TDD/BDD practices before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Testing Review Command

Run a comprehensive production readiness review focused on Testing Strategy & Coverage.

## Purpose

Review code before production release to ensure:
- Unit test coverage >= 80%
- Integration tests for services and databases
- E2E tests for critical user journeys
- Regression tests for bug fixes
- Load/performance tests
- Security tests (OWASP coverage)
- Test quality (no flaky tests, good assertions)
- TDD/BDD practices

## Workflow

### 1. Load the Testing Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/testing-review/SKILL.md
```

### 2. Detect Project Testing Stack

Identify the testing frameworks and coverage tools:
```bash
# Detect JavaScript/TypeScript testing
grep -r "jest\|vitest\|mocha\|cypress\|playwright" package.json 2>/dev/null

# Detect Python testing
grep -r "pytest\|unittest\|nose\|behave" requirements.txt pyproject.toml 2>/dev/null

# Detect Go testing
ls *_test.go 2>/dev/null | head -5

# Check for coverage tools
grep -r "coverage\|nyc\|pytest-cov" package.json requirements.txt 2>/dev/null

# Find test directories
find . -type d -name "*test*" -o -name "*spec*" 2>/dev/null | grep -v node_modules | head -10
```

### 3. Run Testing Checks

Execute all checks in parallel:

**Unit Test Coverage:**
```bash
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" 2>/dev/null | grep -v node_modules | head -20
grep -r "coverageThreshold\|coverage" --include="*.json" --include="*.yaml" 2>/dev/null | head -15
grep -r "codecov\|coveralls" .github .gitlab-ci.yml 2>/dev/null | head -10
```

**Integration Tests:**
```bash
find . -name "*.integration.test.*" -o -name "*integration*" 2>/dev/null | grep -v node_modules | head -15
grep -r "testcontainers\|mock\|stub" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -10
```

**E2E Tests:**
```bash
find . -name "*.e2e.test.*" -o -name "cypress" -type d -o -name "playwright" -type d 2>/dev/null | head -15
grep -r "cypress\|playwright\|puppeteer\|selenium" package.json requirements.txt 2>/dev/null | head -10
```

**Regression Tests:**
```bash
find . -name "*.regression.test.*" -o -name "*regression*" 2>/dev/null | head -10
grep -r "#[0-9]\|issue\|bug\|fix" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15
```

**Load/Performance Tests:**
```bash
find . -name "*.load.test.*" -o -name "*benchmark*" -o -name "k6*.js" 2>/dev/null | head -15
grep -r "k6\|artillery\|locust\|jmeter\|gatling" package.json requirements.txt 2>/dev/null | head -10
```

**Security Tests:**
```bash
find . -name "*.security.test.*" -o -name "*security*" 2>/dev/null | grep -v node_modules | head -10
grep -r "owasp\|snyk\|safety\|bandit" package.json requirements.txt 2>/dev/null | head -10
grep -r "injection\|xss\|csrf" --include="*.test.*" 2>/dev/null | head -10
```

**Test Quality:**
```bash
grep -r "flaky\|retry" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
grep -r "expect\|assert\|should" --include="*.test.*" 2>/dev/null | head -20
```

**TDD/BDD Practices:**
```bash
grep -r "given\|when\|then\|describe\|context" --include="*.test.*" 2>/dev/null | head -20
find . -name "*.feature" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Unit, Integration, E2E, Regression, Load, Security, Quality, TDD/BDD)
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
1. **Critical** - Must fix before production (e.g., coverage < 80%, no load tests)
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/testing-review
```

## When to Use

- Before production releases
- When adding new features
- After bug fixes (regression tests)
- During CI/CD pipeline setup
- When modifying critical business logic
- After authentication/authorization changes
- Before major version releases

## Integration with Other Commands

Consider running alongside:
- `/security-review` - For security vulnerabilities
- `/performance-review` - For performance under load
- `/devops-review` - For CI/CD configuration
- `/quality-check` - For code quality validation
