---
description: Production readiness review for Code Quality. Reviews SOLID principles compliance, linting standards, code review readiness, redundant code detection, and type safety before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Code Quality Review Command

Run a comprehensive production readiness review focused on code quality and maintainability.

## Purpose

Review code before production release to ensure:
- SOLID principles are followed for maintainability
- Linting standards are met and enforced
- Code is ready for peer review
- Redundant and dead code is eliminated
- Type safety is enforced throughout

## Workflow

### 1. Load the Code Quality Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/code-quality-review/SKILL.md
```

### 2. Detect Stack and Tools

Identify the technology stack and quality tools:
```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt pom.xml build.gradle 2>/dev/null || echo "Unknown stack"

# Detect linters
ls .eslintrc* .prettierrc* .pylintrc setup.cfg flake8 ruff.toml .golangci.yml checkstyle.xml 2>/dev/null

# Detect type checkers
grep -r "typescript\|mypy\|pyright\|golangci-lint" package.json requirements.txt go.mod pyproject.toml 2>/dev/null
```

### 3. Run Code Quality Checks

Execute all checks in parallel:

**SOLID Principles:**
```bash
# Find large classes (potential SRP violations)
find . -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -20

# Find long functions
grep -rE "function|def |func |void |public |private " --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -50

# Find deep nesting (potential complexity)
grep -rE "^\s{16,}" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -20
```

**Linting:**
```bash
# Run linter (TypeScript)
npx eslint . --ext .ts,.tsx 2>&1 | head -50

# Run linter (Python)
python -m pylint **/*.py 2>&1 | head -50 || ruff check . 2>&1 | head -50

# Run linter (Go)
golangci-lint run 2>&1 | head -50

# Check for pre-commit hooks
ls -la .git/hooks/pre-commit .pre-commit-config.yaml 2>/dev/null
```

**Code Review Readiness:**
```bash
# Find commented-out code
grep -rE "^\s*//.*[;{}]\s*$|^\s*#.*[;{}]\s*$|^\s*/\*.*\*/\s*$" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find magic numbers
grep -rE "[^a-zA-Z_][0-9]{2,}[^0-9]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find unclear variable names
grep -rE "\b(x|y|z|temp|tmp|data|val|var|str|num|int)\s*[=:]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
```

**Redundant Code:**
```bash
# Find unused imports
npx ts-prune 2>&1 | head -30 || npx unimported 2>&1 | head -30

# Find dead code
npx knip 2>&1 | head -50

# Find empty blocks
grep -rE "\{\s*\}|\:\s*pass\s*$" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
```

**Type Safety:**
```bash
# Check TypeScript strict mode
cat tsconfig.json 2>/dev/null | grep -E "strict|noImplicitAny|strictNullChecks"

# Find any types
grep -rE ": any\b|as any\b|<any>" --include="*.ts" --include="*.tsx" 2>/dev/null | head -30

# Run type checker
npx tsc --noEmit 2>&1 | head -50
python -m mypy . --strict 2>&1 | head -50
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (SOLID 30%, Linting 20%, Code Review 25%, Redundant Code 10%, Type Safety 15%)
- Calculate overall score
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
- Code examples for fixing issues

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Refactor classes violating Single Responsibility
2. [HIGH] Enable strict mode and fix all type errors
3. [HIGH] Replace all `any` types with proper types
4. [HIGH] Fix all linting errors
5. [MEDIUM] Extract duplicate code to shared utilities

**Short-term (Within 1 week):**
6. [MEDIUM] Remove commented-out code
7. [MEDIUM] Replace magic numbers with constants
8. [MEDIUM] Add explicit return types to public functions
9. [LOW] Add inline documentation for complex logic

**Long-term:**
10. [LOW] Set up automated code complexity tracking
11. [LOW] Configure SonarQube or similar quality gate
12. [LOW] Add code coverage threshold enforcement

## Usage

```
/code-quality-review
```

## When to Use

- Before releasing to production
- After significant refactoring
- When adding large new features
- Before submitting code for review
- When onboarding new team members
- After merging long-lived branches
- During sprint code quality reviews
- When reducing technical debt

## Integration with Other Commands

Consider running alongside:
- `/security-review` - For security vulnerabilities
- `/observability-check` - For logging and monitoring
- `/api-readiness-review` - For API design quality
- `/performance-review` - For performance issues
- `/review-pr` - For comprehensive PR review
