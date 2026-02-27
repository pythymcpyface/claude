#!/bin/bash
# Worktree Helper Script for Claude Code
# Manages git worktrees for parallel agent instances

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT")

usage() {
    echo "Usage: worktree-helper.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <branch-name>     Create a new worktree with branch"
    echo "  list                     List all worktrees"
    echo "  remove <branch-name>     Remove a worktree and optionally delete branch"
    echo "  merge <branch-name>      Merge worktree branch to main and cleanup"
    echo "  prune                    Remove stale worktree references"
    echo "  status                   Show worktree status"
    echo ""
    echo "Examples:"
    echo "  worktree-helper.sh create fix/login-bug"
    echo "  worktree-helper.sh create feature/user-auth"
    echo "  worktree-helper.sh merge fix/login-bug"
    echo "  worktree-helper.sh list"
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

    echo ""
    echo "Worktree created successfully!"
    echo "  Branch: $branch_name"
    echo "  Path: $worktree_path"
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
    -h|--help|help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
