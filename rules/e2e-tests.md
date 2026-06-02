---
paths:
  - "**/*.spec.ts"
  - "**/*.e2e.ts"
  - "**/e2e/**"
  - "**/playwright.config.*"
  - "**/cypress/**"
  - "**/cypress.config.*"
---

# E2E Tests

- Critical paths only: login, checkout, core feature flows. Not exhaustive coverage.
- Stable selectors: `data-testid`, never CSS classes or text content.
- Each test sets up and tears down its own state. No cross-test dependencies.
- Retry flaky assertions at the assertion level, not the test level.
- Run in CI; do not block local dev on E2E.
- Tag flaky tests explicitly; do not silently retry forever.
