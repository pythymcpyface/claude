# Security Checklist

Use this checklist to verify security requirements before merging features. Based on OWASP Top 10 (2021).

---

## How to Use This Checklist

1. **Complete during Phase 6.5: Security Review** of the /feature-dev workflow
2. **Run security gate**: `bash .claude/scripts/security-gate.sh`
3. **Review each category** applicable to your feature
4. **Document exceptions** with security justification
5. **Do not merge** until all HIGH priority items pass

---

## A01:2021 - Broken Access Control

| Check | Status | Notes |
|-------|--------|-------|
| Users can only access their own data | [ ] | |
| Role-based permissions verified server-side | [ ] | |
| API endpoints authorize on every request | [ ] | |
| No direct object references without authorization | [ ] | |
| Missing or insecure access control is prevented | [ ] | |

**Common Issues:**
- Allowing IDOR (Insecure Direct Object Reference) via sequential IDs
- Client-side permission checks only
- Missing authentication on sensitive endpoints
- CORS misconfiguration allowing unauthorized access

---

## A02:2021 - Cryptographic Failures

| Check | Status | Notes |
|-------|--------|-------|
| Sensitive data encrypted at rest | [ ] | |
| Sensitive data encrypted in transit (TLS) | [ ] | |
| Strong algorithms only (no MD5, SHA1) | [ ] | |
| Proper key management (no hardcoded secrets) | [ ] | |
| Passwords hashed with bcrypt/argon2 | [ ] | |

**Common Issues:**
- Storing passwords in plaintext or weak hashes
- Using deprecated cryptographic algorithms
- Hardcoded API keys, secrets, or certificates
- Missing encryption on sensitive PII/PHI

---

## A03:2021 - Injection

| Check | Status | Notes |
|-------|--------|-------|
| All user input is validated | [ ] | |
| Parameterized queries for database access | [ ] | |
| ORM used correctly (no raw SQL concatenation) | [ ] | |
| Output encoding to prevent XSS | [ ] | |
| No `eval()` or similar dynamic code execution | [ ] | |
| No `innerHTML` with user content | [ ] | |

**Common Issues:**
- SQL injection via string concatenation
- XSS via unsanitized user input
- Command injection via shell execution
- LDAP injection, NoSQL injection

---

## A04:2021 - Insecure Design

| Check | Status | Notes |
|-------|--------|-------|
| Threat modeling completed for feature | [ ] | |
| Business logic flows validated | [ ] | |
| Rate limiting implemented | [ ] | |
| Abuse cases considered and mitigated | [ ] | |

**Common Issues:**
- Missing rate limiting allowing brute force
- Business logic vulnerabilities (e.g., coupon stacking)
- Missing anti-automation controls
- Insecure state management

---

## A05:2021 - Security Misconfiguration

| Check | Status | Notes |
|-------|--------|-------|
| Security headers configured (CSP, X-Frame-Options, etc.) | [ ] | |
| Debug mode disabled in production | [ ] | |
| Default credentials changed | [ ] | |
| Unused features/components disabled | [ ] | |
- Error messages don't leak sensitive information | [ ] | |

**Common Issues:**
- Default accounts/credentials unchanged
- Verbose error messages revealing stack traces
- Missing security headers
- Cloud storage buckets publicly accessible
- CORS allowing all origins (`*`)

---

## A06:2021 - Vulnerable and Outdated Components

| Check | Status | Notes |
|-------|--------|-------|
| Dependency audit run (`npm audit`, `pip-audit`, etc.) | [ ] | |
| No known high/critical vulnerabilities | [ ] | |
| Dependencies regularly updated | [ ] | |
- Unused dependencies removed | [ ] | |

**Common Issues:**
- Outdated libraries with known CVEs
- Using components beyond end-of-life
- No dependency auditing process

---

## A07:2021 - Identification and Authentication Failures

| Check | Status | Notes |
|-------|--------|-------|
| Strong password policy enforced | [ ] | |
| Password reset flow secure (tokenized, timed) | [ ] | |
| Session timeout configured appropriately | [ ] | |
- MFA available for sensitive operations | [ ] | |
| No credential exposure in logs or error messages | [ ] | |

