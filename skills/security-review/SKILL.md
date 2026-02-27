---
name: security-review
description: Production readiness review for Security. Reviews input validation, authentication, encryption, security headers, dependency scanning, and secrets management before production release. Use PROACTIVELY before releasing to production, when implementing authentication, handling user input, or configuring API security.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Security Review Skill

Production readiness code review focused on Application Security. Ensures code is ready for production with comprehensive protection against OWASP Top 10 and common security vulnerabilities.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "auth", "security", "login", "password", "token", "api", "encrypt", "secret", "input", "validate"
- Authentication/authorization features added
- User input handling implemented
- API endpoints created or modified
- Database operations added
- File upload functionality added
- Payment/financial features implemented
- Third-party integrations added
- Before production releases

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's security libraries and frameworks:

```bash
# Detect Node.js security packages
grep -r "helmet\|cors\|express-rate-limit\|bcrypt\|argon2\|jsonwebtoken\|passport\|express-jwt\|joi\|zod\|express-validator" package.json 2>/dev/null && echo "Node.js security detected"

# Detect Python security packages
grep -r "flask-talisman\|django-cors-headers\|passlib\|bcrypt\|pyjwt\|oauthlib\|authlib\|marshmallow\|pydantic\|cerberus" requirements.txt pyproject.toml setup.py 2>/dev/null && echo "Python security detected"

# Detect Go security packages
grep -r "jwt-go\|bcrypt\|oauth2\|gorilla.csrf\|chi\|echo\|gin" go.mod 2>/dev/null && echo "Go security detected"

# Detect authentication frameworks
grep -r "auth0\|next-auth\|passport\|firebase-auth\|supertokens\|cognito\|okta" --include="*.json" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10

# Find configuration files
find . -name "*.env*" -o -name "security.config.*" -o -name "auth.config.*" 2>/dev/null | grep -v node_modules | head -10
```

### Phase 2: Security Checklist

Run all checks and compile results:

#### 1. Input Validation Review

Input validation prevents injection attacks and data corruption.

| Check | Pattern | Status |
|-------|---------|--------|
| Server-side validation | All inputs validated on server | Required |
| Type validation | Input types enforced | Required |
| Length limits | String lengths bounded | Required |
| Whitelist validation | Allow-list approach used | Required |
| SQL injection prevention | Parameterized queries used | Required |
| XSS prevention | Output encoding/sanitization | Required |
| File upload validation | Type, size, content validated | Required |
| CSRF protection | Tokens or SameSite cookies | Required |

**Search Patterns:**
```bash
# Find validation libraries
grep -r "joi\|zod\|class-validator\|express-validator\|yup\|ajv\|validator\|marshmallow\|pydantic\|cerberus" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -15

# Find validation patterns
grep -r "validate\|sanitize\|escape\|purify\|strip\|trim\|check\|assert" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -15

# Find unsafe patterns (potential XSS)
grep -r "eval\|dangerouslySetInnerHTML\|innerHTML\|v-html\|document.write" --include="*.vue" --include="*.jsx" --include="*.tsx" --include="*.js" 2>/dev/null | head -10

# Find SQL patterns (potential injection)
grep -rE "(SELECT|INSERT|UPDATE|DELETE).*\+" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
grep -r "query.*\$\|execute.*\$\|raw.*query" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find file upload handling
grep -r "multer\|formidable\|busboy\|upload\|multipart\|file.*save" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find CSRF protection
grep -r "csrf\|csurf\|xsrf\|_token" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 2. Authentication Review

Authentication verifies user identity securely.

| Check | Pattern | Status |
|-------|---------|--------|
| Password hashing | bcrypt/argon2/scrypt used | Required |
| Hash strength | Cost factor >= 10 for bcrypt | Required |
| Session management | Secure session handling | Required |
| Token security | JWT signed, short expiry | Required |
| Rate limiting | Auth endpoints rate limited | Required |
| Account lockout | Brute force protection | Required |
| MFA available | Multi-factor authentication | Recommended |
| Password policies | Strong password requirements | Required |

**Search Patterns:**
```bash
# Find authentication libraries
grep -r "passport\|auth0\|next-auth\|express-jwt\|jwt\|jsonwebtoken\|oauth2\|oidc\|firebase-auth" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find password hashing
grep -r "bcrypt\|argon2\|scrypt\|pbkdf2\|hashPassword\|password.*hash" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find session management
grep -r "session\|express-session\|cookie-session\|redis.*session\|session.*store" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find rate limiting
grep -r "rateLimit\|rate.*limit\|throttle\|express-rate-limit\|slowmode\|ratelimit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find MFA/TOTP
grep -r "totp\|otp\|authenticator\|mfa\|2fa\|speakeasy\|otplib" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find token expiration
grep -r "expiresIn\|expire\|tokenExpiry\|maxAge\|expires" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find JWT verification
grep -r "jwt\.verify\|verify.*token\|validateToken\|verifyToken" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 3. Authorization Review

