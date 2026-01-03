#!/bin/bash
# Context Compression Helper
# Called periodically or on session end to help with context management

echo "=== CONTEXT CHECKPOINT ==="
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Git context if in repo
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "## Git Status"
  echo "Branch: $(git branch --show-current)"
  echo "Last commit: $(git log -1 --oneline 2>/dev/null || echo 'None')"

  CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGED" -gt 0 ]; then
    echo "Uncommitted changes: $CHANGED files"
    git status --porcelain | head -10
    [ "$CHANGED" -gt 10 ] && echo "... and $((CHANGED - 10)) more"
  fi
  echo ""
fi

# Project type detection
echo "## Project Type"
[ -f "package.json" ] && echo "- Node.js/TypeScript"
[ -f "Cargo.toml" ] && echo "- Rust"
[ -f "go.mod" ] && echo "- Go"
[ -f "pyproject.toml" ] || [ -f "setup.py" ] && echo "- Python"
echo ""

# Key files recently modified (last hour)
echo "## Recently Modified (last hour)"
find . -type f -mmin -60 \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/__pycache__/*" \
  -not -name "*.log" \
  2>/dev/null | head -20

echo ""
echo "=== END CHECKPOINT ==="
