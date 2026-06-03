#!/bin/bash
# PostToolUse Write|Edit hook: format the touched file in-place.
# Runs the project's preferred formatter if available. Fail-soft: never blocks.
# Reads tool input from stdin (JSON) and extracts file_path.

INPUT=$(cat)

# Extract file_path with python (already a dep in this setup); fall back to grep.
FILE=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path") or d.get("file_path","") )' 2>/dev/null)
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Skip files outside the current working tree (e.g. ~/.claude config).
case "$FILE" in
  "$HOME"/.claude/*) exit 0 ;;
  "$HOME"/.config/*) exit 0 ;;
esac

format_with() {
  command -v "$1" >/dev/null 2>&1 || return 1
  "$@" >/dev/null 2>&1 || true
  return 0
}

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.html|*.md|*.yml|*.yaml)
    if command -v biome >/dev/null 2>&1; then
      biome format --write "$FILE" >/dev/null 2>&1 || true
    elif command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE" >/dev/null 2>&1 || true
    elif command -v black >/dev/null 2>&1; then
      black --quiet "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" >/dev/null 2>&1 || true
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" >/dev/null 2>&1 || true
    ;;
  *.rb)
    command -v rubocop >/dev/null 2>&1 && rubocop -a "$FILE" >/dev/null 2>&1 || true
    ;;
  *.sh)
    command -v shfmt >/dev/null 2>&1 && shfmt -w "$FILE" >/dev/null 2>&1 || true
    ;;
esac

exit 0