Authorization controls access to resources.

| Check | Pattern | Status |
|-------|---------|--------|
| Role-based access | RBAC implemented | Required |
| Resource ownership | User can only access own resources | Required |
| Principle of least privilege | Minimal permissions granted | Required |
| API endpoint protection | All endpoints have auth checks | Required |
| Admin routes protected | Admin-only routes secured | Required |
| Horizontal access control | Users can't access others' data | Required |
| Vertical access control | Users can't escalate privileges | Required |
| Authorization logging | Access attempts logged | Recommended |

**Search Patterns:**
```bash
# Find authorization patterns
grep -r "hasPermission\|hasRole\|isAuthorized\|requireAuth\|can\|checkPermission\|authorize" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find middleware auth
grep -r "authMiddleware\|protect\|guard\|requireAuth\|authenticate\|authorize" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find role checks
grep -r "role.*===\|role.*==\|isAdmin\|is.*Admin\|checkRole\|hasRole" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find ownership checks
grep -r "ownerId\|userId.*===\|belongsTo\|ownedBy\|user.*id.*match" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find admin routes
grep -r "/admin\|admin.*route\|admin.*controller" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 4. Encryption & Cryptography Review

Cryptography protects sensitive data.

| Check | Pattern | Status |
|-------|---------|--------|
| HTTPS enforced | TLS for all connections | Required |
| Sensitive data encrypted | PII/credentials encrypted at rest | Required |
| Strong algorithms | AES-256, RSA-2048, SHA-256+ | Required |
| Secure key management | Keys in vault/env, not code | Required |
| Key rotation | Cryptographic key rotation | Recommended |
| Certificate validation | TLS cert verification enabled | Required |
| Secure random | Crypto-secure RNG for tokens | Required |
| No custom crypto | Standard libraries used | Required |

**Search Patterns:**
```bash
# Find encryption patterns
grep -r "encrypt\|decrypt\|cipher\|AES\|RSA\|crypto" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find TLS/HTTPS enforcement
grep -r "https\|ssl\|tls\|secure\|rejectUnauthorized" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find encryption at rest
grep -r "encrypt.*field\|encrypted.*column\|cipher.*column\|data.*encrypt" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find random generation
grep -r "randomBytes\|crypto\.random\|secrets\|uuid\|nanoid" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find weak crypto (anti-patterns)
grep -r "MD5\|SHA1\|DES\|RC4\|Math.random.*token" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -5
```

#### 5. Security Headers Review

Security headers protect against client-side attacks.

| Check | Pattern | Status |
|-------|---------|--------|
| Content-Security-Policy | CSP header configured | Required |
| X-Frame-Options | Clickjacking protection | Required |
| X-Content-Type-Options | MIME sniffing prevention | Required |
| Strict-Transport-Security | HSTS header set | Required |
| X-XSS-Protection | XSS filter enabled | Recommended |
| Referrer-Policy | Referrer control | Required |
| Permissions-Policy | Feature restrictions | Recommended |
| CORS configured | Proper CORS policy | Required |

**Search Patterns:**
```bash
# Find security header libraries
grep -r "helmet\|cors\|csp\|security-headers" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find CSP configuration
grep -r "Content-Security-Policy\|csp\|default-src\|script-src" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find frame protection
grep -r "X-Frame-Options\|frame-ancestors\|frameguard\|DENY\|SAMEORIGIN" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find HSTS
grep -r "Strict-Transport-Security\|max-age\|includeSubDomains\|preload" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find CORS config
grep -r "cors\|origin\|Access-Control\|allowedOrigins" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find X-Content-Type-Options
grep -r "X-Content-Type-Options\|nosniff" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 6. Dependency Vulnerability Scanning

