#!/bin/bash
# Bash command pre-check hook
# Surfaces delegation hints for expensive operations
# Called by PreToolUse hook for Bash commands

COMMAND="$1"

# Patterns where output volume is typically large enough to warrant
# delegation to a subagent (keeps main context lean)
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
    echo "HINT: '$pattern' often produces verbose output. Consider delegating to a subagent (Task tool with general-purpose or Explore agent) to keep main context lean."
    exit 0
  fi
done

# Large file indicators
if [[ "$COMMAND" == "cat "* ]] || [[ "$COMMAND" == "less "* ]] || [[ "$COMMAND" == "head "* ]] || [[ "$COMMAND" == "tail "* ]]; then
  echo "HINT: Use the Read tool instead of cat/less/head/tail for file inspection."
  exit 0
fi

exit 0
