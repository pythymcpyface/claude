# secrets-management-review — Implementation Patterns

Reusable code snippets and configuration templates for secrets-management-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

