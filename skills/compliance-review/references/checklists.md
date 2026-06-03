# compliance-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for compliance-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's technology stack and data handling patterns:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect database/ORM (where personal data is stored)
grep -r "prisma\|sequelize\|typeorm\|mongoose\|sqlalchemy\|gorm\|django" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Detect authentication libraries (user data handling)
grep -r "passport\|auth0\|firebase-auth\|next-auth\|django-allauth\|devise" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.rb" 2>/dev/null | head -10

# Detect analytics/tracking (data collection)
grep -r "analytics\|segment\|mixpanel\|amplitude\|google-analytics\|gtag\|facebook-pixel" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Detect cookie consent libraries
grep -r "cookiebot\|cookieconsent\|onesignal\|termly\|iubenda\|consent" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10
```

### Phase 2: Compliance Checklist

Run all checks and compile results:

#### 1. GDPR Core Requirements

GDPR requires specific protections for personal data of EU residents.

| Check | Pattern | Status |
|-------|---------|--------|
| Lawful basis documented | Each data processing activity has documented legal basis | Required |
| Privacy policy present | Clear privacy policy accessible to users | Required |
| Data processing register | Inventory of all personal data processed | Required |
| DPO designated | Data Protection Officer assigned (if required) | Conditional |
| Cross-border transfer | Safeguards for data transferred outside EU | Required |
| Records of processing | Documentation of processing activities | Required |
| Privacy by design | Privacy considerations in development process | Required |
| DPIA conducted | Data Protection Impact Assessment for high-risk processing | Conditional |

**Search Patterns:**
```bash
# Find privacy-related files
find . -name "*privacy*" -o -name "*consent*" -o -name "*gdpr*" -o -name "*compliance*" 2>/dev/null | grep -v node_modules | head -10

# Find data processing documentation
grep -r "legal.*basis\|lawful.*basis\|processing.*activity\|data.*controller\|data.*processor" --include="*.md" --include="*.txt" 2>/dev/null | head -10

# Find cross-border transfer code
grep -r "transfer\|cross.*border\|adequacy\|standard.*contractual\|scc" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find DPO or privacy contact references
grep -r "data.*protection.*officer\|DPO\|privacy.*officer\|dpo@" --include="*.ts" --include="*.js" --include="*.py" --include="*.md" 2>/dev/null | head -10
```

#### 2. Data Minimization

Collect and retain only the minimum data necessary for the specified purpose.

| Check | Pattern | Status |
|-------|---------|--------|
| Purpose limitation | Data collected only for specified, explicit purposes | Required |
| Data minimization | Only necessary data collected | Required |
| No excessive collection | Avoid collecting data "just in case" | Required |
| Field-level justification | Each form field justified by purpose | Recommended |
| Optional vs required fields | Non-essential fields are optional | Required |
| Default to minimal | Forms default to minimal data collection | Recommended |

**Search Patterns:**
```bash
# Find user data models/schemas
grep -r "schema\|model\|interface.*User\|type.*User" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | grep -i "user\|profile\|person" | head -20

# Find form/input fields (potential data collection)
grep -r "input.*name\|field.*name\|column\|attribute" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find sensitive data fields
grep -rE "ssn|social.*security|passport|national.*id|tax.*id|credit.*card|card.*number|cvv|bank.*account" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find "required" field definitions
grep -r "required.*true\|nullable.*false\|allowNull.*false" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find analytics/tracking data collection
grep -r "track\|identify\|page\|event\|properties" --include="*.ts" --include="*.js" 2>/dev/null | grep -v node_modules | head -15
```

#### 3. Consent Management

Valid consent must be freely given, specific, informed, and unambiguous.

| Check | Pattern | Status |
|-------|---------|--------|
| Explicit consent | Clear opt-in for data processing | Required |
| Granular consent | Separate consent for different purposes | Required |
| Easy withdrawal | Users can easily withdraw consent | Required |
| Consent records | Audit trail of consent given | Required |
| Pre-ticked boxes prohibited | No pre-checked consent boxes | Required |
| Consent before processing | Consent obtained before data collection | Required |
| Age verification | Parental consent for minors (under 16/13) | Conditional |

**Search Patterns:**
```bash
# Find consent-related code
grep -r "consent\|opt-in\|opt.*in\|agree\|accept.*terms\|cookie.*consent" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20

# Find consent checkboxes
grep -r "checkbox.*consent\|consent.*checkbox\|type.*checkbox.*consent\|checked.*consent" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10

# Find consent withdrawal
grep -r "withdraw.*consent\|revoke.*consent\|opt.*out\|unsubscribe\|delete.*consent" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find consent storage/records
grep -r "consent.*date\|consent.*timestamp\|consent.*version\|consent.*ip" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find age verification
grep -r "age.*verif\|date.*birth\|dob\|isMinor\|under.*age\|parental.*consent" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

