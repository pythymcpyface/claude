---
name: error-resilience-review
description: Production readiness review for Error Resilience. Reviews circuit breaker patterns, retry strategies, fallback mechanisms, timeout configurations, and graceful degradation. Use PROACTIVELY before production releases, when integrating external services, or implementing critical workflows.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Error Resilience Review Skill

Production readiness code review focused on Error Resilience & Fault Tolerance. Ensures code is ready for production with proper circuit breaker patterns, retry strategies, fallback mechanisms, timeout configurations, and graceful degradation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "retry", "circuit breaker", "fallback", "timeout", "resilience", "fault tolerance"
- New external API integrations or service dependencies
- Database or cache connection code added
- Payment, notification, or third-party service integrations
- Critical business logic with external dependencies
- Microservice-to-microservice communication added
- Before major version releases with external dependencies

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's technology stack to apply appropriate checks:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect resilience libraries
grep -r "resilience4j\|polly\|hystrix\|tenacity\|circuit-breaker\|retry" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10

# Detect HTTP clients (common integration points)
grep -r "axios\|fetch\|got\|superagent\|request\|httpx\|aiohttp\|reqwest\|resty" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Detect database clients
grep -r "pg\|mysql\|mongoose\|prisma\|sequelize\|sqlalchemy\|psycopg\|gorm\|sqlx" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

### Phase 2: Error Resilience Checklist

Run all checks and compile results:

#### 1. Circuit Breaker Pattern

The circuit breaker prevents cascading failures by stopping calls to failing services.

| Check | Pattern | Status |
|-------|---------|--------|
| Circuit breaker implemented | Library or custom implementation for external calls | Required |
| Failure threshold configured | Opens after X failures or X% failure rate | Required |
| Recovery/half-open state | Allows test requests before full recovery | Required |
| Open state fallback | Returns cached/default response when open | Required |
| Per-endpoint breakers | Separate breakers for different services/endpoints | Recommended |
| Monitoring & alerting | Circuit state changes logged and alerted | Required |

**Search Patterns:**
```bash
# Find circuit breaker implementations
grep -r "circuit.*breaker\|circuitBreaker\|CircuitBreaker\|breaker\." --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find resilience libraries
grep -r "opossum\|brakes\|resilience4j\|polly\|hystrix\|tenacity" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10

# Find failure threshold configs
grep -r "failureThreshold\|failure.*threshold\|errorThreshold\|error.*percentage" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 2. Retry Strategy

Retry strategies handle transient failures with exponential backoff.

| Check | Pattern | Status |
|-------|---------|--------|
| Retry implemented | Automatic retry for transient failures | Required |
| Exponential backoff | Delay increases between retries (1s, 2s, 4s, ...) | Required |
| Max retry limit | Maximum retries to prevent infinite loops | Required |
| Retryable errors defined | Only retry on transient errors (5xx, timeout, network) | Required |
| Jitter added | Random delay variation to prevent thundering herd | Recommended |
| Retry budget/limit | Global retry rate limiting | Recommended |

**Search Patterns:**
```bash
# Find retry implementations
grep -r "retry\|Retry\|retries\|maxRetries\|max.*retry\|retry.*count" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find exponential backoff
grep -r "exponential\|backoff\|backOff\|back-off" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find jitter implementations
grep -r "jitter\|random.*delay\|fuzz" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 3. Fallback Mechanisms

Fallbacks provide degraded functionality when services fail.

| Check | Pattern | Status |
|-------|---------|--------|
| Fallback implemented | Alternative behavior when primary fails | Required |
| Graceful degradation | Reduced functionality, not full failure | Required |
| Cached data fallback | Return stale cached data if available | Recommended |
| Default values | Safe defaults for non-critical data | Recommended |
| Fallback logging | Fallback activation is logged | Required |
| Fallback monitoring | Alert when fallback rate is high | Recommended |

