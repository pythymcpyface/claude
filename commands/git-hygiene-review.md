---
description: Production readiness review for Git Hygiene. Reviews sensitive files ignored, commit messages, branch strategy, and no secrets. Use PROACTIVELY before production releases, when setting up new repositories, or establishing team workflows.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Git Hygiene Review Command

Run a comprehensive production readiness review focused on git hygiene and repository best practices.

## Purpose

Review git hygiene before production release to ensure:
- Sensitive files are properly ignored (.gitignore)
- Commit messages follow conventions
- Branch strategy is well-organized
- No secrets are committed to the repository

## Workflow

### 1. Load the Git Hygiene Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/git-hygiene-review/SKILL.md
```

### 2. Detect Repository Configuration

Identify the version control system and workflow:
```bash
# Check if git repository
git rev-parse --is-inside-work-tree 2>/dev/null || echo "Not a git repository"

# Get remote URL
git remote get-url origin 2>/dev/null || echo "No remote configured"

# Check for CI/CD configuration
ls -la .github/workflows .gitlab-ci.yml .circleci/config.yml Jenkinsfile 2>/dev/null

# Check for contribution guidelines
ls -la CONTRIBUTING.md .github/CONTRIBUTING.md 2>/dev/null

# Check for pre-commit hooks
ls -la .git/hooks/pre-commit .pre-commit-config.yaml 2>/dev/null
```

### 3. Run Git Hygiene Checks

Execute all checks in parallel:

**Sensitive Files Ignored:**
```bash
# Check .gitignore exists
test -f .gitignore && echo "EXISTS" || echo "MISSING"

# Check for environment files in .gitignore
grep -E "^\.env$|^\.env\.local$|^\.env\.\*\.local$" .gitignore 2>/dev/null

# Check for secrets patterns in .gitignore
grep -E "^\*\.pem$|^\*\.key$|^credentials\.|^secrets\." .gitignore 2>/dev/null

# Find files that should be ignored but aren't
git ls-files | grep -E "\.env$|\.pem$|\.key$|node_modules|\.log$|\.DS_Store" 2>/dev/null | head -20

# Check for sensitive files in working directory
find . -name ".env" -o -name "*.pem" -o -name "*.key" 2>/dev/null | grep -v node_modules | head -10
```

**Commit Messages:**
```bash
# Get recent commit messages
git log --pretty=format:"%s" -20

# Check for conventional commit format
git log --pretty=format:"%s" -50 | grep -E "^(feat|fix|docs|style|refactor|test|build|ci|perf|chore|revert)(\(.+\))?:" | wc -l

# Find short/non-descriptive commits
git log --pretty=format:"%s" -50 | awk 'length < 10 {print}'

# Search for potential secrets in commit messages
git log --all --grep="api.key\|password\|secret\|token\|AWS" --oneline | head -10

# Check for AI attribution
git log --all --grep="Co-Authored-By.*[Cc]laude\|Co-Authored-By.*[Bb]ot\|🤖" --oneline | head -10
```

**Branch Strategy:**
```bash
# List all branches
git branch -a

# Check branch naming
git branch -a | grep -E "feature/|bugfix/|hotfix/|release/|develop" | wc -l

# Check main branch name
git branch --list main master

# Find long-lived branches (>30 days)
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:unix)' refs/heads/ | awk "$(date +%s)-$2 > 2592000 {print $1}" | head -10

# Check for direct commits to main/master
MAIN_BRANCH=$(git branch --list main master | head -1 | tr -d ' *')
git log $MAIN_BRANCH --first-parent --pretty=format:"%h %s" -10
```

**No Secrets in Repository:**
```bash
# Search for secrets in committed files
git grep -i "api_key\|apikey\|secret_key\|password\|passwd" -- '*.ts' '*.js' '*.py' '*.go' '*.yaml' '*.yml' '*.json' 2>/dev/null | head -20

# Search for AWS keys
git grep -E "AKIA[0-9A-Z]{16}" 2>/dev/null | head -10

# Search for private keys
git grep -E "-----BEGIN.*PRIVATE KEY-----" 2>/dev/null | head -10

# Search for connection strings with credentials
git grep -E "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@" 2>/dev/null | head -10

# Check for secret scanning in pre-commit
cat .git/hooks/pre-commit 2>/dev/null | grep -i "secret\|key\|password"
cat .pre-commit-config.yaml 2>/dev/null | grep -i "secret\|detect\|trufflehog\|gitleaks"
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Sensitive Files, Commit Messages, Branch Strategy, No Secrets)
- Calculate overall score (weighted equally at 25% each)
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
1. [CRITICAL] Create comprehensive .gitignore file
2. [CRITICAL] Remove all hardcoded secrets from repository
3. [CRITICAL] Remove secrets from git history (if any found)
4. [HIGH] Enable branch protection on main/master
5. [HIGH] Install pre-commit secret scanning

**Short-term (Within 1 week):**
6. [HIGH] Add CI secret scanning to pipeline
7. [HIGH] Stop direct commits to main (use PRs)
8. [MEDIUM] Improve commit message quality
9. [MEDIUM] Merge or delete long-lived branches
10. [MEDIUM] Add IDE files to .gitignore

**Long-term:**
11. [MEDIUM] Document branching strategy in CONTRIBUTING.md
12. [MEDIUM] Train team on conventional commits
13. [LOW] Add commit message linting (commitlint)
14. [LOW] Configure branch naming enforcement
15. [LOW] Set up automated dependency updates

## Usage

```
/git-hygiene-review
```

## When to Use

- Before releasing to production
- When setting up new repositories
- When establishing team workflows
- When onboarding new team members
- After security incidents
- Before major version releases
- When merging long-lived feature branches
- During code review process
- When creating contribution guidelines

## Integration with Other Commands

Consider running alongside:
- `/secrets-management-review` - For detailed secret handling and vault integration
- `/devops-review` - For CI/CD pipeline security and deployment workflows
- `/security-review` - For comprehensive security audit
- `/api-readiness-review` - For API key management and security
- `/quality-check` - For code quality in commit messages
