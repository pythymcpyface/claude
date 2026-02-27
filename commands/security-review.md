---
description: Production readiness review for Security. Reviews input validation, authentication, encryption, security headers, dependency scanning, and secrets management before production release. Use PROACTIVELY before production releases, when adding authentication, handling user input, or configuring API security.
 
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
 ---

# Security Review Command

Run a comprehensive production readiness review focused on Application Security.

## Purpose
Review code before production release to ensure:
- Input validation and sanitization
- Authentication and authorization
- Encryption and cryptography
- Security headers
- Dependency vulnerability scanning
- Secrets management
- OWASP Top 10 coverage

## Workflow
### 1. Load the Security Review Skill
Read the skill definition to get the full review checklist and patterns:
```
Read: skills/security-review/SKILL.md
### 2. Detect Project Stack and security patterns
```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"
# Detect authentication libraries
grep -r "passport\|auth0\|next-auth\|express-jwt\|oauth2\|oidc" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# Detect crypto/hashing libraries
grep -r "bcrypt\|argon2\|crypto-js\|helmet\|cors" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# Find input validation patterns
grep -r "sanitize\|validate\|escape\|purge\|strip\|trim\|validator\|joi\|class-validator\|zod\|express-validator\|check\| Yup" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -15
# find security headers
grep -r "helmet\|cors\|csp\|security-headers\|X-frame-options\|X-Content-Security" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

### 3. Run Security checks

Execute all checks in parallel:

**Input Validation:**
```bash
# Find input validation patterns
grep -r "sanitize\|validate\|escape\|purge\|strip\|trim\|validator\|joi\|class-validator\|zod\|express-validator\| Yup --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -20

# Find unsafe patterns
grep -r "eval\|dangerouslySetInnerHTML\|innerHTML\|v-html\|dangerouslySet" --include="*.vue" --include="*.jsx" --include="*.tsx" 2>/dev/null | head -10
# Find SQL injection patterns
grep -rE "(SELECT|insert|query|exec||WHERE.*--)" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
# find file upload validation
grep -r "multer\|upload.*single\|file.*upload\|formidable" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find CSRF protection
grep -r "csrf\|csurf\|cors\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

**Authentication & Authorization:**
```bash
# Find authentication patterns
grep -r "passport\|auth0\|next-auth\|express-jwt\|jwt\|jsonwebtoken\|oauth2\|oidc" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find authorization patterns
grep -r "can\|hasPermission\|hasRole\|isAuthorized\|requireAuth\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find session management
grep -r "session\|express-session\|cookie-session\|Cookie\|redis.*session\ --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find rate limiting
grep -r "rateLimit\|rate.*limit\|throttle\|express-rate-limit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find password hashing
grep -r "bcrypt\|argon2\|password\|hashPassword\|pbkdf2\|crypto\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find Mfa/totp
grep -r "otp\|totp\|generateOTP\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find multi-factor auth
grep -r "mfa\|totp\|authenticator\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find token expiration
grep -r "expiresIn\|expire\|tokenExpiry\|exp:\d+|setHours\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find JWT verification
grep -r "verify\|jwt\.verify\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find OAuth patterns
grep -r "oauth2\|passport-oauth\|google-oauth\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Encryption & Cryptography:**
```bash
# Find encryption patterns
grep -r "encrypt\|decrypt\|crypto\|Cipher\|AES\|rsa\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find TLS/https enforcement
grep -r "https\|ssl\|tls\|secure\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find encryption at rest
grep -r "encryption\|encrypt.*\|cipher"| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
# find hardcoded secrets
grep -rE "(password|api_key|secret|token)\s* = .{0,9})" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
# find env var secrets
grep -r "process\.env\|\.env\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find config with secrets
grep -r "password\|api_key\|secret" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" 2>/dev/null | head -10
# find secrets in logs
 grep -r "console\.log\|logger\.info\|logger\.debug" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find error handling with info leakage
grep -r "catch.*console\|res\.*json\|throw new" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find stack traces
 grep -r "stack.*trace\|stack_trace"|Error.*stack\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find debug endpoints
grep -r "debug\|/health\|/healthcheck\|metrics\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find admin panel exposure
grep -r "admin\|dashboard\|/admin\|management" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Dependency Scanning:**
```bash
# Run npm audit
npm audit --audit-level=moderate --json | audit-level=moderate > /dev/null 2>& /dev/null

