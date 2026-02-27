---
name: performance-review
description: Production readiness review for performance and scalability. Reviews load testing at 2-3x peak capacity, auto-scaling configuration, resource optimization, and performance baselines before production release. Use PROACTIVELY before releasing to production, when adding resource-intensive features, or modifying infrastructure.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Performance Review Skill

Production readiness code review focused on Performance & Scalability. Ensures systems are ready for production with proper load testing, auto-scaling, resource optimization, and performance baselines.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "deploy", "release", "production", "go live", "scale", "performance"
- New services or microservices are created
- Database schema changes or migrations
- Caching layer modifications
- Background job/worker implementations
- Infrastructure or deployment configuration changes
- Resource-intensive features (file uploads, data processing, ML inference)
- Before major traffic events (product launches, marketing campaigns)

---

## Review Workflow

### Phase 1: Stack & Infrastructure Detection

Detect the project's technology stack and deployment infrastructure:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect containerization
ls Dockerfile docker-compose.yml docker-compose.yaml 2>/dev/null && echo "Docker detected"

# Detect orchestration
ls kubernetes/ k8s/ manifests/ helm/ chart/ 2>/dev/null && echo "Kubernetes detected"
find . -name "*.yaml" -path "*/kubernetes/*" -o -name "*.yaml" -path "*/k8s/*" 2>/dev/null | head -10

# Detect cloud infrastructure
grep -r "terraform\|cloudformation\|pulumi\|cdk" --include="*.tf" --include="*.yaml" --include="*.json" 2>/dev/null | head -5

# Detect serverless
ls serverless.yml sam.yaml template.yaml 2>/dev/null && echo "Serverless detected"

# Check for load testing tools
grep -r "k6\|artillery\|locust\|jmeter\|gatling\|vegeta" package.json requirements.txt go.mod 2>/dev/null
```

### Phase 2: Performance Checklist

Run all checks and compile results:

#### 1. Load Testing Review

| Check | Pattern | Status |
|-------|---------|--------|
| Load tests exist | Dedicated load/performance test suite | Required |
| 2-3x peak capacity | Tests simulate 2-3x expected peak traffic | Required |
| Sustained load tests | Long-duration tests (15+ min) for stability | Required |
| Spike tests | Sudden traffic increase scenarios | Required |
| Soak tests | Extended duration tests (hours) for memory leaks | Recommended |
| Breakpoint tests | Tests to identify system breaking point | Recommended |
| Baseline metrics | Pre-production performance benchmarks documented | Required |
| CI integration | Load tests run in CI/CD pipeline | Recommended |

**Search Patterns:**
```bash
# Find load testing configurations
find . -name "k6*.js" -o -name "artillery*.yml" -o -name "locust*.py" -o -name "*load*test*" 2>/dev/null | head -20

# Check for load testing scripts
grep -r "k6\|artillery\|locust\|jmeter\|gatling\|vegeta\|loadtest" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" -l 2>/dev/null | head -20

# Find performance test directories
find . -type d -name "*performance*" -o -name "*load*" -o -name "*stress*" 2>/dev/null | head -10

# Check for CI load test steps
grep -r "loadtest\|k6 run\|artillery run\|locust" .github .gitlab-ci.yml Jenkinsfile circleci 2>/dev/null | head -10
```

#### 2. Auto-Scaling Review

| Check | Pattern | Status |
|-------|---------|--------|
| Horizontal scaling | HPA (Kubernetes) or auto-scaling group configured | Required |
| Scaling metrics | CPU, memory, or custom metrics trigger scaling | Required |
| Scale-up thresholds | Defined thresholds for scaling up | Required |
| Scale-down policies | Cooldown periods and minimum instances | Required |
| Minimum replicas | Minimum instances to handle baseline load | Required |
| Maximum replicas | Cap on maximum instances (cost control) | Required |
| Custom metrics | Business metrics for scaling (queue depth, latency) | Recommended |
| Predictive scaling | Proactive scaling based on patterns | Recommended |

**Search Patterns:**
```bash
# Find Kubernetes HPA configurations
find . -name "*.yaml" | xargs grep -l "HorizontalPodAutoscaler\|autoscaling" 2>/dev/null | head -10
grep -r "minReplicas\|maxReplicas\|targetCPUUtilization" --include="*.yaml" 2>/dev/null | head -20

