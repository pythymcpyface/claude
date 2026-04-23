---
name: efficiency-review
description: Production readiness review for deployment efficiency. Analyzes package sizes, dependencies, Docker images, build times, runtime RAM usage, application code efficiency, and provides optimization recommendations to reduce deployment costs and times. Use PROACTIVELY before production releases, when optimizing infrastructure costs, or when build/deploy times are too long.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Efficiency Review Skill

Production readiness code review focused on Deployment Efficiency. Analyzes package sizes, dependencies, Docker images, build times, runtime RAM usage, application code efficiency, and provides optimization recommendations to reduce deployment costs and times.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "optimize", "efficiency", "deploy", "bundle", "reduce", "cost", "size", "memory", "ram"
- Dockerfile or build configuration changes
- package.json, requirements.txt, go.mod, Cargo.toml changes
- New dependencies added
- Deployment times exceed targets (>5 min for typical services)
- Infrastructure cost concerns raised
- Runtime memory issues or high costs
- Production scaling problems

---

## Review Workflow

### Phase 1: Stack & Infrastructure Detection

Detect the project's technology stack and build tooling:

```bash
# Detect package manager and build tools
ls package.json pnpm-lock.yaml yarn.lock bun.lockb 2>/dev/null
ls requirements.txt pyproject.toml setup.py Pipfile 2>/dev/null
ls go.mod go.sum Cargo.toml Cargo.lock 2>/dev/null

# Detect bundlers and build tools
ls webpack.config.js vite.config.ts vite.config.js rollup.config.js esbuild.config.ts next.config.* astro.config.* 2>/dev/null

# Detect containerization
ls Dockerfile docker-compose.yml docker-compose.yaml 2>/dev/null

# Detect monorepo
ls pnpm-workspace.yaml lerna.json turbo.json nx.json 2>/dev/null

# Detect serverless/lambda
ls serverless.yml sam.yaml template.yaml handler.js 2>/dev/null

# Detect background workers
lsProcfile worker.ts cron.yaml celeryconfig.py rq-scheduler 2>/dev/null

# Check for CI configuration
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile circleci/config.yml 2>/dev/null
```

### Phase 2: Efficiency Checklist

#### 1. Dependency Analysis

| Check | Pattern | Status |
|-------|---------|--------|
| No unused dependencies | Dependencies actually imported/used | Required |
| No duplicate dependencies | Single version of each package | Required |
| Minimal dev dependencies | Only production deps in final bundle | Required |
| No security vulnerabilities | npm audit, snyk, dependabot | Required |
| Lock file present | package-lock.json, yarn.lock, etc | Required |
| Optional dependencies used | Native modules as optional | Recommended |
| No bundled deps in node_modules | Check package bundles | Recommended |

**Search Patterns:**
```bash
# Check for package-lock.json or equivalent
ls package-lock.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null

# Find unused dependencies (npm)
npx depcheck --json 2>/dev/null || echo "depcheck not available"

# Check for duplicate packages
npm ls 2>/dev/null | grep -i "dedup" || echo "Checking duplicates..."
ls node_modules/*/node_modules 2>/dev/null | head -20

# Check for heavy dependencies
grep -E "\"lodash|\"moment|\"rxjs|\"graphql|\"prisma|\"typeorm" package.json 2>/dev/null
grep -E "\"clsx|\"classnames|\"tiny-invariant" package.json 2>/dev/null

# Check for security vulnerabilities
npm audit --json 2>/dev/null | head -50 || echo "No audit results"

# Check for bundled dependencies in node_modules
du -sh node_modules/@google-cloud/datastore/node_modules 2>/dev/null || echo "No nested deps"
```

#### 2. Runtime Memory & RAM Analysis

| Check | Pattern | Status |
|-------|---------|--------|
| Memory limits configured | Container/pod memory limits | Required |
| No memory leaks | Proper cleanup on unmount | Required |
| Streaming responses | No full file buffering | Required |
| Pagination implemented | Batch processing for large data | Required |
| WeakRefs used where appropriate | For caches and large objects | Recommended |
| Streaming parsing | JSON parsing incrementally | Recommended |
| Event listener cleanup | Proper cleanup on component unmount | Required |

