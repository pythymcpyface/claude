# Prettifier MCP Server

Automatically formats rich text output in Claude Code.

## Installation

```bash
# Install dependencies
cd ~/.claude/mcp-servers/prettifier
pip install -e .

# Install optional formatters
brew install glow        # Markdown
brew install rich-cli    # Multi-format
brew install jq          # JSON
brew install yq          # YAML
brew install bat         # Code
```

## Add to Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "prettifier": {
      "command": "python3",
      "args": ["/Users/andrewgibson/.claude/mcp-servers/prettifier/server.py"]
    }
  }
}
```

## Available Tools

| Tool | Description |
|------|-------------|
| `format_markdown` | Format markdown with glow/rich |
| `format_json` | Pretty-print and highlight JSON |
| `format_code` | Syntax-highlight code |
| `format_yaml` | Format YAML |
| `format_table` | Create beautiful tables |
| `format_raw` | Auto-detect and format |

## Usage

Claude will automatically use these tools when outputting formatted content.
