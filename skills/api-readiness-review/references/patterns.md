# api-readiness-review — Implementation Patterns

Reusable code snippets and configuration templates for api-readiness-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

