# git-hygiene-review — Implementation Patterns

Reusable code snippets and configuration templates for git-hygiene-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Comprehensive .gitignore

```gitignore
# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc
.pyo
.pyd
.Python
pip-log.txt
pip-delete-this-directory.txt

# Build outputs
dist/
build/
target/
out/
*.class
*.log
*.gz

# Secrets and credentials
*.pem
*.key
*.crt
credentials.json
credentials.yml
secrets.json
secrets.yml
.secrets/
.auth/

# IDE and editors
.vscode/
.idea/
*.swp
*.swo
*~
.project
.classpath
.c9/
*.launch
.settings/

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Test coverage
coverage/
.coverage
.nyc_output/
htmlcov/

# Temporary files
*.tmp
*.temp
.cache/
.parcel-cache/
.eslintcache
.stylelintcache

# Package files
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Database
*.db
*.sqlite
*.sqlite3
*.sql.gz

# Documentation builds
docs/_build/
site/
```

### Conventional Commits Format

```bash
# Format: <type>(<optional scope>): <description>

# Types:
feat:     A new feature
fix:      A bug fix
docs:     Documentation only changes
style:    Changes that do not affect the meaning of the code
refactor: A code change that neither fixes a bug nor adds a feature
test:     Adding missing tests or correcting existing tests
chore:    Changes to the build process or auxiliary tools
perf:     A code change that improves performance
ci:       Changes to CI configuration files and scripts
revert:   Reverts a previous commit

# Examples:
git commit -m "feat(auth): add OAuth2 login support"
git commit -m "fix(api): resolve null pointer in user endpoint"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(utils): extract duplicate validation logic"
git commit -m "test(auth): add unit tests for token validation"

# With body and footer:
git commit -m "feat(api): add rate limiting to endpoints

Implement token bucket algorithm for rate limiting.
Configurable via RATE_LIMIT_REQUESTS and RATE_LIMIT_WINDOW.

Closes #456
BREAKING CHANGE: API now returns 429 for rate limit violations"
```

### Branch Naming Conventions

```bash
# Feature branches
feature/user-authentication
feature/shopping-cart
feature/PROJ-123-dashboard-redesign

# Bugfix branches
bugfix/login-timeout
bugfix/PROJ-456-memory-leak

# Hotfix branches (production issues)
hotfix/critical-security-patch
hotfix/0.1.1-database-connection

# Release branches
release/1.0.0
release/2.1.0-rc1

# Development branches
develop
staging

# Create feature branch
git checkout -b feature/user-authentication

# Keep branch updated
git fetch origin
git rebase origin/main

# Push and create PR
git push -u origin feature/user-authentication
gh pr create --title "feat: add user authentication" --body "Implements OAuth2 login"
```

### Pre-Commit Secret Scanning

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Install: cp scripts/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

echo "Checking for secrets..."

# Check for potential secrets in staged files
if git diff --cached --name-only | xargs grep -lE "(api[_-]?key|apikey|secret[_-]?key|password|token).*=.*['\"][^'\"]{16,}['\"]" 2>/dev/null; then
    echo "ERROR: Potential secrets detected in staged files!"
    echo "Please use environment variables instead."
    echo ""
    echo "Offending files:"
    git diff --cached --name-only | xargs grep -lE "(api[_-]?key|apikey|secret[_-]?key|password|token).*=.*['\"][^'\"]{16,}['\"]" 2>/dev/null
    exit 1
fi

# Check for AWS keys
if git diff --cached | grep -E "AKIA[0-9A-Z]{16}"; then
    echo "ERROR: AWS Access Key detected!"
    exit 1
fi

# Check for private keys
if git diff --cached | grep -E "-----BEGIN.*PRIVATE KEY-----"; then
    echo "ERROR: Private key detected!"
    exit 1
fi

# Check for connection strings with credentials
if git diff --cached | grep -E "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@"; then
    echo "ERROR: Connection string with credentials detected!"
    exit 1
fi

echo "No secrets detected. Proceeding with commit."
```

### Git Secrets Setup

```bash
# Install git-secrets
# macOS
brew install git-secrets

# Linux
wget https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets
sudo install git-secrets /usr/local/bin

# Install in repository
cd your-repo
git secrets --install
git secrets --register-aws

# Scan repository
git secrets --scan-history

# Scan specific files
git secrets --scan file1 file2

# Add custom patterns
git secrets --add 'password\s*=\s*.+'
git secrets --add 'api_key\s*=\s*.+'
```

### BFG Repo-Cleaner (Remove Secrets from History)

```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Create file with secrets to replace
echo "sk_live_abc123def456==>REMOVED" > passwords.txt
echo "AKIAIOSFODNN7EXAMPLE==>REMOVED" >> passwords.txt

# Clean repository
java -jar bfg-1.14.0.jar --replace-text passwords.txt my-repo.git

# Clean up
cd my-repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (WARNING: coordinate with team first!)
git push --force origin main
```

### Branch Protection Rules (GitHub)

```yaml
# .github/settings.yml (with Probot Settings)
repository:
  branch_protection:
    - branch: main
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
        require_code_owner_reviews: true
      required_status_checks:
        strict: true
        contexts:
          - "ci/lint"
          - "ci/test"
          - "ci/build"
      enforce_admins: true
      required_linear_history: true
      allow_force_pushes: false
      allow_deletions: false

    - branch: develop
      required_pull_request_reviews:
        required_approving_review_count: 1
      required_status_checks:
        strict: true
        contexts:
          - "ci/test"
```

### Commitlint Configuration

```javascript
// .commitlintrc.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'revert'],
    ],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-max-length': [2, 'always', 50],
    'body-max-line-length': [2, 'always', 72],
    'references-empty': [1, 'never'], // Warn if no issue reference
  },
};
```

```json
// package.json
{
  "devDependencies": {
    "@commitlint/cli": "^17.0.0",
    "@commitlint/config-conventional": "^17.0.0",
    "husky": "^8.0.0"
  },
  "scripts": {
    "prepare": "husky install"
  }
}
```

```bash
# .husky/commit-msg
npx --no -- commitlint --edit $1
```

### CONTRIBUTING.md Template

```markdown
# Contributing Guide

## Git Workflow

### Branch Naming
- Feature: `feature/description` or `feature/PROJ-123-description`
- Bugfix: `bugfix/description`
- Hotfix: `hotfix/description`
- Release: `release/1.0.0`

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): subject

[optional body]

[optional footer]
```

**Types:** feat, fix, docs, style, refactor, test, chore, perf, ci

**Examples:**
- `feat(auth): add OAuth2 login support`
- `fix(api): resolve null pointer in user endpoint`
- `docs(readme): update installation instructions`

### Pull Requests
1. Create feature branch from `main`
2. Make changes with conventional commits
3. Push branch and create PR
4. Ensure CI passes
5. Get at least 1 approval
6. Squash and merge

### Code Review
- All code requires review before merge
- Be respectful and constructive
- Focus on code quality, not style (use linters)

## Security

### Never Commit Secrets
- Use environment variables
- Add secrets to `.env` (gitignored)
- Pre-commit hooks will scan for secrets
- If you accidentally commit a secret, rotate it immediately

## Branch Protection
- `main` branch is protected
- No direct commits to `main`
- Requires PR with approval and passing CI
```

---