**Search Patterns:**
```bash
# Check for memory limits in Kubernetes/config
grep -ri "memory:" --include="*.yaml" 2>/dev/null | head -20
grep -ri "MAX_old_SPACE|--max-old-space-size" --include="*.yaml" --include="*.json" 2>/dev/null | head -10

# Check for memory leak patterns
grep -r "addEventListener" --include="*.ts" --include="*.tsx" -l 2>/dev/null | head -10
grep -r "useEffect" --include="*.tsx" -l 2>/dev/null | head -10

# Check for streaming responses
grep -r "Stream\|createReadableStream\|pipe" --include="*.ts" --include="*.js" 2>/dev/null | head -10
grep -r "JSON\.parse\|JSON\.stringify" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Check for large data handling
grep -r "fs\.readFileSync\|readFile" --include="*.ts" --include="*.js" 2>/dev/null | head -10
grep -r "large\|chunk\|batch\|limit" --include="*.ts" --include="*.js" -i 2>/dev/null | head -15
```

#### 3. Application Code Efficiency

| Check | Pattern | Status |
|-------|---------|--------|
| No blocking operations | Async/await for I/O | Required |
| Efficient data structures | Maps vs Objects, Sets vs Arrays | Required |
| No N+1 queries | Eager loading or batching | Required |
| Query pagination | Limit/offset or cursor | Required |
| Connection pooling configured | Database pool limits | Required |
| Caching implemented | Redis/memory cache | Required |
| Batch operations | Bulk inserts/updates | Recommended |

**Search Patterns:**
```bash
# Check for blocking operations in async context
grep -r "\.then\|\.catch\|Promise" --include="*.ts" --include="*.js" 2>/dev/null | head -20
grep -r "await.*await\|sync\|readFileSync" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Check for inefficient data structures
grep -r "Object\.keys\|\.values\|\.entries\|\.forEach" --include="*.ts" --include="*.js" 2>/dev/null | head -15
grep -r "\.find\|\.filter\|\.map.*find" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Check for N+1 patterns
grep -r "for.*of\|for.*const.*of" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Check for query optimization
grep -r "include\|\ preload\|\ eager\|_with_" --include="*.ts" --include="*.py" 2>/dev/null | head -15
grep -r "limit\|offset\|paginate\|cursor" --include="*.ts" --include="*.py" 2>/dev/null | head -15
```

#### 4. Bundle Size Analysis

| Check | Pattern | Status |
|-------|---------|--------|
| Bundle analyzed | Size of production bundle known | Required |
| Code splitting configured | Dynamic imports used | Required |
| Tree shaking enabled | Unused code removed | Required |
| Source maps in production | Only in dev/staging | Required |
| Assets optimized | Images, fonts compressed | Required |
| Lazy loading implemented | Route-based code splitting | Required |

**Search Patterns:**
```bash
# Find build output directories
ls dist build out .next .output 2>/dev/null

# Check bundle size (if build exists)
du -sh dist build out .next 2>/dev/null

# Find large files in build output
find dist build .next -type f -size +1M 2>/dev/null | head -20

# Check for source maps in production build
find dist build -name "*.map" 2>/dev/null | head -5

# Check for dynamic imports
grep -r "import\(" --include="*.js" --include="*.ts" --include="*.tsx" -l 2>/dev/null | head -10
```

#### 5. Docker Image Optimization

| Check | Pattern | Status |
|-------|---------|--------|
| Multi-stage build used | Builder pattern for smaller images | Required |
| Minimal base image | alpine, slim, distroless | Required |
| No package manager cache | --no-cache, --clean-cache | Required |
| No dev dependencies in image | NODE_ENV=production | Required |
| Layers optimized | Order for cache efficiency | Required |
| .dockerignore configured | Exclude build artifacts | Required |
| Image size tracked | <200MB for typical services | Required |
| No root user | Security best practice | Required |
| Distroless image | For minimal attack surface | Recommended |
| Just runtime deps | No build tools in final image | Required |

**Search Patterns:**
```bash
# Check for multi-stage builds
grep -E "FROM.*AS|AS build|AS production" Dockerfile 2>/dev/null

# Check base image
grep "^FROM" Dockerfile 2>/dev/null

# Check for npm ci --production
grep -E "npm ci|npm install|npm run" Dockerfile 2>/dev/null

# Check for .dockerignore
cat .dockerignore 2>/dev/null | head -20

# Measure Docker image size (if built)
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep -E "$(basename $(pwd))|app" | head -5

# Check for distroless or scratch
grep -E "gcr.io/distroless|gcr.io/google-containers/base-alpine|scratch" Dockerfile 2>/dev/null

# Check user is non-root
grep -E "USER |adduser |addgroup " Dockerfile 2>/dev/null
```