Vulnerable dependencies are a major attack vector.

| Check | Pattern | Status |
|-------|---------|--------|
| Automated scanning | CI/CD vulnerability scanning | Required |
| No critical vulnerabilities | 0 critical CVEs | Required |
| No high vulnerabilities | 0 high CVEs in direct deps | Required |
| Dependabot/Renovate | Automated dependency updates | Recommended |
| Lock file committed | Package-lock/yarn.lock present | Required |
| Private registry | Internal packages secured | Conditional |
| License compliance | No GPL/incompatible licenses | Recommended |

**Search Patterns:**
```bash
# Check for npm audit
npm audit --audit-level=moderate --json 2>/dev/null | head -20

# Check for pip-audit/safety
pip-audit -r requirements.txt --json 2>/dev/null | head -20 || safety check -r requirements.txt --json 2>/dev/null | head -20

# Check for cargo audit
cargo audit --json 2>/dev/null | head -10

# Check for Go vulncheck
govulncheck ./... 2>&1 | head -20

# Check for Dependabot
ls -la .github/dependabot.yml 2>/dev/null && echo "Dependabot configured"

# Check for Snyk
ls -la .snyk 2>/dev/null && echo "Snyk configured"

# Check for lock files
ls package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock go.sum 2>/dev/null
```

#### 7. Secrets Management Review

Exposed secrets are a critical security risk.

| Check | Pattern | Status |
|-------|---------|--------|
| No hardcoded secrets | Secrets not in source code | Required |
| Environment variables | Secrets from env/vault | Required |
| Secrets not in logs | Sensitive data not logged | Required |
| Secrets not in URLs | Tokens not in query params | Required |
| .env excluded | .env in .gitignore | Required |
| Secret rotation | Periodic secret rotation | Recommended |
| Vault/SM integration | Secrets manager used | Recommended |
| No secrets in CI logs | CI masks secrets | Required |

**Search Patterns:**
```bash
# Find hardcoded secrets (potential)
grep -rE "(password|api_key|secret|token|credential)\s*[=:]\s*['\"][^'\"]{8,}['\"]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find env variable usage
grep -r "process\.env\|os\.environ\|dotenv\|config\.get" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find secrets in config files
grep -rE "(password|api_key|secret|token)" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env*" 2>/dev/null | head -10

# Find logging patterns (potential secret leakage)
grep -r "console\.log\|logger\.info\|logger\.debug\|print\|log\." --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Check .gitignore for .env
grep -r "\.env" .gitignore 2>/dev/null && echo ".env in .gitignore"

# Find error handling that might leak info
grep -r "catch.*send\|catch.*json\|error.*stack.*send\|res\.send.*error" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find debug endpoints
grep -r "/debug\|/health\|/metrics\|/status\|/actuator" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 8. OWASP Top 10 Coverage

Comprehensive coverage of major vulnerability classes.

| OWASP Category | Check | Status |
|----------------|-------|--------|
| A01 Broken Access Control | Authorization checks | Required |
| A02 Cryptographic Failures | Encryption in place | Required |
| A03 Injection | Parameterized queries | Required |
| A04 Insecure Design | Threat modeling done | Recommended |
| A05 Security Misconfiguration | Hardening complete | Required |
| A06 Vulnerable Components | Dependency scanning | Required |
| A07 Auth Failures | Strong auth mechanisms | Required |
| A08 Data Integrity | Input validation | Required |
| A09 Logging Failures | Security logging | Required |
| A10 SSRF | URL validation | Conditional |

**Search Patterns:**
```bash
# A01: Broken Access Control
grep -r "hasPermission\|authorize\|canAccess\|checkAuth" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A02: Cryptographic Failures
grep -r "encrypt\|bcrypt\|argon2\|https\|tls" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A03: Injection
grep -r "parameterized\|prepared\|query.*\?\|query.*\$\|bind" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A05: Security Misconfiguration
grep -r "helmet\|cors\|csp\|security.*header" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A07: Auth Failures
grep -r "session\|jwt\|token\|auth\|login" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A08: Data Integrity
grep -r "validate\|sanitize\|check\|verify" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A09: Logging
grep -r "log\|audit\|monitor\|alert" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# A10: SSRF
grep -r "fetch\|request\|axios\|http\.get\|url.*fetch" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific security gap
2. **Why it matters**: Impact on security posture
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      SECURITY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Security Libraries: [helmet/bcrypt/etc.]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

