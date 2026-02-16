# Performance Requirements Template

Use this template to define and document performance requirements for features. Performance requirements ensure the application meets user expectations and scales appropriately.

---

## How to Use This Template

1. **Define performance budgets** during the design phase
2. **Set measurable targets** for all performance metrics
3. **Include in testing strategy** (TDD-STRATEGY.md)
4. **Verify before merge** using quality-gate.sh

---

## Performance Budget

### Web Vitals Targets (Core Web Vitals)

| Metric | Target | Threshold | Measurement |
|--------|--------|-----------|-------------|
| Largest Contentful Paint (LCP) | < 2.5s | < 4s acceptable | Time to main content |
| First Input Delay (FID) | < 100ms | < 300ms acceptable | Interaction responsiveness |
| Cumulative Layout Shift (CLS) | < 0.1 | < 0.25 acceptable | Visual stability |
| First Contentful Paint (FCP) | < 1.8s | < 3s acceptable | First content rendered |
| Time to Interactive (TTI) | < 3.8s | < 7.3s acceptable | Fully interactive |

### Resource Budgets

| Resource | Budget | Current | Notes |
|----------|--------|---------|-------|
| Initial HTML | < 15KB | | |
| Initial CSS | < 50KB | | |
| Initial JS (non-async) | < 200KB | | |
| Total page weight | < 1MB | | |
| Images per page | < 500KB | | |
| Fonts loaded | < 100KB | | |

### API Response Times

| Endpoint Type | P50 | P95 | P99 | Notes |
|---------------|-----|-----|-----|-------|
| Simple reads | < 50ms | < 100ms | < 200ms | |
| Complex queries | < 200ms | < 500ms | < 1s | |
| Writes/updates | < 100ms | < 300ms | < 500ms | |
| Background jobs | N/A | < 5s | < 10s | Async processing |

---

## Load Testing Scenarios

### Scenario 1: Normal Traffic

| Metric | Target |
|--------|--------|
| Concurrent users | 100 |
| Requests per second | 50 |
| Error rate | < 0.1% |
| Response time (P95) | < 200ms |

### Scenario 2: Peak Traffic

| Metric | Target |
|--------|--------|
| Concurrent users | 1,000 |
| Requests per second | 500 |
| Error rate | < 1% |
| Response time (P95) | < 500ms |

### Scenario 3: Stress Test

| Metric | Target |
|--------|--------|
| Concurrent users | 5,000+ |
| Requests per second | 2,000+ |
| Graceful degradation | Yes |
- No data corruption | Yes |

---

## Database Performance

### Query Performance

| Query Type | Target | Max | Notes |
|------------|--------|-----|-------|
| Primary key lookup | < 1ms | 10ms | |
- Indexed query | < 10ms | 50ms | |
| Full table scan | N/A | N/A | Avoid |
| Join (2-3 tables) | < 50ms | 200ms | |

### Database Connection Pool

| Setting | Value | Notes |
|---------|-------|-------|
| Min connections | 5 | |
| Max connections | 100 | Per application instance |
| Connection timeout | 30s | |
| Idle timeout | 10min | |

### N+1 Query Prevention

| Check | Status | Notes |
|-------|--------|-------|
| Eager loading for relations | [ ] | |
- Batch loading for lists | [ ] | |
| Query result caching | [ ] | |
| No queries in loops | [ ] | |

---

## Caching Strategy

### Cache Layers

| Layer | TTL | Invalidation | Notes |
|-------|-----|--------------|-------|
| CDN / Static assets | 1 year | Hash busting | Images, CSS, JS |
- API responses | 5-60min | Cache tags | GET endpoints |
| Database queries | 5-30min | Write-through | Expensive queries |
| Session data | 24h | Rolling expiry | User sessions |

### Cache Hit Rate Targets

| Cache Type | Target Hit Rate |
|------------|-----------------|
| CDN / Static | > 95% |
- API responses | > 80% |
| Database query | > 70% |

---

## Frontend Performance

### Rendering Performance

| Metric | Target | Notes |
|--------|--------|-------|
| Frame rate | 60fps | Smooth animations |
| Bundle size | < 200KB (gzipped) | Initial JS |
| Time to First Byte (TTFB) | < 600ms | Server response |
| First Paint | < 1s | Visual feedback |

### Code Splitting

