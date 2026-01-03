# Error Classification & Recovery Skill

## Overview
Comprehensive strategies for classifying errors and implementing intelligent escalation strategies in autonomous systems, particularly for AI agents and fault-tolerant services.

## When to Activate
- Building autonomous systems with AI agents
- Implementing retry logic for external services
- Designing fault-tolerant systems
- Creating resilient API integrations
- Developing background job processors

## Error Taxonomy

### 1. Transient Errors (Retry Immediately)

**Characteristics:**
- Temporary condition
- Likely to succeed on retry
- No code changes needed

**Examples:**
- Network timeouts
- API rate limits (429)
- Temporary service unavailability (503)
- Database connection pool exhausted
- Temporary lock contention

**Recovery Strategy:**
```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 30000,
    exponential = true,
  } = options;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      // Don't retry if error is not transient
      if (!isTransientError(error)) {
        throw error;
      }

      // Don't retry if this was the last attempt
      if (attempt === maxRetries) {
        throw new Error(`Failed after ${maxRetries} attempts: ${error.message}`);
      }

      // Calculate delay with exponential backoff
      const delay = exponential
        ? Math.min(baseDelay * Math.pow(2, attempt - 1), maxDelay)
        : baseDelay;

      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
      await sleep(delay);
    }
  }
}

function isTransientError(error: any): boolean {
  // HTTP status codes
  if (error.status === 429) return true; // Rate limit
  if (error.status === 503) return true; // Service unavailable
  if (error.status === 504) return true; // Gateway timeout

  // Network errors
  if (error.code === 'ECONNRESET') return true;
  if (error.code === 'ETIMEDOUT') return true;
  if (error.code === 'ENOTFOUND') return true;

  // Database errors
  if (error.message?.includes('connection pool exhausted')) return true;
  if (error.message?.includes('deadlock')) return true;

  return false;
}
```

### 2. Permanent Errors (Escalate)

**Characteristics:**
- Will not succeed on retry
- Requires intervention or code changes
- Should fail fast

**Examples:**
- Invalid API keys (401, 403)
- Malformed input (400)
- Unsupported operations (405, 501)
- Schema validation errors
- Resource not found (404)

**Recovery Strategy:**
```typescript
class PermanentError extends Error {
  constructor(
    message: string,
    public readonly context: Record<string, any>
  ) {
    super(message);
    this.name = 'PermanentError';
  }
}

async function handlePermanentError(error: Error, context: any) {
  // Log for debugging
  logger.error('Permanent error encountered', {
    error: error.message,
    stack: error.stack,
    context,
  });

  // Escalate to monitoring
  await notifyAdmin({
    severity: 'high',
    title: 'Permanent Error Detected',
    message: error.message,
    requiresAction: true,
    context,
  });

  // Record in error tracking
  await errorTracker.record({
    type: 'permanent',
    error,
    context,
    timestamp: new Date(),
  });

  // Fail fast - don't waste resources retrying
  throw new PermanentError(error.message, context);
}

function isPermanentError(error: any): boolean {
  // HTTP status codes
  if (error.status === 400) return true; // Bad request
  if (error.status === 401) return true; // Unauthorized
  if (error.status === 403) return true; // Forbidden
  if (error.status === 404) return true; // Not found
  if (error.status === 405) return true; // Method not allowed

  // Validation errors
  if (error.name === 'ValidationError') return true;
  if (error.message?.includes('validation failed')) return true;

  // Schema errors
  if (error.message?.includes('schema mismatch')) return true;

  return false;
}
```

### 3. Partial Errors (Replan)

**Characteristics:**
- Some operations succeeded, others failed
- Need to track partial progress
- Can continue with successful portion

**Examples:**
- Batch operations where 5/10 succeed
- Multi-step workflows where step 3/5 fails
- Parallel operations with mixed results
- File uploads where some files succeed