**Search Patterns:**
```bash
# Find fallback implementations
grep -r "fallback\|Fallback\|fallbackFn\|onFailure\|catch.*return\|default.*value" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find cache fallback patterns
grep -r "cache.*fallback\|stale.*cache\|cached.*data\|fallback.*cache" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find graceful degradation
grep -r "graceful\|degraded\|degradation\|partial.*service" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 4. Timeout Configuration

Timeouts prevent hanging requests and resource exhaustion.

| Check | Pattern | Status |
|-------|---------|--------|
| Connection timeout | Time to establish connection | Required |
| Request/response timeout | Total time for request completion | Required |
| Per-operation timeout | Different timeouts for different operations | Recommended |
| Timeout propagation | Timeouts passed through service calls | Required |
| Timeout on retries | Per-retry timeout, not just total | Recommended |
| Configurable timeouts | Timeouts via config, not hardcoded | Required |

**Search Patterns:**
```bash
# Find timeout configurations
grep -r "timeout\|Timeout\|TIMEOUT\|requestTimeout\|connectionTimeout\|socketTimeout" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find hardcoded timeout values
grep -rE "timeout.*[0-9]{4,}|[0-9]{4,}.*timeout" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find timeout in config files
grep -r "timeout" --include="*.env*" --include="*.yaml" --include="*.yml" --include="*.json" 2>/dev/null | head -10
```

#### 5. Error Handling & Classification

Proper error handling ensures failures are handled appropriately.

| Check | Pattern | Status |
|-------|---------|--------|
| Error classification | Transient vs permanent errors distinguished | Required |
| Custom error types | Domain-specific error classes | Recommended |
| Error context | Errors include request ID, user, operation | Required |
| No swallowed errors | All errors logged or handled | Critical |
| Error boundary | Prevents errors from crashing entire app | Required |
| Async error handling | Promises/goroutines have proper error handling | Required |

**Search Patterns:**
```bash
# Find error handling patterns
grep -r "catch\|except\|error\|Error\|throw\|raise" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find empty catch blocks (anti-pattern)
grep -rPzo "catch\s*\([^)]*\)\s*\{\s*\}" --include="*.ts" --include="*.js" 2>/dev/null | head -10
grep -rPzo "except.*:\s*pass" --include="*.py" 2>/dev/null | head -10

# Find error classification
grep -r "isRetryable\|retryable\|transient\|permanent\|Temporary\|Timeout" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 6. Rate Limiting & Throttling

Rate limiting protects against overload and abuse.

| Check | Pattern | Status |
|-------|---------|--------|
| Client rate limiting | Limit outgoing request rates | Recommended |
| Server rate limiting | Protect endpoints from overload | Required |
| Backpressure handling | Handle downstream slowness gracefully | Recommended |
| Queue/buffer limits | Bounded queues to prevent memory exhaustion | Required |
| Rate limit headers | X-RateLimit-* headers in responses | Recommended |
| Graceful rate limit response | 429 with Retry-After header | Required |

**Search Patterns:**
```bash
# Find rate limiting implementations
grep -r "rateLimit\|rate.*limit\|throttle\|Throttle\|limiter\|Limiter" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find rate limit libraries
grep -r "bottleneck\|rate-limiter\|ratelimit\|express-rate-limit\|limiter" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find 429 responses
grep -r "429\|TooManyRequests\|rate.*exceed" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 7. Bulkhead Pattern

Bulkheads isolate failures to prevent total system failure.

| Check | Pattern | Status |
|-------|---------|--------|
| Connection pool limits | Max connections per service | Required |
| Thread/process limits | Bounded concurrency | Required |
| Resource isolation | Separate pools for critical services | Recommended |
| Queue isolation | Separate queues per priority/service | Recommended |
| Timeout on pool acquisition | Fail fast if pool exhausted | Required |

**Search Patterns:**
```bash
# Find connection pool configurations
grep -r "pool\|Pool\|maxConnections\|connection.*limit\|poolSize" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find concurrency limits
grep -r "concurrency\|maxConcurrent\|concurrent.*limit\|worker.*limit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find bulkhead implementations
grep -r "bulkhead\|Bulkhead\|isolation" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific resilience gap
2. **Why it matters**: Impact on system reliability
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      ERROR RESILIENCE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
External Dependencies: [list of external services]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

CIRCUIT BREAKER
  [FAIL] No circuit breaker implementation
  [N/A]  Failure threshold (depends on breaker)
  [N/A]  Recovery state (depends on breaker)
  [N/A]  Fallback on open (depends on breaker)

RETRY STRATEGY
  [PASS] Retry implemented for HTTP calls
  [PASS] Exponential backoff configured
  [PASS] Max retry limit (3 retries)
  [WARN] No jitter in backoff
  [FAIL] Retryable errors not explicitly defined

