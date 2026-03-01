#!/bin/bash
# Post-response token usage display
# Called after each assistant response via Stop hook
#
# Reads stdin for hook data including last_assistant_message
# Estimates tokens from message content since API doesn't expose usage

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKER="$SCRIPT_DIR/../scripts/local-llm-usage.sh"
SESSION_TOKENS="$HOME/.claude/session-tokens.json"

# Read hook input from stdin (JSON)
HOOK_INPUT=$(cat)
LAST_MESSAGE=$(echo "$HOOK_INPUT" | jq -r '.last_assistant_message // ""')

# Estimate tokens: ~4 chars per token for English
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $(( (char_count + 3) / 4 ))
}

# Initialize session if needed
if [[ ! -f "$SESSION_TOKENS" ]]; then
    bash "$TRACKER" --init 2>/dev/null || true
fi

# Try metrics endpoint first (for local llama.cpp)
METRICS_RESULT=""
if [[ -x "$TRACKER" ]]; then
    METRICS_RESULT=$("$TRACKER" --update 2>&1) || METRICS_RESULT=""
fi

# If metrics worked, use that output
if [[ -n "$METRICS_RESULT" ]] && [[ "$METRICS_RESULT" == *"Tokens:"* ]]; then
    echo "$METRICS_RESULT"
else
    # Fallback: estimate from last message content
    if [[ -n "$LAST_MESSAGE" ]]; then
        COMPLETION_TOKENS=$(estimate_tokens "$LAST_MESSAGE")

        # Update session file with estimated completion tokens
        if [[ -f "$SESSION_TOKENS" ]]; then
            TEMP_FILE=$(mktemp)
            jq --arg ct "$COMPLETION_TOKENS" \
               '.completion_tokens += ($ct | tonumber) |
                .total_tokens = (.prompt_tokens + .completion_tokens) |
                .messages += 1' \
               "$SESSION_TOKENS" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SESSION_TOKENS"
        fi

        # Display compact status
        bash "$TRACKER" --compact 2>/dev/null || echo "Tokens: ~${COMPLETION_TOKENS} (estimated)"
    fi
fi
