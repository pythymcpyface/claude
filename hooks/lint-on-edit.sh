#!/bin/bash
# PostToolUse Write|Edit hook: lint the touched file (single-file scope).
# Surfaces warnings/errors to stderr so Claude sees them and can fix immediately.
# Fail-soft: never blocks the tool call. Designed to be FAST (<1s) — single file only.
# Reads tool input from stdin (JSON) and extracts file_path.

INPUT=$(cat)

FILE=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path") or d.get("file_path","") )' 2>/dev/null)
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Skip config/dotfiles outside the project tree (same scope as auto-format).
case "$FILE" in
  "$HOME"/.claude/*) exit 0 ;;
  "$HOME"/.config/*) exit 0 ;;
esac

# Skip generated/vendored files where lint noise isn't actionable.
case "$FILE" in
  */node_modules/*|*/dist/*|*/build/*|*/.next/*|*/target/*|*/__pycache__/*|*/.venv/*|*/venv/*) exit 0 ;;
  *.min.js|*.min.css|*-lock.json|*.lock) exit 0 ;;
esac

# Run linter, capture output. Each branch is wrapped in `|| true` so a
# non-zero exit from the linter never bubbles up.
OUTPUT=""
LINTER=""

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if command -v biome >/dev/null 2>&1; then
      LINTER="biome"
      OUTPUT=$(biome lint "$FILE" 2>&1 || true)
    elif command -v eslint >/dev/null 2>&1; then
      LINTER="eslint"
      OUTPUT=$(eslint --no-error-on-unmatched-pattern "$FILE" 2>&1 || true)
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      LINTER="ruff"
      OUTPUT=$(ruff check "$FILE" 2>&1 || true)
    fi
    ;;
  *.go)
    # gofmt -l prints filenames that need formatting (auto-format handles the fix);
    # for actual lint use go vet on the file's package — but that's package-scope
    # and slower. Skip vet here; users invoke `golangci-lint` via /quality-check.
    ;;
  *.rs)
    # rustc/clippy is crate-scope; per-file isn't meaningful. Skip.
    ;;
  *.sh)
    if command -v shellcheck >/dev/null 2>&1; then
      LINTER="shellcheck"
      OUTPUT=$(shellcheck "$FILE" 2>&1 || true)
    fi
    ;;
esac

# If linter ran and produced output, surface it to stderr.
# Stderr is shown to Claude so it can react in the same turn.
if [ -n "$OUTPUT" ]; then
  printf '\n[lint-on-edit:%s] %s\n%s\n' "$LINTER" "$FILE" "$OUTPUT" >&2
fi

exit 0