FALLBACK MECHANISMS
  [FAIL] No fallback for payment service
  [WARN] Partial caching fallback for user service
  [PASS] Default values for feature flags

TIMEOUT CONFIGURATION
  [PASS] Connection timeout configured (5s)
  [PASS] Request timeout configured (30s)
  [WARN] Timeouts hardcoded, not configurable
  [FAIL] No timeout propagation to downstream

ERROR HANDLING
  [PASS] Error classification implemented
  [FAIL] Empty catch block in order processor
  [PASS] Error context includes trace ID
  [PASS] Error boundary at route level

RATE LIMITING
  [PASS] Rate limiting on public endpoints
  [FAIL] No client-side rate limiting
  [PASS] 429 responses with Retry-After

BULKHEAD
  [PASS] Database connection pool limited
  [FAIL] No connection pool timeout
  [WARN] No isolation between services

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Circuit Breaker Implementation
  Impact: Cascading failures will bring down entire system
  Fix: Add circuit breaker for all external service calls
  File: src/services/payment.service.ts

  import CircuitBreaker from 'opossum';

  const paymentBreaker = new CircuitBreaker(makePaymentRequest, {
    timeout: 10000,              // 10s timeout
    errorThresholdPercentage: 50, // Open if 50% fail
    resetTimeout: 30000          // Try again after 30s
  });

  paymentBreaker.fallback(() => ({
    success: false,
    error: 'Payment service unavailable',
    retryable: true
  }));

  export const processPayment = (data) => paymentBreaker.fire(data);

[CRITICAL] Empty Catch Block in Order Processor
  Impact: Errors silently swallowed, debugging impossible
  Fix: Log all errors and propagate or handle appropriately
  File: src/services/order.processor.ts

  // BEFORE (bad):
  try {
    await processOrder(order);
  } catch (e) {}

  // AFTER (good):
  try {
    await processOrder(order);
  } catch (error) {
    logger.error('Order processing failed', {
      orderId: order.id,
      error: error.message,
      stack: error.stack,
      traceId: getTraceId()
    });
    await queueForRetry(order);
    metrics.increment('order.processing.failed');
  }

[HIGH] No Fallback for Payment Service
  Impact: Complete payment failure when service is down
  Fix: Implement queue-based fallback for async processing
  File: src/services/payment.service.ts

  paymentBreaker.fallback(async (paymentData) => {
    // Queue for async processing
    await paymentQueue.add('retry', paymentData, {
      attempts: 5,
      backoff: {
        type: 'exponential',
        delay: 60000 // Start at 1 minute
      }
    });

    return {
      status: 'queued',
      message: 'Payment queued for processing',
      paymentId: paymentData.id
    };
  });

[HIGH] No Timeout Propagation
  Impact: Downstream timeouts don't respect upstream deadlines
  Fix: Propagate remaining time to downstream calls
  File: src/utils/http-client.ts

  import { context, trace } from '@opentelemetry/api';

  export async function fetchWithTimeout(url, options = {}) {
    const span = trace.getActiveSpan();
    const deadline = span ? span.endTime : null;
    const remainingTime = deadline ? deadline - Date.now() : 30000;

    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      Math.min(options.timeout || 30000, remainingTime)
    );

    try {
      return await fetch(url, {
        ...options,
        signal: controller.signal
      });
    } finally {
      clearTimeout(timeout);
    }
  }

[MEDIUM] No Jitter in Retry Backoff
  Impact: Retry storms can overwhelm recovering services
  Fix: Add jitter to backoff delays
  File: src/utils/retry.ts

  function calculateBackoff(attempt, baseDelay = 1000) {
    const exponentialDelay = baseDelay * Math.pow(2, attempt);
    const jitter = Math.random() * 0.5 * exponentialDelay; // 0-50% jitter
    return exponentialDelay + jitter;
  }

[MEDIUM] Timeouts Hardcoded
  Impact: Cannot adjust timeouts without code deployment
  Fix: Move timeouts to configuration
  File: config/app.yaml

  timeouts:
    connection: 5000
    request: 30000
    services:
      payment: 10000
      inventory: 5000
      notification: 3000

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement circuit breakers for all external services
2. [CRITICAL] Fix empty catch blocks - log and handle all errors
3. [HIGH] Add fallback mechanisms for critical services
4. [HIGH] Implement timeout propagation
5. [MEDIUM] Add jitter to retry backoff
6. [MEDIUM] Move timeouts to configuration