INPUT VALIDATION
  [PASS] Server-side validation present
  [PASS] Type validation implemented
  [FAIL] No file upload validation
  [PASS] SQL injection prevention
  [WARN] Some XSS vectors unaddressed
  [PASS] CSRF protection enabled

AUTHENTICATION
  [PASS] bcrypt password hashing
  [FAIL] Hash cost factor low (8)
  [PASS] JWT with expiration
  [PASS] Rate limiting on auth
  [FAIL] No account lockout
  [WARN] MFA not implemented

AUTHORIZATION
  [PASS] Role-based access control
  [FAIL] Missing ownership checks
  [PASS] API endpoint protection
  [WARN] Admin routes not audit-logged

ENCRYPTION & CRYPTOGRAPHY
  [PASS] HTTPS enforced
  [FAIL] PII not encrypted at rest
  [PASS] Strong algorithms used
  [PASS] Keys in environment
  [WARN] No key rotation policy

SECURITY HEADERS
  [FAIL] CSP header missing
  [PASS] X-Frame-Options set
  [PASS] HSTS enabled
  [FAIL] CORS allows all origins
  [PASS] X-Content-Type-Options set

DEPENDENCY SCANNING
  [PASS] npm audit in CI
  [FAIL] 2 critical CVEs found
  [PASS] Dependabot enabled
  [PASS] Lock file committed

SECRETS MANAGEMENT
  [FAIL] Hardcoded API key found
  [PASS] Environment variables used
  [FAIL] Secrets in error logs
  [PASS] .env in .gitignore

OWASP TOP 10 COVERAGE
  [PASS] A01: Access control
  [WARN] A02: Cryptographic gaps
  [PASS] A03: Injection prevention
  [FAIL] A05: Misconfiguration (CORS)
  [PASS] A06: Dependency scanning
  [WARN] A07: Auth gaps (MFA)
  [PASS] A08: Input validation
  [WARN] A09: Logging incomplete
  [N/A]  A10: SSRF (not applicable)

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Hardcoded API Key Found
  Impact: Secret exposure in version control, credential theft
  Fix: Move secret to environment variable immediately
  File: src/services/external-api.ts:15

  // BEFORE (vulnerable):
  const API_KEY = 'sk-live-abc123xyz...';

  // AFTER (secure):
  const API_KEY = process.env.EXTERNAL_API_KEY;
  if (!API_KEY) {
    throw new Error('EXTERNAL_API_KEY not configured');
  }

[CRITICAL] 2 Critical CVEs in Dependencies
  Impact: Known vulnerabilities exploitable by attackers
  Fix: Update vulnerable packages immediately
  Vulnerabilities:
  - lodash@4.17.15: CVE-2021-23337 (Command Injection)
  - node-fetch@2.6.0: CVE-2022-0235 (Credential Leak)

  npm update lodash node-fetch
  npm audit fix

[CRITICAL] CSP Header Missing
  Impact: XSS attacks not mitigated at browser level
  Fix: Add Content-Security-Policy header
  File: src/middleware/security.ts

  // Using Helmet
  const helmet = require('helmet');
  app.use(helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "https://cdn.trusted.com"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.example.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
    },
  }));

[HIGH] PII Not Encrypted at Rest
  Impact: Data breach exposes sensitive user information
  Fix: Encrypt sensitive fields before storage
  File: src/models/user.ts

  const bcrypt = require('bcrypt');
  const crypto = require('crypto');

  // Encrypt PII before saving
  async function encryptPII(data: string): Promise<string> {
    const key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    
    let encrypted = cipher.update(data, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag();
    
    return iv.toString('hex') + ':' + authTag.toString('hex') + ':' + encrypted;
  }

[HIGH] CORS Allows All Origins
  Impact: Cross-origin attacks, data exfiltration
  Fix: Restrict CORS to known origins
  File: src/server.ts

  // BEFORE (vulnerable):
  app.use(cors({ origin: '*' }));

  // AFTER (secure):
  const allowedOrigins = [
    'https://app.example.com',
    'https://admin.example.com',
  ];

  app.use(cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
    maxAge: 86400,
  }));

