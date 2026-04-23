---
name: efficiency-review
description: Production readiness review for deployment efficiency. Analyzes package sizes, dependencies, Docker images, build times, and provides optimization recommendations to reduce deployment costs and times. Use PROACTIVELY before production releases, when optimizing infrastructure costs, or when build/deploy times are too long.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Efficiency Review Skill

Production readiness code review focused on Deployment Efficiency. Analyzes package sizes, dependencies, Docker images, build times, and provides optimization recommendations to reduce deployment costs and times.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "optimize", "efficiency", "deploy", "bundle", "reduce", "cost", "size"
- Dockerfile or build configuration changes
- package.json, requirements.txt, go.mod, Cargo.toml changes
- New dependencies added
- Deployment times exceed targets (>5 min for typical services)
- Infrastructure cost concerns raised

---

## Review Workflow

### Phase 1: Stack & Infrastructure Detection

Detect the project's technology stack and build tooling:

```bash
# Detect package manager and build tools
ls package.json pnpm-lock.yaml yarn.lock bun.lockb 2>/dev/null
ls requirements.txt pyproject.toml setup.py 2>/dev/null
ls go.mod go.sum Cargo.toml Cargo.lock 2>/dev/null

# Detect bundlers and build tools
ls webpack.config.js vite.config.ts vite.config.js rollup.config.js esbuild.config.ts next.config.* astro.config.* 2>/dev/null

# Detect containerization
ls Dockerfile docker-compose.yml docker-compose.yaml 2>/dev/null

# Detect monorepo
ls pnpm-workspace.yaml lerna.json turbo.json nx.json 2>/dev/null

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

# Check for security vulnerabilities
npm audit --json 2>/dev/null | head -50 || echo "No audit results"
```

#### 2. Bundle Size Analysis

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

#### 3. Docker Image Optimization

| Check | Pattern | Status |
|-------|---------|--------|
| Multi-stage build used | Builder pattern for smaller images | Required |
| Minimal base image | alpine, slim, distroless | Required |
| No package manager cache | --no-cache, --clean-cache | Required |
| No dev dependencies in image | NODE_ENV=production | Required |
| Layers optimized | Order for cache efficiency | Required |
| .dockerignore configured | Exclude build artifacts | Required |
| Image size tracked | <200MB for typical services | Required |
| No root user | Security best practice | Recommended |

**Search Patterns:**
```bash
# Check for multi-stage builds
grep -E "FROM.*AS|AS build|AS production" Dockerfile 2>/dev/null

# Check base image
grep "^FROM" Dockerfile 2>/dev/null

# Check for npm ci --production
grep -E "npm ci|npm install" Dockerfile 2>/dev/null

# Check for .dockerignore
cat .dockerignore 2>/dev/null | head -20

# Measure Docker image size (if built)
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep -E "$(basename $(pwd))|app" | head -5
```

#### 4. Build Performance

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

#### 5. Dependency Size Analysis

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

#### 6. Deployment Cost Optimization

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

### Phase 3: Analysis & Recommendations

For each area, provide:

1. **Current state**: What's currently configured
2. **Gap**: What's missing or suboptimal
3. **Impact**: Effect on deploy time/cost
4. **Recommendation**: Specific fix with code examples

---

### Phase 4: Output Report

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

DEPLOYMENT COST
  [PASS] CDN configured for static assets
  [PASS] Gzip compression enabled
  [PASS] Cache headers properly set

──────────────────────────────────────────────────────────────
                     OPTIMIZATION RECOMMENDATIONS
──────────────────────────────────────────────────────────────

[CRITICAL] Large Docker Image (920MB)
  Impact: Slower deployments, higher storage costs
  Fix: Use node:18-alpine as base image
  File: Dockerfile

  # Before:
  FROM node:18

  # After:
  FROM node:18-alpine AS builder
  FROM node:18-alpine AS runner

[HIGH] 3 Unused Dependencies
  Impact: Longer install times, larger deployments
  Fix: Remove unused packages
  File: package.json

  Remove: ["unused-package-1", "unused-package-2", "unused-package-3"]
  Run: npm audit && npm prune

[HIGH] No Code Splitting
  Impact: Larger initial bundle, slower TTI
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
    sourcemap: false, // or 'hidden' for error tracking only
  }

──────────────────────────────────────────────────────────────
                     COST IMPACT ESTIMATE
──────────────────────────────────────────────────────────────

Current State:
  - Docker image: 920MB
  - Bundle size: 245KB (gzipped)
  - Deploy time: ~3 minutes

After Optimizations:
  - Docker image: 180MB (80% reduction)
  - Bundle size: 175KB (28% reduction)
  - Deploy time: ~1.5 minutes (50% faster)

Monthly Cost Savings:
  - ECR storage: $X.XX/month
  - Build minutes: $X.XX/month
  - Bandwidth: $X.XX/month
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
| Dependency Analysis | 20% |
| Bundle Size | 20% |
| Docker Image | 25% |
| Build Performance | 15% |
| Dependency Size | 10% |
| Deployment Cost | 10% |

---

## Quick Reference: Optimization Patterns

### Docker Multi-Stage Build

```dockerfile
# Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER nodejs
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
docker-compose*

# IDEs
.idea
.vscode
*.swp

# OS
.DS_Store
Thumbs.db
```

### Vite Bundle Optimization

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    target: 'esnext',
    minify: 'esbuild',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          utils: ['lodash-es', 'date-fns'],
        },
      },
    },
  },
  optimizeDeps: {
    include: ['react', 'react-dom'],
  },
});
```

### Code Splitting Example

```typescript
// src/App.tsx
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';
import LoadingSpinner from './components/LoadingSpinner';

const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Dashboard = lazy(() => import('./pages/Dashboard'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </Suspense>
  );
}

export default App;
```

### Named Imports (Tree Shaking)

```typescript
// Bad - imports entire library
import _ from 'lodash';
import { format, parseISO } from 'date-fns';

// Good - named imports enable tree shaking
import debounce from 'lodash/debounce';
import throttle from 'lodash/throttle';
import { format, parseISO } from 'date-fns';

// Better - use ESM alternatives
import { debounce, throttle } from 'lodash-es';
```

### CI Cache Configuration

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

---

## Integration with Other Reviews

This skill complements:
- `/performance-review` - For load testing and scalability
- `/dependency-security-scan` - For vulnerability scanning
- `/devops-review` - For deployment and CI/CD
- `/docker-review` - For container security and best practices