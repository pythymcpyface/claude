---
name: efficiency-review
description: Production readiness review for deployment efficiency. Analyzes package sizes, dependencies, Docker images, build times, runtime RAM usage, application code efficiency, and provides optimization recommendations to reduce deployment costs and times. Use PROACTIVELY before production releases, when optimizing infrastructure costs, or when build/deploy times are too long.
paths:
  - "**/package.json"
  - "**/package-lock.json"
  - "**/yarn.lock"
  - "**/pnpm-lock.yaml"
  - "**/Dockerfile*"
  - "**/.dockerignore"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/Gemfile*"
  - "**/go.mod"
  - "**/Cargo.toml"
  - "**/webpack.config.*"
  - "**/vite.config.*"
  - "**/rollup.config.*"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Efficiency Review Skill

Production readiness review focused on deployment efficiency. Analyzes package size, dependencies, Docker images, build/runtime memory, and application code to surface concrete cost and latency reductions.

## When to Trigger (Proactive)

Suggest this review when any of these are true:

- PR/commit message contains: "optimize", "efficiency", "deploy", "bundle", "reduce", "cost", "size", "memory", "ram"
- Dockerfile or build configuration changes
- `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml` changes
- New dependencies added
- Deployment times exceed targets (>5 min for typical services)
- Infrastructure cost concerns raised
- Runtime memory issues, OOM kills, high costs
- Production scaling problems

---

## How This Skill Is Organized

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| The full checklist tables and search-pattern commands for each category | `references/checklists.md` |
| Runtime memory / event-loop / pool inspection commands | `references/runtime-analysis.md` |
| The output report format and severity-tagged recommendation examples | `references/report-template.md` |
| Reusable optimization snippets (Docker, k8s, lazy load, cache, cron, etc.) | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

---

## Review Workflow

### Phase 1: Stack & Infrastructure Detection

Detect what the project uses before applying any checklist. The right checks depend on the stack.

```bash
# Package managers
ls package.json pnpm-lock.yaml yarn.lock bun.lockb 2>/dev/null
ls requirements.txt pyproject.toml setup.py Pipfile 2>/dev/null
ls go.mod go.sum Cargo.toml Cargo.lock 2>/dev/null

# Bundlers / build tools
ls webpack.config.js vite.config.ts vite.config.js rollup.config.js \
   esbuild.config.ts next.config.* astro.config.* 2>/dev/null

# Containerization
ls Dockerfile docker-compose.yml docker-compose.yaml 2>/dev/null

# Monorepo
ls pnpm-workspace.yaml lerna.json turbo.json nx.json 2>/dev/null

# Serverless
ls serverless.yml sam.yaml template.yaml handler.js 2>/dev/null

# Background workers
ls Procfile worker.ts cron.yaml celeryconfig.py 2>/dev/null

# CI
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile circleci/config.yml 2>/dev/null
```

### Phase 2: Run the Checklists

Open `references/checklists.md` and walk through each of the 11 categories that applies to the detected stack. Skip categories that don't apply (e.g. skip Serverless for a non-Lambda app).

The 11 categories:

1. Dependency Analysis
2. Runtime Memory & RAM
3. Application Code Efficiency
4. Bundle Size
5. Docker Image Optimization
6. Build Performance
7. Dependency Size Analysis
8. Serverless & Cold Start Optimization
9. Background Worker Optimization
10. Deployment Cost Optimization
11. File Exclusion & Cleanup

For each category, record PASS / WARN / FAIL with one-line justification tied to a specific file or pattern.

### Phase 3: Runtime Analysis (optional, when applicable)

For categories 2 and 3 (memory, app code) on a running system, additionally use the commands in `references/runtime-analysis.md`. Skip this phase for static-only reviews.

### Phase 4: Synthesise Findings

For each gap surfaced by the checklists:

1. **Current state** — what is configured today (with file/line)
2. **Gap** — what's missing or suboptimal
3. **Impact** — runtime memory, deploy time, cost
4. **Recommendation** — specific fix with a code example

Pull the snippet you need from `references/patterns.md` rather than inventing one.

### Phase 5: Produce the Report

Use the format and severity-tagged examples in `references/report-template.md`. Include a cost-impact estimate when you have enough data to be specific; otherwise note the qualitative direction (e.g. "smaller image → faster deploys, lower ECR cost").

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
| Serverless / Cold Start | 5% |
| Background Workers | 5% |
| Deployment Cost | 10% |
| File Exclusion & Cleanup | 15% |

---

## Integration with Other Reviews

This skill complements:

- `performance-review` — load testing and scalability
- `dependency-security-scan` — vulnerability scanning
- `devops-review` — deployment and CI/CD
- `database-review` — query optimization and indexing