#### 4. Data Subject Rights

Individuals have rights to access, rectify, erase, and port their data.

| Check | Pattern | Status |
|-------|---------|--------|
| Right to access | Users can request their data | Required |
| Right to rectification | Users can correct their data | Required |
| Right to erasure | Users can request deletion ("right to be forgotten") | Required |
| Right to portability | Users can export their data | Required |
| Right to restrict | Users can limit processing | Required |
| Right to object | Users can object to certain processing | Required |
| Response within 30 days | Requests fulfilled within legal timeframe | Required |
| Identity verification | Requestor identity verified before fulfilling | Required |

**Search Patterns:**
```bash
# Find data export functionality
grep -r "export.*data\|download.*data\|gdpr.*export\|data.*portability\|user.*export" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find data deletion functionality
grep -r "delete.*account\|erase.*data\|forget.*me\|right.*to.*be.*forgotten\|gdpr.*delete\|purge.*user" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find data access/request handling
grep -r "subject.*access\|sar\|data.*request\|access.*request\|gdpr.*request" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find user profile edit functionality
grep -r "update.*profile\|edit.*user\|rectif\|correct.*data" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find identity verification in data requests
grep -r "verify.*identity\|confirm.*identity\|authenticate.*request" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

#### 5. Data Retention Policies

Personal data must not be kept longer than necessary.

| Check | Pattern | Status |
|-------|---------|--------|
| Retention periods defined | Clear retention periods for each data type | Required |
| Automated deletion | Data automatically deleted after retention period | Required |
| Retention documentation | Policies documented and accessible | Required |
| Legal hold capability | Ability to preserve data for legal proceedings | Recommended |
| Backup retention aligned | Backups follow same retention rules | Required |
| Anonymization option | Data anonymized instead of deleted when possible | Recommended |
| Archive before deletion | Option to archive instead of delete | Recommended |

**Search Patterns:**
```bash
# Find retention-related code
grep -r "retention\|expire\|ttl\|lifetime\|purge\|archive\|delete.*after" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find scheduled cleanup jobs
grep -r "cron\|schedule\|job.*delete\|cleanup\|purge.*job\|retention.*job" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find retention configuration
grep -r "retention.*days\|retention.*months\|retention.*years\|keep.*for\|delete.*after.*days" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env*" 2>/dev/null | head -10

# Find database TTL/index configurations
grep -r "expireAfterSeconds\|TTL\|expireAt\|expiresAt" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find soft delete patterns
grep -r "deleted.*at\|soft.*delete\|isDeleted\|deletedAt" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

#### 6. Data Security & Protection

Personal data must be protected with appropriate security measures.

| Check | Pattern | Status |
|-------|---------|--------|
| Encryption at rest | Personal data encrypted in storage | Required |
| Encryption in transit | Data transmitted over TLS/HTTPS | Required |
| Access controls | Role-based access to personal data | Required |
| Audit logging | Access to personal data logged | Required |
| Pseudonymization | Identifiers replaced with pseudonyms where possible | Recommended |
| Data masking | Sensitive data masked in logs/displays | Required |
| Breach notification | Process for notifying authorities within 72 hours | Required |

**Search Patterns:**
```bash
# Find encryption usage
grep -r "encrypt\|decrypt\|cipher\|crypto\|aes\|rsa" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find PII masking/sanitization
grep -r "mask\|redact\|sanitize\|anonymize\|pseudonymize\|hash.*email\|hash.*phone" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find access control/authorization
grep -r "canAccess\|hasPermission\|isAuthorized\|role.*check\|authorize" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find audit logging
grep -r "audit.*log\|access.*log\|data.*access.*log\|log.*access" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find HTTPS/TLS configuration
grep -r "https\|tls\|ssl\|secure.*true" --include="*.ts" --include="*.js" --include="*.py" --include="*.yaml" 2>/dev/null | head -10

# Find breach notification
grep -r "breach\|notify.*authority\|72.*hour\|incident.*report" --include="*.ts" --include="*.js" --include="*.py" --include="*.md" 2>/dev/null | head -10
```

#### 7. Third-Party Data Sharing

Controls for data shared with external parties.

| Check | Pattern | Status |
|-------|---------|--------|
| Data processing agreements | DPAs in place with all processors | Required |
| Third-party inventory | List of all third parties receiving data | Required |
| Data sharing consent | User consent for third-party sharing | Required |
| Sub-processor notification | Users informed of sub-processors | Required |
| API data minimization | APIs expose only necessary personal data | Required |
| Webhook data filtering | Webhooks filter sensitive data | Required |

