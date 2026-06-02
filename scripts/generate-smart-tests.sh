#!/bin/bash
# Smart Test Generation
# AI-powered test generation based on implementation
# Usage: bash .claude/scripts/generate-smart-tests.sh <file-path> [test-type]
# Test Types: unit, integration, e2e, all (default)

set -euo pipefail

# Get script directory and resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_ROOT="$(dirname "$SCRIPT_DIR")"

FILE_PATH="${1:-}"
TEST_TYPE="${2:-all}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print section header
print_header() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""
}

# Function to print usage
print_usage() {
  echo "Usage: bash generate-smart-tests.sh <file-path> [test-type]"
  echo ""
  echo "Arguments:"
  echo "  file-path   - Path to the implementation file"
  echo "  test-type   - Type of tests to generate (default: all)"
  echo ""
  echo "Test Types:"
  echo "  unit        - Unit tests only"
  echo "  integration - Integration tests only"
  echo "  e2e         - End-to-end tests only"
  echo "  all         - All test types (default)"
  echo ""
  echo "Examples:"
  echo "  bash generate-smart-tests.sh src/auth/login.ts"
  echo "  bash generate-smart-tests.sh src/api/users.ts unit"
  echo "  bash generate-smart-tests.sh src/components/Button.tsx e2e"
}

# Function to detect file type and language
detect_language() {
  local file="$1"
  local ext="${file##*.}"
  
  case "$ext" in
    ts|tsx)
      echo "typescript"
      ;;
    js|jsx)
      echo "javascript"
      ;;
    py)
      echo "python"
      ;;
    go)
      echo "go"
      ;;
    rs)
      echo "rust"
      ;;
    java)
      echo "java"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Function to detect test framework
detect_test_framework() {
  local lang="$1"
  
  case "$lang" in
    "typescript"|"javascript")
      if [ -f "package.json" ]; then
        if grep -q "jest" package.json; then
          echo "jest"
        elif grep -q "vitest" package.json; then
          echo "vitest"
        elif grep -q "mocha" package.json; then
          echo "mocha"
        else
          echo "jest" # default
        fi
      else
        echo "jest"
      fi
      ;;
    "python")
      if [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml; then
        echo "pytest"
      else
        echo "pytest" # default
      fi
      ;;
    "go")
      echo "testing"
      ;;
    "rust")
      echo "cargo-test"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Function to determine test file path
get_test_file_path() {
  local impl_file="$1"
  local test_type="$2"
  local lang="$3"
  
  local dir=$(dirname "$impl_file")
  local filename=$(basename "$impl_file")
  local name="${filename%.*}"
  local ext="${filename##*.}"
  
  case "$lang" in
    "typescript"|"javascript")
      case "$test_type" in
        "unit")
          echo "${dir}/${name}.test.${ext}"
          ;;
        "integration")
          echo "${dir}/${name}.integration.test.${ext}"
          ;;
        "e2e")
          echo "e2e/${name}.e2e.${ext}"
          ;;
      esac
      ;;
    "python")
      case "$test_type" in
        "unit")
          echo "${dir}/test_${name}.py"
          ;;
        "integration")
          echo "${dir}/test_${name}_integration.py"
          ;;
        "e2e")
          echo "tests/e2e/test_${name}_e2e.py"
          ;;
      esac
      ;;
    "go")
      echo "${dir}/${name}_test.go"
      ;;
    "rust")
      echo "${dir}/${name}_test.rs"
      ;;
  esac
}

# Function to analyze implementation file
analyze_implementation() {
  local file="$1"
  local lang="$2"
  
  print_header "Analyzing Implementation"
  
  echo -e "${CYAN}File:${NC} $file"
  echo -e "${CYAN}Language:${NC} $lang"
  echo ""
  
  # Count functions/methods
  local func_count=0
  case "$lang" in
    "typescript"|"javascript")
      func_count=$(grep -c "function\|const.*=.*=>\\|async.*function" "$file" 2>/dev/null || echo "0")
      ;;
    "python")
      func_count=$(grep -c "^def " "$file" 2>/dev/null || echo "0")
      ;;
  esac
  
  echo -e "${CYAN}Functions/Methods:${NC} $func_count"
  
  # Detect patterns
  echo ""
  echo -e "${BLUE}Detected Patterns:${NC}"
  
  if grep -q "async\|await\|Promise" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Async operations"
  fi
  
  if grep -q "throw\|Error\|catch" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Error handling"
  fi
  
  if grep -q "fetch\|axios\|http" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} HTTP requests"
  fi
  
  if grep -q "database\|db\|query\|sql" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Database operations"
  fi
  
  if grep -q "validate\|schema\|zod\|yup" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Input validation"
  fi
}

