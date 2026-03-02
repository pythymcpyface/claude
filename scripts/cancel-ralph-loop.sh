#!/bin/bash

# Cancel Ralph Loop Script
# Removes the project-specific ralph-loop state file

set -euo pipefail

# Base directory for Claude config
BASE_DIR="${CLAUDE_BASE_DIR:-${HOME}/.claude}"

# Project-specific state file (must match setup-ralph-loop.sh)
PROJECT_DIR="${PWD:-$(pwd)}"
PROJECT_HASH=$(echo "$PROJECT_DIR" | shasum | cut -d' ' -f1)
RALPH_STATE_FILE="${BASE_DIR}/.claude/ralph-loop.${PROJECT_HASH}.md"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  echo "No active Ralph loop found for this project."
  echo ""
  echo "   Project: $PROJECT_DIR"
  echo "   State file: $RALPH_STATE_FILE"
  exit 0
fi

# Extract current iteration for reporting
ITERATION=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE" | grep '^iteration:' | sed 's/iteration: *//')

# Remove the state file
rm "$RALPH_STATE_FILE"

echo "Cancelled Ralph loop (was at iteration ${ITERATION:-unknown})"
echo ""
echo "   Project: $PROJECT_DIR"
