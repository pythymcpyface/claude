# Auto-Prettify Output

Automatically format rich text output using the prettifier MCP tools.

## Activation

This skill activates when Claude outputs formatted content (markdown, JSON, code, tables).

## Instructions

When outputting formatted content to the user, ALWAYS use the appropriate prettifier tool:

### Markdown Content
When your response contains markdown formatting (headers, lists, bold, code blocks, links, tables), use:
```
mcp__prettifier__format_markdown
```

### JSON Data
When outputting JSON objects or arrays, use:
```
mcp__prettifier__format_json
```

### Code Snippets
When displaying code with syntax highlighting, use:
```
mcp__prettifier__format_code
```
Include the `language` parameter for best results.

### YAML Configuration
When outputting YAML files or configuration, use:
```
mcp__prettifier__format_yaml
```

### Tables
When displaying tabular data, use:
```
mcp__prettifier__format_table
```
Pass data as a JSON array of objects.

### Unknown Content Type
When unsure of content type, use:
```
mcp__prettifier__format_raw
```
This will auto-detect and format appropriately.

## Examples

### Example 1: Markdown Documentation
Instead of just outputting markdown directly, wrap it:
```
format_markdown({
  "text": "# Heading\n\nThis is **bold** text.\n\n- Item 1\n- Item 2"
})
```

### Example 2: JSON API Response
```
format_json({
  "text": "{\"users\":[{\"id\":1,\"name\":\"Alice\"},{\"id\":2,\"name\":\"Bob\"}]}"
})
```

### Example 3: Code Snippet
```
format_code({
  "text": "def hello():\n    print('Hello, World!')",
  "language": "python",
  "line_numbers": true
})
```

## When NOT to Use

Do NOT use prettifier tools when:
- Outputting simple plain text without formatting
- The content is part of a code file being written
- The user explicitly asks for raw output
- Inside code blocks that are meant to be copied

## Fallback Behavior

If prettifier tools are unavailable, output content normally without formatting.
