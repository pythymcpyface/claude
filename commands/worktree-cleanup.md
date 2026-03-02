---
description: Clean up orphaned git worktrees from incomplete bug-fix or feature-dev sessions
argument-hint: Optional: specific branch name to clean up
---

# Worktree Cleanup

Clean up orphaned git worktrees that were left behind from incomplete `/bug-fix` or `/feature-dev` sessions.

## When to Use

- After a `/bug-fix` or `/feature-dev` session was interrupted
- When you see directories like `project-feature-xxx` alongside your main project
- Before starting a new feature or bug fix to ensure clean state
- When `git worktree list` shows worktrees that no longer exist

## Workflow

### 1. List All Worktrees

```bash
git worktree list
```

### 2. Prune Stale References

Remove worktree references that point to non-existent directories:

```bash
git worktree prune -v
```

### 3. Check for Orphaned Directories

Look for worktree directories that exist on disk but may not be in git's records:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
ls -la .. | grep "${REPO_NAME}-"
```

### 4. Analyze Each Worktree

For each worktree found, check:
- Does the branch still exist? `git branch --list <branch-name>`
- Is there a session marker? `cat <worktree-path>/.worktree-session`
- Are there uncommitted changes? `git -C <worktree-path> status --short`

### 5. Present Options

| Worktree | Branch Exists | Uncommitted | Action |
|----------|---------------|-------------|--------|
| `../project-feature-xxx` | Yes | No | Safe to remove |
| `../project-bugfix-yyy` | No | No | Safe to remove |
| `../project-feature-zzz` | Yes | Yes | **Warn user** |

### 6. Cleanup Actions

**For safe worktrees (no uncommitted changes):**
```bash
# Remove the worktree reference
git worktree remove <worktree-path>

# Delete the branch if it exists and is no longer needed
git branch -d <branch-name>

# If the directory still exists on disk
rm -rf <worktree-path>
```

**For worktrees with uncommitted changes:**
Ask user:
1. View the changes first
2. Force remove (discard changes)
3. Skip this worktree

### 7. Final Verification

```bash
git worktree list
git worktree prune
```

## Safety Checks

- **Never remove the main worktree** (first one in the list)
- **Always warn about uncommitted changes**
- **Check for session markers** to identify active work
- **Prefer `git worktree remove` over `rm -rf`** for proper cleanup

## Example Output

```
Found 3 worktrees for myproject:

1. /Users/you/projects/myproject (main) - KEEP
2. /Users/you/projects/myproject-feature-user-auth - ORPHANED (merged)
3. /Users/you/projects/myproject-bugfix-login-crash - ORPHANED (branch deleted)

Reclaimable: ~450MB in node_modules

Clean up all orphaned worktrees? [Y/n]
```
