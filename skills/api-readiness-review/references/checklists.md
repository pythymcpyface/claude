# api-readiness-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for api-readiness-review. SKILL.md routes here when running the review workflow.


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