# Find cloud auto-scaling configurations
grep -r "autoscaling\|auto_scaling\|scale\|desired_capacity" --include="*.tf" --include="*.json" 2>/dev/null | head -20

# Check for serverless auto-scaling
grep -r "provisionedConcurrency\|reservedConcurrency\|autoScaling" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Find scaling thresholds
grep -r "scaleUp\|scaleDown\|scale.*threshold\|scaling.*policy" --include="*.yaml" --include="*.tf" --include="*.json" 2>/dev/null | head -15
```

#### 3. Resource Optimization Review

| Check | Pattern | Status |
|-------|---------|--------|
| Resource requests | CPU/memory requests defined in Kubernetes | Required |
| Resource limits | Hard limits to prevent runaway processes | Required |
| Memory efficiency | No memory leaks, proper garbage collection | Required |
| CPU optimization | Efficient algorithms, no CPU hotspots | Required |
| Connection pooling | Database and HTTP connection pools | Required |
| Caching strategy | Appropriate caching layers (Redis, CDN) | Required |
| Async processing | Heavy operations offloaded to background | Recommended |
| Resource quotas | Namespace/deployment resource quotas | Recommended |

**Search Patterns:**
```bash
# Find Kubernetes resource definitions
grep -r "resources:\|requests:\|limits:\|cpu:\|memory:" --include="*.yaml" 2>/dev/null | head -30

# Check for connection pooling
grep -r "pool\|maxConnections\|connectionLimit\|poolSize" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find caching configurations
grep -r "redis\|cache\|memcached\|cdn" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.yaml" --include="*.json" 2>/dev/null | head -20

# Check for async/background processing
grep -r "queue\|worker\|background\|async\|bull\|celery\|sidekiq" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -15
```

#### 4. Database Performance Review

| Check | Pattern | Status |
|-------|---------|--------|
| Query optimization | N+1 queries resolved, efficient joins | Required |
| Indexing strategy | Appropriate indexes on query patterns | Required |
| Connection pooling | Database connection pool configured | Required |
| Read replicas | Read traffic offloaded to replicas | Recommended |
| Query timeouts | Query execution time limits | Required |
| Pagination | Large result sets properly paginated | Required |
| Database caching | Query result caching where appropriate | Recommended |
| Migration strategy | Non-blocking schema migrations | Required |

**Search Patterns:**
```bash
# Find database configurations
grep -r "pool\|maxConnections\|connectionLimit\|idleTimeout" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for ORM/query patterns
grep -r "prisma\|sequelize\|typeorm\|sqlalchemy\|gorm\|eager\|lazy\|include\|preload" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -15

# Find pagination implementations
grep -r "limit\|offset\|cursor\|paginate\|page" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for database indexes
find . -name "*.sql" | xargs grep -i "index\|key" 2>/dev/null | head -15
grep -r "@Index\|@@index\|index:" --include="*.ts" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

#### 5. Performance Baseline Review

| Check | Pattern | Status |
|-------|---------|--------|
| Latency targets | p50, p95, p99 latency SLOs defined | Required |
| Throughput targets | Requests per second capacity documented | Required |
| Error rate budget | Acceptable error rate threshold | Required |
| Resource utilization | Normal CPU/memory usage baseline | Required |
| Response time budget | Maximum acceptable response times | Required |
| Performance regression | Automated detection of performance regressions | Recommended |
| APM integration | Application performance monitoring | Required |

**Search Patterns:**
```bash
# Find performance documentation
find . -name "*perf*" -o -name "*slo*" -o -name "*sla*" 2>/dev/null | head -10

# Check for APM integrations
grep -r "datadog\|newrelic\|appdynamics\|dynatrace\|sentry\|honeycomb" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.json" 2>/dev/null | head -15

# Find SLO/SLA definitions
grep -r "slo\|sla\|latency\|throughput\|error.*rate\|p99\|p95" --include="*.md" --include="*.yaml" --include="*.json" 2>/dev/null | head -15

# Check for performance benchmarks
find . -name "benchmark*" -o -name "*perf*test*" 2>/dev/null | head -10
```

