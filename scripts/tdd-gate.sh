#!/bin/bash
# TDD Compliance Verification Script
# Ensures tests exist before implementation code is written
# Enhanced with test quality checks beyond coverage
# Usage: bash .claude/scripts/tdd-gate.sh [file_path]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FILE_PATH="${1:-}"

echo "🔍 TDD Compliance Gate"
echo ""

FAILURES=0
WARNINGS=0

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

# Function to check test quality (beyond coverage)
check_test_quality() {
  local test_file="$1"
  local quality_issues=0

  echo -e "   ${BLUE}Quality Check:${NC} $test_file"

  # Check for meaningful assertions
  echo -n "      Assertion quality... "
  if grep -q "expect\|assert\|should" "$test_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC} No assertions found"
    quality_issues=$((quality_issues + 1))
  fi

  # Check for test descriptions (avoid generic names)
  echo -n "      Test descriptions... "
  local generic_tests=$(grep -c "test()\|it('')" "$test_file" 2>/dev/null || echo 0)
  if [ "$generic_tests" -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${YELLOW}⚠${NC} $generic_tests generic test name(s)"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check for setup/teardown if needed
  echo -n "      Test isolation... "
  if grep -q "beforeEach\|before\|setup\|tearDown" "$test_file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${BLUE}○${NC} No setup/teardown (may be needed)"
  fi

  # Check for edge case tests
  echo -n "      Edge case coverage... "
  local edge_indicators=$(grep -ci "edge\|boundary\|empty\|null\|invalid" "$test_file" 2>/dev/null || echo 0)
  if [ "$edge_indicators" -ge 2 ]; then
    echo -e "${GREEN}✓${NC}"
  elif [ "$edge_indicators" -eq 1 ]; then
    echo -e "${YELLOW}⚠${NC} Limited edge case coverage"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${YELLOW}⚠${NC} No obvious edge case tests"
    WARNINGS=$((WARNINGS + 1))
  fi

  return $quality_issues
}

# Function to check if acceptance criteria have tests
check_acceptance_criteria_coverage() {
  local tdd_strategy_file=".claude/docs/*/TDD-STRATEGY.md"
  local found=0

  for file in $tdd_strategy_file; do
    if [ -f "$file" ]; then
      found=1
      echo ""
      echo -e "${BLUE}📋 Acceptance Criteria Coverage${NC}"
      echo "   Using: $file"

      # Count test cases in TDD strategy
      local total_tests=$(grep -c "^\\*\\*TEST-" "$file" 2>/dev/null || echo 0)

      if [ "$total_tests" -gt 0 ]; then
        echo -e "   ${GREEN}✓${NC} $total_tests test cases defined"
      else
        echo -e "   ${YELLOW}⚠${NC} No test cases found in TDD strategy"
      fi
      break
    fi
  done

  if [ $found -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠ No TDD-STRATEGY.md found - skip acceptance criteria check${NC}"
  fi
}

# Function to provide mutation testing guidance
check_mutation_testing_ready() {
  echo ""
  echo -e "${BLUE}🧬 Mutation Testing Readiness${NC}"

  # Check if tests are deterministic (no random data without seeding)
  local has_random=0
  if [ -d "tests" ] || [ -d "test" ] || [ -d "spec" ]; then
    if grep -r "Math\.random\|random\|faker" --include="*.test.*" --include="*_spec.*" tests/ test/ spec/ 2>/dev/null | grep -v "seed" | grep -q .; then
      has_random=1
      echo -e "   ${YELLOW}⚠${NC} Tests use random data - consider seeding for mutation testing"
    else
      echo -e "   ${GREEN}✓${NC} Tests appear deterministic"
    fi
  fi

  # Check for test doubles/mocks usage
  echo -n "   Test doubles usage... "
  if grep -r "mock\|stub\|spy" --include="*.test.*" --include="*_spec.*" tests/ test/ spec/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC} Mocks/stubs found"
  else
    echo -e "${BLUE}○${NC} No mocks detected (may need for mutation testing)"
  fi

  echo ""
  echo -e "   ${BLUE}💡 Mutation Testing Tools${NC}"
  echo "      JavaScript/TypeScript: stryker-mutator"
  echo "      Python: mutmut, pytest-mut"
  echo "      Ruby: mutant"
  echo "      Java: PITest"
}

# If specific file provided, check only that file
if [ -n "$FILE_PATH" ]; then
  echo "Checking: $FILE_PATH"
  if ! check_test_coverage "$FILE_PATH"; then
    FAILURES=$((FAILURES + 1))
  fi
  # Also run quality check on the test file if it exists
  if [[ "$FILE_PATH" =~ ^src/(.*)\.ts$ ]] && [ -f "tests/${BASH_REMATCH[1]}.test.ts" ]; then
    check_test_quality "tests/${BASH_REMATCH[1]}.test.ts" || true
  elif [[ "$FILE_PATH" =~ ^src/(.*)\.js$ ]] && [ -f "tests/${BASH_REMATCH[1]}.test.js" ]; then
    check_test_quality "tests/${BASH_REMATCH[1]}.test.js" || true
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

  # Run acceptance criteria coverage check
  check_acceptance_criteria_coverage

  # Run mutation testing readiness check
  check_mutation_testing_ready
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✅ TDD compliance verified${NC}"
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️ $WARNINGS warning(s) to review${NC}"
  fi
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
  echo ""
  echo "Test Quality Tips:"
  echo "- Write descriptive test names (what, when, then)"
  echo "- Test edge cases and boundaries"
  echo "- Use setup/teardown for shared test data"
  echo "- Consider mutation testing for critical paths"
  exit 1
fi