#### 6. Build Performance

| Check | Pattern | Status |
|-------|---------|--------|
| Caching configured | Build cache enabled | Required |
| Parallel builds | Multiple cores utilized | Recommended |
| Incremental builds | Only changed files rebuilt | Recommended |
| Build time measured | <3 min for typical projects | Required |
| CI caching | Cache node_modules, build cache | Required |

**Search Patterns:**
```bash
# Check for build caching
grep -E "cache|nx| turbo" package.json 2>/dev/null | head -10

# Check CI cache configuration
grep -r "cache:" .github/workflows/*.yml .gitlab-ci.yml 2>/dev/null | head -10

# Measure build time (if build script exists)
time npm run build 2>&1 | tail -10

# Check for parallelization
grep -E "parallel|workers|jobs" package.json vite.config.* webpack.config.* 2>/dev/null
```

#### 7. Dependency Size Analysis

| Check | Pattern | Status |
|-------|---------|--------|
| Heavy deps replaced | Consider alternatives | Required |
| Tree-shakeable imports | Only import what's needed | Required |
| No polyfill bloat | Use modern browserslist | Required |
| Conditional imports | Feature detection | Recommended |

**Search Patterns:**
```bash
# Find large node_modules
du -sh node_modules/* 2>/dev/null | sort -rh | head -20

# Check for problematic dependencies
grep -E "\"date-fns|\"luxon|\"dayjs" package.json 2>/dev/null
grep -E "\"lodash|\"underscore" package.json 2>/dev/null
grep -E "\"@babel|\"typescript" package.json 2>/dev/null

# Check for full imports vs named imports
grep -r "from 'lodash'" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Check browserslist target
grep -A5 "browserslist" package.json 2>/dev/null
```

#### 8. Serverless & Cold Start Optimization

| Check | Pattern | Status |
|-------|---------|--------|
| Minimal handler size | <5MB package size | Required |
| No heavy imports in handler | Lazy load heavy deps | Required |
| Warm-up configured | Scheduled warm-up | Recommended |
| Provisioned concurrency | For latency-sensitive | Recommended |
| Outside handler code | Modules loaded at cold start | Required |

**Search Patterns:**
```bash
# Check handler file size
ls -lh handler.js handler.ts index.js 2>/dev/null

# Check for heavy imports at module level
head -20 handler.js handler.ts 2>/dev/null

# Check serverless config
grep -r "provider:|functions:" serverless.yml 2>/dev/null | head -10
grep -r "provisionedConcurrency|reservedConcurrency" serverless.yml 2>/dev/null | head -5

# Check for webpack layering
grep -r "layer|webpack" serverless.yml 2>/dev/null | head -5
```

#### 9. Background Worker Optimization

| Check | Pattern | Status |
|-------|---------|--------|
| Worker concurrency configured | Limit concurrent jobs | Required |
| Memory per worker | Sized correctly | Required |
| Job chunking | Process in batches | Required |
| Graceful shutdown | Signal handling | Required |

**Search Patterns:**
```bash
# Check for worker configuration
grep -r "concurrency|workers|maxJobs" --include="*.js" --include="*.ts" --include="*.yaml" 2>/dev/null | head -10

# Check for cron/schedule
grep -r "cron|schedule|interval" --include="*.js" --include="*.ts" --include="*.yaml" 2>/dev/null | head -10

# Check Procfile
cat Procfile 2>/dev/null
```

#### 10. Deployment Cost Optimization

| Check | Pattern | Status |
|-------|---------|--------|
| Minimal replicas | Right-size infrastructure | Required |
| Spot/preemptible instances | 60-80% cost savings | Recommended |
| Resource requests optimized | No over-provisioning | Required |
| CDN for static assets | Offload bandwidth | Required |
| Gzip/Brotli compression | Reduce transfer size | Required |
| Caching headers | Reduce repeated fetches | Required |