**Recovery Strategy:**
```typescript
interface OperationResult<T> {
  success: boolean;
  data?: T;
  error?: Error;
  id: string;
}

async function recoverPartialFailure<T>(
  results: OperationResult<T>[]
): Promise<RecoveryResult<T>> {
  // Separate succeeded and failed operations
  const succeeded = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  // Mark succeeded operations as complete
  await markComplete(succeeded.map(r => r.id));

  // Log partial success
  logger.info('Partial operation completed', {
    total: results.length,
    succeeded: succeeded.length,
    failed: failed.length,
  });

  // Classify failed operations
  const transient = failed.filter(r => isTransientError(r.error));
  const permanent = failed.filter(r => isPermanentError(r.error));

  // Replan for transient failures
  if (transient.length > 0) {
    logger.info(`Rescheduling ${transient.length} transient failures`);
    await scheduleRetry(transient.map(r => r.id));
  }

  // Escalate permanent failures
  if (permanent.length > 0) {
    logger.error(`${permanent.length} permanent failures detected`);
    await notifyAdmin({
      severity: 'medium',
      message: `Permanent failures in batch operation`,
      details: permanent,
    });
  }

  return {
    completedCount: succeeded.length,
    retriedCount: transient.length,
    failedCount: permanent.length,
    replanStrategy: transient.length > 0 ? 'scheduled_retry' : 'none',
  };
}
```

### 4. Resource Errors (Backoff)

**Characteristics:**
- System resource constraints
- Need to reduce load
- May require scaling

**Examples:**
- Out of memory (OOM)
- Disk full
- Quota exceeded
- Connection pool exhausted
- CPU throttling

**Recovery Strategy:**
```typescript
class ResourceThrottle {
  private currentCapacity: number = 1.0; // 100%

  async handleResourceError(error: ResourceError) {
    // Immediately reduce load
    await this.reduce(0.5); // Drop to 50% capacity

    // Log the issue
    logger.warn('Resource constraint detected', {
      error: error.message,
      newCapacity: this.currentCapacity,
    });

    // Wait for resources to free up
    const backoffTime = this.calculateBackoff(error);
    await sleep(backoffTime);

    // Gradually ramp back up
    await this.gradualIncrease();
  }

  async reduce(factor: number) {
    this.currentCapacity *= factor;
    await this.applyCapacityLimit();
  }

  async gradualIncrease() {
    const steps = 10;
    const increment = (1.0 - this.currentCapacity) / steps;

    for (let i = 0; i < steps; i++) {
      this.currentCapacity += increment;
      await this.applyCapacityLimit();
      await sleep(5000); // 5 seconds between steps
    }
  }

  private calculateBackoff(error: ResourceError): number {
    switch (error.type) {
      case 'memory':
        return 30000; // 30 seconds
      case 'disk':
        return 60000; // 1 minute
      case 'quota':
        return 300000; // 5 minutes
      default:
        return 10000; // 10 seconds
    }
  }

  private async applyCapacityLimit() {
    // Implement capacity limiting (e.g., reduce worker count)
    const maxConcurrent = Math.floor(100 * this.currentCapacity);
    await updateWorkerPool(maxConcurrent);
  }
}
```

## Multi-Level Escalation Strategy

### Level 1: Same Model Retry (with error context)

Retry with the same system but provide error context.

```typescript
async function retryWithContext<T>(
  operation: (prompt: string) => Promise<T>,
  prompt: string,
  maxRetries: number = 2
): Promise<T> {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      // First attempt uses original prompt
      if (attempt === 1) {
        return await operation(prompt);
      }

      // Subsequent attempts include error context
      const contextualPrompt = `
${prompt}

Note: Previous attempt failed with error: ${lastError?.message}
Please try again, taking this error into account.
      `.trim();

      return await operation(contextualPrompt);
    } catch (error) {
      lastError = error;
      if (attempt === maxRetries) {
        throw error;
      }
    }
  }

  throw lastError;
}
```

### Level 2: Model Switch (more capable model)