| Check | Status | Notes |
|-------|--------|-------|
| Route-based splitting | [ ] | |
- Component-based splitting | [ ] | |
| Lazy loading for images | [ ] | |
| Tree shaking enabled | [ ] | |

### Asset Optimization

| Check | Status | Notes |
|-------|--------|-------|
| Images compressed (WebP) | [ ] | |
| CSS minified | [ ] | |
- JS minified | [ ] | |
| Source maps available | [ ] | Dev/staging only |

---

## Backend Performance

### Service Level Objectives (SLOs)

| Service | SLO | Error Budget |
|---------|-----|--------------|
| API availability | 99.9% | 43min/month downtime |
| API response time | P95 < 200ms | |
| Data consistency | 99.99% | |

### Queue/Job Processing

| Job Type | Max Wait Time | Max Process Time | Retry Policy |
|----------|---------------|------------------|--------------|
| Email | 5s | 3s | 3 retries, exponential backoff |
| Report generation | 10s | 30s | 5 retries |
| Webhook delivery | 1s | 2s | 7 retries, exponential backoff |

---

## Performance Regression Testing

### Baseline Metrics

| Feature | Metric | Baseline | Threshold |
|---------|--------|----------|-----------|
| | | | |
| | | | |
| | | | |

### Regression Test Plan

1. **Establish baseline** before implementation
2. **Run performance tests** after implementation
3. **Compare against baseline**
4. **Flag regressions > 10%**
5. **Investigate and fix** before merge

---

## Performance Testing Tools

### Load Testing Tools

| Tool | Use Case | Link |
|------|----------|------|
| k6 | Scriptable load testing | https://k6.io/ |
| Apache Bench (ab) | Simple load testing | Built-in |
| wrk | HTTP benchmarking | https://github.com/wg/wrk |
| Artillery | Cloud load testing | https://artillery.io/ |
| locust | Python load testing | https://locust.io/ |

### Monitoring Tools

| Tool | Use Case | Link |
|------|----------|------|
| Lighthouse | Web vitals audit | Chrome DevTools |
| WebPageTest | Detailed performance analysis | https://www.webpagetest.org/ |
| Chrome DevTools | Performance profiling | Built-in |
| New Relic / Datadog | APM monitoring | Commercial |

### Database Query Analysis

| Tool | Use Case |
|------|----------|
| EXPLAIN (SQL) | Query execution plan |
| Slow query log | Identify slow queries |
- Query profiler | Real-time analysis |

---

## Performance Testing Checklist

| Category | Check | Status |
|----------|-------|--------|
| Web Vitals | LCP < 2.5s | [ ] |
| | FID < 100ms | [ ] |
| | CLS < 0.1 | [ ] |
| API Performance | P95 response time met | [ ] |
| | Error rate within budget | [ ] |
| Database | No N+1 queries | [ ] |
| | Indexes used appropriately | [ ] |
| Caching | Cache hit rate met | [ ] | |
- Frontend | Bundle size within budget | [ ] |
| | Code splitting configured | [ ] |
| Load Testing | Peak traffic scenario passed | [ ] |
| | Stress test completed | [ ] |

---

## Performance Optimization Techniques

### Database Optimization
- Use indexes for frequently queried columns
- Avoid SELECT * - only select needed columns
- Use connection pooling
- Implement query result caching
- Denormalize for read-heavy workloads

### API Optimization
- Implement pagination for large result sets
- Use compression (gzip, brotli)
- Implement rate limiting
- Use HTTP/2 or HTTP/3
- Consider GraphQL for complex data needs

### Frontend Optimization
- Lazy load images and components
- Minimize DOM manipulation
- Use virtual scrolling for long lists
- Debounce/throttle event handlers
- Use Web Workers for CPU-intensive tasks

---

## Document Completion

| Item | Status |
|------|--------|
| Performance budgets defined | [ ] |
| Load testing scenarios documented | [ ] |
- Baseline metrics established | [ ] |
| Performance tools selected | [ ] |
| Testing checklist completed | [ ] |

---

## References

- [Web.dev Performance](https://web.dev/performance/)
- [Core Web Vitals](https://web.dev/vitals/)
- [Google Lighthouse](https://developers.google.com/web/tools/lighthouse)
- [k6 Documentation](https://k6.io/docs/)

---

*End of PERFORMANCE-REQUIREMENTS template*
