#!/bin/bash
# Security Gate Verification Script
# Run before merge to verify security requirements
# Usage: bash .claude/scripts/security-gate.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔒 Security Gate Verification"
echo "Checking for OWASP Top 10 vulnerabilities..."
echo ""

FAILURES=0
WARNINGS=0

# Function to run a security check
check_security() {
  local category="$1"
  local description="$2"
  local command="$3"
  local severity="${4:-HIGH}"

  echo -n "   [$category] $description... "

  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    return 0
  else
    if [ "$severity" = "HIGH" ]; then
      echo -e "${RED}FAIL${NC}"
      FAILURES=$((FAILURES + 1))
    else
      echo -e "${YELLOW}WARN${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
    return 1
  fi
}

# Function to check for security patterns in code
check_code_pattern() {
  local pattern="$1"
  local file_pattern="$2"
  local description="$3"
  local severity="${4:-HIGH}"

  echo -n "   [CODE] $description... "

  local matches=$(grep -r "$pattern" $file_pattern 2>/dev/null | wc -l | tr -d ' ')

  if [ "$matches" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}"
    return 0
  else
    if [ "$severity" = "HIGH" ]; then
      echo -e "${RED}FAIL${NC} ($matches occurrences)"
      grep -rn "$pattern" $file_pattern 2>/dev/null | head -3 | sed 's/^/      /'
      FAILURES=$((FAILURES + 1))
    else
      echo -e "${YELLOW}WARN${NC} ($matches occurrences)"
      WARNINGS=$((WARNINGS + 1))
    fi
    return 1
  fi
}

# 1. Dependency Vulnerability Scanning (A01:2021 - Broken Access Control)
echo "📦 A01: Dependency Vulnerabilities"
if [ -f "package.json" ]; then
  if command -v npm &> /dev/null; then
    echo "   Running npm audit..."
    if npm audit --production 2>&1 | grep -q "found 0 vulnerabilities"; then
      echo -e "   ${GREEN}✓ No known vulnerabilities${NC}"
    else
      echo -e "   ${RED}✗ Vulnerabilities found${NC}"
      npm audit --production 2>&1 | grep -E "vulnerabilities|High|Critical" | head -5 | sed 's/^/      /'
      FAILURES=$((FAILURES + 1))
    fi
  else
    echo -e "   ${YELLOW}⚠ npm not available${NC}"
  fi
elif [ -f "Gemfile" ]; then
  if command -v bundle &> /dev/null; then
    echo "   Running bundle audit..."
    if bundle audit check 2>&1 | grep -q "No vulnerabilities"; then
      echo -e "   ${GREEN}✓ No known vulnerabilities${NC}"
    else
      echo -e "   ${RED}✗ Vulnerabilities found${NC}"
      bundle audit check 2>&1 | head -5 | sed 's/^/      /'
      FAILURES=$((FAILURES + 1))
    fi
  else
    echo -e "   ${YELLOW}⚠ bundle not available${NC}"
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  if command -v pip-audit &> /dev/null; then
    echo "   Running pip-audit..."
    if pip-audit 2>&1 | grep -q "No known vulnerabilities"; then
      echo -e "   ${GREEN}✓ No known vulnerabilities${NC}"
    else
      echo -e "   ${RED}✗ Vulnerabilities found${NC}"
      pip-audit 2>&1 | head -5 | sed 's/^/      /'
      FAILURES=$((FAILURES + 1))
    fi
  elif command -v safety &> /dev/null; then
    echo "   Running safety check..."
    if safety check 2>&1 | grep -q "No issues found"; then
      echo -e "   ${GREEN}✓ No known vulnerabilities${NC}"
    else
      echo -e "   ${RED}✗ Vulnerabilities found${NC}"
      safety check 2>&1 | head -5 | sed 's/^/      /'
      FAILURES=$((FAILURES + 1))
    fi
  else
    echo -e "   ${YELLOW}⚠ pip-audit or safety not installed${NC}"
  fi
else
  echo -e "   ${YELLOW}⚠ No dependency file found${NC}"
fi
echo ""

# 2. Input Validation Checks (A03:2021 - Injection)
echo "💉 A03: Injection Prevention"
check_code_pattern "eval(" "--include=*.js --include=*.ts --include=*.py --include=*.rb" "eval() usage detected" "HIGH"
check_code_pattern "innerHTML\s*=" "--include=*.js --include=*.ts" "innerHTML assignment detected" "HIGH"
check_code_pattern "dangerouslySetInnerHTML" "--include=*.js --include=*.ts --include=*.jsx --include=*.tsx" "dangerouslySetInnerHTML usage" "HIGH"
echo ""

# 3. SQL Injection Prevention
echo "🗄️ SQL Injection Prevention"
check_code_pattern "\\$\\{.*}\\.*sql" "--include=*.js --include=*.ts" "Template literal SQL interpolation" "HIGH"
check_code_pattern "execute\\(.*\\+.*\\)" "--include=*.py" "String concatenation in SQL" "HIGH"
echo ""

