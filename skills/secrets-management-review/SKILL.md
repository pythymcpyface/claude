---
name: secrets-management-review
description: Production readiness review for Secrets Management. Reviews 12-Factor compliance, vault integration, environment variable security, secret rotation, and secrets storage. Use PROACTIVELY before production releases, when setting up CI/CD pipelines, or configuring external service integrations.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Secrets Management Review Skill

Production readiness code review focused on Secrets Management & Configuration Security. Ensures code is ready for production with proper 12-Factor app compliance, vault integration, environment variable security, secret rotation capabilities, and secure storage practices.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "secret", "credential", "api key", "token", "password", "vault", "env", "environment", "config"
- New external service integrations (AWS, Stripe, Twilio, SendGrid, etc.)
- CI/CD pipeline configuration changes
- Docker/kubernetes configuration files added/modified
- Authentication or authorization code changes
- Database connection configuration
- New environment variables introduced
- Before major version releases involving external dependencies

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's technology stack and secret management patterns:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect secret management libraries
grep -r "vault\|dotenv\|config\|secrets\|credentials" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10

# Detect cloud provider SDKs (common secret sources)
grep -r "aws-sdk\|@aws-sdk\|google-cloud\|azure-sdk\|@azure" package.json requirements.txt go.mod 2>/dev/null

# Detect vault clients
grep -r "node-vault\|hvac\|vault-client\|spring-cloud-vault" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10

# Detect secret scanning tools
grep -r "git-secrets\|detect-secrets\|trufflehog\|gitleaks" .pre-commit-config.yaml 2>/dev/null
```

### Phase 2: Secrets Management Checklist

Run all checks and compile results:

#### 1. 12-Factor App Compliance

The 12-Factor methodology requires strict separation of config from code.

| Check | Pattern | Status |
|-------|---------|--------|
| Config in environment | Secrets stored in env vars, not code | Required |
| No hardcoded secrets | No API keys, passwords, tokens in source | Critical |
| Environment parity | Same code across environments, different env vars | Required |
| Env var validation | Required env vars validated at startup | Required |
| Default values | Safe defaults for non-critical config only | Recommended |
| Config documentation | All env vars documented with purpose | Required |

**Search Patterns:**
```bash
# Find hardcoded secrets (common patterns)
grep -rE "(api[_-]?key|apikey|secret[_-]?key|secretkey|password|passwd|token|auth[_-]?token)[\"']?\s*[:=]\s*[\"'][^\"']{8,}[\"']" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find AWS keys in code
grep -rE "AKIA[0-9A-Z]{16}" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find generic secret patterns
grep -rE "-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----" --include="*" 2>/dev/null | head -10

# Find connection strings with credentials
grep -rE "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find process.env usage
grep -r "process\.env\|os\.environ\|os\.getenv\|System\.getenv\|viper\.Get" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -30

# Find .env files (should be in .gitignore)
find . -name ".env*" -not -path "./node_modules/*" 2>/dev/null | head -10

# Check if .env files are gitignored
grep -r "^\.env" .gitignore 2>/dev/null
```

#### 2. Vault Integration & External Secret Stores

External secret stores provide centralized, auditable secret management.

| Check | Pattern | Status |
|-------|---------|--------|
| Vault integration | HashiCorp Vault, AWS Secrets Manager, or similar | Required (prod) |
| Secret injection | Secrets injected at runtime, not build time | Required |
| Secret caching | Appropriate caching with TTL | Recommended |
| Lease/renewal | Secret leases renewed before expiry | Required |
| Audit logging | Secret access logged and auditable | Required |
| Secret versioning | Ability to rollback secrets | Recommended |
| IAM/role-based access | Least privilege access to secrets | Required |

**Search Patterns:**
```bash
# Find vault client imports
grep -r "node-vault\|hvac\|vault\|HashiCorp" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find AWS Secrets Manager usage
grep -r "SecretsManager\|GetSecretValue\|secretsmanager" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find GCP Secret Manager usage
grep -r "SecretManagerServiceClient\|secretmanager\|SecretVersion" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find Azure Key Vault usage
grep -r "KeyVault\|SecretClient\|azure.*keyvault" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find Kubernetes secrets mounting
grep -r "secretKeyRef\|valueFrom.*secret" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10