Escalate to a more powerful model or system.

```typescript
async function executeWithEscalation<T>(
  task: string,
  options: EscalationOptions = {}
): Promise<T> {
  const { tryHaiku = true, trySonnet = true, tryOpus = true } = options;

  // Level 1: Try fast model (Haiku)
  if (tryHaiku) {
    try {
      logger.info('Attempting with Haiku model');
      return await haiku.execute(task);
    } catch (error) {
      logger.warn('Haiku failed, escalating to Sonnet', { error: error.message });
    }
  }

  // Level 2: Try mid-tier model (Sonnet)
  if (trySonnet) {
    try {
      logger.info('Attempting with Sonnet model');
      return await sonnet.execute(task);
    } catch (error) {
      logger.warn('Sonnet failed, escalating to Opus', { error: error.message });
    }
  }

  // Level 3: Try most capable model (Opus)
  if (tryOpus) {
    try {
      logger.info('Attempting with Opus model');
      return await opus.execute(task);
    } catch (error) {
      logger.error('All models failed', { error: error.message });
      throw new Error(`All escalation levels failed: ${error.message}`);
    }
  }

  throw new Error('No escalation options enabled');
}
```

### Level 3: Human Intervention

When all automated recovery fails, pause and notify humans.

```typescript
interface HumanInterventionRequest {
  severity: 'low' | 'medium' | 'high' | 'critical';
  title: string;
  description: string;
  context: Record<string, any>;
  suggestedActions: string[];
}

async function requestHumanIntervention(request: HumanInterventionRequest) {
  // Pause the system
  await pauseSystem();

  // Log the intervention request
  logger.critical('Human intervention required', request);

  // Notify administrators
  await notifyAdmin({
    severity: request.severity,
    title: request.title,
    message: request.description,
    requiresAction: true,
    context: request.context,
    suggestedActions: request.suggestedActions,
  });

  // Create ticket in issue tracker
  await createTicket({
    priority: request.severity,
    title: request.title,
    description: request.description,
    labels: ['human-intervention-required', 'system-paused'],
  });

  // Wait for resolution
  await waitForResolution();

  // Resume system
  await resumeSystem();
}

async function handleCriticalFailure(error: Error, context: any) {
  if (requiresHumanIntervention(error)) {
    await requestHumanIntervention({
      severity: 'critical',
      title: 'System paused - critical failure',
      description: `A critical error occurred that requires human intervention: ${error.message}`,
      context: {
        error: error.stack,
        systemState: await captureSystemState(),
        ...context,
      },
      suggestedActions: [
        'Review error logs',
        'Check system resources',
        'Verify external dependencies',
        'Consider rollback to previous version',
      ],
    });
  }
}
```

## Error Classification Function

Centralized error classification logic.

