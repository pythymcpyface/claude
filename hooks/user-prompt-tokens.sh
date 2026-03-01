#!/bin/bash
# User Prompt Token Estimator
# Called via UserPromptSubmit hook to track input tokens
# Reads the user's prompt from stdin and estimates token count

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_TOKENS="$HOME/.claude/session-tokens.json"

# Read hook input from stdin (JSON)
HOOK_INPUT=$(cat)
USER_PROMPT=$(echo "$HOOK_INPUT" | jq -r '.prompt // ""')

# Estimate tokens: ~4 chars per token for English
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $(( (char_count + 3) / 4 ))
}

# Initialize session if needed
if [[ ! -f "$SESSION_TOKENS" ]]; then
    mkdir -p "$(dirname "$SESSION_TOKENS")"
    cat > "$SESSION_TOKENS" << EOF
{
  "session_id": "$(date +%s)",
  "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "messages": 0,
  "prompt_tokens": 0,
  "completion_tokens": 0,
  "total_tokens": 0
}
EOF
fi

# Estimate and store prompt tokens
if [[ -n "$USER_PROMPT" ]]; then
    PROMPT_TOKENS=$(estimate_tokens "$USER_PROMPT")

    TEMP_FILE=$(mktemp)
    jq --arg pt "$PROMPT_TOKENS" \
       '.prompt_tokens += ($pt | tonumber) |
        .total_tokens = (.prompt_tokens + .completion_tokens)' \
       "$SESSION_TOKENS" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SESSION_TOKENS"
fi
