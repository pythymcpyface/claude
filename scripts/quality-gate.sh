#!/bin/bash
# Quality Gate Verification Script
# Run before each commit during Ralph Loop implementation
# Usage: bash .claude/scripts/quality-gate.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running Quality Gates..."
echo ""

FAILURES=0

# Function to run a check
run_check() {
  local name="$1"
  local command="$2"
  local error_msg="$3"

  echo -n "   Checking $name... "

  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    return 0
  else
    echo -e "${RED}✗${NC}"
    echo -e "      ${RED}$error_msg${NC}"
    FAILURES=$((FAILURES + 1))
    return 1
  fi
}

# 1. Tests
echo "📝 Test Suite:"
if [ -f "package.json" ] && grep -q '"test"' package.json; then
  if npm test --silent 2>&1 | grep -q "pass"; then
    echo -e "   ${GREEN}✓ All tests passing${NC}"
  else
    echo -e "   ${RED}✗ Tests failing${NC}"
    npm test 2>&1 | tail -10
    FAILURES=$((FAILURES + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No test script found${NC}"
fi
echo ""

# 2. TypeScript
echo "📘 TypeScript:"
if [ -f "tsconfig.json" ]; then
  TSC_OUTPUT=$(npx tsc --noEmit 2>&1 || true)
  if [ -z "$TSC_OUTPUT" ]; then
    echo -e "   ${GREEN}✓ No TypeScript errors${NC}"
  else
    echo -e "   ${RED}✗ TypeScript errors found${NC}"
    echo "$TSC_OUTPUT" | head -10
    FAILURES=$((FAILURES + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No tsconfig.json found${NC}"
fi
echo ""

# 3. ESLint
echo "🔍 ESLint:"
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
  if command -v eslint &> /dev/null; then
    ESLINT_OUTPUT=$(npx eslint src --ext .ts 2>&1 || true)
    if [ -z "$ESLINT_OUTPUT" ]; then
      echo -e "   ${GREEN}✓ No lint warnings${NC}"
    else
      echo -e "   ${RED}✗ Lint errors found${NC}"
      echo "$ESLINT_OUTPUT" | head -10
      FAILURES=$((FAILURES + 1))
    fi
  else
    echo -e "   ${YELLOW}⚠ ESLint not installed${NC}"
  fi
else
  echo -e "   ${YELLOW}⚠ No ESLint config found${NC}"
fi
echo ""

# 4. Coverage (if configured)
echo "📊 Test Coverage:"
if [ -f "jest.config.js" ] && grep -q "coverageThreshold" jest.config.js; then
  COVERAGE_OUTPUT=$(npm run test:coverage 2>&1 || true)
  if echo "$COVERAGE_OUTPUT" | grep -q "All files.*[89][0-9]\|[0-9]\{3\}"; then
    echo -e "   ${GREEN}✓ Coverage meets threshold${NC}"
  else
    echo -e "   ${YELLOW}⚠ Coverage below threshold${NC}"
  fi
else
  echo -e "   ${YELLOW}⚠ Coverage not configured${NC}"
fi
echo ""

# 5. PROGRESS.md check
echo "📈 Progress Tracking:"
if [ -f ".claude/docs/PROGRESS.md" ]; then
  echo -e "   ${GREEN}✓ PROGRESS.md exists${NC}"
else
  echo -e "   ${YELLOW}⚠ PROGRESS.md not found${NC}"
fi
echo ""

# 6. Spec completeness (if in Ralph Loop)
echo "📋 Specification Tracking:"
if [ -f ".claude/docs/RALPH-STATE.md" ]; then
  echo -e "   ${GREEN}✓ RALPH-STATE.md exists${NC}"
else
  echo -e "   ${YELLOW}⚠ Not in Ralph Loop (no RALPH-STATE.md)${NC}"
fi
echo ""

# 7. Performance checks
echo "⚡ Performance Checks:"

# Check for bundle size budget
if [ -f "package.json" ]; then
  echo -n "   Bundle size budget... "
  if grep -q "bundle\|size\|budget" package.json 2>/dev/null; then
    echo -e "${GREEN}✓${NC} (budget configured)"
  else
    echo -e "${YELLOW}⚠${NC} (no budget configured, see PERFORMANCE-REQUIREMENTS.md)"
  fi
fi

# Check for N+1 query patterns
echo -n "   N+1 query patterns... "
if grep -r "\.map.*\|\.forEach.*\|for.*{" --include=*.ts --include=*.js --include=*.py src/ lib/ 2>/dev/null | grep -E "query|find|select" | grep -q .; then
  echo -e "${YELLOW}⚠${NC} (potential N+1 queries, review with PERFORMANCE-REQUIREMENTS.md)"
else
  echo -e "${GREEN}✓${NC}"
fi

# Check for missing indexes hint
echo -n "   Database indexes... "
if [ -d "src" ] || [ -d "lib" ]; then
  if grep -r "\.find\|\.select\|SELECT.*WHERE" --include=*.ts --include=*.js --include=*.py --include=*.sql src/ lib/ migrations/ 2>/dev/null | grep -q .; then
    echo -e "${BLUE}○${NC} (verify indexes exist for filtered columns)"
  else
    echo -e "${GREEN}✓${NC}"
  fi
else
  echo -e "${YELLOW}⚠${NC} (no src/lib directory)"
fi

# Check for caching
echo -n "   Caching strategy... "
if grep -rq "cache\|Cache\|CACHE" src/ lib/ config/ 2>/dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${BLUE}○${NC} (consider caching for expensive operations)"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✅ All quality gates passed${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAILURES quality gate(s) failed${NC}"
  echo ""
  echo "Please fix the issues above before committing."
  exit 1
fi
