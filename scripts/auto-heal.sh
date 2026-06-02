#!/bin/bash
# Auto-Healing Workflows
# Detects and automatically fixes common development issues
# Usage: bash .claude/scripts/auto-heal.sh [category]
# Categories: lint, format, deps, imports, security, all

set -euo pipefail

# Get script directory and resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_ROOT="$(dirname "$SCRIPT_DIR")"

CATEGORY="${1:-all}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
ISSUES_FOUND=0
ISSUES_FIXED=0
ISSUES_MANUAL=0

# Function to print section header
print_header() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""
}

# Function to print issue
print_issue() {
  local severity="$1"
  local message="$2"
  
  case "$severity" in
    "error")
      echo -e "${RED}✗${NC} $message"
      ;;
    "warning")
      echo -e "${YELLOW}⚠${NC} $message"
      ;;
    "info")
      echo -e "${CYAN}ℹ${NC} $message"
      ;;
  esac
}

# Function to print fix
print_fix() {
  local status="$1"
  local message="$2"
  
  case "$status" in
    "fixed")
      echo -e "  ${GREEN}✓${NC} $message"
      ((ISSUES_FIXED++))
      ;;
    "manual")
      echo -e "  ${YELLOW}⚡${NC} $message"
      ((ISSUES_MANUAL++))
      ;;
    "skipped")
      echo -e "  ${CYAN}⊘${NC} $message"
      ;;
  esac
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to detect project type
detect_project_type() {
  if [ -f "package.json" ]; then
    echo "node"
  elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "python"
  elif [ -f "Cargo.toml" ]; then
    echo "rust"
  elif [ -f "go.mod" ]; then
    echo "go"
  else
    echo "unknown"
  fi
}

# ============================================================================
# LINT FIXES
# ============================================================================

heal_lint() {
  print_header "Auto-Healing: Lint Issues"
  
  local project_type=$(detect_project_type)
  
  case "$project_type" in
    "node")
      heal_lint_node
      ;;
    "python")
      heal_lint_python
      ;;
    "rust")
      heal_lint_rust
      ;;
    *)
      print_issue "info" "No linter detected for project type: $project_type"
      ;;
  esac
}

heal_lint_node() {
  if [ ! -f "package.json" ]; then
    return
  fi
  
  # Check for ESLint
  if command_exists eslint || [ -f "node_modules/.bin/eslint" ]; then
    print_issue "info" "Running ESLint auto-fix..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'eslint . --fix'"
    else
      if npx eslint . --fix 2>/dev/null; then
        print_fix "fixed" "ESLint auto-fix completed"
      else
        print_fix "manual" "Some ESLint errors require manual fixes"
      fi
    fi
    ((ISSUES_FOUND++))
  fi
  
  # Check for Prettier
  if command_exists prettier || [ -f "node_modules/.bin/prettier" ]; then
    print_issue "info" "Running Prettier auto-format..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'prettier --write .'"
    else
      if npx prettier --write . 2>/dev/null; then
        print_fix "fixed" "Prettier formatting completed"
      else
        print_fix "manual" "Some files could not be formatted"
      fi
    fi
    ((ISSUES_FOUND++))
  fi
}

heal_lint_python() {
  # Check for Black
  if command_exists black; then
    print_issue "info" "Running Black auto-format..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'black .'"
    else
      if black . 2>/dev/null; then
        print_fix "fixed" "Black formatting completed"
      else
        print_fix "manual" "Some files could not be formatted"
      fi
    fi
    ((ISSUES_FOUND++))
  fi
  
  # Check for isort
  if command_exists isort; then
    print_issue "info" "Running isort (import sorting)..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'isort .'"
    else
      if isort . 2>/dev/null; then
        print_fix "fixed" "Import sorting completed"
      else
        print_fix "manual" "Some imports could not be sorted"
      fi
    fi
    ((ISSUES_FOUND++))
  fi
}

heal_lint_rust() {
  if command_exists rustfmt; then
    print_issue "info" "Running rustfmt..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'cargo fmt'"
    else
      if cargo fmt 2>/dev/null; then
        print_fix "fixed" "Rust formatting completed"
      else
        print_fix "manual" "Some files could not be formatted"
      fi
    fi
    ((ISSUES_FOUND++))
  fi
}

# ============================================================================
# DEPENDENCY FIXES
# ============================================================================

heal_deps() {
  print_header "Auto-Healing: Dependencies"
  
  local project_type=$(detect_project_type)
  
  case "$project_type" in
    "node")
      heal_deps_node
      ;;
    "python")
      heal_deps_python
      ;;
    *)
      print_issue "info" "No dependency manager detected"
      ;;
  esac
}

heal_deps_node() {
  if [ ! -f "package.json" ]; then
    return
  fi
  
  # Check for missing node_modules
  if [ ! -d "node_modules" ]; then
    print_issue "error" "node_modules directory missing"
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'npm install'"
    else
      print_fix "manual" "Run 'npm install' to install dependencies"
    fi
    ((ISSUES_FOUND++))
    ((ISSUES_MANUAL++))
    return
  fi
  
  # Check for outdated dependencies (security)
  print_issue "info" "Checking for security vulnerabilities..."
  
  if npm audit --audit-level=high 2>/dev/null | grep -q "vulnerabilities"; then
    print_issue "warning" "Security vulnerabilities found"
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'npm audit fix'"
    else
      print_fix "manual" "Run 'npm audit fix' to fix vulnerabilities"
    fi
    ((ISSUES_FOUND++))
    ((ISSUES_MANUAL++))
  else
    print_fix "fixed" "No security vulnerabilities found"
  fi
}

