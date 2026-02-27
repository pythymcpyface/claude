---
description: Production readiness review for Compliance (GDPR, Data Minimization, Retention). Reviews data protection, privacy controls, consent management, data retention policies, and regulatory compliance. Use PROACTIVELY before production releases, when handling personal data, or implementing data-intensive features.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Compliance Review Command

Run a comprehensive compliance review before production release.

## Purpose

Review code for compliance with data protection regulations to ensure:
- GDPR requirements are met (lawful basis, data subject rights, cross-border transfers)
- Data minimization principles are followed (collect only what's needed)
- Consent is properly obtained and managed
- Data retention policies are defined and enforced
- Data subject rights can be exercised (access, rectification, erasure, portability)
- Third-party data sharing is documented and consented

## The Critical Importance

**Data protection violations carry severe consequences.** GDPR fines can reach €20 million or 4% of global annual revenue, whichever is higher. Beyond fines, breaches damage trust and can lead to lawsuits, regulatory investigations, and reputational harm. Proper compliance protects both users and the organization.

## Workflow

### 1. Load the Compliance Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/compliance-review/SKILL.md
```

### 2. Detect Stack and Data Types

Identify the technology stack and data handling patterns:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null && echo "Stack detected"

# Detect database/ORM (where personal data lives)
grep -r "prisma\|sequelize\|typeorm\|mongoose\|sqlalchemy\|gorm" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Detect user data models
grep -r "interface.*User\|type.*User\|class.*User\|model.*User" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Detect authentication (indicates personal data handling)
grep -r "auth\|login\|register\|signup\|passport\|firebase" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Detect analytics/tracking (data collection)
grep -r "analytics\|segment\|mixpanel\|track\|identify" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -10
```

### 3. Run Compliance Checks

Execute checks for each compliance category:

**GDPR Core:**
```bash
# Find privacy-related documentation
find . -name "*privacy*" -o -name "*consent*" -o -name "*gdpr*" 2>/dev/null | grep -v node_modules | head -10

# Find legal basis documentation
grep -r "legal.*basis\|lawful.*basis\|data.*controller" --include="*.md" --include="*.txt" 2>/dev/null | head -10

# Find DPO contact
grep -r "data.*protection.*officer\|DPO\|privacy.*officer" --include="*.ts" --include="*.js" --include="*.md" 2>/dev/null | head -10
```

**Data Minimization:**
```bash
# Find user data schemas
grep -r "schema\|model.*User\|interface.*User" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -20

# Find form fields
grep -r "input.*name\|field.*required" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find sensitive data fields
grep -rE "ssn|passport|credit.*card|card.*number|tax.*id" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**Consent Management:**
```bash
# Find consent mechanisms
grep -r "consent\|opt-in\|agree.*terms\|cookie.*banner" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | head -20

# Find pre-checked boxes (anti-pattern)
grep -r "checked.*true.*consent\|defaultChecked.*consent" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find consent storage
grep -r "consent.*date\|consent.*timestamp\|consent.*version" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**Data Subject Rights:**
```bash
# Find data export
grep -r "export.*data\|download.*data\|data.*portability" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find data deletion
grep -r "delete.*account\|erase.*data\|forget.*me\|right.*to.*be.*forgotten" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find profile editing
grep -r "update.*profile\|edit.*user\|rectif" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**Data Retention:**
```bash
# Find retention policies
grep -r "retention\|expire\|ttl\|delete.*after" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -20

# Find cleanup jobs
grep -r "cron\|schedule.*delete\|cleanup.*job\|retention.*job" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find soft delete
grep -r "deletedAt\|soft.*delete\|isDeleted" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**Data Security:**
```bash
# Find encryption
grep -r "encrypt\|decrypt\|cipher\|crypto" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find audit logging
grep -r "audit.*log\|access.*log\|log.*access" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find PII masking
grep -r "mask\|redact\|anonymize\|pseudonymize" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**Third-Party Sharing:**
```bash
# Find third-party integrations
grep -r "stripe\|twilio\|mailchimp\|hubspot\|salesforce\|zendesk" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find API data exposure
grep -r "res\.json\|return.*user\|response\.data" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find webhooks
grep -r "webhook\|callback.*external" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Evaluate each category (GDPR Core, Data Minimization, Consent, Subject Rights, Retention, Security, Third-Party)
- Count passed/failed/warn items per category
- Calculate category scores based on weight distribution
- Calculate overall score
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All critical compliance requirements met |
| 70-89 | NEEDS WORK | Minor compliance gaps |
| 50-69 | AT RISK | Significant gaps, high regulatory risk |
| 0-49 | BLOCK | Critical gaps, likely regulatory violations |

**Category Weights:**
- GDPR Core Requirements: 15%
- Data Minimization: 20%
- Consent Management: 20%
- Data Subject Rights: 20%
- Data Retention: 15%
- Data Security: 5%
- Third-Party Sharing: 5%

### 5. Generate Report

Output the formatted report with:
- Executive summary with overall compliance posture
- Overall score and blocking status
- Checklist results (PASS/FAIL/WARN/N/A for each item)
- Gap analysis with specific code examples
- Prioritized recommendations
- Quick reference implementation patterns

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Implement explicit consent mechanism with audit records
2. [CRITICAL] Add account deletion functionality (right to erasure)
3. [CRITICAL] Define and document retention policies
4. [CRITICAL] Disable analytics/tracking until consent obtained
5. [HIGH] Add data export functionality (right to portability)
6. [HIGH] Implement audit logging for personal data access

**Short-term (Within 1 week):**
7. [HIGH] Create SAR (Subject Access Request) process
8. [HIGH] Review and minimize data collection
9. [MEDIUM] Filter API responses to minimum necessary data
10. [MEDIUM] Add consent withdrawal mechanism

**Long-term:**
11. [LOW] Set up automated retention cleanup jobs
12. [LOW] Implement privacy dashboard for users
13. [LOW] Create breach notification procedures
14. [LOW] Schedule regular compliance audits

## Usage

```
/compliance-review
```

## When to Use

- Before any production release handling personal data
- When adding user registration, profiles, or authentication
- When implementing data collection or analytics
- When adding third-party integrations that process user data
- When creating data export or deletion features
- During architecture reviews for data-intensive features
- Before expanding to new markets (different regulations)

## Blocking Conditions

This command will **recommend blocking** production release if:
- No consent mechanism for data processing
- No data deletion capability (right to erasure)
- No retention policy defined
- Pre-checked consent boxes present
- Analytics/tracking without consent
- Excessive data collection without justification

## Integration with Other Commands

Run alongside other production readiness checks:
- `/secrets-management-review` - For securing API keys and credentials
- `/observability-check` - For audit logging and monitoring
- `/api-readiness-review` - For API data exposure
- `/quality-check` - For code quality

## Example Output

```
═══════════════════════════════════════════════════════════════
      COMPLIANCE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: user-management-service
Stack: Node.js/TypeScript with PostgreSQL
Data Types: Email, Name, Phone, Address, Payment Info
Regulations: GDPR, CCPA
Date: 2026-02-27

OVERALL SCORE: 45/100 [BLOCK]

───────────────────────────────────────────────────────────────
              EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Compliance Posture: CRITICAL GAPS
- Consent: No explicit opt-in mechanism
- Data Rights: No deletion or export functionality
- Retention: No policy defined
- Minimization: Excessive data collection

RECOMMENDATION: Address critical gaps before production

═══════════════════════════════════════════════════════════════
```