# Function to generate test template
generate_test_template() {
  local impl_file="$1"
  local test_file="$2"
  local test_type="$3"
  local lang="$4"
  local framework="$5"
  
  print_header "Generating $test_type Tests"
  
  echo -e "${CYAN}Test File:${NC} $test_file"
  echo -e "${CYAN}Framework:${NC} $framework"
  echo ""
  
  # Create test directory if needed
  local test_dir=$(dirname "$test_file")
  mkdir -p "$test_dir"
  
  # Generate test content based on language and framework
  case "$lang" in
    "typescript"|"javascript")
      generate_typescript_tests "$impl_file" "$test_file" "$test_type" "$framework"
      ;;
    "python")
      generate_python_tests "$impl_file" "$test_file" "$test_type" "$framework"
      ;;
    *)
      echo -e "${YELLOW}⚠ Test generation not yet supported for $lang${NC}"
      return 1
      ;;
  esac
}

# Function to generate TypeScript/JavaScript tests
generate_typescript_tests() {
  local impl_file="$1"
  local test_file="$2"
  local test_type="$3"
  local framework="$4"
  
  # Extract module name
  local module_name=$(basename "$impl_file" | sed 's/\.[^.]*$//')
  
  # Generate test content
  cat > "$test_file" << EOF
/**
 * ${test_type^} tests for ${module_name}
 * Generated by Smart Test Generation
 * 
 * TODO: Review and customize these tests based on your specific requirements
 */

import { describe, it, expect, beforeEach, afterEach } from '${framework}';
// TODO: Import the functions/classes you want to test
// import { functionName } from './${module_name}';

describe('${module_name}', () => {
  // Setup and teardown
  beforeEach(() => {
    // TODO: Set up test fixtures, mocks, etc.
  });

  afterEach(() => {
    // TODO: Clean up after tests
  });

  describe('Happy Path Tests', () => {
    it('should handle valid input correctly', () => {
      // TODO: Test with valid input
      // Arrange
      const input = {};
      
      // Act
      // const result = functionName(input);
      
      // Assert
      // expect(result).toBeDefined();
      expect(true).toBe(true); // Placeholder
    });

    it('should return expected output format', () => {
      // TODO: Verify output structure
      expect(true).toBe(true); // Placeholder
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty input', () => {
      // TODO: Test with empty/null/undefined input
      expect(true).toBe(true); // Placeholder
    });

    it('should handle boundary values', () => {
      // TODO: Test with min/max values
      expect(true).toBe(true); // Placeholder
    });

    it('should handle special characters', () => {
      // TODO: Test with special characters if applicable
      expect(true).toBe(true); // Placeholder
    });
  });

  describe('Error Handling', () => {
    it('should throw error for invalid input', () => {
      // TODO: Test error cases
      expect(() => {
        // functionName(invalidInput);
      }).toThrow();
    });

    it('should handle async errors gracefully', async () => {
      // TODO: Test async error handling
      expect(true).toBe(true); // Placeholder
    });
  });

  describe('Performance', () => {
    it('should complete within acceptable time', () => {
      // TODO: Add performance tests if needed
      const start = Date.now();
      // functionName(input);
      const duration = Date.now() - start;
      expect(duration).toBeLessThan(1000); // 1 second
    });
  });
});
EOF

  echo -e "${GREEN}✓${NC} Generated test template: $test_file"
  echo -e "${YELLOW}⚡${NC} Review and customize the TODOs in the test file"
}