heal_deps_python() {
  if [ -f "requirements.txt" ]; then
    print_issue "info" "Checking Python dependencies..."
    
    # Check if virtual environment exists
    if [ ! -d "venv" ] && [ ! -d ".venv" ]; then
      print_issue "warning" "No virtual environment found"
      print_fix "manual" "Create virtual environment: python -m venv venv"
      ((ISSUES_FOUND++))
      ((ISSUES_MANUAL++))
    fi
  fi
}

# ============================================================================
# IMPORT FIXES
# ============================================================================

heal_imports() {
  print_header "Auto-Healing: Import Issues"
  
  local project_type=$(detect_project_type)
  
  case "$project_type" in
    "node")
      heal_imports_node
      ;;
    "python")
      heal_imports_python
      ;;
    *)
      print_issue "info" "No import fixer available for project type"
      ;;
  esac
}

heal_imports_node() {
  # Check for unused imports (requires eslint-plugin-unused-imports)
  if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
    print_issue "info" "Checking for unused imports..."
    
    if npx eslint . --fix --rule 'unused-imports/no-unused-imports: error' 2>/dev/null; then
      print_fix "fixed" "Removed unused imports"
      ((ISSUES_FOUND++))
    else
      print_fix "manual" "Some unused imports require manual review"
      ((ISSUES_FOUND++))
      ((ISSUES_MANUAL++))
    fi
  fi
}

heal_imports_python() {
  if command_exists isort; then
    print_issue "info" "Organizing Python imports..."
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'isort .'"
    else
      if isort . 2>/dev/null; then
        print_fix "fixed" "Import organization completed"
        ((ISSUES_FOUND++))
      fi
    fi
  fi
}

# ============================================================================
# SECURITY FIXES
# ============================================================================

heal_security() {
  print_header "Auto-Healing: Security Issues"
  
  local project_type=$(detect_project_type)
  
  case "$project_type" in
    "node")
      heal_security_node
      ;;
    *)
      print_issue "info" "No security auto-fix available for project type"
      ;;
  esac
}

heal_security_node() {
  if [ ! -f "package.json" ]; then
    return
  fi
  
  # Check for security vulnerabilities
  print_issue "info" "Scanning for security vulnerabilities..."
  
  if npm audit --audit-level=moderate 2>/dev/null | grep -q "vulnerabilities"; then
    print_issue "warning" "Security vulnerabilities detected"
    
    if [ "$DRY_RUN" = "true" ]; then
      print_fix "skipped" "Dry run: Would run 'npm audit fix'"
    else
      print_fix "manual" "Run 'npm audit fix' (may cause breaking changes)"
      print_fix "manual" "Or run 'npm audit fix --force' for all fixes"
    fi
    ((ISSUES_FOUND++))
    ((ISSUES_MANUAL++))
  else
    print_fix "fixed" "No security vulnerabilities found"
  fi
}

# ============================================================================
# FORMAT FIXES
# ============================================================================

heal_format() {
  print_header "Auto-Healing: Code Formatting"
  
  # This is similar to lint but focuses only on formatting
  heal_lint
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

print_usage() {
  echo "Usage: bash auto-heal.sh [category]"
  echo ""
  echo "Categories:"
  echo "  lint      - Fix linting issues (ESLint, Prettier, etc.)"
  echo "  format    - Fix code formatting"
  echo "  deps      - Check and fix dependency issues"
  echo "  imports   - Fix import issues"
  echo "  security  - Check and fix security vulnerabilities"
  echo "  all       - Run all auto-healing checks (default)"
  echo ""
  echo "Environment Variables:"
  echo "  DRY_RUN=true  - Show what would be fixed without making changes"
  echo ""
  echo "Examples:"
  echo "  bash auto-heal.sh lint"
  echo "  DRY_RUN=true bash auto-heal.sh all"
}

main() {
  if [ "$CATEGORY" = "help" ] || [ "$CATEGORY" = "--help" ] || [ "$CATEGORY" = "-h" ]; then
    print_usage
    exit 0
  fi
  
  print_header "🔧 Auto-Healing Workflows"
  
  if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}Running in DRY RUN mode - no changes will be made${NC}"
    echo ""
  fi
  
  case "$CATEGORY" in
    "lint")
      heal_lint
      ;;
    "format")
      heal_format
      ;;
    "deps")
      heal_deps
      ;;
    "imports")
      heal_imports
      ;;
    "security")
      heal_security
      ;;
    "all")
      heal_lint
      heal_deps
      heal_imports
      heal_security
      ;;
    *)
      echo -e "${RED}Unknown category: $CATEGORY${NC}"
      echo ""
      print_usage
      exit 1
      ;;
  esac
  
  # Print summary
  print_header "Summary"
  echo -e "Issues Found:    ${YELLOW}$ISSUES_FOUND${NC}"
  echo -e "Auto-Fixed:      ${GREEN}$ISSUES_FIXED${NC}"
  echo -e "Manual Required: ${YELLOW}$ISSUES_MANUAL${NC}"
  echo ""
  
  if [ $ISSUES_MANUAL -gt 0 ]; then
    echo -e "${YELLOW}⚡ Some issues require manual intervention${NC}"
    echo -e "${YELLOW}   Review the output above for details${NC}"
    exit 1
  elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ No issues found - codebase is healthy!${NC}"
    exit 0
  else
    echo -e "${GREEN}✓ All issues auto-fixed successfully!${NC}"
    exit 0
  fi
}

main