#### 6. Traffic Management Review

| Check | Pattern | Status |
|-------|---------|--------|
| Rate limiting | Request rate limits implemented | Required |
| Circuit breakers | Cascading failure prevention | Required |
| Bulkheads | Resource isolation for critical paths | Recommended |
| Backpressure | Flow control under load | Recommended |
| Graceful degradation | Non-critical features disabled under load | Required |
| Queue management | Request queuing with size limits | Recommended |
| Timeout policies | Upstream service call timeouts | Required |

**Search Patterns:**
```bash
# Find rate limiting
grep -r "rateLimit\|rate.*limit\|throttle" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Check for circuit breakers
grep -r "circuitBreaker\|circuit.*breaker\|breaker\|hystrix\|resilience4j\|opossum" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find timeout configurations
grep -r "timeout\|Timeout\|TIMEOUT" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.yaml" 2>/dev/null | head -20

# Check for graceful degradation
grep -r "degrad\|fallback\|feature.*flag\|circuit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific performance/scalability gap
2. **Why it matters**: Impact on production reliability and user experience
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         PERFORMANCE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Infrastructure: [Kubernetes/Serverless/VMs]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

LOAD TESTING
  [PASS] Load test suite exists (k6)
  [FAIL] No 2-3x peak capacity tests
  [PASS] Spike tests implemented
  [WARN] No soak tests for memory leak detection

AUTO-SCALING
  [PASS] HPA configured in Kubernetes
  [PASS] CPU-based scaling enabled
  [FAIL] No custom metrics for scaling
  [WARN] Scale-down cooldown not configured

RESOURCE OPTIMIZATION
  [PASS] Resource requests defined
  [FAIL] No resource limits set
  [PASS] Connection pooling configured
  [PASS] Redis caching implemented

DATABASE PERFORMANCE
  [PASS] Connection pooling enabled
  [FAIL] N+1 queries detected in user service
  [WARN] No read replicas configured
  [PASS] Pagination implemented

PERFORMANCE BASELINES
  [FAIL] No SLO targets documented
  [PASS] APM integration (Datadog)
  [WARN] No performance regression tests
  [FAIL] No throughput targets defined

TRAFFIC MANAGEMENT
  [PASS] Rate limiting implemented
  [FAIL] No circuit breakers for external APIs
  [PASS] Timeouts configured
  [WARN] No graceful degradation strategy

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Load Tests at 2-3x Peak Capacity
  Impact: System may fail under unexpected traffic spikes
  Fix: Create load tests simulating 2-3x expected peak
  File: tests/load/peak-load.js

  import http from 'k6/http';
  import { check } from 'k6';

  export const options = {
    stages: [
      { duration: '2m', target: 100 },  // Normal load
      { duration: '5m', target: 300 },  // 3x peak
      { duration: '2m', target: 300 },  // Sustained peak
      { duration: '2m', target: 100 },  // Scale down
    ],
    thresholds: {
      http_req_duration: ['p(95)<500', 'p(99)<1000'],
      http_req_failed: ['rate<0.01'],
    },
  };

  export default function () {
    const res = http.get('https://api.example.com/users');
    check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 500ms': (r) => r.timings.duration < 500,
    });
  }

[HIGH] No Circuit Breakers for External APIs
  Impact: Cascading failures can bring down the entire system
  Fix: Implement circuit breaker pattern for external calls
  File: src/services/external-api.ts

  import CircuitBreaker from 'opossum';

  const externalApiCall = new CircuitBreaker(async (data) => {
    const response = await fetch('https://external-api.com/endpoint', {
      method: 'POST',
      body: JSON.stringify(data),
    });
    return response.json();
  }, {
    timeout: 3000,
    errorThresholdPercentage: 50,
    resetTimeout: 30000,
  });

  externalApiCall.fallback(() => ({ cached: true, data: getCachedData() }));

  export const callExternalApi = externalApiCall;

[HIGH] N+1 Queries in User Service
  Impact: Database overload under load, slow response times
  Fix: Use eager loading to batch queries
  File: src/services/user.service.ts

  // Before (N+1 problem):
  const users = await prisma.user.findMany();
  for (const user of users) {
    user.posts = await prisma.post.findMany({ where: { userId: user.id } });
  }

  // After (eager loading):
  const users = await prisma.user.findMany({
    include: { posts: true },
  });

[HIGH] No Resource Limits in Kubernetes
  Impact: Runaway processes can consume all node resources
  Fix: Add resource limits to deployment
  File: kubernetes/deployment.yaml

  resources:
    requests:
      cpu: "100m"
      memory: "128Mi"
    limits:
      cpu: "500m"
      memory: "512Mi"

[MEDIUM] No SLO Targets Documented
  Impact: No clear performance goals or incident triggers
  Fix: Define and document SLO targets
  File: docs/slos.md

  # Service Level Objectives

  | Metric | Target | Description |
  |--------|--------|-------------|
  | Availability | 99.9% | Uptime per month |
  | Latency (p95) | < 200ms | 95% of requests |
  | Latency (p99) | < 500ms | 99% of requests |
  | Error Rate | < 0.1% | HTTP 5xx responses |
  | Throughput | 1000 RPS | Requests per second |

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Run load tests at 2-3x peak capacity
2. [HIGH] Add circuit breakers for all external API calls
3. [HIGH] Fix N+1 queries in user service
4. [HIGH] Set resource limits in Kubernetes deployments
5. [MEDIUM] Document SLO targets and error budgets
6. [MEDIUM] Configure custom metrics for auto-scaling

After Production:
1. Implement soak tests for memory leak detection
2. Add read replicas for database read traffic
3. Configure graceful degradation for non-critical features
4. Set up performance regression testing in CI
5. Implement predictive scaling based on traffic patterns

═══════════════════════════════════════════════════════════════
```

