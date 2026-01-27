#!/bin/bash
# Z.AI Usage Tracker
# Tracks API calls within 5-hour rolling window for Pro plan quota management

set -euo pipefail

USAGE_FILE="$HOME/.claude/usage.json"
PLAN_TIER="pro"
PROMPTS_PER_WINDOW=600
WINDOW_HOURS=5
WINDOW_SECONDS=$((WINDOW_HOURS * 3600))

# Initialize usage file if it doesn't exist
init_usage() {
    if [[ ! -f "$USAGE_FILE" ]]; then
        cat > "$USAGE_FILE" << EOF
{
  "plan_tier": "$PLAN_TIER",
  "prompts_per_window": $PROMPTS_PER_WINDOW,
  "window_hours": $WINDOW_HOURS,
  "calls": []
}
EOF
        echo "USAGE: Initialized tracking file at $USAGE_FILE"
    fi
}

# Get current timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Convert ISO timestamp to Unix seconds
timestamp_to_seconds() {
    local ts="$1"
    if command -v gdate &> /dev/null; then
        gdate -d "$ts" +%s
    else
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null || \
        date -d "$ts" +%s 2>/dev/null
    fi
}

# Remove calls older than the rolling window
reset_old_calls() {
    local current_seconds
    current_seconds=$(date +%s)
    local cutoff_seconds=$((current_seconds - WINDOW_SECONDS))

    local temp_file
    temp_file=$(mktemp)

    jq --arg cutoff "$cutoff_seconds" \
       '.calls |= map(select((.timestamp_seconds // 0) >= ($cutoff | tonumber)))' \
       "$USAGE_FILE" > "$temp_file" && mv "$temp_file" "$USAGE_FILE"
}

# Record an API call
record_call() {
    local model="$1"
    init_usage

    local timestamp
    timestamp=$(get_timestamp)
    local timestamp_seconds
    timestamp_seconds=$(date +%s)

    local temp_file
    temp_file=$(mktemp)

    jq --arg ts "$timestamp" \
       --arg ts_sec "$timestamp_seconds" \
       --arg model "$model" \
       '.calls += [{"timestamp": $ts, "timestamp_seconds": ($ts_sec | tonumber), "model": $model}]' \
       "$USAGE_FILE" > "$temp_file" && mv "$temp_file" "$USAGE_FILE"

    reset_old_calls
}

# Get current usage statistics
get_usage() {
    init_usage
    reset_old_calls

    local usage_json
    usage_json=$(jq -r '
        .plan_tier as $tier |
        .prompts_per_window as $total |
        (.calls | length) as $used |
        ($total - $used) as $remaining |
        ($remaining / $total * 100) as $pct |
        {
            tier: $tier,
            total: $total,
            used: $used,
            remaining: $remaining,
            percentage: ($pct | floor)
        }
    ' "$USAGE_FILE")

    echo "$usage_json"
}

# Check quota and return delegation model
check_quota() {
    local usage
    usage=$(get_usage)

    local remaining
    remaining=$(echo "$usage" | jq -r '.remaining')
    local percentage
    percentage=$(echo "$usage" | jq -r '.percentage')

    local delegate_model="sonnet"
    if [[ $percentage -lt 50 ]]; then
        delegate_model="haiku"
    fi
    if [[ $percentage -lt 20 ]]; then
        delegate_model="haiku-only"
    fi

    echo "USAGE: ${percentage}%|${delegate_model}|remaining:${remaining}"
}

# Display formatted usage status
show_status() {
    local usage
    usage=$(get_usage)

    local tier
    tier=$(echo "$usage" | jq -r '.tier')
    local total
    total=$(echo "$usage" | jq -r '.total')
    local used
    used=$(echo "$usage" | jq -r '.used')
    local remaining
    remaining=$(echo "$usage" | jq -r '.remaining')
    local percentage
    percentage=$(echo "$usage" | jq -r '.percentage')

    local delegate_model="sonnet"
    local status="OK"
    if [[ $percentage -lt 50 ]]; then
        delegate_model="haiku"
        status="CONSERVATIVE"
    fi
    if [[ $percentage -lt 20 ]]; then
        delegate_model="haiku-only"
        status="LOW QUOTA"
    fi

    cat << EOF

╔════════════════════════════════════════╗
║     Z.AI Usage Tracker ($tier)         ║
╠════════════════════════════════════════╣
║ Window: ${WINDOW_HOURS}h rolling | Limit: ${total} prompts ║
╠════════════════════════════════════════╣
║ Used:      ${used} prompts                  ║
║ Remaining: ${remaining} prompts (${percentage}%)          ║
║ Status:    ${status}                    ║
║ Delegate:  ${delegate_model}                    ║
╚════════════════════════════════════════╝
EOF
}

# Main command dispatcher
case "${1:-}" in
    --init|-i)
        init_usage
        ;;
    --record|-r)
        record_call "${2:-unknown}"
        ;;
    --check|-c)
        check_quota
        ;;
    --status|-s)
        show_status
        ;;
    --json|-j)
        get_usage
        ;;
    *)
        echo "Usage: $0 [--init|--record MODEL|--check|--status|--json]"
        echo ""
        echo "Commands:"
        echo "  --init, -i     Initialize usage tracking file"
        echo "  --record, -r   Record an API call with model name"
        echo "  --check, -c    Check quota and get delegation model"
        echo "  --status, -s   Display formatted usage status"
        echo "  --json, -j     Output usage as JSON"
        exit 1
        ;;
esac