After Production:
1. Add resilience dashboards (circuit state, retry rates)
2. Implement chaos engineering tests
3. Add client-side rate limiting
4. Create service isolation with bulkheads
5. Document SLOs for each external service

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
| Circuit Breaker | 20% |
| Retry Strategy | 20% |
| Fallback Mechanisms | 15% |
| Timeout Configuration | 15% |
| Error Handling | 15% |
| Rate Limiting | 10% |
| Bulkhead | 5% |

---

## Quick Reference: Implementation Patterns

### Circuit Breaker (TypeScript with Opossum)

```typescript
import CircuitBreaker from 'opossum';
import logger from './logger';
import metrics from './metrics';

// Circuit breaker configuration
const breakerOptions = {
  timeout: 10000,               // If function takes longer than 10s, trigger failure
  errorThresholdPercentage: 50, // When 50% of requests fail, open the circuit
  resetTimeout: 30000,          // After 30s, try again (half-open state)
  volumeThreshold: 10,          // Minimum requests before calculating percentage
};

// Create breaker for payment service
const paymentBreaker = new CircuitBreaker(callPaymentService, breakerOptions);

// Fallback when circuit is open
paymentBreaker.fallback((params) => {
  logger.warn('Payment service circuit open, using fallback', { params });
  return {
    success: false,
    queued: true,
    message: 'Payment queued for later processing'
  };
});

// Monitor circuit state changes
paymentBreaker.on('open', () => {
  logger.error('Payment circuit opened');
  metrics.increment('circuit_breaker.opened', { service: 'payment' });
});

paymentBreaker.on('halfOpen', () => {
  logger.info('Payment circuit half-open, testing...');
  metrics.increment('circuit_breaker.half_open', { service: 'payment' });
});

paymentBreaker.on('close', () => {
  logger.info('Payment circuit closed, service recovered');
  metrics.increment('circuit_breaker.closed', { service: 'payment' });
});

export const processPayment = (paymentData) => paymentBreaker.fire(paymentData);
```

### Retry with Exponential Backoff (TypeScript)

```typescript
interface RetryOptions {
  maxRetries: number;
  baseDelay: number;
  maxDelay: number;
  retryableErrors: (error: Error) => boolean;
}

async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions
): Promise<T> {
  const { maxRetries, baseDelay, maxDelay, retryableErrors } = options;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      const isLastAttempt = attempt === maxRetries;
      const isRetryable = retryableErrors(error);

      if (isLastAttempt || !isRetryable) {
        throw error;
      }

      // Exponential backoff with jitter
      const exponentialDelay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
      const jitter = Math.random() * 0.5 * exponentialDelay;
      const delay = exponentialDelay + jitter;

      logger.warn('Retrying after error', {
        attempt: attempt + 1,
        maxRetries,
        delay,
        error: error.message
      });

      await sleep(delay);
    }
  }

  throw new Error('Max retries exceeded');
}

// Usage
const result = await retryWithBackoff(
  () => fetchExternalAPI(url),
  {
    maxRetries: 3,
    baseDelay: 1000,
    maxDelay: 30000,
    retryableErrors: (err) => isTransientError(err)
  }
);

function isTransientError(error: Error): boolean {
  // Retry on network errors, timeouts, and 5xx responses
  return (
    error.name === 'NetworkError' ||
    error.name === 'TimeoutError' ||
    (error as any).statusCode >= 500 ||
    (error as any).code === 'ECONNRESET'
  );
}
```

### Fallback with Cache (TypeScript)

```typescript
import { Cache } from './cache';

async function getUserWithFallback(userId: string): Promise<User> {
  const cacheKey = `user:${userId}`;

  try {
    // Try primary source
    const user = await userService.getUser(userId);

    // Update cache on success
    await cache.set(cacheKey, user, { ttl: 300 }); // 5 minutes

    return user;
  } catch (error) {
    logger.error('User service failed, attempting cache fallback', {
      userId,
      error: error.message
    });

    // Try cache fallback
    const cachedUser = await cache.get<User>(cacheKey);
    if (cachedUser) {
      logger.info('Returning cached user data', { userId });
      metrics.increment('fallback.cache_hit', { service: 'user' });
      return { ...cachedUser, _stale: true }; // Mark as stale
    }

    // No cache, return safe default
    logger.warn('No cache available, returning default user', { userId });
    metrics.increment('fallback.default', { service: 'user' });
    return getDefaultUser();
  }
}
```