[HIGH] Missing File Upload Validation
  Impact: Malicious file uploads, RCE, malware distribution
  Fix: Implement comprehensive file validation
  File: src/middleware/upload.ts

  const multer = require('multer');
  const path = require('path');
  const crypto = require('crypto');

  const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'];
  const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

  const storage = multer.diskStorage({
    destination: '/tmp/uploads',
    filename: (req, file, cb) => {
      // Use random filename to prevent path traversal
      crypto.randomBytes(16, (err, raw) => {
        cb(err, raw.toString('hex') + path.extname(file.originalname));
      });
    },
  });

  const upload = multer({
    storage,
    limits: { fileSize: MAX_FILE_SIZE },
    fileFilter: (req, file, cb) => {
      // Validate MIME type
      if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
        return cb(new Error('Invalid file type'), false);
      }
      cb(null, true);
    },
  });

  // Additional content validation after upload
  async function validateFileContent(filePath: string): Promise<boolean> {
    const magicNumbers = await readFileHeader(filePath);
    // Verify actual file type matches extension
    // Scan for malware
    return true;
  }

[MEDIUM] No Account Lockout
  Impact: Brute force attacks on user accounts
  Fix: Implement account lockout after failed attempts
  File: src/services/auth.ts

  const MAX_LOGIN_ATTEMPTS = 5;
  const LOCKOUT_DURATION = 15 * 60 * 1000; // 15 minutes

  async function handleFailedLogin(userId: string): Promise<void> {
    const user = await User.findById(userId);
    user.loginAttempts = (user.loginAttempts || 0) + 1;
    
    if (user.loginAttempts >= MAX_LOGIN_ATTEMPTS) {
      user.lockedUntil = new Date(Date.now() + LOCKOUT_DURATION);
      await auditLog('account_locked', { userId, reason: 'too_many_attempts' });
    }
    
    await user.save();
  }

[MEDIUM] Secrets in Error Logs
  Impact: Credential exposure in log aggregation systems
  Fix: Sanitize logs before output
  File: src/middleware/error-handler.ts

  const SENSITIVE_FIELDS = ['password', 'token', 'apiKey', 'secret'];

  function sanitizeForLog(obj: any): any {
    const sanitized = { ...obj };
    for (const field of SENSITIVE_FIELDS) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }
    return sanitized;
  }

  app.use((err, req, res, next) => {
    // Log sanitized error
    logger.error('Request error', {
      error: sanitizeForLog(err),
      path: req.path,
      method: req.method,
    });
    
    res.status(500).json({ error: 'Internal server error' });
  });

[MEDIUM] Hash Cost Factor Too Low
  Impact: Faster offline password cracking
  Fix: Increase bcrypt cost factor to at least 12
  File: src/services/password.ts

  // BEFORE (weak):
  const hash = await bcrypt.hash(password, 8);

  // AFTER (strong):
  const hash = await bcrypt.hash(password, 12);

