#!/bin/bash
# Worktree Helper Script for Claude Code
# Manages git worktrees for parallel agent instances
# Supports session isolation via .worktree-session marker

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT")

usage() {
    echo "Usage: worktree-helper.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <branch-name>     Create a new worktree with branch"
    echo "  list                     List all worktrees with session status"
    echo "  remove <branch-name>     Remove a worktree and optionally delete branch"
    echo "  merge <branch-name>      Merge worktree branch to main and cleanup"
    echo "  prune                    Remove stale worktree references"
    echo "  status                   Show worktree status"
    echo "  session <branch-name>    Show session info for a worktree"
    echo "  abandon                  Abandon current worktree session (return to main)"
    echo ""
    echo "Branch Naming Convention (MANDATORY):"
    echo "  feature/<description>        New feature (e.g., feature/user-auth)"
    echo "  feature/<issue-id>-<desc>    Feature with issue (e.g., feature/JIRA-123-auth)"
    echo "  bugfix/<description>         Bug fix (e.g., bugfix/login-timeout)"
    echo "  bugfix/<issue-id>-<desc>     Bug fix with issue (e.g., bugfix/GH-789-crash)"
    echo "  hotfix/<description>         Production hotfix (e.g., hotfix/security-patch)"
    echo "  release/v<version>           Release branch (e.g., release/v2.1.0)"
    echo "  docs/<description>           Documentation (e.g., docs/api-reference)"
    echo "  refactor/<description>       Refactoring (e.g., refactor/auth-module)"
    echo "  test/<description>           Testing (e.g., test/integration-coverage)"
    echo "  chore/<description>          Maintenance (e.g., chore/update-deps)"
    echo ""
    echo "Examples:"
    echo "  worktree-helper.sh create bugfix/login-bug"
    echo "  worktree-helper.sh create feature/JIRA-123-user-auth"
    echo "  worktree-helper.sh merge bugfix/login-bug"
    echo "  worktree-helper.sh list"
    echo "  worktree-helper.sh session feature/user-auth"
}

get_worktree_path() {
    local branch_name="$1"
    local safe_name=$(echo "$branch_name" | sed 's/\//-/g')
    echo "../${REPO_NAME}-${safe_name}"
}

cmd_create() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "Error: Branch name required"
        usage
        exit 1
    fi

    # Validate branch naming convention
    if [[ ! "$branch_name" =~ ^(feature|bugfix|hotfix|release|docs|refactor|test|chore)/ ]]; then
        echo "Warning: Branch name does not follow naming convention."
        echo "Expected pattern: <type>/<description> where type is one of:"
        echo "  feature, bugfix, hotfix, release, docs, refactor, test, chore"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check branch name length
    if [ ${#branch_name} -gt 50 ]; then
        echo "Warning: Branch name exceeds 50 characters (current: ${#branch_name})"
        echo "Consider shortening the description."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    local worktree_path=$(get_worktree_path "$branch_name")

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        echo "Error: Worktree already exists at $worktree_path"
        exit 1
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Branch $branch_name already exists. Creating worktree from existing branch..."
        git worktree add "$worktree_path" "$branch_name"
    else
        echo "Creating new branch $branch_name and worktree at $worktree_path..."
        git worktree add "$worktree_path" -b "$branch_name"
    fi

    # Create session marker for worktree isolation
    echo "{\"branch\":\"$branch_name\",\"created\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"pid\":$$}" > "$worktree_path/.worktree-session"

    echo ""
    echo "Worktree created successfully!"
    echo "  Branch: $branch_name"
    echo "  Path: $worktree_path"
    echo "  Session marker: .worktree-session"
    echo ""
    echo "To start a Claude session in this worktree:"
    echo "  cd $worktree_path && claude"
}

cmd_list() {
    echo "Worktrees for $REPO_NAME:"
    echo ""
    git worktree list
    echo ""

    # Show additional info
    local worktrees=$(git worktree list | tail -n +2)
    if [ -n "$worktrees" ]; then
        echo "Active worktrees:"
        echo "$worktrees" | while read path commit branch; do
            local branch_name=$(echo "$branch" | tr -d '[]')
            echo "  - $branch_name -> $path"
        done
    else
        echo "No additional worktrees (only main repo)"
    fi
}

cmd_remove() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "Error: Branch name required"
        usage
        exit 1
    fi

    local worktree_path=$(get_worktree_path "$branch_name")

    if [ ! -d "$worktree_path" ]; then
        echo "Error: Worktree not found at $worktree_path"
        echo "Available worktrees:"
        git worktree list
        exit 1
    fi

    # Remove session marker first
    local session_file="$worktree_path/.worktree-session"
    if [ -f "$session_file" ]; then
        rm "$session_file"
        echo "Session marker removed"
    fi

    echo "Removing worktree at $worktree_path..."
    git worktree remove "$worktree_path"

    read -p "Delete branch '$branch_name'? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -d "$branch_name" 2>/dev/null || git branch -D "$branch_name"
        echo "Branch $branch_name deleted"
    fi

    git worktree prune
    echo "Worktree removed successfully"
}