**Search Patterns:**
```bash
# Check for CDN configuration
grep -r "cdn|cloudfront|cloudflare|fastly" --include="*.ts" --include="*.js" --include="*.yaml" 2>/dev/null | head -10

# Check for compression
grep -r "brotli|gzip|compression" --include="*.ts" --include="*.js" --include="*.yaml" --include="*.json" 2>/dev/null | head -10

# Check caching headers
grep -r "Cache-Control|max-age|stale-while-revalidate" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Check Kubernetes resource requests
grep -r "resources:\|requests:\|limits:" --include="*.yaml" 2>/dev/null | head -15
```

#### 11. File Exclusion & Cleanup Analysis

| Check | Pattern | Status |
|-------|---------|--------|
| .dockerignore configured | Excludes build artifacts | Required |
| .gitignore optimized | No tracking unnecessary files | Required |
| No test files in image | Tests excluded from production | Required |
| No docs in image | README, markdown excluded | Required |
| No IDE configs in image | .vscode, idea excluded | Required |
| No secrets in repo | .env, credentials excluded | Required |
| Cron jobs reviewed | Remove unused scheduled tasks | Required |
| Long running tasks optimized | Background jobs efficient | Required |
| Caching strategy | Invalidation rules defined | Required |
| Test suite optimized | Only essential tests in CI | Recommended |

**Search Patterns:**
```bash
# Check for .dockerignore
cat .dockerignore 2>/dev/null | head -30

# Check for .gitignore
cat .gitignore 2>/dev/null | head -30

# Check for test files in repository
find . -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | wc -l

# Check for cron jobs
crontab -l 2>/dev/null || echo "No crontab"
grep -r "cron\|schedule\|setInterval\|setTimeout" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Check for background jobs
grep -r "worker\|queue\|bull\|celery\|sidekiq" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Check for cache files being created
grep -r "cache\|tmp\|temp" --include="*.ts" --include="*.js" 2>/dev/null | grep -i "write\|create" | head -10

# Check for unnecessary files in build
find dist build .next -type f \( -name "*.md" -o -name "*.test.*" -o -name "*.spec.*" -o -name "*.map" \) 2>/dev/null | head -20

# Check for large untracked files
git ls-files --others --exclude-standard | xargs du -sh 2>/dev/null | sort -rh | head -15
grep -r "TODO\|FIXME\|HACK" --include="*.ts" --include="*.js" 2>/dev/null | wc -l
```

**File Exclusion Checklist:**

| File Type | Should Be in .dockerignore | Should Be in .gitignore |
|----------|---------------------------|--------------------------|
| node_modules | YES | NO |
| .git | YES | NO |
| .gitignore | NO | YES (if local only) |
| dist/build | YES | NO |
| *.log | YES | NO |
| .env/.env.* | YES | YES (except .env.example) |
| README.md | NO | NO |
| coverage | YES | NO |
| .vscode/.idea | YES | YES |
| __tests__ | YES | NO |
| *.test.ts | YES | NO |
| *.spec.ts | YES | NO |
| .dockerignore | NO | NO |
| Dockerfile | NO | YES (if templates) |
| docker-compose* | NO | Conditional |

**Cron Job & Scheduled Task Analysis:**

| Check | Status |
|-------|--------|
| All cron jobs documented | Required |
| No orphaned scheduled tasks | Required |
| Job failures monitored | Required |
| Job runtime limited | Recommended |
| Backoff on failure | Recommended |
| No duplicate jobs | Required |

**Test Optimization:**

| Check | Status |
|-------|--------|
| Unit tests fast | Required (<1 min) |
| Integration tests filtered | Recommended |
| E2E tests separate | Required |
| Test skipping for small changes | Recommended |
| Only affected tests in PR | Recommended |
| Tests excluded from Docker | Required |
| No test dependencies in production | Required |

**Test Exclusion Patterns:**

```bash
# Check if test files are in Docker build
find dist -name "*.test.*" -o -name "*.spec.*" 2>/dev/null

# Check test dependencies
grep -E "jest|vitest|mocha|playwright|cypress" package.json | grep -v "devDependencies"

# Check for test code in production bundle
grep -r "describe\|it\('\|test(" dist/ 2>/dev/null | head -5
```

**CI Test Optimization:**