```typescript
enum ErrorType {
  TRANSIENT_RATE_LIMIT = 'transient_rate_limit',
  TRANSIENT_TIMEOUT = 'transient_timeout',
  TRANSIENT_SERVICE = 'transient_service',
  PERMANENT_AUTH = 'permanent_auth',
  PERMANENT_VALIDATION = 'permanent_validation',
  PERMANENT_NOT_FOUND = 'permanent_not_found',
  RESOURCE_MEMORY = 'resource_memory',
  RESOURCE_DISK = 'resource_disk',
  RESOURCE_QUOTA = 'resource_quota',
  PARTIAL = 'partial',
  UNKNOWN = 'unknown',
}

interface ClassifiedError {
  type: ErrorType;
  retryable: boolean;
  escalate: boolean;
  backoffMs: number;
}

function classifyError(error: any): ClassifiedError {
  // HTTP status codes
  if (error.status === 429) {
    return {
      type: ErrorType.TRANSIENT_RATE_LIMIT,
      retryable: true,
      escalate: false,
      backoffMs: 60000, // 1 minute
    };
  }

  if (error.status === 503 || error.status === 504) {
    return {
      type: ErrorType.TRANSIENT_SERVICE,
      retryable: true,
      escalate: false,
      backoffMs: 5000,
    };
  }

  if (error.status === 401 || error.status === 403) {
    return {
      type: ErrorType.PERMANENT_AUTH,
      retryable: false,
      escalate: true,
      backoffMs: 0,
    };
  }

  if (error.status === 400 || error.status === 422) {
    return {
      type: ErrorType.PERMANENT_VALIDATION,
      retryable: false,
      escalate: true,
      backoffMs: 0,
    };
  }

  // Error messages
  if (error.message?.includes('timeout')) {
    return {
      type: ErrorType.TRANSIENT_TIMEOUT,
      retryable: true,
      escalate: false,
      backoffMs: 3000,
    };
  }

  if (error.message?.includes('out of memory')) {
    return {
      type: ErrorType.RESOURCE_MEMORY,
      retryable: true,
      escalate: true,
      backoffMs: 30000,
    };
  }

  if (error.message?.includes('quota exceeded')) {
    return {
      type: ErrorType.RESOURCE_QUOTA,
      retryable: true,
      escalate: true,
      backoffMs: 300000, // 5 minutes
    };
  }

  // Default to unknown permanent error
  return {
    type: ErrorType.UNKNOWN,
    retryable: false,
    escalate: true,
    backoffMs: 0,
  };
}
```

## Recovery Decision Tree

```typescript
async function handleError(error: Error, context: any): Promise<any> {
  const classified = classifyError(error);

  logger.info('Error classified', {
    type: classified.type,
    retryable: classified.retryable,
    escalate: classified.escalate,
  });

  // Decision tree
  if (classified.retryable) {
    // Transient or resource errors - retry
    if (classified.backoffMs > 0) {
      await sleep(classified.backoffMs);
    }

    if (classified.type.startsWith('resource_')) {
      // Resource errors - reduce load
      await resourceThrottle.handleResourceError(error);
    }

    return 'retry';
  }

  if (classified.escalate) {
    // Permanent errors - escalate
    await handlePermanentError(error, context);
    return 'escalated';
  }

  // Unknown handling
  logger.error('Unhandled error type', { error, classified });
  throw error;
}
```

## Monitoring & Metrics

Track error patterns to improve classification and recovery.

```typescript
interface ErrorMetrics {
  errorTypeDistribution: Record<ErrorType, number>;
  retrySuccessRate: number;
  escalationFrequency: number;
  averageRecoveryTime: number;
  humanInterventionRate: number;
}

class ErrorMetricsTracker {
  private metrics: ErrorMetrics = {
    errorTypeDistribution: {} as Record<ErrorType, number>,
    retrySuccessRate: 0,
    escalationFrequency: 0,
    averageRecoveryTime: 0,
    humanInterventionRate: 0,
  };

  recordError(type: ErrorType, recovered: boolean, recoveryTimeMs: number) {
    // Update distribution
    this.metrics.errorTypeDistribution[type] =
      (this.metrics.errorTypeDistribution[type] || 0) + 1;

    // Update recovery metrics
    if (recovered) {
      this.updateRecoveryTime(recoveryTimeMs);
    }
  }

  private updateRecoveryTime(timeMs: number) {
    // Update rolling average
    const alpha = 0.1; // Smoothing factor
    this.metrics.averageRecoveryTime =
      alpha * timeMs + (1 - alpha) * this.metrics.averageRecoveryTime;
  }

  getReport(): ErrorMetrics {
    return { ...this.metrics };
  }
}
```

## Best Practices

1. **Classify Early**: Determine error type immediately
2. **Fail Fast**: Don't retry permanent errors
3. **Exponential Backoff**: Prevent thundering herd
4. **Context Preservation**: Include context in retries
5. **Circuit Breakers**: Stop retrying if system is down
6. **Graceful Degradation**: Provide partial functionality
7. **Monitoring**: Track error patterns and recovery success
