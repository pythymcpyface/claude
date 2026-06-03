# error-resilience-review — Implementation Patterns

Reusable code snippets and configuration templates for error-resilience-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

