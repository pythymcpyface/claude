---
description: Production readiness review for API design. Reviews versioning strategy, rate limiting implementation, and documentation completeness before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# API Readiness Review Command

Run a comprehensive production readiness review focused on API design and contract quality.

## Purpose

Review APIs before production release to ensure:
- Versioning strategy is implemented and documented
- Rate limiting protects against abuse and overload
- API documentation is complete and accurate
- Error handling follows best practices
- Backward compatibility is maintained

## Workflow

### 1. Load the API Readiness Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/api-readiness-review/SKILL.md
```

### 2. Detect API Stack

Identify the API technology and framework:
```bash
# Detect REST API frameworks
grep -r "express\|fastify\|nestjs\|koa\|hapi\|fastapi\|flask\|django\|gin\|echo\|fiber" package.json requirements.txt go.mod 2>/dev/null && echo "REST API"

# Detect GraphQL
grep -r "graphql\|apollo\|hasura\|gql" package.json requirements.txt go.mod 2>/dev/null && echo "GraphQL"

# Detect gRPC
grep -r "grpc\|protobuf\|proto3" package.json requirements.txt go.mod 2>/dev/null && echo "gRPC"

# Detect OpenAPI/Swagger
find . -name "openapi*.yaml" -o -name "openapi*.json" -o -name "swagger*.yaml" -o -name "swagger*.json" 2>/dev/null | head -5
```

### 3. Run API Readiness Checks

Execute all checks in parallel:

**API Versioning:**
```bash
# Find version prefixes in routes
grep -r "/v[0-9]\|/api/v[0-9]\|version.*[0-9]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for version middleware
grep -r "accept-version\|api-version\|x-api-version" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find deprecation/sunset headers
grep -r "sunset\|deprecat\|Deprecation" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Rate Limiting:**
```bash
# Find rate limiting implementations
grep -r "rateLimit\|rate.*limit\|throttle\|ratelimit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Check for rate limit libraries
grep -r "express-rate-limit\|rate-limiter-flexible\|flask-limiter\|django-ratelimit" package.json requirements.txt go.mod 2>/dev/null

# Find 429 responses and Retry-After headers
grep -r "429\|TooManyRequests\|Retry-After\|retryAfter" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find rate limit headers
grep -r "X-RateLimit\|rateLimit.*header" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Documentation:**
```bash
# Find OpenAPI/Swagger specs
find . -name "openapi*.yaml" -o -name "openapi*.json" -o -name "swagger*.yaml" -o -name "swagger*.json" 2>/dev/null | head -10

# Check for Swagger/OpenAPI libraries
grep -r "swagger\|openapi\|swagger-ui\|redoc" package.json requirements.txt go.mod 2>/dev/null

# Find documentation routes
grep -r "/docs\|/swagger\|/api-docs\|/redoc" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find API documentation files
find . -name "README*.md" -o -name "API*.md" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Versioning, Rate Limiting, Documentation)
- Calculate overall score (weighted: 35% / 35% / 30%)
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All required checks pass |
| 70-89 | NEEDS WORK | Minor gaps, mostly complete |
| 50-69 | AT RISK | Significant gaps found |
| 0-49 | BLOCK | Critical gaps, do not release |

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Implement missing rate limiting
2. [CRITICAL] Add Retry-After headers to 429 responses
3. [HIGH] Add version strategy to all endpoints
4. [HIGH] Complete OpenAPI documentation

**Short-term (Within 1 week):**
5. [MEDIUM] Add request/response examples
6. [MEDIUM] Document all error codes
7. [MEDIUM] Add deprecation headers to legacy endpoints

**Long-term:**
8. [LOW] Set up interactive API documentation
9. [LOW] Create API changelog
10. [LOW] Implement per-endpoint rate limits

## Usage

```
/api-readiness-review
```

## When to Use

- Before releasing APIs to production
- When adding new API endpoints
- When modifying API contracts
- When changing versioning strategy
- After rate limiting changes
- Before deprecating endpoints
- During API design reviews

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For logging, metrics, tracing
- `/security-review` - For authentication, authorization
- `/devops-review` - For deployment safety
- `/quality-check` - For lint, types, tests
- `/review-pr` - For comprehensive PR review
