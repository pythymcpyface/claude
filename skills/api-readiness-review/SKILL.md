---
name: api-readiness-review
description: Production readiness review for API design. Reviews versioning strategy, rate limiting implementation, and documentation completeness before production release. Use PROACTIVELY before releasing APIs, when adding new endpoints, or modifying API contracts.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# API Readiness Review Skill

Production readiness code review focused on API design and contract quality. Ensures APIs are ready for production with proper versioning, rate limiting, and documentation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "api", "endpoint", "route", "rest", "graphql", "grpc"
- New API endpoints or routes are added
- OpenAPI/Swagger specs are modified
- API middleware or interceptors are changed
- Rate limiting or throttling code is modified
- Before major version releases of APIs
- When deprecating or removing endpoints

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's API technology stack to apply appropriate checks:

```bash
# Detect REST API frameworks
grep -r "express\|fastify\|nestjs\|koa\|hapi\|fastapi\|flask\|django\|gin\|echo\|fiber" package.json requirements.txt go.mod 2>/dev/null && echo "REST API detected"

# Detect GraphQL
grep -r "graphql\|apollo\|hasura\|gql" package.json requirements.txt go.mod 2>/dev/null && echo "GraphQL detected"

# Detect gRPC
grep -r "grpc\|protobuf\|proto3" package.json requirements.txt go.mod go.sum 2>/dev/null && echo "gRPC detected"

# Detect OpenAPI/Swagger
find . -name "openapi*.yaml" -o -name "openapi*.json" -o -name "swagger*.yaml" -o -name "swagger*.json" 2>/dev/null | head -5

# Detect API gateway/middleware
grep -r "rate.*limit\|throttle\|cors\|helmet" package.json requirements.txt go.mod 2>/dev/null
```

### Phase 2: API Readiness Checklist

Run all checks and compile results:

#### 1. API Versioning Review

| Check | Pattern | Status |
|-------|---------|--------|
| Version strategy | URL path (/v1/), header (Accept-Version), or query param | Required |
| Version in routes | All endpoints include version prefix | Required |
| Backward compatibility | Non-breaking changes in minor versions | Required |
| Deprecation headers | Sunset header for deprecated endpoints | Recommended |
| Version documentation | Changelog/README for version changes | Required |
| Breaking change policy | Documented process for major version bumps | Recommended |
| Content negotiation | Accept header versioning support | Recommended |

**Search Patterns:**
```bash
# Find version prefixes in routes
grep -r "/v[0-9]\|/api/v[0-9]\|version.*[0-9]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for version middleware
grep -r "version\|accept.*version\|api-version" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find deprecation/sunset headers
grep -r "sunset\|deprecat\|x-api-version\|Deprecation" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Check route definitions
grep -r "router\.\|app\.\|Route\|@Route\|@Get\|@Post" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30
```

#### 2. Rate Limiting Review

| Check | Pattern | Status |
|-------|---------|--------|
| Rate limiter present | Global or per-endpoint rate limiting | Required |
| 429 response handling | Proper HTTP 429 Too Many Requests | Required |
| Retry-After header | Clients know when to retry | Required |
| Rate limit headers | X-RateLimit-Limit, -Remaining, -Reset | Recommended |
| Per-user limits | Authenticated users have higher limits | Recommended |
| Per-endpoint limits | Expensive operations have stricter limits | Recommended |
| Graceful degradation | Service degrades, not crashes, under load | Required |
| Rate limit bypass | Admin/internal bypass for emergencies | Recommended |

**Search Patterns:**
```bash
# Find rate limiting implementations
grep -r "rateLimit\|rate.*limit\|throttle\|ratelimit\|rate-limiter" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for rate limit libraries
grep -r "express-rate-limit\|rate-limiter-flexible\|flask-limiter\|django-ratelimit\|gin-limiter" package.json requirements.txt go.mod 2>/dev/null

# Find 429 responses
grep -r "429\|TooManyRequests\|too.*many.*requests" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Check for Retry-After header
grep -r "Retry-After\|retryAfter\|retry.*after" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find rate limit headers
grep -r "X-RateLimit\|X-Rate-Limit\|ratelimit.*header\|rateLimitHeaders" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 3. API Documentation Review

| Check | Pattern | Status |
|-------|---------|--------|
| OpenAPI/Swagger spec | API specification file present | Required |
| Request examples | Example payloads for all operations | Required |
| Response examples | Example responses including errors | Required |
| Error documentation | All error codes documented with solutions | Required |
| Authentication docs | Auth methods and requirements documented | Required |
| Version documentation | Version differences documented | Required |
| Interactive docs | Swagger UI, Redoc, or similar | Recommended |
| Changelog | API changes documented per version | Recommended |

**Search Patterns:**
```bash
# Find OpenAPI/Swagger specs
find . -name "openapi*.yaml" -o -name "openapi*.json" -o -name "swagger*.yaml" -o -name "swagger*.json" -o -name "api-spec*.yaml" 2>/dev/null | head -10

