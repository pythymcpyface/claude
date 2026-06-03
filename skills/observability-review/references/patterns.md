# Observability Review — Implementation Patterns

Reusable code snippets for fixing observability gaps. Reach for these when writing remediation guidance in Phase 3 (Gap Analysis) or when the user asks how to implement a specific observability primitive.

---

## Structured Logging (TypeScript)

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME,
    version: process.env.SERVICE_VERSION,
  },
  transports: [
    new winston.transports.Console(),
  ],
});
```

---

## RED Metrics (Node.js)

```typescript
import client from 'prom-client';

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
});

// Middleware
app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    end({ method: req.method, route: req.route?.path, status_code: res.statusCode });
  });
  next();
});
```

---

## OpenTelemetry Tracing

```typescript
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const sdk = new NodeSDK({
  serviceName: process.env.OTEL_SERVICE_NAME,
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
  }),
});

sdk.start();
```

---

## Health Endpoints

```typescript
// Health check - always returns 200 if process is running
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Readiness check - verifies dependencies
app.get('/ready', async (req, res) => {
  try {
    await db.ping();
    await redis.ping();
    res.json({ status: 'ready', checks: { db: 'ok', redis: 'ok' } });
  } catch (error) {
    res.status(503).json({ status: 'not ready', error: error.message });
  }
});
```
