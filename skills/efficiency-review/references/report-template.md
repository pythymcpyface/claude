# Efficiency Review — Report Template

Use this template to assemble the final efficiency report after running through the checklists in `references/checklists.md`. Fill in concrete findings; never include sections you did not actually verify.

## Output Report Format

```
══════════════════════════════════════════════════════════════
          DEPLOYMENT EFFICIENCY REVIEW REPORT
══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Date: [timestamp]

OVERALL SCORE: [X/100] [OPTIMIZED/NEEDS WORK/CRITICAL]

──────────────────────────────────────────────────────────────
                     CHECKLIST RESULTS
──────────────────────────────────────────────────────────────

DEPENDENCY ANALYSIS
  [PASS] Lock file present (package-lock.json)
  [FAIL] 3 unused dependencies detected
  [PASS] No duplicate dependencies
  [WARN] No security audit automation

RUNTIME MEMORY & RAM
  [FAIL] No memory limits configured in container
  [WARN] Potential memory leak in user service (listeners not cleaned)
  [PASS] Streaming responses enabled for large files
  [PASS] Pagination implemented for database queries

APPLICATION CODE EFFICIENCY
  [FAIL] N+1 queries in user service
  [PASS] Using Maps for lookups
  [WARN] Blocking I/O in async handler
  [PASS] Connection pooling configured (10 connections)

BUNDLE SIZE
  [PASS] Production bundle: 245KB (gzipped)
  [FAIL] No code splitting configured
  [PASS] Tree shaking enabled
  [WARN] Source maps included in production build

DOCKER IMAGE
  [PASS] Multi-stage build used
  [FAIL] Using node:18 (not alpine), image 920MB
  [PASS] NODE_ENV=production set
  [PASS] .dockerignore configured
  [FAIL] Running as root user

BUILD PERFORMANCE
  [PASS] Build caching configured (Vite)
  [PASS] Build time: 45 seconds
  [PASS] CI caching enabled

DEPENDENCY SIZE
  [WARN] lodash full import (consider lodash-es)
  [PASS] Using date-fns instead of moment
  [PASS] Proper named imports used

SERVERLESS & COLD START
  [PASS] Handler size: 2.5MB
  [WARN] Heavy module imports at handler level
  [FAIL] No provisioned concurrency

BACKGROUND WORKERS
  [PASS] Worker concurrency limited to 5
  [PASS] Graceful shutdown implemented

DEPLOYMENT COST
  [PASS] CDN configured for static assets
  [PASS] Gzip compression enabled
  [PASS] Cache headers properly set
  [WARN] Using on-demand instances (not spot)

──────────────────────────────────────────────────────────────
                     OPTIMIZATION RECOMMENDATIONS
──────────────────────────────────────────────────────────────

[See Recommendation Examples below]

──────────────────────────────────────────────────────────────
                     COST IMPACT ESTIMATE
──────────────────────────────────────────────────────────────

Runtime Memory Impact:
  - Current baseline: 450MB heap, 800MB container
  - After optimization: 280MB heap, 400MB container
  - Potential reduction: 50% less RAM per instance

Monthly Cost Savings:
  - Container memory: 512MB -> 400MB = XX% reduction
  - ECR storage: $X.XX/month (after image optimization)
  - Compute (spot): $X.XX/month (60% savings)
  - Database queries: $X.XX/month (after fixing N+1)
  - Bandwidth: $X.XX/month (after CDN optimization)
  - Total estimated: $X.XX/month

══════════════════════════════════════════════════════════════
```

## Recommendation Examples

Use the same `[SEVERITY] Title / Impact / Fix / File / before-after-code` shape for every finding so output is consistent.

### [CRITICAL] Large Docker Image (920MB)
- **Impact**: Slower deployments, higher ECR storage costs
- **Fix**: Use `node:18-alpine` as base image
- **File**: `Dockerfile`

```dockerfile
# Before:
FROM node:18

# After:
FROM node:18-alpine AS builder
FROM node:18-alpine AS runner
```

