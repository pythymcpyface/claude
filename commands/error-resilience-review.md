---
description: Production readiness review for Error Resilience. Reviews circuit breaker patterns, retry strategies, fallback mechanisms, timeout configurations, and graceful degradation. Use PROACTIVELY before production releases, when integrating external services, or implementing critical workflows.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Error Resilience Review Command

Run a comprehensive error resilience review before production release.

## Purpose

Review code for error resilience patterns to ensure:
- Circuit breakers prevent cascading failures
- Retry strategies handle transient failures with exponential backoff
- Fallback mechanisms provide graceful degradation
- Timeouts prevent hanging requests and resource exhaustion
- Error handling properly classifies and handles errors
- Rate limiting protects against overload
- Bulkheads isolate failures to prevent total system failure

## The Critical Importance

**External service failures are inevitable.** Without proper error resilience, a single failing dependency can cascade through your entire system, causing widespread outages. Circuit breakers, retries, and fallbacks are essential defense mechanisms that keep your system running even when dependencies fail.

## Workflow

### 1. Load the Error Resilience Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/error-resilience-review/SKILL.md
```

### 2. Detect Stack and Dependencies

Identify the technology stack and external dependencies:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null && echo "Stack detected"

# Detect external service integrations
grep -rE "https?://|api\.|\.api\." --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.env*" 2>/dev/null | head -20

# Detect resilience libraries
grep -r "opossum\|brakes\|resilience4j\|polly\|hystrix\|tenacity\|circuit.*breaker" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Detect HTTP clients (integration points)
grep -r "axios\|fetch\|got\|superagent\|httpx\|aiohttp\|reqwest\|resty" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

### 3. Run Resilience Checks

Execute checks for each resilience pattern category:

**Circuit Breaker:**
```bash
# Find circuit breaker implementations
grep -r "circuit.*breaker\|circuitBreaker\|CircuitBreaker\|breaker\." --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find resilience libraries
grep -r "opossum\|brakes\|resilience4j\|polly\|hystrix" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10

# Check for failure threshold configs
grep -r "failureThreshold\|errorThreshold\|errorThresholdPercentage" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Retry Strategy:**
```bash
# Find retry implementations
grep -r "retry\|Retry\|retries\|maxRetries" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find exponential backoff
grep -r "exponential\|backoff\|backOff" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find jitter
grep -r "jitter\|random.*delay" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Fallback Mechanisms:**
```bash
# Find fallback implementations
grep -r "fallback\|Fallback\|onFailure\|catch.*return" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find graceful degradation
grep -r "graceful\|degraded\|degradation" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Timeout Configuration:**
```bash
# Find timeout configurations
grep -r "timeout\|Timeout\|TIMEOUT" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Check config files for timeouts
grep -r "timeout" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env*" 2>/dev/null | head -15
```

**Error Handling:**
```bash
# Find error handling patterns
grep -r "catch\|except\|error\|Error" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find empty catch blocks (anti-pattern)
grep -rPzo "catch\s*\([^)]*\)\s*\{\s*\}" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Find error classification
grep -r "isRetryable\|retryable\|transient\|permanent\|Temporary" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Rate Limiting:**
```bash
# Find rate limiting
grep -r "rateLimit\|rate.*limit\|throttle\|Limiter" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find 429 responses
grep -r "429\|TooManyRequests" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Bulkhead:**
```bash
# Find connection pools
grep -r "pool\|Pool\|maxConnections\|poolSize" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find concurrency limits
grep -r "concurrency\|maxConcurrent\|bulkhead" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Evaluate each category (Circuit Breaker, Retry, Fallback, Timeout, Error Handling, Rate Limiting, Bulkhead)
- Count passed/failed/warn items per category
- Calculate category scores based on weight distribution
- Calculate overall score
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All critical patterns implemented |
| 70-89 | NEEDS WORK | Minor gaps in resilience |
| 50-69 | AT RISK | Significant gaps, high risk of cascading failures |
| 0-49 | BLOCK | Critical gaps, will fail under load |

**Category Weights:**
- Circuit Breaker: 20%
- Retry Strategy: 20%
- Fallback Mechanisms: 15%
- Timeout Configuration: 15%
- Error Handling: 15%
- Rate Limiting: 10%
- Bulkhead: 5%

### 5. Generate Report

Output the formatted report with:
- Executive summary with overall resilience posture
- Overall score and blocking status
- Checklist results (PASS/FAIL/WARN/N/A for each item)
- Gap analysis with specific code examples
- Prioritized recommendations
- Quick reference implementation patterns

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Implement circuit breakers for all external services
2. [CRITICAL] Fix empty catch blocks and swallowed errors
3. [HIGH] Add fallback mechanisms for critical service failures
4. [HIGH] Configure timeouts on all external calls

**Short-term (Within 1 week):**
5. [MEDIUM] Add jitter to retry backoff
6. [MEDIUM] Move timeouts to configuration
7. [MEDIUM] Implement proper error classification

**Long-term:**
8. [LOW] Add client-side rate limiting
9. [LOW] Implement bulkhead isolation
10. [LOW] Add resilience monitoring dashboards

## Usage

```
/error-resilience-review
```

## When to Use

- Before any production release with external dependencies
- When adding new external service integrations
- After implementing payment, notification, or third-party services
- During architecture reviews for distributed systems
- After a service outage to identify resilience gaps
- When implementing microservice communication

## Blocking Conditions

This command will **recommend blocking** production release if:
- No circuit breakers for critical external services
- Empty catch blocks that swallow errors
- No timeout configuration on external calls
- No retry mechanism for transient failures

## Integration with Other Commands

Run alongside other production readiness checks:
- `/observability-check` - For monitoring resilience metrics
- `/devops-review` - For deployment safety
- `/api-readiness-review` - For API error handling
- `/quality-check` - For code quality

## Example Output

```
═══════════════════════════════════════════════════════════════
      ERROR RESILIENCE PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: payment-service
Stack: Node.js/TypeScript
External Dependencies: Stripe, Twilio, Internal APIs
Date: 2026-02-27

OVERALL SCORE: 55/100 [AT RISK]

───────────────────────────────────────────────────────────────
              EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Resilience Posture: MODERATE RISK
- Circuit breakers: Not implemented (CRITICAL)
- Retry logic: Partially implemented
- Fallbacks: Not implemented for critical paths
- Timeouts: Configured but not propagated

RECOMMENDATION: Address critical gaps before production

═══════════════════════════════════════════════════════════════
```
