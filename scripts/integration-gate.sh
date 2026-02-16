#!/bin/bash
# Integration Test Verification Script
# Verifies integration tests exist and validate service communication
# Usage: bash .claude/scripts/integration-gate.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔗 Integration Test Gate"
echo ""
echo "Verifying integration tests for service communication and data flow..."
echo ""

FAILURES=0
WARNINGS=0

# Function to check for integration tests
check_integration_tests() {
  echo "📁 Checking for integration test directory..."

  local found_integration_tests=0

  # Check common integration test directories
  if [ -d "tests/integration" ] || [ -d "test/integration" ]; then
    echo -e "   ${GREEN}✓${NC} Integration test directory found"
    found_integration_tests=1
  fi

  if [ -d "tests/e2e" ] || [ -d "test/e2e" ] || [ -d "e2e" ]; then
    echo -e "   ${GREEN}✓${NC} E2E test directory found"
    found_integration_tests=1
  fi

  if [ $found_integration_tests -eq 0 ]; then
    echo -e "   ${YELLOW}⚠${NC} No integration test directory found"
    echo -e "      ${YELLOW}Create tests/integration/ or tests/e2e/ directory${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
  echo ""
}

# Function to check for API endpoint testing
check_api_testing() {
  echo "🌐 Checking API endpoint coverage..."

  # Look for API endpoint definitions
  local endpoints=0
  if [ -f "package.json" ]; then
    # JavaScript/TypeScript - look for Express, Fastify, etc.
    if grep -r "\.get\|\.post\|\.put\|\.delete\|router\|@Get\|@Post" --include=*.ts --include=*.js src/ 2>/dev/null | grep -q .; then
      endpoints=$(grep -r "\.get\|\.post\|\.put\|\.delete" --include=*.ts --include=*.js src/ 2>/dev/null | wc -l | tr -d ' ')
    fi
  elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    # Python - look for Flask, FastAPI, Django
    if grep -r "@app\.route\|@router\|@app\.get\|@app\.post" --include=*.py src/ 2>/dev/null | grep -q .; then
      endpoints=$(grep -r "@app\.route\|@router\|@app\.get\|@app\.post" --include=*.py src/ 2>/dev/null | wc -l | tr -d ' ')
    fi
  elif [ -f "Gemfile" ]; then
    # Ruby - look for Rails routes
    if grep -r "get\|post\|put\|delete" config/routes.rb 2>/dev/null | grep -q .; then
      endpoints=$(grep -E "get|post|put|delete" config/routes.rb 2>/dev/null | wc -l | tr -d ' ')
    fi
  fi

  if [ "$endpoints" -gt 0 ]; then
    echo -e "   ${BLUE}Found $endpoints API endpoints${NC}"

    # Check if integration tests exist for API
    echo -n "   API integration tests... "
    if grep -r "fetch\|axios\|request\|supertest\|chai\.http" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
      echo -e "${GREEN}✓${NC}"
    else
      echo -e "${YELLOW}⚠${NC} No API integration tests found"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo -e "   ${BLUE}○${NC} No API endpoints detected (may not be applicable)"
  fi
  echo ""
}

# Function to check for database integration tests
check_database_integration() {
  echo "🗄️ Checking database integration..."

  echo -n "   Database connection in tests... "
  if grep -r "database\|sequelize\|mongoose\|prisma\|typeorm\|pg\|mysql" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${BLUE}○${NC} (may be using mocks)"
  fi

  echo -n "   Test database configuration... "
  if [ -f ".env.test" ] || grep -q "TEST_DB\|test.*database" .env 2>/dev/null || grep -q "test.*database" .env.example 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${YELLOW}⚠${NC} No test database configuration found"
    WARNINGS=$((WARNINGS + 1))
  fi
  echo ""
}

# Function to check for service communication testing
check_service_communication() {
  echo "🔄 Checking service communication tests..."

  # Look for external service calls
  local external_calls=0
  if grep -r "fetch\|axios\|http\.request\|client\." --include=*.ts --include=*.js --include=*.py src/ lib/ 2>/dev/null | grep -v "localhost\|127\.0\.0\.1" | grep -q .; then
    external_calls=1
  fi

  if [ $external_calls -eq 1 ]; then
    echo -n "   External service calls detected... "
    if grep -r "nock\|msw\|wiremock\|mock.*service\|stub.*service" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
      echo -e "${GREEN}✓${NC} (mocking/stubbing found)"
    else
      echo -e "${YELLOW}⚠${NC} Consider adding service mocking"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo -e "   ${BLUE}○${NC} No external service calls detected"
  fi
  echo ""
}

# Function to check for data flow validation
check_data_flow() {
  echo "📊 Checking data flow validation..."

  echo -n "   End-to-end user flows... "
  if grep -r "e2e\|end.*to.*end\|flow.*test\|scenario" --include="*.test.*" --include="*.spec.*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${YELLOW}⚠${NC} No explicit end-to-end flow tests found"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo -n "   Error propagation tests... "
  if grep -r "error\|fail\|reject\|throw" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${BLUE}○${NC} Consider adding error scenario tests"
  fi
  echo ""
}

# Function to check for fallback behavior testing
check_fallback_testing() {
  echo "🛡️ Checking fallback behavior tests..."

  local has_fallback_tests=0

  # Check for timeout handling
  echo -n "   Timeout handling... "
  if grep -r "timeout\|setTimeout\|deadline" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
    has_fallback_tests=1
  else
    echo -e "${BLUE}○${NC} No timeout tests found"
  fi

  # Check for retry logic tests
  echo -n "   Retry logic... "
  if grep -r "retry\|retries" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
    has_fallback_tests=1
  else
    echo -e "${BLUE}○${NC} No retry tests found"
  fi

  # Check for circuit breaker tests
  echo -n "   Circuit breaker... "
  if grep -r "circuit.*breaker\|breaker" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
    has_fallback_tests=1
  else
    echo -e "${BLUE}○${NC} No circuit breaker tests found"
  fi

  # Check for graceful degradation
  echo -n "   Graceful degradation... "
  if grep -r "fallback\|degrad\|cache.*fallback" --include="*.test.*" --include="*.spec.*" --include="*integration*" tests/ test/ 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓${NC}"
    has_fallback_tests=1
  else
    echo -e "${BLUE}○${NC} No fallback tests found"
  fi
  echo ""

  if [ $has_fallback_tests -eq 0 ]; then
    echo -e "   ${BLUE}💡${NC} Consider testing fallback scenarios for resilience"
  fi
}

# Run all checks
check_integration_tests
check_api_testing
check_database_integration
check_service_communication
check_data_flow
check_fallback_testing

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Integration Test Summary${NC}"
echo "   Issues found: $FAILURES"
echo "   Suggestions: $WARNINGS"
echo ""

if [ $FAILURES -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Integration test verification passed${NC}"
  else
    echo -e "${GREEN}✅ No critical issues - $WARNINGS suggestion(s) to review${NC}"
  fi
  echo ""
  echo -e "${BLUE}📋 Integration Testing Template${NC}"
  echo "   Reference: .claude/docs/templates/INTEGRATION-TEST-TEMPLATE.md"
  exit 0
else
  echo -e "${RED}❌ Integration test verification failed${NC}"
  echo ""
  echo "Required Actions:"
  echo "1. Create integration tests for API endpoints"
  echo "2. Test service communication and fallbacks"
  echo "3. Validate data flow end-to-end"
  echo "4. Test error scenarios and recovery"
  echo ""
  exit 1
fi