### [CRITICAL] No Container Memory Limits
- **Impact**: Container can consume all node memory, OOM kills
- **Fix**: Set memory limit to 1.5x typical usage
- **File**: `kubernetes/deployment.yaml`

```yaml
resources:
  limits:
    memory: "512Mi"
  requests:
    memory: "256Mi"
```

### [CRITICAL] No Memory Limits in Node.js
- **Impact**: V8 can exceed container limits causing OOM
- **Fix**: Set `--max-old-space-size`
- **File**: `Dockerfile`

```dockerfile
# Set to 80% of container limit
ENV NODE_OPTIONS="--max-old-space-size=400"
```

### [HIGH] Unused Dependencies
- **Impact**: Longer install times, larger deployments
- **Fix**: Remove unused packages
- **File**: `package.json`

```bash
Remove: ["unused-package-1", "unused-package-2", "unused-package-3"]
Run: npm audit && npm prune
```

### [HIGH] N+1 Queries
- **Impact**: Database overload, slow responses, high DB costs
- **Fix**: Use eager loading
- **File**: e.g. `src/services/user.service.ts`

```typescript
// Before:
const users = await prisma.user.findMany();
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { userId: user.id } });
}

// After:
const users = await prisma.user.findMany({
  include: { posts: true },
});
```

### [HIGH] No Code Splitting
- **Impact**: Larger initial bundle, slower TTI, more RAM
- **Fix**: Implement route-based code splitting
- **File**: e.g. `src/App.tsx`

```typescript
// Before:
import { Home, About, Contact } from './pages';

// After:
const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Contact = lazy(() => import('./pages/Contact'));
```

### [HIGH] Running as Root in Docker
- **Impact**: Security vulnerability, potential container escape
- **Fix**: Create non-root user
- **File**: `Dockerfile`

```dockerfile
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs
```

### [HIGH] Memory Leak — Event Listeners
- **Impact**: Memory grows over time, requires restarts
- **Fix**: Cleanup in `useEffect` return
- **File**: e.g. `src/components/UserList.tsx`

```typescript
useEffect(() => {
  window.addEventListener('resize', handleResize);
  return () => window.removeEventListener('resize', handleResize);
}, []);
```

### [HIGH] Blocking I/O in Async Handler
- **Impact**: Event loop blocked, slow responses
- **Fix**: Use async I/O operations
- **File**: e.g. `src/api/handler.ts`

```typescript
// Before:
const data = fs.readFileSync(path);
const result = await processData(data);

// After:
const data = await fs.promises.readFile(path);
const result = await processData(data);
```

### [MEDIUM] Full Lodash Import
- **Impact**: ~70KB extra bundle size
- **Fix**: Use `lodash-es` or individual imports
- **File**: e.g. `src/utils.ts`

```typescript
// Before:
import _ from 'lodash';

// After:
import debounce from 'lodash/debounce';
// Or: import { debounce } from 'lodash-es';
```

### [MEDIUM] Source Maps in Production
- **Impact**: Larger build output, exposes source code
- **Fix**: Disable source maps in production
- **File**: `vite.config.ts`

```typescript
build: {
  sourcemap: false,
}
```

### [MEDIUM] Heavy Imports in Handler
- **Impact**: Slow cold starts, billed duration increase
- **Fix**: Lazy load heavy modules
- **File**: e.g. `handler.js`

```typescript
// Before (slow cold start):
const { heavyLib } = require('heavy-lib');
exports.handler = async (event) => { ... };

// After (lazy load):
exports.handler = async (event) => {
  const { heavyLib } = await import('heavy-lib');
  return await heavyLib.process(event);
};
```

### [MEDIUM] No Spot Instances
- **Impact**: 60-80% higher compute costs
- **Fix**: Use spot/preemptible instances
- **File**: `kubernetes/deployment.yaml`

```yaml
spec:
  template:
    spec:
      tolerations:
        - key: "spot"
          operator: "Equal"
          value: "true"
          effect: "NoSchedule"
```