# Check for Swagger/OpenAPI libraries
grep -r "swagger\|openapi\|swagger-ui\|redoc\|swagger-jsdoc" package.json requirements.txt go.mod 2>/dev/null

# Find documentation routes
grep -r "/docs\|/swagger\|/api-docs\|/redoc" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Check for JSDoc/API documentation
grep -r "@api\|@operation\|@response\|@param" --include="*.ts" --include="*.js" 2>/dev/null | head -20

# Find README or API docs
find . -name "README*.md" -o -name "API*.md" -o -name "api-docs" -type d 2>/dev/null | head -10
```

#### 4. REST/GraphQL/gRPC Specific Checks

**REST API Specific:**
| Check | Pattern | Status |
|-------|---------|--------|
| HTTP methods | Correct use of GET, POST, PUT, PATCH, DELETE | Required |
| Status codes | Appropriate status codes (200, 201, 400, 404, 500) | Required |
| Resource naming | Plural nouns, consistent naming | Required |
| Pagination | Cursor or offset-based pagination | Required |
| Filtering/Sorting | Query parameter support for collections | Recommended |

**GraphQL Specific:**
| Check | Pattern | Status |
|-------|---------|--------|
| Query complexity | Query depth/complexity limiting | Required |
| Introspection | Disabled in production | Required |
| Persisted queries | For production use | Recommended |
| Field-level rate limiting | Per-field cost analysis | Recommended |

**gRPC Specific:**
| Check | Pattern | Status |
|-------|---------|--------|
| Proto versioning | Proto file versioning strategy | Required |
| Backward compatibility | Non-breaking proto changes | Required |
| Error codes | Proper gRPC status codes | Required |
| Reflection | gRPC reflection for discovery | Recommended |

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific API readiness gap
2. **Why it matters**: Impact on API consumers and operations
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         API READINESS PRODUCTION REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
API Type: [REST/GraphQL/gRPC]
Framework: [detected framework]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

API VERSIONING
  [PASS] Version strategy implemented (URL path)
  [FAIL] No deprecation headers for legacy endpoints
  [PASS] Backward compatible changes
  [WARN] No version changelog found

RATE LIMITING
  [PASS] Rate limiter middleware present
  [PASS] 429 responses implemented
  [FAIL] Missing Retry-After header
  [WARN] No per-endpoint rate limits

DOCUMENTATION
  [PASS] OpenAPI spec present
  [FAIL] Missing request/response examples
  [FAIL] Error codes not documented
  [PASS] Authentication documented

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Missing Retry-After Header on Rate Limit
  Impact: Clients cannot implement intelligent retry logic
  Fix: Add Retry-After header to 429 responses
  File: src/middleware/rateLimiter.ts

  // Add to rate limit handler:
  res.setHeader('Retry-After', Math.ceil(resetTime / 1000));
  res.status(429).json({
    error: 'Too Many Requests',
    retryAfter: Math.ceil(resetTime / 1000)
  });

[HIGH] No Request/Response Examples in OpenAPI Spec
  Impact: API consumers struggle to integrate correctly
  Fix: Add examples to all operations in OpenAPI spec
  File: openapi.yaml

  paths:
    /v1/users:
      post:
        requestBody:
          content:
            application/json:
              example:
                name: "John Doe"
                email: "john@example.com"
        responses:
          '201':
            content:
              application/json:
                example:
                  id: "usr_123"
                  name: "John Doe"
                  email: "john@example.com"

[HIGH] Error Codes Not Documented
  Impact: Consumers cannot handle errors programmatically
  Fix: Document all error responses with codes and solutions
  File: openapi.yaml

  components:
    responses:
      BadRequest:
        description: Invalid request parameters
        content:
          application/json:
            example:
              code: "INVALID_INPUT"
              message: "Email format is invalid"
              field: "email"

[MEDIUM] No Deprecation Headers for Legacy Endpoints
  Impact: Clients unaware of upcoming breaking changes
  Fix: Add Sunset header to deprecated endpoints
  File: src/routes/deprecated.ts

  app.get('/v1/legacy-endpoint', (req, res) => {
    res.setHeader('Sunset', 'Sat, 31 Dec 2026 23:59:59 GMT');
    res.setHeader('Deprecation', 'true');
    res.setHeader('Link', '</v2/new-endpoint>; rel="successor-version"');
    // ... handler logic
  });

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add Retry-After header to all rate limit responses
2. [HIGH] Add request/response examples to OpenAPI spec
3. [HIGH] Document all error codes with solutions
4. [MEDIUM] Add deprecation headers to legacy endpoints
5. [MEDIUM] Create API version changelog

After Production:
1. Add per-endpoint rate limits for expensive operations
2. Implement query complexity limiting (GraphQL)
3. Add interactive API documentation (Swagger UI)
4. Set up API analytics and usage tracking

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
| API Versioning | 35% |
| Rate Limiting | 35% |
| Documentation | 30% |

---

## Quick Reference: Implementation Patterns

### API Versioning (URL Path)

```typescript
// Express.js version routing
import { Router } from 'express';
import v1Routes from './v1/routes';
import v2Routes from './v2/routes';

