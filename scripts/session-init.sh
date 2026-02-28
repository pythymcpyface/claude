#!/bin/bash
# Consolidated Session Initialization
# Combines: generate-project-claude, detect-project, track-usage --init, worktree detection
# Reduces hook overhead from 3 scripts to 1

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
CACHE_DIR="$CLAUDE_DIR"
CACHE_FILE="$CACHE_DIR/.cache_hash"

# ============================================
# 1. USAGE TRACKING INIT (for local LLM)
# ============================================
# Initialize local LLM token tracking via dedicated script
# This sets up session tracking for llama.cpp servers with --metrics
bash "$HOME/.claude/scripts/local-llm-usage.sh" --init 2>/dev/null || true

# ============================================
# 2. WORKTREE DETECTION
# ============================================
# Check if we're in a git worktree and handle session isolation
detect_worktree() {
    local project_dir="$1"

    # Check if we're in a git repository
    if ! git -C "$project_dir" rev-parse --git-dir &>/dev/null; then
        return 1
    fi

    # Get the main worktree path (first worktree in list)
    local main_worktree=$(git -C "$project_dir" worktree list 2>/dev/null | head -1 | cut -f1)
    local current_worktree=$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null)

    # If current path differs from main worktree, we're in a worktree
    if [ -n "$main_worktree" ] && [ "$main_worktree" != "$current_worktree" ]; then
        # Check for session marker
        local session_marker="$project_dir/.worktree-session"
        if [ -f "$session_marker" ]; then
            local branch=$(cat "$session_marker" 2>/dev/null | grep -o '"branch":"[^"]*"' | cut -d'"' -f4)
            local created=$(cat "$session_marker" 2>/dev/null | grep -o '"created":"[^"]*"' | cut -d'"' -f4)
            echo "WORKTREE_DETECTED=1"
            echo "WORKTREE_BRANCH=$branch"
            echo "WORKTREE_CREATED=$created"
            echo "MAIN_REPO=$main_worktree"
            return 0
        fi
    fi
    return 1
}

# Store worktree info for Claude to use
WORKTREE_INFO=$(detect_worktree "$PROJECT_DIR")
if [ -n "$WORKTREE_INFO" ]; then
    echo "$WORKTREE_INFO" > "$CLAUDE_DIR/.worktree-context"
else
    rm -f "$CLAUDE_DIR/.worktree-context" 2>/dev/null || true
fi

# ============================================
# 3. PROJECT DETECTION (skip if not a project)
# ============================================
cd "$PROJECT_DIR" 2>/dev/null || exit 0

IS_PROJECT=false
[ -f "package.json" ] && IS_PROJECT=true
[ -f "Cargo.toml" ] && IS_PROJECT=true
[ -f "go.mod" ] && IS_PROJECT=true
[ -f "pyproject.toml" ] && IS_PROJECT=true
[ -f "requirements.txt" ] && IS_PROJECT=true
[ -d ".git" ] && IS_PROJECT=true

if [ "$IS_PROJECT" = false ]; then
    exit 0
fi

# ============================================
# 4. COPY AUTONOMOUS DEVELOPMENT FLOW DOC
# ============================================
mkdir -p "$CLAUDE_DIR/docs"
GLOBAL_DOCS="$HOME/.claude/docs"
if [ -f "$GLOBAL_DOCS/AUTONOMOUS-DEVELOPMENT-FLOW.md" ] && [ ! -f "$CLAUDE_DIR/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md" ]; then
  cp "$GLOBAL_DOCS/AUTONOMOUS-DEVELOPMENT-FLOW.md" "$CLAUDE_DIR/docs/"
fi

# ============================================
# 5. GENERATE CLAUDE.md IF NEEDED
# ============================================
PROJECT_CLAUDE="$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$PROJECT_CLAUDE" ]; then
    # Delegate to the full generator script
    bash "$HOME/.claude/scripts/generate-project-claude.sh" "$PROJECT_DIR" 2>/dev/null || true
fi

# ============================================
# 6. CACHE HASH FOR DETECTION
# ============================================
calculate_hash() {
    local hash_input=""
    for f in package.json Cargo.toml go.mod pyproject.toml; do
        [ -f "$f" ] && hash_input+="$(cat "$f" 2>/dev/null | wc -c)"
    done
    if command -v md5 >/dev/null 2>&1; then
        echo "$hash_input" | md5
    elif command -v md5sum >/dev/null 2>&1; then
        echo "$hash_input" | md5sum | awk '{print $1}'
    else
        echo "$hash_input" | cksum | awk '{print $1}'
    fi
}

CURRENT_HASH=$(calculate_hash)
mkdir -p "$CACHE_DIR"
echo "$CURRENT_HASH" > "$CACHE_FILE"

exit 0