# Find secret configuration
grep -r "vault.*url\|vault.*addr\|VAULT_ADDR\|VAULT_TOKEN" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.yaml" 2>/dev/null | head -10
```

#### 3. Environment Variable Security

Environment variables must be handled securely throughout the application.

| Check | Pattern | Status |
|-------|---------|--------|
| No secrets in logs | Secrets never logged or printed | Critical |
| No secrets in error messages | Errors don't expose secrets | Required |
| No secrets in stack traces | Stack traces sanitized | Required |
| No secrets in debug output | Debug mode doesn't leak secrets | Required |
| Env var encryption at rest | Secrets encrypted when persisted | Recommended |
| Env var in process list | Secrets not visible in process list | Recommended |
| No secrets in client-side code | Frontend code has no secrets | Critical |

**Search Patterns:**
```bash
# Find potential secret logging
grep -r "console\.log.*env\|logger\..*env\|print.*environ\|log\.Info.*env\|fmt\.Print.*env" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find secrets in error handling
grep -rE "throw.*env|raise.*env|error.*password|error.*secret|error.*token" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find JSON serialization of env
grep -r "JSON\.stringify.*process\.env\|json\.dumps.*environ" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find frontend secret exposure
grep -rE "process\.env\.(API_KEY|SECRET|PASSWORD|TOKEN|PRIVATE)" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -10

# Find NEXT_PUBLIC_ patterns (Next.js)
grep -r "NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*PASSWORD\|NEXT_PUBLIC_.*TOKEN" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | head -10
```

#### 4. Secret Rotation & Lifecycle

Secrets must be rotated regularly and have clear lifecycle management.

| Check | Pattern | Status |
|-------|---------|--------|
| Rotation policy | Secrets rotated on schedule | Required |
| Rotation automation | Automated rotation for supported services | Recommended |
| Graceful rotation | App handles secret changes without restart | Required |
| Old secret revocation | Old secrets revoked after rotation | Required |
| Rotation monitoring | Alerts for failed rotations | Required |
| Emergency rotation | Process for immediate rotation | Required |

**Search Patterns:**
```bash
# Find rotation-related code
grep -r "rotate\|rotation\|renew\|refresh.*secret\|secret.*refresh" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find secret expiry checks
grep -r "expire\|expiry\|ttl\|lease.*duration\|lease.*ttl" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find secret update/reload mechanisms
grep -r "reload.*config\|update.*secret\|watch.*secret\|onChange.*secret" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 5. Secret Storage & Transmission

Secrets must be encrypted at rest and in transit.

| Check | Pattern | Status |
|-------|---------|--------|
| TLS for secret transmission | Secrets sent over HTTPS/TLS only | Required |
| Encrypted at rest | Secrets encrypted in databases/storage | Required |
| No secrets in version control | .env files, credentials not in git | Critical |
| No secrets in container images | Secrets not baked into Docker images | Required |
| No secrets in build logs | CI/CD logs don't expose secrets | Required |
| Secure memory handling | Secrets cleared from memory after use | Recommended |

**Search Patterns:**
```bash
# Check gitignore for sensitive files
cat .gitignore 2>/dev/null | grep -E "^\.env|^.*\.pem|^.*\.key|^credentials|^secrets"

# Find potential secrets in Docker files
grep -rE "ENV.*PASSWORD|ENV.*SECRET|ENV.*KEY|ENV.*TOKEN" --include="Dockerfile*" 2>/dev/null | head -10

# Find secrets in docker-compose
grep -rE "environment:.*=.*[^$]" --include="docker-compose*.yml" --include="docker-compose*.yaml" 2>/dev/null | head -10

# Find hardcoded secrets in CI/CD configs
grep -rE "password:|secret:|api_key:|token:" --include="*.yml" --include="*.yaml" .github .gitlab-ci.yml .circleci 2>/dev/null | head -10

# Find unencrypted secret files
find . -name "*.pem" -o -name "*.key" -o -name "*credentials*" -o -name "*secrets*" 2>/dev/null | grep -v node_modules | head -10

# Check for HTTP URLs in config (should be HTTPS for secrets)
grep -rE "http://.*(vault|secrets|auth|login)" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env*" 2>/dev/null | head -10
```

#### 6. Dependency & Third-Party Secrets

Third-party integrations often introduce secret management challenges.

| Check | Pattern | Status |
|-------|---------|--------|
| Third-party secrets isolated | Each service has unique credentials | Required |
| API key restrictions | Keys restricted by IP, domain, or scope | Required |
| Webhook secrets validated | HMAC signatures verified | Required |
| OAuth tokens secured | Tokens stored securely, refreshed properly | Required |
| Service account keys rotated | Service account credentials rotated | Required |
| Third-party access audited | Regular review of external access | Recommended |

