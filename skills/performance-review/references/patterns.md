# performance-review — Implementation Patterns

Reusable code snippets and configuration templates for performance-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

