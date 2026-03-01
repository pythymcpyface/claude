#!/bin/bash
# Local LLM Token Usage Tracker
# Tracks token usage for llama.cpp server via /metrics endpoint
# Requires llama.cpp server started with --metrics flag

set -euo pipefail

USAGE_FILE="$HOME/.claude/local-usage.json"
SESSION_FILE="$HOME/.claude/session-tokens.json"
LAST_METRICS_FILE="$HOME/.claude/.last-metrics"
METRICS_URL="${LLAMA_METRICS_URL:-http://localhost:8080/metrics}"
BASE_URL="${ANTHROPIC_BASE_URL:-http://localhost:8080}"

# Derive metrics URL from base URL if not explicitly set
if [[ -z "${LLAMA_METRICS_URL:-}" ]]; then
    # Strip trailing /v1 or /api/anthropic if present
    METRICS_URL="${BASE_URL%/v1}"
    METRICS_URL="${METRICS_URL%/api/anthropic}"
    METRICS_URL="${METRICS_URL}/metrics"
fi

# Initialize session file
init_session() {
    cat > "$SESSION_FILE" << EOF
{
  "session_id": "$(date +%s)",
  "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "messages": 0,
  "prompt_tokens": 0,
  "completion_tokens": 0,
  "total_tokens": 0,
  "last_prompt_tokens": 0,
  "last_completion_tokens": 0
}
EOF
    echo "0 0" > "$LAST_METRICS_FILE"
}

# Initialize usage file
init_usage() {
    if [[ ! -f "$USAGE_FILE" ]]; then
        cat > "$USAGE_FILE" << EOF
{
  "sessions": [],
  "total_prompt_tokens": 0,
  "total_completion_tokens": 0,
  "total_tokens": 0,
  "total_messages": 0
}
EOF
    fi
}

# Query llama.cpp metrics endpoint
query_metrics() {
    local response
    response=$(curl -s --connect-timeout 1 --max-time 2 "$METRICS_URL" 2>/dev/null) || echo ""

    # Validate this looks like Prometheus metrics (not a JSON error response)
    if [[ -n "$response" ]] && echo "$response" | grep -qE "^llamacpp:"; then
        echo "$response"
    else
        echo ""
    fi
}

# Extract token counts from llama.cpp Prometheus metrics
# llama.cpp uses these metric names (with colon):
#   llamacpp:n_prompt_tokens_processed_total
#   llamacpp:n_tokens_predicted_total
parse_metrics() {
    local metrics="$1"

    # Try colon format first (llama.cpp default)
    local prompt=$(echo "$metrics" | grep -E "^llamacpp:n_prompt_tokens_processed_total" | awk '{print $2}' | tr -d '\r' | head -1)
    local completion=$(echo "$metrics" | grep -E "^llamacpp:n_tokens_predicted_total" | awk '{print $2}' | tr -d '\r' | head -1)

    # Handle empty values
    prompt=${prompt:-0}
    completion=${completion:-0}

    # Convert to integers (handle floats)
    prompt=$(echo "$prompt" | awk '{printf "%.0f", $1}')
    completion=$(echo "$completion" | awk '{printf "%.0f", $1}')

    echo "$prompt $completion"
}

# Get last recorded metrics
get_last_metrics() {
    if [[ -f "$LAST_METRICS_FILE" ]]; then
        cat "$LAST_METRICS_FILE"
    else
        echo "0 0"
    fi
}

# Save current metrics for delta calculation
save_metrics() {
    echo "$1 $2" > "$LAST_METRICS_FILE"
}

# Calculate delta from last measurement
calculate_delta() {
    local current_prompt="$1"
    local current_completion="$2"
    local last_prompt="$3"
    local last_completion="$4"

    local delta_prompt=$((current_prompt - last_prompt))
    local delta_completion=$((current_completion - last_completion))

    # Clamp to non-negative (handles server restart)
    [[ $delta_prompt -lt 0 ]] && delta_prompt=$current_prompt
    [[ $delta_completion -lt 0 ]] && delta_completion=$current_completion

    echo "$delta_prompt $delta_completion"
}

