#!/bin/bash
# Setup Claude Code authentication
# Usage: source ~/.claude/scripts/setup-auth.sh "your-token-here"

TOKEN="${1:-}"

if [ -z "$TOKEN" ]; then
    echo "Usage: source ~/.claude/scripts/setup-auth.sh \"your-token-here\""
    echo ""
    echo "Or set manually:"
    echo "  export ANTHROPIC_AUTH_TOKEN=\"your-token\""
    return 1
fi

# Export for current session
export ANTHROPIC_AUTH_TOKEN="$TOKEN"

# Add to shell profile for persistence
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

# Check if already exists
if grep -q "ANTHROPIC_AUTH_TOKEN" "$SHELL_RC" 2>/dev/null; then
    # Update existing
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|export ANTHROPIC_AUTH_TOKEN=.*|export ANTHROPIC_AUTH_TOKEN=\"$TOKEN\"|" "$SHELL_RC"
    else
        sed -i "s|export ANTHROPIC_AUTH_TOKEN=.*|export ANTHROPIC_AUTH_TOKEN=\"$TOKEN\"|" "$SHELL_RC"
    fi
    echo "Updated ANTHROPIC_AUTH_TOKEN in $SHELL_RC"
else
    # Add new
    echo "" >> "$SHELL_RC"
    echo "# Claude Code / Z.AI authentication" >> "$SHELL_RC"
    echo "export ANTHROPIC_AUTH_TOKEN=\"$TOKEN\"" >> "$SHELL_RC"
    echo "Added ANTHROPIC_AUTH_TOKEN to $SHELL_RC"
fi

echo ""
echo "Token set for current session and saved to $SHELL_RC"
echo "Run 'source $SHELL_RC' or open a new terminal to apply"
