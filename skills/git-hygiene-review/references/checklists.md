# git-hygiene-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for git-hygiene-review. SKILL.md routes here when running the review workflow.


### Phase 1: Repository Detection

Detect the project's version control system and workflow patterns:

```bash
# Check if git repository
git rev-parse --is-inside-work-tree 2>/dev/null || echo "Not a git repository"

# Get remote URL
git remote get-url origin 2>/dev/null || echo "No remote configured"

# Check for CI/CD configuration
ls -la .github/workflows .gitlab-ci.yml .circleci/config.yml Jenkinsfile 2>/dev/null

# Check for branch protection rules (requires GitHub CLI)
gh branch list --json name,isProtected 2>/dev/null | head -20

# Check for contribution guidelines
ls -la CONTRIBUTING.md .github/CONTRIBUTING.md docs/CONTRIBUTING.md 2>/dev/null

# Check for pre-commit hooks
ls -la .git/hooks/pre-commit .pre-commit-config.yaml 2>/dev/null

# Check git configuration
git config --list | grep -E "user\.(name|email)|commit\.(template|gpgsign)"
```

### Phase 2: Git Hygiene Checklist

Run all checks and compile results:

#### 1. Sensitive Files Ignored

Proper .gitignore prevents accidental commits of sensitive data and build artifacts.

| Check | Pattern | Status |
|-------|---------|--------|
| .gitignore exists | Root .gitignore file present | Required |
| Environment files ignored | .env, .env.local, .env.*.local in .gitignore | Critical |
| Secrets ignored | *.pem, *.key, credentials.*, secrets.* | Critical |
| Build artifacts ignored | node_modules, dist, build, __pycache__ | Required |
| IDE files ignored | .vscode, .idea, *.swp, *.swo | Recommended |
| OS files ignored | .DS_Store, Thumbs.db, desktop.ini | Recommended |
| Log files ignored | *.log, logs/, npm-debug.log* | Required |
| Dependency directories | vendor/, target/, .venv/ | Required |
| Test coverage reports | coverage/, .nyc_output/, .coverage | Recommended |
| Temporary files | *.tmp, *.temp, .cache/ | Required |

**Search Patterns:**
```bash
# Check .gitignore exists
test -f .gitignore && echo "EXISTS" || echo "MISSING"

# Check for environment files
grep -E "^\.env$|^\.env\.local$|^\.env\.\*\.local$" .gitignore 2>/dev/null

# Check for secrets patterns
grep -E "^\*\.pem$|^\*\.key$|^credentials\.|^secrets\." .gitignore 2>/dev/null

# Check for build artifacts
grep -E "^node_modules$|^dist$|^build$|^__pycache__$" .gitignore 2>/dev/null

# Find files that should be ignored but aren't
git ls-files | grep -E "\.env$|\.pem$|\.key$|node_modules|\.log$|\.DS_Store" 2>/dev/null | head -20

# Check for sensitive files in working directory (not committed)
find . -name ".env" -o -name "*.pem" -o -name "*.key" 2>/dev/null | grep -v node_modules | head -10

# List all gitignored files (verify patterns work)
git check-ignore -v .env *.pem 2>/dev/null
```

#### 2. Commit Messages

Clean commit history improves code review, debugging, and collaboration.