```yaml
# .github/workflows/test.yml
name: Test

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get changed files
        uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            src:
              - 'src/**'
            tests:
              - 'tests/**'
              - '**/*.test.*'
              - '**/*.spec.*'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests (always fast)
        run: npm run test:unit

      - name: Run tests (only if source changed)
        if: steps.filter.outputs.src == 'true'
        run: npm run test

      - name: Run integration tests (only if needed)
        if: steps.filter.outputs.src == 'true'
        run: npm run test:integration

      - name: Cache test results
        uses: actions/cache@v4
        with:
          path: |
            coverage/
            .turbo/
          key: test-${{ hashFiles('package-lock.json') }}
```

---

### Phase 3: Runtime Analysis Commands

Additional commands specifically for runtime efficiency:

```bash
# Analyze runtime memory consumption
node --inspect --expose-gc -e "
const before = process.memoryUsage();
console.log('Heap Used:', Math.round(before.heapUsed / 1024 / 1024), 'MB');
console.log('Heap Total:', Math.round(before.heapTotal / 1024 / 1024), 'MB');
console.log('RSS:', Math.round(before.rss / 1024 / 1024), 'MB');
"

# Check for memory leaks in running process
node --inspect -e "
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(Date.now(), mem.heapUsed / 1024 / 1024);
}, 5000);
" 2>&1 | head -20

# Analyze event loop blocking
node -e "
const { EventEmitter } = require('events');
const emitter = new EventEmitter();
let listeners = emitter.listenerCount('event');
console.log('Event emitter slots:', listeners);
"

# Check database connection pool health
grep -r "pool\|max\|connection" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | grep -i "db\|database\|redis" | head -10
```

---

### Phase 4: Analysis & Recommendations

For each area, provide:

1. **Current state**: What's currently configured
2. **Gap**: What's missing or suboptimal
3. **Impact**: Effect on runtime memory, deploy time, and costs
4. **Recommendation**: Specific fix with code examples

---

### Phase 5: Output Report

Generate a comprehensive efficiency report:

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

[CRITICAL] Large Docker Image (920MB)
  Impact: Slower deployments, higher ECR storage costs
  Fix: Use node:18-alpine as base image
  File: Dockerfile

  # Before:
  FROM node:18

  # After:
  FROM node:18-alpine AS builder
  FROM node:18-alpine AS runner

[CRITICAL] No Container Memory Limits
  Impact: Container can consume all node memory, OOM kills
  Fix: Set memory limit to 1.5x typical usage
  File: kubernetes/deployment.yaml

  resources:
    limits:
      memory: "512Mi"
    requests:
      memory: "256Mi"

[CRITICAL] No Memory Limits in Node.js
  Impact: V8 can exceed container limits causing OOM
  Fix: Set --max-old-space-size
  File: Dockerfile

  # Set to 80% of container limit
  ENV NODE_OPTIONS="--max-old-space-size=400"

[HIGH] 3 Unused Dependencies
  Impact: Longer install times, larger deployments
  Fix: Remove unused packages
  File: package.json

  Remove: ["unused-package-1", "unused-package-2", "unused-package-3"]
  Run: npm audit && npm prune

[HIGH] N+1 Queries in User Service
  Impact: Database overload, slow responses, high DB costs
  Fix: Use eager loading
  File: src/services/user.service.ts

  // Before:
  const users = await prisma.user.findMany();
  for (const user of users) {
    user.posts = await prisma.post.findMany({ where: { userId: user.id } });
  }

  // After:
  const users = await prisma.user.findMany({
    include: { posts: true },
  });

[HIGH] No Code Splitting
  Impact: Larger initial bundle, slower TTI, more RAM
  Fix: Implement route-based code splitting
  File: src/App.tsx

  // Before:
  import { Home, About, Contact } from './pages';

  // After:
  const Home = lazy(() => import('./pages/Home'));
  const About = lazy(() => import('./pages/About'));
  const Contact = lazy(() => import('./pages/Contact'));

[HIGH] Running as Root in Docker
  Impact: Security vulnerability, potential container escape
  Fix: Create non-root user
  File: Dockerfile

  RUN addgroup -g 1001 -S nodejs && \
      adduser -S nodejs -u 1001
  USER nodejs