[LOW] MFA Not Implemented
  Impact: Single factor authentication risk
  Fix: Add optional MFA for enhanced security
  File: src/services/mfa.ts

  const speakeasy = require('speakeasy');
  const qrcode = require('qrcode');

  async function setupMFA(userId: string): Promise<{ secret: string, qrCode: string }> {
    const secret = speakeasy.generateSecret({
      name: `MyApp (${userId})`,
      length: 20,
    });

    await User.update(userId, { mfaSecret: secret.base32 });
    
    const qrCode = await qrcode.toDataURL(secret.otpauth_url);
    return { secret: secret.base32, qrCode };
  }

  function verifyMFA(secret: string, token: string): boolean {
    return speakeasy.totp.verify({
      secret,
      encoding: 'base32',
      token,
      window: 1,
    });
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Remove hardcoded API key, use environment variable
2. [CRITICAL] Update vulnerable dependencies (lodash, node-fetch)
3. [CRITICAL] Add Content-Security-Policy header
4. [HIGH] Encrypt PII at rest
5. [HIGH] Restrict CORS to known origins
6. [HIGH] Implement file upload validation
7. [MEDIUM] Add account lockout mechanism
8. [MEDIUM] Sanitize error logs
9. [MEDIUM] Increase bcrypt cost factor to 12

After Production:
1. Implement MFA for all users
2. Add security audit logging
3. Set up WAF rules
4. Implement API rate limiting globally
5. Add key rotation procedures
6. Set up intrusion detection
7. Conduct penetration testing
8. Implement bug bounty program

═══════════════════════════════════════════════════════════════
```

---

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Input Validation | 15% |
| Authentication | 20% |
| Authorization | 15% |
| Encryption & Cryptography | 15% |
| Security Headers | 10% |
| Dependency Scanning | 10% |
| Secrets Management | 10% |
| OWASP Top 10 Coverage | 5% |

---

## Quick Reference: Implementation Patterns

### Input Validation with Zod

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain number')
    .regex(/[^A-Za-z0-9]/, 'Must contain special character'),
  name: z.string().min(1).max(100).regex(/^[\w\s-]+$/),
  age: z.number().int().min(0).max(150).optional(),
});

// Usage in route
app.post('/users', validate(createUserSchema), createUserHandler);
```

### Password Hashing with bcrypt

```typescript
// src/services/password.ts
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

export async function hashPassword(plainPassword: string): Promise<string> {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
}

export async function verifyPassword(
  plainPassword: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(plainPassword, hashedPassword);
}
```

### JWT Authentication

```typescript
// src/services/jwt.ts
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_EXPIRES_IN = '15m';
const REFRESH_EXPIRES_IN = '7d';

export function generateAccessToken(userId: string): string {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

export function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId, type: 'refresh' }, JWT_SECRET, { 
    expiresIn: REFRESH_EXPIRES_IN 
  });
}

export function verifyToken(token: string): { userId: string } {
  return jwt.verify(token, JWT_SECRET) as { userId: string };
}
```

### Security Headers with Helmet

```typescript
// src/middleware/security.ts
import helmet from 'helmet';
import cors from 'cors';

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:'],
    connectSrc: ["'self'"],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    frameAncestors: ["'none'"],
  },
}));

const allowedOrigins = ['https://app.example.com'];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));
```

### Rate Limiting

```typescript
// src/middleware/rateLimit.ts
import rateLimit from 'express-rate-limit';

// General API rate limit
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { error: 'Too many requests' },
});

// Stricter auth rate limit
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 login attempts per 15 minutes
  skipSuccessfulRequests: true,
});

app.use('/api/', apiLimiter);
app.use('/auth/login', authLimiter);
```

### SQL Injection Prevention

```typescript
// BAD - vulnerable to SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// GOOD - parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);

// Using an ORM (Prisma)
const user = await prisma.user.findUnique({
  where: { id: userId },
});
```

### XSS Prevention

```typescript
// Server-side output encoding
import { escape } from 'html-escaper';

function sanitizeOutput(userInput: string): string {
  return escape(userInput);
}

// React automatically escapes
<div>{userInput}</div>

// When you MUST use HTML, sanitize first
import DOMPurify from 'dompurify';

function safeHTML(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
  });
}
```

### CSRF Protection

```typescript
// src/middleware/csrf.ts
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });

app.get('/api/csrf-token', csrfProtection, (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Protected routes
app.post('/api/data', csrfProtection, (req, res) => {
  // CSRF token validated
});
```

### Secrets from Environment

```typescript
// BAD - hardcoded secret
const apiKey = 'sk-live-abc123xyz';

// GOOD - from environment
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY environment variable not set');
}

// Using dotenv for local development
import 'dotenv/config';

// Validation with zod
const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  API_KEY: z.string().min(1),
});

const env = envSchema.parse(process.env);
```

---

## Integration with Other Reviews

This skill complements:
- `/dependency-security-scan` - For detailed dependency vulnerabilities
- `/secrets-management-review` - For comprehensive secrets audit
- `/api-readiness-review` - For API security patterns
- `/compliance-review` - For data protection compliance
- `/error-resilience-review` - For secure error handling
