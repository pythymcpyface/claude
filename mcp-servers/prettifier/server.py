#!/usr/bin/env python3
"""
MCP Prettifier Server - Automatically format rich text output
Provides tools for Claude to format markdown, JSON, YAML, and code.
"""

import json
import subprocess
import shutil
from typing import Optional
from mcp.server import Server
from mcp.types import Tool, TextContent
import mcp.server.stdio

server = Server("prettifier")

# Check available formatters
FORMATTERS = {
    "glow": shutil.which("glow") is not None,
    "rich": shutil.which("rich") is not None,
    "jq": shutil.which("jq") is not None,
    "yq": shutil.which("yq") is not None,
    "bat": shutil.which("bat") is not None,
    "python": shutil.which("python3") is not None,
}


def run_command(cmd: list[str], input_text: str, timeout: int = 10) -> tuple[bool, str]:
    """Run a command with input and return success status and output."""
    try:
        result = subprocess.run(
            cmd,
            input=input_text,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        if result.returncode == 0 and result.stdout.strip():
            return True, result.stdout
        return False, result.stderr or "Command failed"
    except subprocess.TimeoutExpired:
        return False, "Command timed out"
    except Exception as e:
        return False, str(e)


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="format_markdown",
            description="Format markdown text for beautiful terminal output. Use this when outputting any markdown content to the user.",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The markdown text to format"
                    },
                    "theme": {
                        "type": "string",
                        "description": "Theme: 'dark', 'light', 'notty', 'dracula', 'pink', 'ascii' (default: auto-detect)",
                        "default": "auto"
                    },
                    "width": {
                        "type": "integer",
                        "description": "Maximum width for wrapping (default: terminal width)",
                        "default": 0
                    }
                },
                "required": ["text"]
            }
        ),
        Tool(
            name="format_json",
            description="Format and syntax-highlight JSON data. Use this when outputting any JSON to the user.",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The JSON text to format"
                    },
                    "indent": {
                        "type": "integer",
                        "description": "Indentation spaces (default: 2)",
                        "default": 2
                    },
                    "color": {
                        "type": "boolean",
                        "description": "Enable syntax highlighting (default: true)",
                        "default": True
                    }
                },
                "required": ["text"]
            }
        ),
        Tool(
            name="format_code",
            description="Format and syntax-highlight source code. Use this when outputting code snippets to the user.",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The code to format"
                    },
                    "language": {
                        "type": "string",
                        "description": "Programming language (e.g., 'python', 'javascript', 'typescript', 'go', 'rust')",
                        "default": "auto"
                    },
                    "line_numbers": {
                        "type": "boolean",
                        "description": "Show line numbers (default: false)",
                        "default": False
                    },
                    "theme": {
                        "type": "string",
                        "description": "Color theme (e.g., 'monokai', 'dracula', 'github-dark')",
                        "default": "monokai"
                    }
                },
                "required": ["text"]
            }
        ),
        Tool(
            name="format_yaml",
            description="Format and syntax-highlight YAML data. Use this when outputting any YAML to the user.",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The YAML text to format"
                    }
                },
                "required": ["text"]
            }
        ),
        Tool(
            name="format_table",
            description="Format data as a beautiful terminal table. Use this for structured data display.",
            inputSchema={
                "type": "object",
                "properties": {
                    "data": {
                        "type": "string",
                        "description": "JSON array of objects or array of arrays to format as table"
                    },
                    "title": {
                        "type": "string",
                        "description": "Optional table title"
                    }
                },
                "required": ["data"]
            }
        ),
        Tool(
            name="format_raw",
            description="Auto-detect content type and format appropriately. Use this when content type is unknown.",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The text to auto-format"
                    }
                },
                "required": ["text"]
            }
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    text = arguments.get("text", "")

    if name == "format_markdown":
        theme = arguments.get("theme", "auto")
        width = arguments.get("width", 0)

        # Try glow first (best markdown renderer)
        if FORMATTERS["glow"]:
            cmd = ["glow", "-"]
            if theme != "auto":
                cmd.extend(["-s", theme])
            if width > 0:
                cmd.extend(["-w", str(width)])

            success, output = run_command(cmd, text)
            if success:
                return [TextContent(type="text", text=output)]

        # Fallback to rich-cli
        if FORMATTERS["rich"]:
            cmd = ["rich", "-", "--markdown"]
            if width > 0:
                cmd.extend(["-w", str(width)])

            success, output = run_command(cmd, text)
            if success:
                return [TextContent(type="text", text=output)]

        # Fallback to python built-in
        return [TextContent(type="text", text=text)]

    elif name == "format_json":
        indent = arguments.get("indent", 2)

        # Try jq first
        if FORMATTERS["jq"]:
            success, output = run_command(["jq", "."], text)
            if success:
                return [TextContent(type="text", text=output)]

        # Fallback to python json.tool
        try:
            data = json.loads(text)
            formatted = json.dumps(data, indent=indent, ensure_ascii=False)
            return [TextContent(type="text", text=formatted)]
        except json.JSONDecodeError as e:
            return [TextContent(type="text", text=f"Invalid JSON: {e}")]

    elif name == "format_code":
        language = arguments.get("language", "auto")
        line_numbers = arguments.get("line_numbers", False)
        theme = arguments.get("theme", "monokai")

        # Try rich-cli
        if FORMATTERS["rich"]:
            cmd = ["rich", "-"]
            if language != "auto":
                cmd.extend(["--lexer", language])
            if line_numbers:
                cmd.append("--line-numbers")
            cmd.extend(["--theme", theme])

            success, output = run_command(cmd, text)
            if success:
                return [TextContent(type="text", text=output)]

        # Try bat
        if FORMATTERS["bat"]:
            cmd = ["bat", "-p", "--theme", theme]
            if language != "auto":
                cmd.extend(["-l", language])
            if line_numbers:
                cmd.append("--number")

            success, output = run_command(cmd, text)
            if success:
                return [TextContent(type="text", text=output)]

        # Fallback to plain text
        return [TextContent(type="text", text=text)]

    elif name == "format_yaml":
        # Try yq
        if FORMATTERS["yq"]:
            success, output = run_command(["yq", "."], text)
            if success:
                return [TextContent(type="text", text=output)]

        # Fallback to python
        try:
            import yaml
            data = yaml.safe_load(text)
            formatted = yaml.dump(data, default_flow_style=False, sort_keys=False)
            return [TextContent(type="text", text=formatted)]
        except ImportError:
            return [TextContent(type="text", text=text)]

    elif name == "format_table":
        data_str = arguments.get("data", "[]")
        title = arguments.get("title")

        try:
            data = json.loads(data_str)
        except json.JSONDecodeError:
            return [TextContent(type="text", text="Invalid JSON data for table")]

        # Use rich for table formatting via python
        try:
            from rich.console import Console
            from rich.table import Table
            from io import StringIO

            console = Console(file=StringIO(), force_terminal=True)

            if isinstance(data, list) and len(data) > 0:
                if isinstance(data[0], dict):
                    headers = list(data[0].keys())
                    table = Table(title=title, show_header=True, header_style="bold magenta")
                    for header in headers:
                        table.add_column(header)
                    for row in data:
                        table.add_row(*[str(v) for v in row.values()])
                else:
                    table = Table(title=title, show_header=False)
                    for row in data:
                        table.add_row(*[str(v) for v in row])

                console.print(table)
                return [TextContent(type="text", text=console.file.getvalue())]
        except ImportError:
            pass

        # Fallback: simple ASCII table
        lines = []
        if title:
            lines.append(title)
            lines.append("-" * len(title))

        if isinstance(data, list) and len(data) > 0:
            if isinstance(data[0], dict):
                headers = list(data[0].keys())
                lines.append(" | ".join(headers))
                lines.append("-+-".join("-" * len(h) for h in headers))
                for row in data:
                    lines.append(" | ".join(str(row.get(h, "")) for h in headers))

        return [TextContent(type="text", text="\n".join(lines))]

    elif name == "format_raw":
        # Auto-detect content type
        stripped = text.strip()

        # Try JSON
        if stripped.startswith("{") or stripped.startswith("["):
            try:
                json.loads(stripped)
                return await call_tool("format_json", {"text": text})
            except json.JSONDecodeError:
                pass

        # Try YAML
        if stripped.startswith("---") or ":" in stripped.split("\n")[0]:
            if FORMATTERS["yq"]:
                success, _ = run_command(["yq", "."], text)
                if success:
                    return await call_tool("format_yaml", {"text": text})

        # Check for markdown indicators
        md_indicators = ["# ", "## ", "### ", "- ", "* ", "```", "[", "|"]
        if any(ind in stripped[:500] for ind in md_indicators):
            return await call_tool("format_markdown", {"text": text})

        # Return as-is
        return [TextContent(type="text", text=text)]

    return [TextContent(type="text", text=f"Unknown tool: {name}")]


async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