**Common Issues:**
- Weak password requirements
- Password reset tokens predictable or not expired
- Session fixation vulnerabilities
- Credential stuffing allowed (no rate limiting)

---

## A08:2021 - Software and Data Integrity Failures

| Check | Status | Notes |
|-------|--------|-------|
| Code signing verified for dependencies | [ ] | |
| CI/CD pipeline secure (no unverified updates) | [ ] | |
- Immutable infrastructure for production | [ ] | |
| Integrity checks for critical data | [ ] | |

**Common Issues:**
- Auto-update without integrity verification
- Supply chain attacks via compromised dependencies
- Insecure CI/CD allowing unauthorized code changes

---

## A09:2021 - Security Logging and Monitoring Failures

| Check | Status | Notes |
|-------|--------|-------|
| Authentication failures logged | [ ] | |
| Authorization failures logged | [ ] | |
| Input validation failures logged | [ ] | |
- Security events generate alerts | [ ] | |
| Logs protected from tampering | [ ] | |

**Common Issues:**
- No logging of security events
- Logs not monitored or actionable
- Insufficient log retention for forensics

---

## A10:2021 - Server-Side Request Forgery (SSRF)

| Check | Status | Notes |
|-------|--------|-------|
| User-supplied URLs validated | [ ] | |
| Network segmentation for external requests | [ ] | |
- denylist for internal IP ranges | [ ] | |
| Response size limited | [ ] | |

**Common Issues:**
- Allowing arbitrary URLs from user input
- No validation of URL schemes
- Accessing internal services via user input

---

## Additional Security Considerations

### File Upload
| Check | Status | Notes |
|-------|--------|-------|
| File type validated (not by extension only) | [ ] | |
| File size limited | [ ] | |
- Executable content not served from upload dir | [ ] | |
| Virus scanning for uploads | [ ] | |

### API Security
| Check | Status | Notes |
|-------|--------|-------|
| Authentication required for sensitive endpoints | [ ] | |
| Rate limiting per user/IP | [ ] | |
- API versioning | [ ] | |
| Input validation schema defined | [ ] | |

### Secrets Management
| Check | Status | Notes |
|-------|--------|-------|
| No secrets in code (use environment variables) | [ ] | |
| Secrets not in git history | [ ] | |
| Secrets rotated regularly | [ ] | |
- .env.example provides template without real values | [ ] | |

---

## Security Test Requirements

### Automated Security Tests
- [ ] Static analysis (SAST) integrated in CI
- [ ] Dependency scanning (SCA) integrated in CI
- [ ] Dynamic analysis (DAST) for critical APIs
- [ ] Secret scanning in pre-commit hooks

### Manual Security Testing
- [ ] Penetration testing for high-risk features
- [ ] Threat modeling completed
- [ ] Error handling reviewed for information leakage
- [ ] Session management tested

---

## Audit Logging Requirements

### Required Security Events to Log
1. **Authentication Events**
   - Successful logins
   - Failed login attempts
   - Password changes
   - MFA changes

2. **Authorization Events**
   - Permission escalations
   - Access denied events
   - Privileged actions

3. **Data Events**
   - Sensitive data access
   - Data exports
   - Configuration changes

4. **System Events**
   - Service starts/stops
   - Configuration changes
   - Security-related errors

### Log Format Requirements
- Timestamp (UTC)
- User ID (when applicable)
- Action performed
- Source IP address
- Outcome (success/failure)
- Correlation ID (for request tracing)

---

## Document Completion

| Item | Status |
|------|--------|
| Security checklist completed | [ ] |
| Security gate (`bash .claude/scripts/security-gate.sh`) passed | [ ] |
| High/Critical issues resolved | [ ] |
| Warnings reviewed and accepted or resolved | [ ] |
| Security documentation updated for feature | [ ] |

---

## References

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)

---

*End of SECURITY-CHECKLIST template*