---

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Load Testing | 25% |
| Auto-Scaling | 20% |
| Resource Optimization | 20% |
| Database Performance | 15% |
| Performance Baselines | 10% |
| Traffic Management | 10% |

---

## Quick Reference: Implementation Patterns

### K6 Load Testing

```javascript
// tests/load/api-load.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up
    { duration: '5m', target: 100 },   // Steady state
    { duration: '2m', target: 300 },   // 3x peak
    { duration: '5m', target: 300 },   // Sustained peak
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/endpoint');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### Artillery Load Testing

```yaml
# artillery-config.yml
config:
  target: 'https://api.example.com'
  phases:
    - duration: 120
      arrivalRate: 10
      name: "Warm up"
    - duration: 300
      arrivalRate: 50
      name: "Sustained 50 RPS"
    - duration: 120
      arrivalRate: 150
      name: "3x Peak load"
scenarios:
  - flow:
      - get:
          url: "/api/v1/users"
```

### Kubernetes HPA

```yaml
# kubernetes/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-deployment
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

### Circuit Breaker (TypeScript)

```typescript
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(asyncFunction, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
});

breaker.fallback(() => ({ cached: true }));
breaker.on('open', () => console.log('Circuit opened'));
breaker.on('halfOpen', () => console.log('Circuit half-open'));
breaker.on('close', () => console.log('Circuit closed'));
```

### Connection Pooling

```typescript
// PostgreSQL with pg
import { Pool } from 'pg';

const pool = new Pool({
  max: 20,
  min: 5,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Redis with ioredis
import Redis from 'ioredis';

const redis = new Redis({
  maxRetriesPerRequest: 3,
  enableReadyCheck: true,
  lazyConnect: false,
});
```

### Resource Limits (Kubernetes)

```yaml
# kubernetes/deployment.yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging, metrics, tracing
- `/api-readiness-review` - For API versioning and rate limiting
- `/devops-review` - For deployment and CI/CD
- `/error-resilience-review` - For error handling and retries