### Timeout with AbortController (TypeScript)

```typescript
interface FetchOptions extends RequestInit {
  timeout?: number;
}

async function fetchWithTimeout(
  url: string,
  options: FetchOptions = {}
): Promise<Response> {
  const { timeout = 30000, ...fetchOptions } = options;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      ...fetchOptions,
      signal: controller.signal,
    });

    return response;
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new TimeoutError(`Request timed out after ${timeout}ms`);
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
}

// Propagate timeout from incoming request
async function handleRequest(req: Request, res: Response) {
  const deadline = req.headers.get('x-request-deadline');
  const remainingTime = deadline
    ? Math.max(0, parseInt(deadline) - Date.now())
    : 30000;

  const response = await fetchWithTimeout(externalUrl, {
    timeout: Math.min(remainingTime, 10000) // Max 10s for this call
  });
}
```

### Rate Limiting (TypeScript with Bottleneck)

```typescript
import Bottleneck from 'bottleneck';

// Rate limiter for external API
const apiLimiter = new Bottleneck({
  minTime: 100,      // Minimum 100ms between requests (10 req/s)
  maxConcurrent: 5,  // Max 5 concurrent requests
  reservoir: 100,    // Start with 100 requests
  reservoirRefreshAmount: 100,
  reservoirRefreshInterval: 60000, // Refresh every minute
});

// Handle rate limit errors
apiLimiter.on('failed', async (error, jobInfo) => {
  if (error.statusCode === 429) {
    const retryAfter = error.headers?.['retry-after'] || 60;
    return retryAfter * 1000; // Retry after X seconds
  }
});

export const rateLimitedFetch = apiLimiter.wrap(fetchExternalAPI);
```

### Bulkhead with Connection Pool (TypeScript)

```typescript
import { Pool } from 'pg';

// Isolated connection pools per service priority
const criticalPool = new Pool({
  max: 20,                    // Max connections
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 30000,
});

const standardPool = new Pool({
  max: 10,
  connectionTimeoutMillis: 3000,
  idleTimeoutMillis: 30000,
});

// Use appropriate pool based on priority
async function queryDatabase(query: string, priority: 'critical' | 'standard') {
  const pool = priority === 'critical' ? criticalPool : standardPool;

  try {
    return await pool.query(query);
  } catch (error) {
    if (error.code === 'ETIMEDOUT') {
      throw new Error('Connection pool exhausted');
    }
    throw error;
  }
}
```

### Error Classification (TypeScript)

```typescript
enum ErrorType {
  TRANSIENT = 'TRANSIENT',     // Retry may succeed
  PERMANENT = 'PERMANENT',     // Retry won't help
  TIMEOUT = 'TIMEOUT',         // Request timed out
  RATE_LIMIT = 'RATE_LIMIT',   // Rate limited, retry after delay
}

class AppError extends Error {
  constructor(
    message: string,
    public type: ErrorType,
    public retryable: boolean,
    public statusCode?: number,
    public retryAfter?: number
  ) {
    super(message);
    this.name = 'AppError';
  }
}

function classifyError(error: Error): AppError {
  // Network/timeout errors
  if (error.name === 'AbortError' || error.message.includes('timeout')) {
    return new AppError(error.message, ErrorType.TIMEOUT, true);
  }

  // HTTP status codes
  const statusCode = (error as any).statusCode;
  if (statusCode) {
    if (statusCode === 429) {
      const retryAfter = (error as any).headers?.['retry-after'];
      return new AppError(
        'Rate limited',
        ErrorType.RATE_LIMIT,
        true,
        statusCode,
        retryAfter ? parseInt(retryAfter) : 60
      );
    }

    if (statusCode >= 500) {
      return new AppError(error.message, ErrorType.TRANSIENT, true, statusCode);
    }

    if (statusCode >= 400) {
      return new AppError(error.message, ErrorType.PERMANENT, false, statusCode);
    }
  }

  // Default to transient
  return new AppError(error.message, ErrorType.TRANSIENT, true);
}
```

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For monitoring and alerting on resilience metrics
- `/devops-review` - For deployment safety and rollback
- `/api-readiness-review` - For API error responses and rate limiting
- `/quality-check` - For code quality in error handling
