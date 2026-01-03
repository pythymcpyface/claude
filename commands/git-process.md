---
description: Checkout new branch, stage all changes, create commit, and push to remote (use with caution)
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git diff:*), Bash(git log:*), Bash(git pull:*), Bash(git checkout:*), Bash(git switch:*), Bash(find:*), Bash(grep:*), Bash(cat:*)
---

# Git Process Command

Stage all changes, commit with conventional format, and push to remote.

## Workflow

### 1. Analyze Changes
Run in parallel:
- `git status` - Modified/added/deleted/untracked files
- `git diff --stat` - Change statistics
- `git log -1 --oneline` - Recent commit for message style

### 2. Safety Checks

**STOP if detected:**
- Secrets: `.env*`, `*.key`, `*.pem`, `credentials.json`, API keys with real values
- Large files: >10MB not in Git LFS
- Build artifacts: `node_modules/`, `dist/`, `build/`, `__pycache__/`
- Merge conflicts or unmerged paths

**Verify:**
- `.gitignore` properly configured
- Correct branch (warn if main/master)
- Pre-commit hooks present

### 3. Branch Management

If on main/master, create new branch:
```
feat/[scope]-[description]
fix/[issue-number]-[description]
docs/[description]
refactor/[scope]-[description]
```

### 4. Confirm with User

```
📊 Changes Summary:
- X files modified, Y added, Z deleted
- Total: +AAA insertions, -BBB deletions

🔒 Safety Checks: ✅ No secrets ✅ No large files

🌿 Branch: [current-branch] → origin/[current-branch]

📝 Proposed commit:
[type]([scope]): [brief summary]

Proceed? (yes/review/no)
```

**WAIT for explicit response.**

### 5. Pull Before Push

**CRITICAL**: Always pull latest to sync any automated release commits:
```bash
git pull origin $(git branch --show-current) --no-rebase
```

### 6. Stage and Commit

```bash
git add .
git commit -m "$(cat <<'EOF'
[type]([scope]): Brief summary

- Key change 1
- Key change 2
EOF
)"
```

**Conventional Commit Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code refactoring
- `test` - Tests
- `chore` - Maintenance

**CRITICAL - No AI Attribution:**
- NEVER include "Co-Authored-By: Claude"
- NEVER include robot emojis or watermarks

### 7. Push

```bash
git push -u origin $(git branch --show-current)
```

### 8. Confirm Success

```
✅ Successfully committed and pushed!
Commit: [hash] [message]
Branch: [branch] → origin/[branch]

Next: gh pr create --web
```

## Error Handling

| Error | Solution |
|-------|----------|
| Pre-commit hook failed | Fix issues, retry |
| Non-fast-forward | `git pull --no-rebase && git push` |
| Protected branch | Create feature branch and PR |

## When to Use

✅ Multi-file feature, bug fix, documentation update
❌ Uncertain changes, contains secrets, multiple unrelated changes
