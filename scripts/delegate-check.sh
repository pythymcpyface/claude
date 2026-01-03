#!/bin/bash
# MCP Delegation Pre-Hook
# Suggests delegation to Gemini for expensive operations
# Called by PreToolUse hook for Bash commands

COMMAND="$1"

# Patterns that should be delegated to Gemini
EXPENSIVE_PATTERNS=(
  "npm test"
  "npm run test"
  "yarn test"
  "pnpm test"
  "cargo test"
  "pytest"
  "go test"
  "jest"
  "vitest"
  "npm run build"
  "npm run lint"
  "cargo build"
  "cargo clippy"
  "go build"
  "git log"
  "git diff"
  "npm audit"
  "cargo audit"
)

# Check if command matches expensive patterns
for pattern in "${EXPENSIVE_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "DELEGATE_SUGGESTION: Consider delegating '$pattern' to Gemini via ultra-mcp"
    echo "Tool: mcp__ultra-mcp__debug-issue for tests/builds"
    echo "Tool: mcp__ultra-mcp__analyze-code for logs/diffs"
    exit 0
  fi
done

# Large file indicators
if [[ "$COMMAND" == *"cat "* ]] || [[ "$COMMAND" == *"less "* ]]; then
  echo "DELEGATE_SUGGESTION: For large files, consider mcp__ultra-mcp__analyze-code"
  exit 0
fi

exit 0