**Search Patterns:**
```bash
# Find third-party API configurations
grep -r "stripe\|twilio\|sendgrid\|mailgun\|slack\|github.*token\|gitlab.*token" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find webhook secret validation
grep -r "webhook.*secret\|signature.*verify\|hmac.*verify\|X-Hub-Signature\|X-Slack-Signature" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find OAuth implementations
grep -r "oauth\|OAuth\|access_token\|refresh_token\|client_secret" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find service account usage
grep -r "service_account\|serviceAccount\|client_email\|private_key" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific secrets management gap
2. **Why it matters**: Impact on security and compliance
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      SECRETS MANAGEMENT PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Secret Store: [Vault/AWS Secrets Manager/None detected]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

12-FACTOR COMPLIANCE
  [PASS] Config in environment variables
  [FAIL] Hardcoded API key found in src/services/api.ts
  [PASS] Environment parity (same code, different env)
  [WARN] Missing env var validation at startup
  [FAIL] No environment variable documentation

VAULT INTEGRATION
  [FAIL] No vault integration detected
  [N/A]  Secret injection (depends on vault)
  [N/A]  Secret caching (depends on vault)
  [N/A]  Lease/renewal (depends on vault)

ENV VAR SECURITY
  [PASS] No secrets in logs
  [WARN] Potential secret in error message (stack trace)
  [PASS] No secrets in client-side code
  [FAIL] NEXT_PUBLIC_ prefixed secrets detected

SECRET ROTATION
  [FAIL] No rotation policy defined
  [N/A]  Rotation automation (no vault)
  [FAIL] No graceful secret reload
  [FAIL] No emergency rotation process

SECRET STORAGE
  [PASS] .env files in .gitignore
  [FAIL] Secrets in Dockerfile ENV
  [PASS] TLS enabled for external calls
  [WARN] Potential secrets in docker-compose.yml

THIRD-PARTY SECRETS
  [WARN] Stripe key has no IP restrictions
  [PASS] Webhook signatures validated
  [FAIL] Service account key not rotated

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Hardcoded API Key in Source Code
  Impact: Secret exposure through code repository access
  Fix: Move to environment variable and rotate immediately
  File: src/services/api.ts:42

  // BEFORE (critical vulnerability):
  const API_KEY = 'sk_live_abc123...';

  // AFTER (secure):
  const API_KEY = process.env.API_KEY;
  if (!API_KEY) {
    throw new Error('API_KEY environment variable is required');
  }

[CRITICAL] NEXT_PUBLIC_ Prefixed Secrets
  Impact: Secrets exposed to browser/client-side code
  Fix: Use server-side API routes for secret access
  File: .env.production

  # BEFORE (exposed to client):
  NEXT_PUBLIC_STRIPE_SECRET_KEY=sk_live_...

  # AFTER (server-side only):
  STRIPE_SECRET_KEY=sk_live_...

[CRITICAL] Secrets in Dockerfile
  Impact: Secrets baked into container images, visible in image history
  Fix: Use runtime secret injection via environment or vault
  File: Dockerfile:15

  # BEFORE (insecure):
  ENV DATABASE_PASSWORD=supersecret

  # AFTER (secure):
  # Database password passed via environment at runtime
  # docker run -e DATABASE_PASSWORD=xxx myapp

[HIGH] No Vault Integration
  Impact: Manual secret management, no audit trail, difficult rotation
  Fix: Integrate HashiCorp Vault or cloud secret manager
  Priority: Required for production

  // TypeScript example with AWS Secrets Manager
  import { SecretsManager } from '@aws-sdk/client-secrets-manager';

  const secretsManager = new SecretsManager({});

  async function getSecret(secretId: string): Promise<string> {
    const response = await secretsManager.getSecretValue({
      SecretId: secretId
    });
    return response.SecretString;
  }

  // Usage
  const dbPassword = await getSecret('prod/database/password');

[HIGH] No Environment Variable Validation
  Impact: App fails silently or with cryptic errors when env vars missing
  Fix: Validate required env vars at startup
  File: src/config/index.ts

  import { z } from 'zod';

  const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']),
    DATABASE_URL: z.string().url(),
    API_KEY: z.string().min(32),
    JWT_SECRET: z.string().min(64),
  });

  export const env = envSchema.parse(process.env);

[HIGH] No Secret Rotation Policy
  Impact: Compromised secrets remain valid indefinitely
  Fix: Implement rotation schedule and automation
  File: docs/secrets-rotation.md (create)

  # Secret Rotation Schedule
  - Database passwords: Every 90 days
  - API keys: Every 180 days
  - JWT secrets: Every 365 days
  - Service account keys: Every 90 days
  - OAuth tokens: Automatic refresh

[MEDIUM] Stripe Key Without IP Restrictions
  Impact: Key can be used from any IP if compromised
  Fix: Add IP restrictions in Stripe dashboard
  Action: Stripe Dashboard > Developers > API Keys > Edit > IP Restrictions

[MEDIUM] No Graceful Secret Reload
  Impact: App requires restart when secrets change
  Fix: Implement secret watching and hot reload
  File: src/config/secrets.ts

  // Watch for secret changes (with Vault)
  vault.watch('secret/data/app', (data) => {
    logger.info('Secret updated, reloading configuration');
    updateConfig(data);
  });

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Remove all hardcoded secrets from source code
2. [CRITICAL] Rotate any exposed secrets immediately
3. [CRITICAL] Remove NEXT_PUBLIC_ prefix from secrets
4. [CRITICAL] Remove secrets from Dockerfiles
5. [HIGH] Integrate vault or cloud secret manager
6. [HIGH] Add environment variable validation at startup
7. [HIGH] Document all environment variables
8. [HIGH] Create secret rotation policy

After Production:
1. Set up secret scanning in CI/CD (git-secrets, trufflehog)
2. Implement automated secret rotation
3. Add secret access audit logging
4. Configure IP restrictions for third-party API keys
5. Create emergency rotation runbook
6. Set up secret expiry monitoring and alerts

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
| 12-Factor Compliance | 25% |
| Vault Integration | 20% |
| Env Var Security | 20% |
| Secret Rotation | 15% |
| Secret Storage | 15% |
| Third-Party Secrets | 5% |

---

## Quick Reference: Implementation Patterns

### Environment Variable Validation (TypeScript with Zod)

```typescript
import { z } from 'zod';