# OR
# Run pip-audit/safety
pip-audit -r requirements.txt --audit-level=moderate > /dev/null 2>& /dev/null
# OR
# Run pip-check
pip-check -y requirements.txt || pip install -r requirements.txt
# pip-audit -r requirements.txt --json | audit-level=moderate > /dev/null 2>& /dev/null
 # OR
# Run cargo audit
cargo audit --json 2>/dev/null | echo "No Cargo.lock found"
# OR
# Run govulncheck
govulncheck ./... 2>&/dev/null || echo "No Go modules found"
# OR
# Run Snyk monitor
snyk monitor 2>/dev/null || echo "No snyk installed"
# OR
# Run safety check
safety check -r requirements.txt --json 1>/dev/null | echo "No safety installed"
# OR
# Run trivy
trivy fs --report=trivy-results --json 2>/dev/null || echo "No trivy config"
# OR
# Check Dependabot
ls -la .github/dependabot.yml 2>/dev/null || echo "No Dependabot"
# OR
# Check for Snyk/Dependabot
snyk monitor --json 2>/dev/null || echo "No snyk/dependabot"
# OR
# Run pip-audit/safety
pip-audit -r requirements.txt --json 1>/dev/null || echo "No safety/pip-audit"
# OR
# Run bandit
bandit -r . --include="*.py" 2>/dev/null | head -5
# OR
# Run gosec
gosec ./... 2>/dev/null | echo "No gosec installed"
```

**Security Headers:**
```bash
# Find security header implementations
grep -r "helmet\|cors\|csp\|security-headers\| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find frame protection
grep -r "frame-ancestors|X-Frame-options"|frameguard"| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find CORS configuration
grep -r "cors\|origin\|corsMiddleware" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find CSP headers
grep -r "Content-Security-Policy\|csp\|X-Content-Security-Policy" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find HSTS headers
grep -r "Strict-Transport-Security\|X-Frame-Options"| --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# find X-Content-Type-Options
grep -r "X-Content-Type-Options\|nosniff" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**OWASP Top 10 Coverage:**
```bash
# Find OWASP-related security measures
grep -r "injection\|xss\|csrf\|sqli\|rce\|lfi\|xxe\|ssti"|idor\|ssrf" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
# Find auth measures
grep -r "auth\|password\|token\|session\|jwt\|oauth" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
# Find crypto usage
grep -r "encrypt\|decrypt\|crypto\|bcrypt\|argon" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
# Find secrets
grep -rE "password|api_key|secret|token|credential" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
# Check for hardcoded secrets
grep -rE "(password|api_key|secret|token)\s*[=:]\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**CI/CD Security:**
```bash
# Check for secrets in CI config
grep -r "password\|api_key\|secret\|token" .github .gitlab-ci.yml Jenkinsfile circleci 2>/dev/null | head -10
# Check for secure environment variables
grep -r "secrets\|vault\|aws.*secrets\|azure.*keyvault\|gcp.*secret" .github .gitlab-ci.yml 2>/dev/null | head -10
```

### 4. Analyze and Score

 Based on the skill checklist:
- Score each category (Input Validation, Auth, Encryption, Headers, Dependencies, Secrets)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

 Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

 Provide prioritized recommendations:
1. **Critical** - Must fix before production
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/security-review
```

## When to Use

- Before production releases
- When implementing authentication
- When handling user input
- After security incidents
- During security audits
- When adding API endpoints
- Before compliance reviews

## Integration with Other Commands

Consider running alongside:
- `/dependency-security-scan` - For dependency vulnerabilities
- `/secrets-management-review` - For secrets management
- `/api-readiness-review` - For API security
- `/compliance-review` - For data protection
- `/error-resilience-review` - For error handling