[HIGH] Memory Leak - Event Listeners
  Impact: Memory grows over time, requires restarts
  Fix: Cleanup in useEffect return
  File: src/components/UserList.tsx

  useEffect(() => {
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

[HIGH] Blocking I/O in Async Handler
  Impact: Event loop blocked, slow responses
  Fix: Use async I/O operations
  File: src/api/handler.ts

  // Before:
  const data = fs.readFileSync(path);
  const result = await processData(data);

  // After:
  const data = await fs.promises.readFile(path);
  const result = await processData(data);

[MEDIUM] Full Lodash Import
  Impact: 70KB extra bundle size
  Fix: Use lodash-es or individual imports
  File: src/utils.ts

  // Before:
  import _ from 'lodash';

  // After:
  import debounce from 'lodash/debounce';
  // Or: import { debounce } from 'lodash-es';

[MEDIUM] Source Maps in Production
  Impact: Larger build output, exposes source code
  Fix: Disable source maps in production
  File: vite.config.ts

  build: {
    sourcemap: false,
  }

[MEDIUM] Heavy Imports in Handler
  Impact: Slow cold starts, billed duration increase
  Fix: Lazy load heavy modules
  File: handler.js

  // Before (slow cold start):
  const { heavyLib } = require('heavy-lib');
  exports.handler = async (event) => { ... };

  // After (lazy load):
  exports.handler = async (event) => {
    const { heavyLib } = await import('heavy-lib');
    return await heavyLib.process(event);
  };

[MEDIUM] No Spot Instances
  Impact: 60-80% higher compute costs
  Fix: Use spot/preemptible instances
  File: kubernetes/deployment.yaml

  spec:
    template:
      spec:
        tolerations:
          - key: "spot"
            operator: "Equal"
            value: "true"
            effect: "NoSchedule"

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

---

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | OPTIMIZED | Good to deploy |
| 70-89 | NEEDS WORK | Address high-priority items |
| 50-69 | AT RISK | Significant optimization needed |
| 0-49 | CRITICAL | Do not deploy until fixed |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Dependency Analysis | 8% |
| Runtime Memory & RAM | 15% |
| Application Code Efficiency | 12% |
| Bundle Size | 8% |
| Docker Image | 12% |
| Build Performance | 5% |
| Dependency Size | 5% |
| Serverless/Cold Start | 5% |
| Background Workers | 5% |
| Deployment Cost | 10% |
| File Exclusion & Cleanup | 15% |

---

## Quick Reference: Optimization Patterns

### Docker Multi-Stage Build with Memory Limits

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

### .dockerignore

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

#OS
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

### Memory Limit Configuration

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

### V8 Heap Memory Optimization

```javascript
// Set at entry point
const v8 = require('v8');
console.log('Heap statistics:', v8.getHeapStatistics());
```

### Lazy Loading Heavy Modules

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

### Event Listener Cleanup

```typescript
// React component
useEffect(() => {
  window.addEventListener('resize', handleResize);
  window.addEventListener('scroll', handleScroll);

  // Cleanup function
  return () => {
    window.removeEventListener('resize', handleResize);
    window.removeEventListener('scroll', handleScroll);
  };
}, [deps]);

// Cleanup on unmount
useEffect(() => {
  return () => {
    // Cleanup subscriptions, intervals, timeouts
    subscription.unsubscribe();
    clearInterval(intervalId);
    clearTimeout(timeoutId);
  };
}, []);
```

### Database Query Optimization

```typescript
// N+1 query fix with Prisma
const usersWithPosts = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
  },
});

// Pagination for large queries
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

### Connection Pool Configuration (PostgreSQL)

```typescript
import { Pool } from 'pg';

const pool = new Pool({
  max: 20,                    // Max connections
  idleTimeoutMillis: 30000,    // Close idle after 30s
  connectionTimeoutMillis: 2000,  // Connection timeout
});

export const query = async (text: string, params: any[]) => {
  const start = Date.now();
  const result = await pool.query(text, params);
  return result.rows;
};
```

### Redis Caching for Expensive Queries

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

### Background Worker Chunking

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

### Serverless Warm-Up

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

### CI Cache Configuration with GitHub Actions

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

### Optimal .gitignore for Efficiency

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

### Cron Job & Scheduled Task Optimization

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

### Redis Cache Invalidation

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

---

## Integration with Other Reviews

This skill complements:
- `/performance-review` - For load testing and scalability
- `/dependency-security-scan` - For vulnerability scanning
- `/devops-review` - For deployment and CI/CD
- `/docker-review` - For container security and best practices
- `/database-review` - For query optimization and indexing