| Check | Pattern | Status |
|-------|---------|--------|
| Conventional commits | feat:/fix:/docs:/refactor:/test:/chore: format | Required |
| Descriptive messages | Minimum 10 characters, explains WHY | Required |
| No secrets in messages | No API keys, passwords, tokens in commits | Critical |
| Issue references | Links to tickets (#123, PROJ-456) | Recommended |
| Consistent formatting | Same style across all commits | Required |
| Breaking changes noted | BREAKING CHANGE: for major changes | Required |
| No co-authored-by spam | AI attribution removed | Required |
| Imperative mood | "Add feature" not "Added feature" | Recommended |
| Subject line length | 50 characters or less | Recommended |
| Body wrapped at 72 chars | Commit message body formatted | Recommended |

**Search Patterns:**
```bash
# Get recent commit messages
git log --pretty=format:"%s" -20

# Check for conventional commit format
git log --pretty=format:"%s" -50 | grep -E "^(feat|fix|docs|style|refactor|test|build|ci|perf|chore|revert)(\(.+\))?:" | wc -l

# Find short/non-descriptive commits
git log --pretty=format:"%s" -50 | awk 'length < 10 {print}'

# Search for potential secrets in commit messages
git log --all --grep="api.key\|password\|secret\|token\|AWS" --oneline | head -10

# Check for issue references
git log --pretty=format:"%s" -50 | grep -E "#[0-9]+|[A-Z]+-[0-9]+" | wc -l

# Check for AI attribution
git log --all --grep="Co-Authored-By.*[Cc]laude\|Co-Authored-By.*[Bb]ot\|🤖" --oneline | head -10

# Check commit message body length
git log --format="%B" -10 | awk 'NR > 1 && length > 72 {print}'

# Get commit statistics
git log --pretty=format:"%s" --shortstat -20
```

#### 3. Branch Strategy

Structured branching enables parallel development and safe deployments.

| Check | Pattern | Status |
|-------|---------|--------|
| Naming convention | feature/*, bugfix/*, hotfix/*, release/* | Required |
| Main branch protection | No direct commits to main/master | Required |
| Feature branches | New work in feature/* branches | Required |
| Branch freshness | Branches rebased/merged regularly | Recommended |
| No long-lived branches | Branches merged within 30 days | Required |
| Hotfix workflow | Hotfix branches for emergency fixes | Recommended |
| Release branches | release/* for version prep | Recommended |
| Branch cleanup | Merged branches deleted | Recommended |
| Up-to-date branches | Feature branches updated with main | Required |

**Search Patterns:**
```bash
# List all branches
git branch -a

# Check branch naming
git branch -a | grep -E "feature/|bugfix/|hotfix/|release/|develop" | wc -l

# Find branches not merged to main
git branch --no-merged main 2>/dev/null || git branch --no-merged master 2>/dev/null

# Check branch ages
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ | head -20

# Find long-lived branches (>30 days)
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:unix)' refs/heads/ | awk "$(date +%s)-$2 > 2592000 {print $1}" | head -10

# Check main branch name
git branch --list main master

# Check for direct commits to main/master
MAIN_BRANCH=$(git branch --list main master | head -1 | tr -d ' *')
git log $MAIN_BRANCH --first-parent --pretty=format:"%h %s" -20

# Check remote tracking
git branch -vv | grep -v "\[origin/" | head -10

# Check for stale branches (no commits in 90 days)
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:unix)' refs/heads/ | awk "$(date +%s)-$2 > 7776000 {print $1}"
```

#### 4. No Secrets in Repository

Secrets must never be committed to version control.

| Check | Pattern | Status |
|-------|---------|--------|
| No hardcoded secrets | No API keys, passwords in source | Critical |
| No secrets in history | Git history clean of secrets | Critical |
| No secrets in files | Even gitignored files checked | Critical |
| Pre-commit hooks | Secret scanning before commit | Required |
| CI secret scanning | Automated secret detection | Required |
| No AWS keys | AKIA* patterns not present | Critical |
| No private keys | No *.pem, *.key files committed | Critical |
| No connection strings | No DB URLs with credentials | Critical |
| No API keys | No API_KEY=, api_key: patterns | Critical |

**Search Patterns:**
```bash
# Search for secrets in committed files
git grep -i "api_key\|apikey\|secret_key\|secretkey\|password\|passwd" -- '*.ts' '*.js' '*.py' '*.go' '*.java' '*.yaml' '*.yml' '*.json' '*.env*' 2>/dev/null | head -20

# Search for AWS keys
git grep -E "AKIA[0-9A-Z]{16}" 2>/dev/null | head -10

# Search for private keys
git grep -E "-----BEGIN.*PRIVATE KEY-----" 2>/dev/null | head -10

# Search for connection strings with credentials
git grep -E "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@" 2>/dev/null | head -10

# Search entire git history for secrets
git log --all -p | grep -E "AKIA[0-9A-Z]{16}|api.key.*=.*['\"][^'\"]{16,}['\"]|password.*=.*['\"][^'\"]{8,}['\"]" | head -20

# Check for secret patterns in all commits
git rev-list --all | xargs git grep -l "api_key\|secret_key\|password" 2>/dev/null | head -20

# Check pre-commit hooks for secret scanning
cat .git/hooks/pre-commit 2>/dev/null | grep -i "secret\|key\|password"
cat .pre-commit-config.yaml 2>/dev/null | grep -i "secret\|detect\|trufflehog\|gitleaks"

# Check CI for secret scanning
grep -r "secret.*scan\|trufflehog\|gitleaks\|detect-secrets" .github/workflows/* .gitlab-ci.yml .circleci 2>/dev/null | head -10

# Find potentially sensitive files
git ls-files | grep -iE "credential|secret|key|password|token|auth" | head -20
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific git hygiene gap
2. **Why it matters**: Impact on security and collaboration
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         GIT HYGIENE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Repository: [git remote URL]
Branch: [current branch]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

SENSITIVE FILES IGNORED (25% weight)
  [FAIL] .gitignore file missing
  [FAIL] .env files not in .gitignore
  [PASS] Build artifacts ignored (node_modules, dist)
  [WARN] IDE files not ignored (.vscode, .idea)
  [PASS] OS files ignored (.DS_Store)

COMMIT MESSAGES (25% weight)
  [PASS] Conventional commits format used (85% compliance)
  [FAIL] 5 short commit messages (<10 chars)
  [PASS] No secrets in commit messages
  [WARN] Only 40% of commits reference issues
  [PASS] No AI attribution found
  [FAIL] 3 commit subjects >50 characters

BRANCH STRATEGY (25% weight)
  [PASS] Clear naming convention (feature/*, bugfix/*)
  [FAIL] No branch protection on main
  [WARN] 2 long-lived branches (>30 days)
  [PASS] Feature branches for new work
  [FAIL] Direct commits to main detected
  [PASS] Merged branches cleaned up

NO SECRETS IN REPOSITORY (25% weight)
  [FAIL] Hardcoded API key in src/config.ts
  [FAIL] AWS key found in commit history (abc123)
  [PASS] No private keys committed
  [FAIL] No pre-commit secret scanning
  [FAIL] No CI secret scanning
  [PASS] Connection strings use env vars

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Missing .gitignore File
  Impact: Risk of committing sensitive files, credentials, and build artifacts
  Fix: Create comprehensive .gitignore at repository root
  File: .gitignore (create)

  # Environment variables
  .env
  .env.local
  .env.*.local

  # Dependencies
  node_modules/
  vendor/
  __pycache__/

  # Build outputs
  dist/
  build/
  target/

  # Secrets
  *.pem
  *.key
  credentials.*
  secrets.*

  # IDE
  .vscode/
  .idea/
  *.swp

  # OS
  .DS_Store
  Thumbs.db

  # Logs
  *.log
  logs/

[CRITICAL] Hardcoded API Key in Source Code
  Impact: Secret exposure through repository access
  Fix: Remove immediately, rotate key, use environment variables
  File: src/config.ts:15

  // BEFORE (critical vulnerability):
  const API_KEY = 'sk_live_abc123def456...';

  // AFTER (secure):
  const API_KEY = process.env.API_KEY;
  if (!API_KEY) {
    throw new Error('API_KEY environment variable is required');
  }

  # Immediate actions:
  1. Remove the hardcoded key from src/config.ts
  2. Rotate the API key immediately (it's now compromised)
  3. Add API_KEY to .env file (already gitignored)
  4. Update deployment configuration to inject the secret

[CRITICAL] AWS Key in Commit History
  Impact: Exposed credential can be used even if deleted
  Fix: Remove from history using git filter-branch or BFG Repo-Cleaner
  Commit: abc123 "Add deployment config"

  # Option 1: BFG Repo-Cleaner (recommended)
  bfg --replace-text passwords.txt my-repo.git
  git reflog expire --expire=now --all && git gc --prune=now --aggressive

  # Option 2: git filter-branch
  git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch path/to/file/with/key' \
    --prune-empty --tag-name-filter cat -- --all

  # After cleaning:
  1. Force push to remote (coordinate with team first!)
  2. Rotate the AWS key immediately
  3. All team members must re-clone the repository

[HIGH] No Branch Protection on Main
  Impact: Direct commits can break production, no code review enforcement
  Fix: Enable branch protection rules in GitHub/GitLab
  Action: Repository Settings > Branches > Add rule for 'main'

  # Recommended protection rules:
  - Require pull request before merging
  - Require approvals (minimum 1-2 reviewers)
  - Require status checks to pass (CI/CD)
  - Require branches to be up to date
  - Require signed commits
  - Do not allow bypassing settings

[HIGH] No Pre-Commit Secret Scanning
  Impact: Secrets can be committed before detection
  Fix: Install git-secrets, detect-secrets, or trufflehog
  Action: Add pre-commit hook for automated scanning

  # Option 1: git-secrets (AWS focused)
  brew install git-secrets
  git secrets --install
  git secrets --register-aws

  # Option 2: pre-commit framework with multiple scanners
  # .pre-commit-config.yaml
  repos:
    - repo: https://github.com/Yelp/detect-secrets
      rev: v1.4.0
      hooks:
        - id: detect-secrets
          args: ['--baseline', '.secrets.baseline']

    - repo: https://github.com/gitleaks/gitleaks
      rev: v8.16.0
      hooks:
        - id: gitleaks

  # Install hooks
  pip install pre-commit
  pre-commit install

[HIGH] Direct Commits to Main Branch
  Impact: Bypasses code review, risky for production
  Fix: Enforce PR workflow, educate team
  Files: 3 direct commits found

  # Recent direct commits:
  git log main --first-parent --oneline -5
  abc1234 "Quick fix for production bug"
  def5678 "Update config"
  ghi9012 "Hotfix authentication"

  # Prevention:
  1. Enable branch protection (see above)
  2. Train team on PR workflow
  3. Use conventional commits with PRs

[MEDIUM] Short Commit Messages
  Impact: Difficult to understand change history
  Fix: Use descriptive commit messages explaining WHY
  Commits: 5 messages under 10 characters

  # BEFORE (too short):
  "fix bug"
  "update"
  "wip"

  # AFTER (descriptive):
  "fix: resolve null pointer exception in user authentication"
  "refactor: extract duplicate validation logic to shared utility"
  "feat: add rate limiting to API endpoints for security"

[MEDIUM] Long-Lived Feature Branches
  Impact: Merge conflicts, stale code, difficult integration
  Fix: Merge or rebase branches within 30 days
  Branches: feature/user-redesign (45 days), feature/new-api (60 days)

  # Options:
  1. Complete and merge the feature
  2. Rebase onto main regularly to stay current
  3. Break into smaller, mergeable chunks
  4. Delete if no longer needed

[MEDIUM] IDE Files Not Ignored
  Impact: Unnecessary conflicts, team-specific settings in repo
  Fix: Add IDE directories to .gitignore
  Files: .vscode/, .idea/ found in repository

  # Add to .gitignore:
  .vscode/
  .idea/
  *.swp
  *.swo
  *~

[LOW] Missing Issue References in Commits
  Impact: Difficult to trace commits to requirements
  Fix: Reference issue numbers in commit messages
  Current: 40% of commits have issue references

  # BEFORE:
  git commit -m "fix: resolve login timeout issue"

  # AFTER:
  git commit -m "fix: resolve login timeout issue

  Closes #456"

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Create comprehensive .gitignore file
2. [CRITICAL] Remove hardcoded API key and rotate immediately
3. [CRITICAL] Remove AWS key from git history and rotate
4. [HIGH] Enable branch protection on main branch
5. [HIGH] Install pre-commit secret scanning (git-secrets or trufflehog)
6. [HIGH] Add CI secret scanning to pipeline
7. [HIGH] Stop direct commits to main (use PRs)
8. [MEDIUM] Improve commit message quality
9. [MEDIUM] Merge or delete long-lived branches

After Production:
1. Document branching strategy in CONTRIBUTING.md
2. Train team on conventional commits
3. Set up automated branch cleanup
4. Add commit message linting (commitlint)
5. Configure branch naming enforcement
6. Set up automated dependency updates (Dependabot)
7. Create git workflow documentation

═══════════════════════════════════════════════════════════════
```

---