# Record a message exchange using metrics
record_from_metrics() {
    init_usage
    [[ ! -f "$SESSION_FILE" ]] && init_session

    local metrics=$(query_metrics)

    if [[ -z "$metrics" ]]; then
        # Metrics not available - use estimation mode
        return 1
    fi

    read -r current_prompt current_completion <<< "$(parse_metrics "$metrics")"
    read -r last_prompt last_completion <<< "$(get_last_metrics)"

    # Calculate delta (tokens used since last check)
    read -r delta_prompt delta_completion <<< "$(calculate_delta $current_prompt $current_completion $last_prompt $last_completion)"

    # Save current for next time
    save_metrics "$current_prompt" "$current_completion"

    # Update session with delta
    local temp_file=$(mktemp)
    jq --arg dp "$delta_prompt" \
       --arg dc "$delta_completion" \
       --arg cp "$current_prompt" \
       --arg cc "$current_completion" \
       '.messages += 1 |
        .prompt_tokens += ($dp | tonumber) |
        .completion_tokens += ($dc | tonumber) |
        .total_tokens = (.prompt_tokens + .completion_tokens) |
        .last_prompt_tokens = ($cp | tonumber) |
        .last_completion_tokens = ($cc | tonumber)' \
       "$SESSION_FILE" > "$temp_file" && mv "$temp_file" "$SESSION_FILE"

    # Update all-time stats with delta
    local temp_file2=$(mktemp)
    jq --arg dp "$delta_prompt" \
       --arg dc "$delta_completion" \
       '.total_prompt_tokens += ($dp | tonumber) |
        .total_completion_tokens += ($dc | tonumber) |
        .total_tokens = (.total_prompt_tokens + .total_completion_tokens) |
        .total_messages += 1' \
       "$USAGE_FILE" > "$temp_file2" && mv "$temp_file2" "$USAGE_FILE"

    return 0
}

# Estimate tokens from text (fallback: ~4 chars per token)
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $(( (char_count + 3) / 4 ))
}

# Get session stats
get_session_stats() {
    [[ ! -f "$SESSION_FILE" ]] && init_session
    cat "$SESSION_FILE"
}

# Get all-time stats
get_all_time_stats() {
    init_usage
    cat "$USAGE_FILE"
}

# Format number with K/M suffix
format_number() {
    local n=$1
    if (( n >= 1000000 )); then
        printf "%.1fM" $(echo "scale=1; $n / 1000000" | bc 2>/dev/null || echo "$n")
    elif (( n >= 1000 )); then
        printf "%.1fK" $(echo "scale=1; $n / 1000" | bc 2>/dev/null || echo "$n")
    else
        echo "$n"
    fi
}

# Display compact status (for hooks) - ONE LINE ONLY
show_compact() {
    [[ ! -f "$SESSION_FILE" ]] && init_session

    local stats=$(cat "$SESSION_FILE")
    local prompt=$(echo "$stats" | jq -r '.prompt_tokens // 0')
    local completion=$(echo "$stats" | jq -r '.completion_tokens // 0')
    local total=$((prompt + completion))
    local messages=$(echo "$stats" | jq -r '.messages // 0')

    local prompt_f=$(format_number $prompt)
    local completion_f=$(format_number $completion)
    local total_f=$(format_number $total)

    # Single compact line - no emoji for cleaner output
    echo "Tokens: ${total_f} (in:${prompt_f} out:${completion_f}) | ${messages} msgs"
}

# Display detailed status
show_status() {
    [[ ! -f "$SESSION_FILE" ]] && init_session
    init_usage

    local session=$(cat "$SESSION_FILE")
    local all_time=$(cat "$USAGE_FILE")

    local s_prompt=$(echo "$session" | jq -r '.prompt_tokens // 0')
    local s_completion=$(echo "$session" | jq -r '.completion_tokens // 0')
    local s_total=$((s_prompt + s_completion))
    local s_messages=$(echo "$session" | jq -r '.messages // 0')

    local a_prompt=$(echo "$all_time" | jq -r '.total_prompt_tokens // 0')
    local a_completion=$(echo "$all_time" | jq -r '.total_completion_tokens // 0')
    local a_total=$((a_prompt + a_completion))
    local a_messages=$(echo "$all_time" | jq -r '.total_messages // 0')

    cat << EOF

┌─────────────────────────────────────────────────┐
│           Local LLM Token Usage                 │
├─────────────────────────────────────────────────┤
│  SESSION                                        │
│    Messages:       ${s_messages}
│    Prompt:         $(format_number $s_prompt) tokens
│    Completion:     $(format_number $s_completion) tokens
│    Total:          $(format_number $s_total) tokens
├─────────────────────────────────────────────────┤
│  ALL TIME                                       │
│    Total Messages: ${a_messages}
│    Total Tokens:   $(format_number $a_total)
│    Prompt:         $(format_number $a_prompt)
│    Completion:     $(format_number $a_completion)
└─────────────────────────────────────────────────┘
EOF
}

