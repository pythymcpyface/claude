#!/bin/bash
# TDD Compliance Verification Script
# Ensures tests exist before implementation code is written
# Usage: bash .claude/scripts/tdd-gate.sh [file_path]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FILE_PATH="${1:-}"

echo "🔍 TDD Compliance Gate"
echo ""

FAILURES=0

# Function to check if implementation has corresponding test
check_test_coverage() {
  local impl_file="$1"
  local test_file=""
  local has_test=0

  # Determine expected test file path
  if [[ "$impl_file" =~ ^src/(.*)\.ts$ ]]; then
    # TypeScript implementation
    test_file="tests/${BASH_REMATCH[1]}.test.ts"
  elif [[ "$impl_file" =~ ^src/(.*)\.js$ ]]; then
    # JavaScript implementation
    test_file="tests/${BASH_REMATCH[1]}.test.js"
  elif [[ "$impl_file" =~ ^lib/(.*)\.rb$ ]]; then
    # Ruby implementation
    test_file="spec/${BASH_REMATCH[1]}_spec.rb"
  elif [[ "$impl_file" =~ ^lib/(.*)\.py$ ]]; then
    # Python implementation
    test_file="tests/${BASH_REMATCH[1]}_test.py"
  else
    echo -e "   ${YELLOW}⚠ Unknown file type: $impl_file${NC}"
    return 0
  fi

  # Check if test file exists
  if [ -f "$test_file" ]; then
    # Check if test file has at least one test case
    local test_count=0
    if [[ "$test_file" =~ \.ts$ ]] || [[ "$test_file" =~ \.js$ ]]; then
      test_count=$(grep -c "describe\|test\|it" "$test_file" 2>/dev/null || echo 0)
    elif [[ "$test_file" =~ \.rb$ ]]; then
      test_count=$(grep -c "RSpec\|describe\|it" "$test_file" 2>/dev/null || echo 0)
    elif [[ "$test_file" =~ \.py$ ]]; then
      test_count=$(grep -c "def test_\|class Test" "$test_file" 2>/dev/null || echo 0)
    fi

    if [ "$test_count" -gt 0 ]; then
      echo -e "   ${GREEN}✓${NC} Test exists: $test_file ($test_count tests)"
      return 0
    else
      echo -e "   ${YELLOW}⚠${NC} Test file exists but empty: $test_file"
      return 1
    fi
  else
    echo -e "   ${RED}✗${NC} Missing test file: $test_file"
    echo -e "      ${RED}Expected test for: $impl_file${NC}"
    return 1
  fi
}

# If specific file provided, check only that file
if [ -n "$FILE_PATH" ]; then
  echo "Checking: $FILE_PATH"
  if ! check_test_coverage "$FILE_PATH"; then
    FAILURES=$((FAILURES + 1))
  fi
else
  # Check all implementation files against test coverage
  echo "📝 Checking test coverage..."

  # Check TypeScript/JavaScript source files
  if [ -d "src" ]; then
    echo ""
    echo "TypeScript/JavaScript files:"

    while IFS= read -r -d '' file; do
      check_test_coverage "$file" || FAILURES=$((FAILURES + 1))
    done < <(find src -name "*.ts" -o -name "*.js" | grep -v ".test." | head -20)
  fi

  # Check Ruby source files
  if [ -d "lib" ] && [ -f "Gemfile" ]; then
    echo ""
    echo "Ruby files:"

    while IFS= read -r -d '' file; do
      check_test_coverage "$file" || FAILURES=$((FAILURES + 1))
    done < <(find lib -name "*.rb" | grep -v "_spec.rb" | head -20)
  fi

  # Check Python source files
  if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo ""
    echo "Python files:"

    while IFS= read -r -d '' file; do
      check_test_coverage "$file" || FAILURES=$((FAILURES + 1))
    done < <(find . -name "*.py" -not -path "./tests/*" -not -path "./venv/*" -not -path "./.venv/*" | head -20)
  fi
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✅ TDD compliance verified${NC}"
  echo "All implementation files have corresponding tests."
  exit 0
else
  echo -e "${RED}❌ TDD compliance failed${NC}"
  echo ""
  echo "TDD Rule: Write the test FIRST, then implement."
  echo ""
  echo "Missing tests found. Please:"
  echo "1. Write failing test (RED)"
  echo "2. Run test to confirm failure"
  echo "3. Write implementation (GREEN)"
  echo "4. Run test to confirm pass"
  echo "5. Refactor (REFACTOR)"
  exit 1
fi
