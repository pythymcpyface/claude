---
description: Production readiness review for performance and scalability. Reviews load testing at 2-3x peak capacity, auto-scaling configuration, resource optimization, and performance baselines before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Performance Review Command

Run a comprehensive production readiness review focused on Performance & Scalability.

## Purpose

Review code before production release to ensure:
- Load testing at 2-3x peak capacity
- Auto-scaling configuration (HPA, ASG)
- Resource optimization and limits
- Database performance and query optimization
- Performance baselines and SLO targets
- Traffic management (rate limiting, circuit breakers)

## Workflow

### 1. Load the Performance Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/performance-review/SKILL.md
```

### 2. Detect Project Stack & Infrastructure

Identify the technology stack and deployment infrastructure:
```bash
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null
ls Dockerfile docker-compose.yml kubernetes/ k8s/ helm/ 2>/dev/null
find . -name "*.yaml" -path "*/kubernetes/*" 2>/dev/null | head -10
grep -r "terraform\|cloudformation" --include="*.tf" --include="*.yaml" 2>/dev/null | head -5
```

### 3. Run Performance Checks

Execute all checks in parallel:

**Load Testing:**
```bash
find . -name "k6*.js" -o -name "artillery*.yml" -o -name "locust*.py" 2>/dev/null | head -10
grep -r "k6\|artillery\|locust\|gatling\|vegeta" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -15
find . -type d -name "*performance*" -o -name "*load*" 2>/dev/null | head -10
```

**Auto-Scaling:**
```bash
find . -name "*.yaml" | xargs grep -l "HorizontalPodAutoscaler\|autoscaling" 2>/dev/null | head -10
grep -r "minReplicas\|maxReplicas\|targetCPUUtilization" --include="*.yaml" 2>/dev/null | head -15
grep -r "autoscaling\|auto_scaling\|scale" --include="*.tf" --include="*.json" 2>/dev/null | head -15
```

**Resource Optimization:**
```bash
grep -r "resources:\|requests:\|limits:\|cpu:\|memory:" --include="*.yaml" 2>/dev/null | head -20
grep -r "pool\|maxConnections\|connectionLimit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
grep -r "redis\|cache\|memcached" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -10
```

**Database Performance:**
```bash
grep -r "pool\|maxConnections\|connectionLimit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
grep -r "prisma\|sequelize\|typeorm\|sqlalchemy\|gorm" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -10
grep -r "@@index\|@Index\|index:" --include="*.ts" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Performance Baselines:**
```bash
find . -name "*perf*" -o -name "*slo*" -o -name "*sla*" 2>/dev/null | head -10
grep -r "datadog\|newrelic\|appdynamics\|sentry\|honeycomb" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -10
grep -r "slo\|sla\|latency\|throughput\|p99\|p95" --include="*.md" --include="*.yaml" 2>/dev/null | head -10
```

**Traffic Management:**
```bash
grep -r "rateLimit\|rate.*limit\|throttle" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
grep -r "circuitBreaker\|circuit.*breaker\|hystrix\|opossum" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
grep -r "timeout\|Timeout" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Load Testing, Auto-Scaling, Resources, Database, Baselines, Traffic)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must fix before production
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/performance-review
```

## When to Use

- Before production releases
- When adding resource-intensive features
- During infrastructure changes
- Before major traffic events
- When scaling configuration is modified
- During capacity planning

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For logging, metrics, tracing
- `/api-readiness-review` - For API versioning and rate limiting
- `/devops-review` - For deployment and CI/CD
- `/error-resilience-review` - For error handling patterns