# End session (merge into all-time)
end_session() {
    [[ ! -f "$SESSION_FILE" ]] && return 0

    local session=$(cat "$SESSION_FILE")
    local s_prompt=$(echo "$session" | jq -r '.prompt_tokens // 0')
    local s_completion=$(echo "$session" | jq -r '.completion_tokens // 0')
    local s_total=$((s_prompt + s_completion))
    local s_messages=$(echo "$session" | jq -r '.messages // 0')
    local session_id=$(echo "$session" | jq -r '.session_id')
    local start_time=$(echo "$session" | jq -r '.start_time')

    init_usage

    # Add session to history (only if there was activity)
    if [[ $s_messages -gt 0 ]]; then
        local temp_file=$(mktemp)
        jq --arg id "$session_id" \
           --arg start "$start_time" \
           --arg end "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           --arg pt "$s_prompt" \
           --arg ct "$s_completion" \
           --arg total "$s_total" \
           --arg msgs "$s_messages" \
           '.sessions += [{
               session_id: $id,
               start_time: $start,
               end_time: $end,
               prompt_tokens: ($pt | tonumber),
               completion_tokens: ($ct | tonumber),
               total_tokens: ($total | tonumber),
               messages: ($msgs | tonumber)
           }]' \
           "$USAGE_FILE" > "$temp_file" && mv "$temp_file" "$USAGE_FILE"
    fi

    # Clear session file
    rm -f "$SESSION_FILE" "$LAST_METRICS_FILE"
}

# Show metrics URL being used
show_config() {
    echo "Metrics URL: $METRICS_URL"
    echo "Testing connection..."
    local metrics=$(query_metrics)
    if [[ -n "$metrics" ]]; then
        echo "Connection: OK"
        read -r prompt completion <<< "$(parse_metrics "$metrics")"
        echo "Current prompt tokens: $prompt"
        echo "Current completion tokens: $completion"
    else
        echo "Connection: FAILED"
        echo "Make sure llama.cpp server is running with --metrics flag"
    fi
}

# Main command dispatcher
case "${1:-}" in
    --init|-i)
        init_usage
        init_session
        echo "Initialized token tracking"
        ;;
    --update|-u)
        if record_from_metrics; then
            show_compact
        else
            echo "Metrics unavailable - is llama.cpp running with --metrics?"
        fi
        ;;
    --record|-r)
        # Manual record: prompt_tokens completion_tokens
        init_usage
        [[ ! -f "$SESSION_FILE" ]] && init_session
        local pt="${2:-0}"
        local ct="${3:-0}"
        local total=$((pt + ct))

        local temp_file=$(mktemp)
        jq --arg pt "$pt" \
           --arg ct "$ct" \
           --arg total "$total" \
           '.messages += 1 |
            .prompt_tokens += ($pt | tonumber) |
            .completion_tokens += ($ct | tonumber) |
            .total_tokens += ($total | tonumber)' \
           "$SESSION_FILE" > "$temp_file" && mv "$temp_file" "$SESSION_FILE"
        show_compact
        ;;
    --compact|-c)
        show_compact
        ;;
    --status|-s)
        show_status
        ;;
    --end|-e)
        end_session
        ;;
    --config)
        show_config
        ;;
    --session)
        get_session_stats
        ;;
    --all-time)
        get_all_time_stats
        ;;
    --estimate)
        estimate_tokens "$2"
        ;;
    *)
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  --init           Initialize tracking files"
        echo "  --update         Query metrics and update (use in hooks)"
        echo "  --record PT CT   Manually record exchange"
        echo "  --compact        Show compact one-line status"
        echo "  --status         Show detailed status"
        echo "  --config         Show metrics URL and test connection"
        echo "  --end            End session and save to history"
        echo "  --session        Output session stats as JSON"
        echo "  --all-time       Output all-time stats as JSON"
        echo "  --estimate TEXT  Estimate tokens in text"
        ;;
esac