# 4. Authentication/Authorization (A07:2021 - Identification and Authentication Failures)
echo "🔑 A07: Authentication/Authorization"
if [ -d "src" ] || [ -d "lib" ]; then
  # Check for hardcoded secrets
  echo -n "   [SECRETS] Checking for hardcoded secrets... "
  local secrets_found=0

  # Common secret patterns
  local patterns=(
    "password\\s*=\\s*['\"][^'\"]+['\"]"
    "api_key\\s*=\\s*['\"][^'\"]+['\"]"
    "secret\\s*=\\s*['\"][^'\"]+['\"]"
    "token\\s*=\\s*['\"][^'\"]+['\"]"
    "apikey\\s*=\\s*['\"][^'\"]+['\"]"
  )

  for pattern in "${patterns[@]}"; do
    if grep -r "$pattern" --include=*.js --include=*.ts --include=*.py --include=*.rb src/ lib/ 2>/dev/null | grep -v "example" | grep -v "test" | grep -v "fixture" | grep -q .; then
      secrets_found=1
      break
    fi
  done

  if [ $secrets_found -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}"
  else
    echo -e "${RED}FAIL${NC}"
    echo -e "      ${RED}Possible hardcoded secrets found${NC}"
    echo -e "      ${YELLOW}Review matches and use environment variables${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No src/lib directory${NC}"
fi
echo ""

# 5. Output Sanitization (A03:2021 - Injection, XSS)
echo "🛡️ Output Sanitization"
if [ -f "package.json" ]; then
  echo -n "   [XSS] Checking for XSS protection libraries... "

  if grep -q "sanitize\|DOMPurify\|xss\|helmet" package.json 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
  else
    echo -e "${YELLOW}WARN${NC}"
    echo -e "      ${YELLOW}Consider adding XSS protection (DOMPurify, helmet)${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No package.json found${NC}"
fi
echo ""

# 6. Security Headers (A05:2021 - Security Misconfiguration)
echo "📋 A05: Security Configuration"
if [ -f "package.json" ]; then
  echo -n "   [HEADERS] Checking for security headers library... "

  if grep -q "helmet\|cors" package.json 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
  else
    echo -e "${YELLOW}WARN${NC}"
    echo -e "      ${YELLOW}Consider adding helmet for security headers${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No package.json found${NC}"
fi
echo ""

# 7. Cryptography Checks (A02:2021 - Cryptographic Failures)
echo "🔐 A02: Cryptography"
check_code_pattern "md5\\(" "--include=*.js --include=*.ts --include=*.py --include=*.rb" "Weak hash MD5 detected" "HIGH"
check_code_pattern "sha1\\(" "--include=*.js --include=*.ts --include=*.py --include=*.rb" "Weak hash SHA1 detected" "MEDIUM"
echo ""

# 8. File Upload Security (A03:2021 - Injection via file upload)
echo "📁 File Upload Security"
if [ -d "src" ]; then
  echo -n "   [UPLOAD] Checking file upload validation... "

  if grep -r "upload\|multipart" --include=*.js --include=*.ts src/ 2>/dev/null | grep -q .; then
    # Check if there's validation
    if grep -r "\\..*\\.(ext|type|mimeType)" --include=*.js --include=*.ts src/ 2>/dev/null | grep -q .; then
      echo -e "${GREEN}PASS${NC}"
    else
      echo -e "${YELLOW}WARN${NC}"
      echo -e "      ${YELLOW}File uploads detected - verify validation exists${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo -e "${GREEN}PASS${NC} (no file uploads found)"
  fi
else
  echo -e "   ${YELLOW}⚠ No src directory${NC}"
fi
echo ""

# 9. Logging and Monitoring (A09:2021 - Security Logging and Monitoring Failures)
echo "📊 A09: Security Logging"
if [ -d "src" ] || [ -d "lib" ]; then
  echo -n "   [LOGGING] Checking for security event logging... "

  local security_logging=0
  if grep -r "log.*auth\|log.*login\|log.*fail\|log.*error" --include=*.js --include=*.ts --include=*.py --include=*.rb src/ lib/ 2>/dev/null | grep -q .; then
    security_logging=1
  fi

  if [ $security_logging -eq 1 ]; then
    echo -e "${GREEN}PASS${NC}"
  else
    echo -e "${YELLOW}WARN${NC}"
    echo -e "      ${YELLOW}Consider adding security event logging${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ No src/lib directory${NC}"
fi
echo ""

# 10. Environment Variables Check
echo "🔧 Environment Configuration"
echo -n "   [ENV] Checking for .env file in git... "
if git ls-files | grep -q "^\.env$"; then
  echo -e "${RED}FAIL${NC}"
  echo -e "      ${RED}.env file should be in .gitignore${NC}"
  FAILURES=$((FAILURES + 1))
else
  echo -e "${GREEN}PASS${NC}"
fi

echo -n "   [ENV] Checking for .env.example... "
if [ -f ".env.example" ] || [ -f ".env.template" ] || [ -f ".env.sample" ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC}"
  echo -e "      ${YELLOW}Consider adding .env.example for documentation${NC}"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Security Scan Summary${NC}"
echo "   High/Critical Issues: $FAILURES"
echo "   Warnings: $WARNINGS"
echo ""

if [ $FAILURES -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All security checks passed${NC}"
  else
    echo -e "${GREEN}✅ No critical issues - $WARNINGS warning(s) to review${NC}"
  fi
  echo ""
  echo -e "${BLUE}📋 Security Checklist${NC}"
  echo "   Review the full security checklist at:"
  echo "   .claude/docs/templates/SECURITY-CHECKLIST.md"
  exit 0
else
  echo -e "${RED}❌ Security gate failed - $FAILURES critical issue(s) found${NC}"
  echo ""
  echo "Required Actions:"
  echo "1. Review and fix all HIGH severity issues"
  echo "2. Re-run this security gate"
  echo "3. Only merge after all critical issues are resolved"
  echo ""
  echo "Reference: .claude/docs/templates/SECURITY-CHECKLIST.md"
  exit 1
fi