const envSchema = z.object({
  // Required
  NODE_ENV: z.enum(['development', 'test', 'production']),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(64),
  ENCRYPTION_KEY: z.string().length(32),

  // Optional with defaults
  PORT: z.string().regex(/^\d+$/).default('3000'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  // Feature flags
  ENABLE_METRICS: z.string().transform(v => v === 'true').default('false'),
});

export type Env = z.infer<typeof envSchema>;

// Validate at startup - throws if invalid
export const env: Env = envSchema.parse(process.env);

// Usage
const dbUrl = env.DATABASE_URL; // Type-safe access
```

### HashiCorp Vault Integration (TypeScript)

```typescript
import Vault from 'node-vault';
import logger from './logger';

const vault = Vault({
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,
});

interface SecretCache {
  [key: string]: { value: any; expires: number };
}

const cache: SecretCache = {};
const CACHE_TTL = 300000; // 5 minutes

export async function getSecret<T = any>(path: string): Promise<T> {
  const cached = cache[path];
  if (cached && cached.expires > Date.now()) {
    return cached.value;
  }

  try {
    const result = await vault.read(path);
    const value = result.data;

    cache[path] = {
      value,
      expires: Date.now() + CACHE_TTL,
    };

    return value;
  } catch (error) {
    logger.error('Failed to fetch secret from Vault', { path, error });
    throw new Error(`Secret not found: ${path}`);
  }
}

export async function getDatabaseCredentials() {
  const secret = await getSecret<{ username: string; password: string }>(
    'secret/data/database/credentials'
  );
  return {
    username: secret.username,
    password: secret.password,
  };
}

// Lease renewal for dynamic secrets
export async function renewLease(leaseId: string) {
  await vault.write(`sys/leases/renew`, {
    lease_id: leaseId,
    increment: 3600, // 1 hour
  });
}
```

### AWS Secrets Manager (TypeScript)

```typescript
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';
import logger from './logger';

const client = new SecretsManagerClient({});

interface SecretCache {
  [key: string]: { value: any; expires: number };
}

const cache: SecretCache = {};

export async function getSecret<T = any>(secretId: string): Promise<T> {
  const cached = cache[secretId];
  if (cached && cached.expires > Date.now()) {
    return cached.value;
  }

  try {
    const command = new GetSecretValueCommand({ SecretId: secretId });
    const response = await client.send(command);

    const value = JSON.parse(response.SecretString);

    cache[secretId] = {
      value,
      expires: Date.now() + 300000, // 5 minutes
    };

    return value;
  } catch (error) {
    logger.error('Failed to fetch secret from AWS', { secretId, error });
    throw error;
  }
}

// Usage
const dbCredentials = await getSecret<{ username: string; password: string }>(
  'prod/database/credentials'
);
```

### Kubernetes Secrets (YAML)

```yaml
# secret.yaml - Reference only, do not commit with real values
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgresql://..."
  JWT_SECRET: "..."
  API_KEY: "..."

---
# deployment.yaml - Mount secrets as environment variables
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        - name: app
          image: myapp:latest
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: DATABASE_URL
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: JWT_SECRET

---
# External Secrets Operator (recommended for production)
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: app-secrets
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: secret/data/app
        property: database_url
```

### Docker Runtime Secret Injection

```dockerfile
# Dockerfile - No secrets!
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
# No ENV for secrets!
CMD ["node", "dist/index.js"]
```

```bash
# Run with secrets via environment
docker run -d \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e JWT_SECRET="${JWT_SECRET}" \
  -e API_KEY="${API_KEY}" \
  myapp:latest

# Or with Docker Secrets (Swarm)
docker service create \
  --secret database_url \
  --secret jwt_secret \
  myapp:latest
```

### Webhook Signature Verification

```typescript
import crypto from 'crypto';

export function verifyStripeWebhook(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const elements = signature.split(',');
  const timestamp = elements.find(e => e.startsWith('t='))?.slice(2);
  const v1 = elements.find(e => e.startsWith('v1='))?.slice(3);

  if (!timestamp || !v1) return false;

  // Prevent replay attacks (5 minute window)
  const now = Math.floor(Date.now() / 1000);
  if (now - parseInt(timestamp) > 300) return false;

  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(`${timestamp}.${payload}`)
    .digest('hex');

  return crypto.timingSafeEqual(
    Buffer.from(v1),
    Buffer.from(expectedSignature)
  );
}

// Usage
app.post('/webhooks/stripe', (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  const payload = JSON.stringify(req.body);

  if (!verifyStripeWebhook(payload, sig, process.env.STRIPE_WEBHOOK_SECRET)) {
    return res.status(400).json({ error: 'Invalid signature' });
  }

  // Process webhook
});
```

### Secret Rotation Handler

```typescript
import { SecretsManager } from '@aws-sdk/client-secrets-manager';
import logger from './logger';

const secretsManager = new SecretsManager({});

let currentCredentials: { username: string; password: string };
let rotationInProgress = false;

export async function initializeCredentials() {
  currentCredentials = await fetchCredentials();

  // Poll for changes every minute
  setInterval(checkForRotation, 60000);
}

async function fetchCredentials() {
  const response = await secretsManager.getSecretValue({
    SecretId: 'prod/database/credentials',
  });
  return JSON.parse(response.SecretString);
}

async function checkForRotation() {
  if (rotationInProgress) return;

  try {
    const newCredentials = await fetchCredentials();

    if (newCredentials.password !== currentCredentials.password) {
      rotationInProgress = true;
      logger.info('Secret rotation detected, updating connections');

      // Gracefully update connections
      await updateDatabaseConnections(newCredentials);
      currentCredentials = newCredentials;

      logger.info('Secret rotation completed successfully');
      rotationInProgress = false;
    }
  } catch (error) {
    logger.error('Failed to check for secret rotation', { error });
  }
}

async function updateDatabaseConnections(newCredentials: any) {
  // Implement graceful connection pool update
  // This varies by database driver
}
```

### Git Pre-Commit Hook for Secret Scanning

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Install: cp scripts/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

# Check for potential secrets
if git diff --cached --name-only | xargs grep -lE "(api[_-]?key|apikey|secret[_-]?key|password|token).*=.*['\"][^'\"]{16,}['\"]" 2>/dev/null; then
    echo "ERROR: Potential secrets detected in staged files!"
    echo "Please use environment variables instead."
    exit 1
fi

# Check for AWS keys
if git diff --cached | grep -E "AKIA[0-9A-Z]{16}"; then
    echo "ERROR: AWS Access Key detected!"
    exit 1
fi

# Check for private keys
if git diff --cached | grep -E "-----BEGIN.*PRIVATE KEY-----"; then
    echo "ERROR: Private key detected!"
    exit 1
fi
```

### Environment Documentation Template

```markdown
# Environment Variables

## Required Variables

| Variable | Description | Example | Secret |
|----------|-------------|---------|--------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` | Yes |
| `JWT_SECRET` | Secret for signing JWT tokens | 64+ character random string | Yes |
| `API_KEY` | External API authentication key | `sk_live_...` | Yes |

## Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `LOG_LEVEL` | Logging verbosity | `info` |
| `NODE_ENV` | Environment mode | `development` |

## Setup

1. Copy `.env.example` to `.env`
2. Fill in all required variables
3. Never commit `.env` to version control
4. For production, use vault or cloud secret manager
```

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging and monitoring of secret access
- `/devops-review` - For CI/CD secret injection and deployment
- `/api-readiness-review` - For API key management
- `/security-review` - For comprehensive security audit
- `/quality-check` - For code quality in secret handling