# Function to generate Python tests
generate_python_tests() {
  local impl_file="$1"
  local test_file="$2"
  local test_type="$3"
  local framework="$4"
  
  # Extract module name
  local module_name=$(basename "$impl_file" .py)
  
  # Generate test content
  cat > "$test_file" << EOF
"""
${test_type^} tests for ${module_name}
Generated by Smart Test Generation

TODO: Review and customize these tests based on your specific requirements
"""

import pytest
# TODO: Import the functions/classes you want to test
# from ${module_name} import function_name


class Test${module_name^}:
    """Test suite for ${module_name}"""

    @pytest.fixture
    def setup(self):
        """Set up test fixtures"""
        # TODO: Set up test fixtures, mocks, etc.
        pass

    def test_happy_path(self, setup):
        """Test with valid input"""
        # TODO: Test with valid input
        # Arrange
        input_data = {}
        
        # Act
        # result = function_name(input_data)
        
        # Assert
        # assert result is not None
        assert True  # Placeholder

    def test_empty_input(self, setup):
        """Test with empty input"""
        # TODO: Test with empty/None input
        assert True  # Placeholder

    def test_boundary_values(self, setup):
        """Test with boundary values"""
        # TODO: Test with min/max values
        assert True  # Placeholder

    def test_error_handling(self, setup):
        """Test error cases"""
        # TODO: Test error cases
        with pytest.raises(Exception):
            # function_name(invalid_input)
            pass

    def test_async_operations(self, setup):
        """Test async operations if applicable"""
        # TODO: Test async operations
        assert True  # Placeholder

    @pytest.mark.performance
    def test_performance(self, setup):
        """Test performance"""
        # TODO: Add performance tests if needed
        import time
        start = time.time()
        # function_name(input_data)
        duration = time.time() - start
        assert duration < 1.0  # 1 second
EOF

  echo -e "${GREEN}✓${NC} Generated test template: $test_file"
  echo -e "${YELLOW}⚡${NC} Review and customize the TODOs in the test file"
}

# Function to generate test coverage report
generate_coverage_report() {
  local impl_file="$1"
  local lang="$2"
  
  print_header "Test Coverage Analysis"
  
  case "$lang" in
    "typescript"|"javascript")
      if command -v npx >/dev/null 2>&1; then
        echo -e "${CYAN}Running coverage analysis...${NC}"
        npx jest --coverage --collectCoverageFrom="$impl_file" 2>/dev/null || true
      fi
      ;;
    "python")
      if command -v pytest >/dev/null 2>&1; then
        echo -e "${CYAN}Running coverage analysis...${NC}"
        pytest --cov="$impl_file" 2>/dev/null || true
      fi
      ;;
  esac
}

# Main execution
main() {
  if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "help" ] || [ "$FILE_PATH" = "--help" ]; then
    print_usage
    exit 0
  fi
  
  # Validate file exists
  if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}Error: File not found: $FILE_PATH${NC}"
    exit 1
  fi
  
  print_header "🧪 Smart Test Generation"
  
  # Detect language and framework
  local lang=$(detect_language "$FILE_PATH")
  local framework=$(detect_test_framework "$lang")
  
  if [ "$lang" = "unknown" ]; then
    echo -e "${RED}Error: Unsupported file type${NC}"
    exit 1
  fi
  
  # Analyze implementation
  analyze_implementation "$FILE_PATH" "$lang"
  
  # Generate tests based on type
  case "$TEST_TYPE" in
    "unit")
      local test_file=$(get_test_file_path "$FILE_PATH" "unit" "$lang")
      generate_test_template "$FILE_PATH" "$test_file" "unit" "$lang" "$framework"
      ;;
    "integration")
      local test_file=$(get_test_file_path "$FILE_PATH" "integration" "$lang")
      generate_test_template "$FILE_PATH" "$test_file" "integration" "$lang" "$framework"
      ;;
    "e2e")
      local test_file=$(get_test_file_path "$FILE_PATH" "e2e" "$lang")
      generate_test_template "$FILE_PATH" "$test_file" "e2e" "$lang" "$framework"
      ;;
    "all")
      local unit_test=$(get_test_file_path "$FILE_PATH" "unit" "$lang")
      local integration_test=$(get_test_file_path "$FILE_PATH" "integration" "$lang")
      
      generate_test_template "$FILE_PATH" "$unit_test" "unit" "$lang" "$framework"
      generate_test_template "$FILE_PATH" "$integration_test" "integration" "$lang" "$framework"
      ;;
    *)
      echo -e "${RED}Error: Unknown test type: $TEST_TYPE${NC}"
      print_usage
      exit 1
      ;;
  esac
  
  # Summary
  print_header "Summary"
  echo -e "${GREEN}✓ Test generation complete${NC}"
  echo ""
  echo -e "${BLUE}Next Steps:${NC}"
  echo -e "  1. Review generated test files"
  echo -e "  2. Customize TODOs based on your implementation"
  echo -e "  3. Add specific test cases for your business logic"
  echo -e "  4. Run tests: ${CYAN}npm test${NC} or ${CYAN}pytest${NC}"
  echo -e "  5. Check coverage: ${CYAN}npm test -- --coverage${NC}"
  echo ""
}

main