const router = Router();
router.use('/v1', v1Routes);
router.use('/v2', v2Routes);

// Default to latest version
router.use('/', v2Routes);
```

### API Versioning (Header)

```typescript
// Header-based versioning middleware
app.use((req, res, next) => {
  const version = req.headers['accept-version'] || '1';
  req.apiVersion = version;
  next();
});

// Or via Accept header
app.use((req, res, next) => {
  const accept = req.headers.accept || '';
  const match = accept.match(/version=(\d+)/);
  req.apiVersion = match ? match[1] : '1';
  next();
});
```

### Deprecation Headers

```typescript
// Middleware for deprecated endpoints
function deprecated(sunsetDate, successorPath) {
  return (req, res, next) => {
    res.setHeader('Sunset', sunsetDate);
    res.setHeader('Deprecation', 'true');
    res.setHeader('Link', `<${successorPath}>; rel="successor-version"`);
    next();
  };
}

// Usage
app.get('/v1/legacy',
  deprecated('Sat, 31 Dec 2026 23:59:59 GMT', '/v2/new-endpoint'),
  handler
);
```

### Rate Limiting (Express)

```typescript
import rateLimit from 'express-rate-limit';

// Global rate limiter
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.setHeader('Retry-After', Math.ceil(req.rateLimit.resetTime / 1000));
    res.status(429).json({
      error: 'Too Many Requests',
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000),
      limit: req.rateLimit.limit,
      remaining: req.rateLimit.remaining
    });
  }
});

app.use(globalLimiter);

// Per-endpoint strict limiter
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 attempts per hour
  handler: (req, res) => {
    res.setHeader('Retry-After', Math.ceil(req.rateLimit.resetTime / 1000));
    res.status(429).json({
      error: 'Too Many Attempts',
      message: 'Please try again later',
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000)
    });
  }
});

app.post('/auth/login', authLimiter, loginHandler);
```

### Rate Limiting (FastAPI)

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.util import get_remote_address
import time

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()

@app.exception_handler(429)
async def rate_limit_handler(request: Request, exc):
    return JSONResponse(
        status_code=429,
        content={
            "error": "Too Many Requests",
            "retryAfter": exc.detail
        },
        headers={"Retry-After": str(exc.detail)}
    )

@app.get("/api/v1/data")
@limiter.limit("100/minute")
async def get_data(request: Request):
    return {"data": "response"}
```

### Rate Limiting (Go/Gin)

```go
import (
    "github.com/gin-gonic/gin"
    "github.com/ulule/limiter/v3"
    mgin "github.com/ulule/limiter/v3/drivers/middleware/gin"
    "github.com/ulule/limiter/v3/drivers/store/memory"
)

func setupRateLimit() gin.HandlerFunc {
    store := memory.NewStore()
    rate := limiter.Rate{
        Period: 15 * time.Minute,
        Limit:  100,
    }
    instance := limiter.New(store, rate)
    middleware := mgin.NewMiddleware(instance)

    return func(c *gin.Context) {
        middleware(c)
        if c.Writer.Status() == 429 {
            c.Header("Retry-After", "900")
            c.JSON(429, gin.H{
                "error":      "Too Many Requests",
                "retryAfter": 900,
            })
            c.Abort()
            return
        }
        c.Next()
    }
}
```

### OpenAPI Documentation

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: My API
  version: 2.0.0
  description: Production-ready API with versioning and rate limiting

servers:
  - url: https://api.example.com/v2
    description: Production

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
        - name: cursor
          in: query
          schema:
            type: string
      responses:
        '200':
          description: Success
          headers:
            X-RateLimit-Limit:
              schema:
                type: integer
              description: Request limit per window
            X-RateLimit-Remaining:
              schema:
                type: integer
              description: Remaining requests in window
          content:
            application/json:
              example:
                users:
                  - id: "usr_123"
                    name: "John Doe"
                nextCursor: "eyJpZCI6MTAwfQ"
        '429':
          description: Rate limit exceeded
          headers:
            Retry-After:
              schema:
                type: integer
              description: Seconds until retry
          content:
            application/json:
              example:
                error: "Too Many Requests"
                retryAfter: 60
```

### Swagger UI Setup

```typescript
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';

const swaggerDocument = YAML.load('./openapi.yaml');

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'My API Documentation'
}));
```

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For logging, metrics, tracing
- `/security-review` - For authentication, authorization
- `/devops-review` - For deployment and CI/CD
- `/quality-check` - For code quality
