---
description: Production readiness review for monitoring and observability. Reviews code for logging, metrics, distributed tracing, alerting, and SLO compliance before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Observability Check Command

Run a comprehensive production readiness review focused on Monitoring & Observability.

## Purpose

Review code before production release to ensure:
- Proper structured logging with correlation IDs
- RED metrics (Rate, Errors, Duration) for all endpoints
- Distributed tracing instrumentation
- Alert definitions for critical conditions
- Health and readiness endpoints

## Workflow

### 1. Load the Observability Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/observability-review/SKILL.md
```

### 2. Detect Project Stack

Identify the technology stack:
```bash
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt setup.py 2>/dev/null
cat package.json 2>/dev/null | head -50
cat go.mod 2>/dev/null | head -20
cat requirements.txt pyproject.toml 2>/dev/null | head -30
```

### 3. Run Observability Checks

Execute all checks in parallel:

**Logging:**
```bash
grep -r "logger\|winston\|pino\|bunyan\|structlog\|zap\|slog" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -20
grep -r "trace_id\|correlation\|requestId" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -20
```

**Metrics:**
```bash
grep -r "prom-client\|prometheus\|Counter\|Histogram\|Gauge" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -20
grep -r "metrics.*middleware\|metricsMiddleware" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Tracing:**
```bash
grep -r "opentelemetry\|jaeger\|zipkin\|@opentelemetry" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -20
grep -r "span\|tracer\|startSpan" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
```

**Alerting:**
```bash
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l "alert\|Alert" 2>/dev/null | head -20
grep -r "alertmanager\|alert.*rules" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10
```

**Health:**
```bash
grep -r "health\|healthz\|readiness\|liveness" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20
grep -r "SIGTERM\|graceful.*shutdown" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Logging, Metrics, Tracing, Alerting, Health)
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
/observability-check
```

## When to Use

- Before production releases
- After adding new API endpoints
- When creating new services
- During PR reviews for critical features
- Before go-live milestones

## Integration with Other Commands

Consider running alongside:
- `/quality-check` - For lint, types, tests
- `/security-review` - For security vulnerabilities
- `/review-pr` - For comprehensive PR review
