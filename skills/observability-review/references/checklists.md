# Observability Review — Checklists

Detailed checklists, search patterns, and the gap-analysis report template for the observability-review skill.

---

## Phase 1: Stack Detection

Detect the project's technology stack to apply appropriate checks:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect framework
grep -r "express\|fastify\|nestjs\|koa" package.json 2>/dev/null && echo "Node.js API"
grep -r "flask\|django\|fastapi\|starlette" requirements.txt pyproject.toml 2>/dev/null && echo "Python API"
grep -r "gin\|echo\|fiber" go.mod 2>/dev/null && echo "Go API"
```

---

## Phase 2: Observability Checklist

Run all checks and compile results.

### 1. Logging Review

| Check | Pattern | Status |
|-------|---------|--------|
| Structured logging | JSON logs with timestamp, level, service | Required |
| Log levels used | DEBUG, INFO, WARN, ERROR, FATAL appropriately | Required |
| Correlation IDs | trace_id, span_id in logs for distributed tracing | Required |
| PII/sensitive data | No passwords, tokens, personal data in logs | Critical |
| Error context | Stack traces, request context, user ID | Required |
| Log sampling | Rate limiting for high-volume logs | Recommended |

**Search patterns:**

```bash
# Find logging implementations
grep -r "logger\|log\.\|winston\|pino\|bunyan\|structlog\|zap\|slog" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"

# Check for structured logging
grep -r "JSON\|json\|structured" --include="*log*" 2>/dev/null

# Find potential PII leaks
grep -rE "password|token|secret|api_key|credit_card|ssn" --include="*.log" --include="*logger*" 2>/dev/null
```

### 2. Metrics Review

| Check | Pattern | Status |
|-------|---------|--------|
| RED metrics | Rate, Errors, Duration for all endpoints | Required |
| Golden signals | Latency, Traffic, Errors, Saturation | Required |
| Business metrics | Domain-specific KPIs (orders, signups, etc.) | Recommended |
| Custom metrics | Application-specific measurements | Recommended |
| Metric naming | Follow Prometheus/OpenMetrics conventions | Required |
| Label cardinality | No unbounded labels (user IDs, etc.) | Required |

**Search patterns:**

```bash
# Find metrics implementations
grep -r "prom-client\|prometheus\|metrics\|Counter\|Histogram\|Gauge" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"

# Check for HTTP metrics middleware
grep -r "metricsMiddleware\|metrics.*middleware\|promMiddleware" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"
```

### 3. Distributed Tracing Review

| Check | Pattern | Status |
|-------|---------|--------|
| Trace instrumentation | OpenTelemetry, Jaeger, Zipkin integration | Required |
| Span creation | All significant operations have spans | Required |
| Context propagation | Trace context passed across services | Required |
| Span attributes | Rich context on spans (user, request, etc.) | Recommended |
| Error tracking | Exceptions linked to traces | Required |

**Search patterns:**

```bash
# Find tracing implementations
grep -r "opentelemetry\|@opentelemetry\|jaeger\|zipkin\|tracing\|span\|trace" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"

# Check for trace context
grep -r "traceparent\|trace.*context\|propagation\|w3c" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"
```

### 4. Alerting Review

| Check | Pattern | Status |
|-------|---------|--------|
| Error rate alerts | Alert on elevated 5xx rates | Required |
| Latency alerts | Alert on elevated p95/p99 latency | Required |
| Availability alerts | Alert on service down/unhealthy | Required |
| Resource alerts | CPU, memory, disk saturation warnings | Required |
| Alert routing | Critical alerts to on-call, info to Slack | Required |
| Runbooks | Documentation for each alert | Recommended |

**Search patterns:**

```bash
# Find alert definitions
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l "alert\|Alert\|alerting" 2>/dev/null

# Check for alertmanager/prometheus alerts
grep -r "alertmanager\|alert.*rules\|recording_rules" --include="*.yml" --include="*.yaml" 2>/dev/null
```

### 5. Health & Readiness

| Check | Pattern | Status |
|-------|---------|--------|
| Health endpoint | /health or /healthz returns 200 | Required |
| Readiness endpoint | /ready for k8s readiness probes | Required |
| Dependency checks | Health checks DB, cache, external APIs | Required |
| Graceful shutdown | SIGTERM handling, connection draining | Required |

**Search patterns:**

```bash
# Find health endpoints
grep -r "health\|healthz\|readiness\|liveness\|live" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"

# Check for graceful shutdown
grep -r "SIGTERM\|shutdown\|graceful\|drain" --include="*.ts" --include="*.js" --include="*.py" --include="*.go"
```

### 6. SLO/SLI Compliance

| Check | Pattern | Status |
|-------|---------|--------|
| SLOs defined | Target availability/latency documented | Recommended |
| Error budgets | Burn rate tracking implemented | Recommended |
| SLI instrumentation | Key indicators measured | Recommended |

---

## Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific observability gap
2. **Why it matters**: Impact on production operations
3. **How to fix**: Concrete implementation guidance with code examples (see `patterns.md`)
4. **Priority**: Critical / High / Medium / Low

---

## Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         OBSERVABILITY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

LOGGING
  [PASS] Structured logging (JSON format)
  [FAIL] Correlation IDs - Missing trace_id in logs
  [PASS] No PII in logs
  [WARN] Log sampling not implemented

METRICS
  [PASS] RED metrics for HTTP endpoints
  [FAIL] Business metrics - No order/payment tracking
  [WARN] High cardinality labels detected

TRACING
  [FAIL] No distributed tracing instrumentation
  [N/A]  Context propagation (depends on tracing)

ALERTING
  [FAIL] No alert definitions found
  [N/A]  Runbooks (depends on alerts)

HEALTH
  [PASS] Health endpoint at /health
  [FAIL] Readiness probe missing
  [PASS] Graceful shutdown implemented

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Distributed Tracing Not Instrumented
  Impact: Cannot debug issues across services
  Fix: Add OpenTelemetry instrumentation
  File: src/app.ts

  // Add to your application entry point:
  import { NodeSDK } from '@opentelemetry/sdk-node';
  const sdk = new NodeSDK({
    serviceName: process.env.SERVICE_NAME,
    traceExporter: new OTLPTraceExporter(),
  });
  sdk.start();

[HIGH] Missing Correlation IDs in Logs
  Impact: Cannot correlate logs with traces
  Fix: Add trace context to all log entries
  File: src/utils/logger.ts

  // Add trace context to logger:
  const logger = winston.createLogger({
    format: winston.format.combine(
      winston.format((info) => {
        const span = opentelemetry.trace.getActiveSpan();
        if (span) {
          info.trace_id = span.spanContext().traceId;
          info.span_id = span.spanContext().spanId;
        }
        return info;
      })(),
      winston.format.json()
    )
  });

[MEDIUM] No Alert Definitions
  Impact: On-call team won't be notified of issues
  Fix: Create Prometheus alerting rules
  File: alerts/application.yml

  groups:
    - name: application
      rules:
        - alert: HighErrorRate
          expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
          for: 5m
          labels:
            severity: critical

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add distributed tracing with OpenTelemetry
2. [HIGH] Implement correlation IDs in logs
3. [HIGH] Create alert definitions for error rate and latency
4. [MEDIUM] Add readiness probe endpoint

After Production:
1. Create runbooks for each alert
2. Define SLOs and error budgets
3. Add business KPI metrics

═══════════════════════════════════════════════════════════════
```
