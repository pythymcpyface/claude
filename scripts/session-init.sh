#!/bin/bash
# Consolidated Session Initialization
# Combines: generate-project-claude, detect-project, track-usage --init
# Reduces hook overhead from 3 scripts to 1

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
CACHE_DIR="$CLAUDE_DIR"
CACHE_FILE="$CACHE_DIR/.cache_hash"

# ============================================
# 1. USAGE TRACKING INIT (minimal)
# ============================================
USAGE_FILE="$HOME/.claude/usage.json"
if [[ ! -f "$USAGE_FILE" ]]; then
    mkdir -p "$(dirname "$USAGE_FILE")"
    echo '{"plan_tier":"pro","prompts_per_window":600,"window_hours":5,"calls":[]}' > "$USAGE_FILE"
fi

# ============================================
# 2. PROJECT DETECTION (skip if not a project)
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
# 3. COPY AUTONOMOUS DEVELOPMENT FLOW DOC
# ============================================
mkdir -p "$CLAUDE_DIR/docs"
GLOBAL_DOCS="$HOME/.claude/docs"
if [ -f "$GLOBAL_DOCS/AUTONOMOUS-DEVELOPMENT-FLOW.md" ] && [ ! -f "$CLAUDE_DIR/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md" ]; then
  cp "$GLOBAL_DOCS/AUTONOMOUS-DEVELOPMENT-FLOW.md" "$CLAUDE_DIR/docs/"
fi

# ============================================
# 4. GENERATE CLAUDE.md IF NEEDED
# ============================================
PROJECT_CLAUDE="$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$PROJECT_CLAUDE" ]; then
    # Delegate to the full generator script
    bash "$HOME/.claude/scripts/generate-project-claude.sh" "$PROJECT_DIR" 2>/dev/null || true
fi

# ============================================
# 5. CACHE HASH FOR DETECTION
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
