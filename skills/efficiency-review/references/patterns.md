# Efficiency Review — Optimization Patterns

Reusable code/config snippets for the most common efficiency fixes. Copy and adapt; do not paste verbatim into a project without confirming the project's stack.

## Docker Multi-Stage Build with Memory Limits

```dockerfile
# Dockerfile
# Stage 1: Dependencies
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Runner (minimal)
FROM node:18-alpine-slim AS runner
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set Node memory limit (80% of container limit)
ENV NODE_OPTIONS="--max-old-space-size=384"

# Copy only what's needed
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

USER nodejs
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## .dockerignore

```
# Dependencies
node_modules
npm-debug.log*

# Build outputs
dist
build
.next
.out

# Development
.git
.gitignore
*.md
README*
.env*
.env.*
docker-compose*
.vscode
.idea
*.swp

# OS
.DS_Store
Thumbs.db

# CI
.github
.gitlab-ci.yml

# Tests
__tests__
*.test.ts
*.spec.ts
coverage
```

## Kubernetes Memory Limit Configuration

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: api
          image: api:latest
          env:
            - name: NODE_OPTIONS
              value: "--max-old-space-size=384"
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

## V8 Heap Memory Inspection

```javascript
// Set at entry point
const v8 = require('v8');
console.log('Heap statistics:', v8.getHeapStatistics());
```

## Lazy Loading Heavy Modules (Serverless)

```typescript
// handler.ts
import type { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event) => {
  // Only import heavy modules when needed
  const { processLargeFile } = await import('./heavy-processor');
  const { validation } = await import('./validators');
  const { analytics } = await import('./analytics');

  // ... handler logic
};
```

## Event Listener Cleanup (React)

```typescript
useEffect(() => {
  window.addEventListener('resize', handleResize);
  window.addEventListener('scroll', handleScroll);

  // Cleanup function
  return () => {
    window.removeEventListener('resize', handleResize);
    window.removeEventListener('scroll', handleScroll);
  };
}, [deps]);

// Cleanup subscriptions, intervals, timeouts on unmount
useEffect(() => {
  return () => {
    subscription.unsubscribe();
    clearInterval(intervalId);
    clearTimeout(timeoutId);
  };
}, []);
```

## Database Query Optimization (Prisma)

```typescript
// N+1 query fix with Prisma
const usersWithPosts = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
  },
});

// Cursor-based pagination for large queries
const pageSize = 100;
let cursor: string | null = undefined;

do {
  const { data, nextCursor } = await prisma.post.findMany({
    take: pageSize,
    cursor: cursor ? { id: cursor } : undefined,
    skip: cursor ? 1 : 0,
  });
  cursor = nextCursor;
  // Process batch
} while (cursor);
```

## Connection Pool Configuration (PostgreSQL)

```typescript
import { Pool } from 'pg';

const pool = new Pool({
  max: 20,                       // Max connections
  idleTimeoutMillis: 30000,      // Close idle after 30s
  connectionTimeoutMillis: 2000, // Connection timeout
});

export const query = async (text: string, params: any[]) => {
  const start = Date.now();
  const result = await pool.query(text, params);
  return result.rows;
};
```

## Redis Caching for Expensive Queries

```typescript
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: 3,
  lazyConnect: true,
});

async function getCachedUsers() {
  const cached = await redis.get('users:all');
  if (cached) return JSON.parse(cached);

  const users = await db.users.findMany();
  await redis.setex('users:all', 300, JSON.stringify(users)); // 5 min TTL
  return users;
}
```

## Background Worker Chunking

```typescript
async function processQueue() {
  const batchSize = 100;

  while (true) {
    const items = await redis.lpopCount('queue', batchSize);
    if (!items.length) break;

    // Process batch
    await Promise.all(items.map(processItem));

    // Brief pause to allow other workers
    await new Promise(r => setTimeout(r, 10));
  }
}
```

## Serverless Warm-Up

```yaml
# serverless.yml
functions:
  warmUp:
    handler: handler.warmUp
    events:
      - schedule: rate(5 minutes)

  main:
    handler: handler.main
    events:
      - http:
          path: /api
          method: any
    # Enable provisioned concurrency
    provisionedConcurrency: 1
```

## CI Cache Configuration (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: app:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Optimal .gitignore for Efficiency

```
# Dependencies
node_modules/
npm-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
.next/
out/
.nuxt/
.turbo/

# Test & Coverage
coverage/
.nyc_output/
__pycache__/
*.pyc
.pytest_cache/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Debug
*.log
npm-debug.log*

# Cloud/state
.firebase/
.firebaserc
.netlify/
.vercel/
now.json

# CMS/Database
*.db
*.sqlite
*.sql.gz
```

## Cron Job & Scheduled Task with Timeout

```typescript
// background/cron.ts
import { CronJob } from 'cron';

const job = new CronJob('0 * * * *', async () => {
  const start = Date.now();

  try {
    // Limit runtime to avoid long-running tasks
    await runWithTimeout(cleanupOldRecords(), 5 * 60 * 1000);
  } catch (error) {
    console.error('Cron job failed:', error);
    // Send to monitoring
  } finally {
    const duration = Date.now() - start;
    console.log(`Job completed in ${duration}ms`);
  }
}, null, true, 'UTC');

async function runWithTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error('Job timeout')), ms)
    ),
  ]);
}
```

## Redis Cache Invalidation Strategy

```typescript
// cache/invalidation.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

interface CacheRule {
  pattern: string;
  ttl: number;
  invalidation: 'auto' | 'manual' | 'on-update';
}

const CACHE_RULES: CacheRule[] = [
  { pattern: 'users:*', ttl: 300, invalidation: 'auto' },
  { pattern: 'posts:*', ttl: 60, invalidation: 'on-update' },
  { pattern: 'stats:*', ttl: 3600, invalidation: 'manual' },
];

async function invalidateCache(pattern: string) {
  const keys = await redis.keys(pattern);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
}
```