**Search Patterns:**
```bash
# Find third-party integrations
grep -r "stripe\|twilio\|sendgrid\|mailchimp\|hubspot\|salesforce\|zendesk\|intercom\|mixpanel\|segment" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find API responses with personal data
grep -r "res\.json\|response\.json\|return.*user\|return.*profile" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find webhook payloads
grep -r "webhook\|callback\|notify.*external\|push.*to" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find data sharing configuration
grep -r "share.*data\|third.*party\|external.*service\|partner" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env*" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific compliance gap
2. **Why it matters**: Legal/regulatory impact and risk
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      COMPLIANCE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Data Types: [personal data types identified]
Regulations: GDPR, CCPA, [others as applicable]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

GDPR CORE REQUIREMENTS
  [FAIL] No documented lawful basis for data processing
  [WARN] Privacy policy exists but not versioned
  [FAIL] No data processing register found
  [N/A]  DPO designated (not required - under threshold)
  [WARN] Cross-border transfer safeguards unclear

DATA MINIMIZATION
  [PASS] Purpose limitation in privacy policy
  [WARN] Excessive fields in user registration
  [FAIL] Analytics tracking all pages without consent
  [PASS] Optional fields marked as optional
  [WARN] Full name collected when first name sufficient

CONSENT MANAGEMENT
  [FAIL] No explicit consent mechanism
  [FAIL] Newsletter checkbox pre-checked
  [WARN] Consent records not stored
  [N/A]  Age verification (no minors expected)
  [FAIL] No consent withdrawal mechanism

DATA SUBJECT RIGHTS
  [FAIL] No data export functionality
  [FAIL] No account deletion functionality
  [PASS] User profile editable
  [WARN] No SAR (Subject Access Request) process
  [FAIL] No identity verification for data requests

DATA RETENTION
  [FAIL] No retention periods defined
  [FAIL] No automated data deletion
  [N/A]  Retention documentation (no policy)
  [WARN] Soft delete without hard delete schedule
  [FAIL] Backups kept indefinitely

DATA SECURITY
  [PASS] TLS enabled for all connections
  [WARN] PII not encrypted at rest
  [PASS] Role-based access control implemented
  [FAIL] No audit logging for data access
  [PASS] Password hashing with bcrypt

THIRD-PARTY SHARING
  [WARN] Stripe integration - DPA status unknown
  [FAIL] Analytics tracking without consent
  [WARN] API returns excessive personal data
  [PASS] Webhooks filter sensitive fields

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Explicit Consent Mechanism
  Impact: Unlawful data processing, GDPR fines up to 4% revenue
  Fix: Implement explicit opt-in consent before any data collection
  File: src/components/RegistrationForm.tsx

  // BEFORE (non-compliant):
  <form onSubmit={handleSubmit}>
    <input name="email" />
    <input name="name" />
    <button>Sign Up</button>
  </form>

  // AFTER (compliant):
  <form onSubmit={handleSubmit}>
    <input name="email" required />
    <input name="name" required />

    <label>
      <input
        type="checkbox"
        name="consent"
        required
        checked={consent}
        onChange={(e) => setConsent(e.target.checked)}
      />
      I agree to the <a href="/privacy">Privacy Policy</a> and
      consent to processing of my personal data.
    </label>

    <button disabled={!consent}>Sign Up</button>
  </form>

  // Store consent record
  await db.consents.create({
    userId: user.id,
    type: 'registration',
    version: PRIVACY_POLICY_VERSION,
    timestamp: new Date(),
    ipAddress: req.ip,
    userAgent: req.headers['user-agent']
  });

[CRITICAL] No Account Deletion Functionality
  Impact: Violates right to erasure, GDPR non-compliance
  Fix: Implement account deletion with data cleanup
  File: src/services/user.service.ts

  async function deleteUserData(userId: string) {
    const user = await db.users.findById(userId);
    if (!user) throw new NotFoundError('User not found');

    // Verify identity (should be done before calling this)
    // Anonymize references in other records
    await db.orders.updateMany(
      { userId },
      { $set: { userId: null, customerEmail: anonymizeEmail(user.email) } }
    );

    // Delete personal data
    await db.profiles.deleteOne({ userId });
    await db.sessions.deleteMany({ userId });
    await db.consents.deleteMany({ userId });

    // Soft delete with scheduled hard delete
    await db.users.updateOne(
      { _id: userId },
      {
        $set: {
          deletedAt: new Date(),
          email: `deleted_${userId}@anonymized.example.com`,
          name: '[Deleted User]',
          deletionScheduledAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
        }
      }
    );

    // Log for audit
    await auditLog('user.deletion_requested', { userId, requestedBy: userId });

    return { success: true, message: 'Account scheduled for deletion' };
  }

[CRITICAL] No Retention Policy Defined
  Impact: Indefinite data retention violates storage limitation principle
  Fix: Define and implement retention periods
  File: config/retention.yaml (create)

  retention_periods:
    user_accounts:
      active: indefinite
      deleted: 30_days
      inactive: 3_years

    personal_data:
      email: duration_of_account_plus_30_days
      name: duration_of_account_plus_30_days
      payment_info: 7_years # Legal requirement

    logs:
      access_logs: 90_days
      audit_logs: 7_years
      error_logs: 30_days

    backups:
      daily: 30_days
      weekly: 12_weeks
      monthly: 12_months

  File: src/jobs/retentionCleanup.ts (create)

  import cron from 'node-cron';

  // Run daily at 2 AM
  cron.schedule('0 2 * * *', async () => {
    logger.info('Starting retention cleanup job');

    // Hard delete soft-deleted accounts past retention
    const deletedUsers = await db.users.deleteMany({
      deletedAt: { $lte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
    });
    logger.info(`Hard deleted ${deletedUsers.count} users`);

    // Delete old access logs
    const deletedLogs = await db.accessLogs.deleteMany({
      timestamp: { $lte: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000) }
    });
    logger.info(`Deleted ${deletedLogs.count} old access logs`);
  });

[HIGH] Excessive Fields in Registration
  Impact: Violates data minimization principle
  Fix: Remove unnecessary fields or make them optional
  File: src/components/RegistrationForm.tsx

  // BEFORE (excessive collection):
  const fields = ['email', 'password', 'firstName', 'lastName', 'phone',
                  'address', 'city', 'country', 'company', 'jobTitle'];

  // AFTER (minimized):
  const requiredFields = ['email', 'password'];
  const optionalFields = ['firstName']; // Only if needed for personalization

  // Collect additional data only when needed:
  // - Address: at checkout
  // - Phone: for 2FA setup (optional)
  // - Company: for B2B features (optional)

[HIGH] No Audit Logging for Data Access
  Impact: Cannot demonstrate compliance, no breach detection capability
  Fix: Implement audit logging for personal data access
  File: src/middleware/auditLog.ts

  export function auditPersonalDataAccess(req, res, next) {
    const originalJson = res.json.bind(res);

    res.json = (data) => {
      // Log access to personal data
      if (containsPersonalData(data)) {
        auditLogger.log('data.access', {
          userId: req.user?.id,
          resource: req.path,
          method: req.method,
          dataType: identifyDataTypes(data),
          timestamp: new Date(),
          ipAddress: req.ip
        });
      }

      return originalJson(data);
    };

    next();
  }

[MEDIUM] API Returns Excessive Personal Data
  Impact: Over-exposure of personal data, data minimization violation
  Fix: Filter API responses to minimum necessary
  File: src/api/users/controller.ts

  // BEFORE (over-exposure):
  async function getUser(req, res) {
    const user = await db.users.findById(req.params.id);
    res.json(user); // Returns all fields including internal data
  }

  // AFTER (filtered):
  const USER_PUBLIC_FIELDS = ['id', 'name', 'avatarUrl'];
  const USER_PROFILE_FIELDS = ['id', 'name', 'email', 'avatarUrl', 'createdAt'];

  async function getUser(req, res) {
    const user = await db.users.findById(req.params.id);

    // Return only public fields for other users
    if (req.user?.id !== user.id) {
      return res.json(pick(user, USER_PUBLIC_FIELDS));
    }

    // Return profile fields for own data
    return res.json(pick(user, USER_PROFILE_FIELDS));
  }

[MEDIUM] Analytics Tracking Without Consent
  Impact: Unlawful tracking, GDPR violation
  Fix: Implement consent-based analytics
  File: src/lib/analytics.ts

  let analyticsConsent = false;

  export function setAnalyticsConsent(consent: boolean) {
    analyticsConsent = consent;

    if (consent) {
      // Initialize analytics only after consent
      initializeAnalytics();
    } else {
      // Disable analytics
      disableAnalytics();
    }
  }

  export function track(event: string, properties?: object) {
    if (!analyticsConsent) {
      return; // Don't track without consent
    }

    analytics.track(event, {
      ...properties,
      // Remove PII from tracking
      email: undefined,
      name: undefined,
      phone: undefined
    });
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement explicit consent mechanism with records
2. [CRITICAL] Add account deletion (right to erasure)
3. [CRITICAL] Define and document retention policies
4. [CRITICAL] Disable analytics until consent obtained
5. [HIGH] Add data export functionality (portability)
6. [HIGH] Implement audit logging for data access
7. [HIGH] Review and minimize data collection
8. [HIGH] Add SAR (Subject Access Request) process

After Production:
1. Set up retention cleanup jobs
2. Implement automated consent versioning
3. Add privacy dashboard for users
4. Set up compliance monitoring dashboards
5. Create breach notification procedures
6. Schedule regular compliance audits
7. Train team on data protection

═══════════════════════════════════════════════════════════════
```

---

