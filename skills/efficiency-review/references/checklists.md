# Efficiency Review — Detailed Checklists

This file contains the full checklist tables and search-pattern commands for each efficiency category. Read this when SKILL.md tells you to drill into a specific category.

## Table of Contents
1. Dependency Analysis
2. Runtime Memory & RAM
3. Application Code Efficiency
4. Bundle Size
5. Docker Image Optimization
6. Build Performance
7. Dependency Size Analysis
8. Serverless & Cold Start
9. Background Worker Optimization
10. Deployment Cost
11. File Exclusion & Cleanup

---

## 1. Dependency Analysis

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

---

## 2. Runtime Memory & RAM

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

---

## 3. Application Code Efficiency

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

---

## 4. Bundle Size

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

---

## 5. Docker Image Optimization

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

---

## 6. Build Performance

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

---

## 7. Dependency Size Analysis

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

---

## 8. Serverless & Cold Start Optimization

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

---

## 9. Background Worker Optimization

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

---

## 10. Deployment Cost Optimization

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

---

## 11. File Exclusion & Cleanup

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

### File Exclusion Reference Table

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

### Cron Job & Scheduled Task Analysis

| Check | Status |
|-------|--------|
| All cron jobs documented | Required |
| No orphaned scheduled tasks | Required |
| Job failures monitored | Required |
| Job runtime limited | Recommended |
| Backoff on failure | Recommended |
| No duplicate jobs | Required |

### Test Optimization

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

**CI Test Optimization Example:**
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