cmd_merge() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "Error: Branch name required"
        usage
        exit 1
    fi

    local worktree_path=$(get_worktree_path "$branch_name")

    # Check for uncommitted changes in worktree
    if [ -d "$worktree_path" ]; then
        echo "Checking for uncommitted changes in worktree..."
        if ! git -C "$worktree_path" diff-index --quiet HEAD -- 2>/dev/null; then
            echo "Warning: Uncommitted changes in worktree. Please commit or stash first."
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    # Switch to main and merge
    local main_branch=$(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d":" -f2 | tr -d ' ')
    if [ -z "$main_branch" ]; then
        main_branch="main"
    fi

    echo "Switching to $main_branch and merging $branch_name..."
    git checkout "$main_branch"
    git pull --no-rebase 2>/dev/null || true
    git merge --no-ff "$branch_name" -m "Merge $branch_name"

    read -p "Push to remote? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin "$main_branch"
        echo "Pushed to remote"
    fi

    # Cleanup
    if [ -d "$worktree_path" ]; then
        echo "Removing worktree..."
        git worktree remove "$worktree_path"
    fi

    read -p "Delete branch '$branch_name'? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -d "$branch_name" 2>/dev/null || git branch -D "$branch_name"
        echo "Branch $branch_name deleted"
    fi

    git worktree prune
    echo "Merge complete!"
}

cmd_prune() {
    echo "Pruning stale worktree references..."
    git worktree prune -v
    echo "Done"
}

cmd_status() {
    echo "Worktree Status for $REPO_NAME"
    echo "================================"
    echo ""
    echo "Current directory: $(pwd)"
    echo "Main repo: $REPO_ROOT"
    echo ""

    echo "All worktrees:"
    git worktree list
    echo ""

    echo "Current branch: $(git branch --show-current)"

    # Check for session markers
    echo ""
    echo "Active sessions:"
    local found_session=false
    for wt_path in $(git worktree list | tail -n +2 | awk '{print $1}'); do
        if [ -f "$wt_path/.worktree-session" ]; then
            local branch=$(cat "$wt_path/.worktree-session" 2>/dev/null | grep -o '"branch":"[^"]*"' | cut -d'"' -f4)
            local created=$(cat "$wt_path/.worktree-session" 2>/dev/null | grep -o '"created":"[^"]*"' | cut -d'"' -f4)
            echo "  $branch (created: $created)"
            found_session=true
        fi
    done
    if [ "$found_session" = false ]; then
        echo "  No active sessions with markers"
    fi

    # Check for modified worktrees
    echo ""
    echo "Uncommitted changes by worktree:"
    git worktree list | while read path commit branch; do
        if [ "$path" != "." ] && [ -d "$path" ]; then
            if ! git -C "$path" diff-index --quiet HEAD -- 2>/dev/null; then
                echo "  $branch: HAS UNCOMMITTED CHANGES"
            fi
        fi
    done
}

cmd_session() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "Error: Branch name required"
        usage
        exit 1
    fi

    local worktree_path=$(get_worktree_path "$branch_name")
    local session_file="$worktree_path/.worktree-session"

    if [ ! -f "$session_file" ]; then
        echo "No session marker found for branch $branch_name"
        echo "Worktree path: $worktree_path"
        exit 1
    fi

    echo "Session info for $branch_name:"
    echo "================================"
    cat "$session_file" | python3 -m json.tool 2>/dev/null || cat "$session_file"
    echo ""
    echo "Worktree path: $worktree_path"
}

cmd_abandon() {
    # Check if we're in a worktree
    local current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
    local main_worktree=$(git worktree list 2>/dev/null | head -1 | cut -f1)

    if [ "$current_worktree" = "$main_worktree" ] || [ -z "$main_worktree" ]; then
        echo "Not in a worktree - already in main repo"
        exit 0
    fi

    local session_file="$current_worktree/.worktree-session"
    local branch_name=$(git branch --show-current)

    echo "Abandoning worktree session..."
    echo "  Branch: $branch_name"
    echo "  Path: $current_worktree"
    echo ""

    # Remove session marker
    if [ -f "$session_file" ]; then
        rm "$session_file"
        echo "Session marker removed"
    fi

    echo ""
    echo "To return to main repo:"
    echo "  cd $main_worktree"
    echo ""
    echo "To clean up the worktree:"
    echo "  worktree-helper.sh remove $branch_name"
}

# Main command dispatcher
case "${1:-}" in
    create)
        cmd_create "$2"
        ;;
    list)
        cmd_list
        ;;
    remove)
        cmd_remove "$2"
        ;;
    merge)
        cmd_merge "$2"
        ;;
    prune)
        cmd_prune
        ;;
    status)
        cmd_status
        ;;
    session)
        cmd_session "$2"
        ;;
    abandon)
        cmd_abandon
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
