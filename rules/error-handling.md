---
paths:
  - "**/errors/**"
  - "**/*.error.ts"
  - "**/*.error.js"
  - "**/retry*.ts"
  - "**/circuit-breaker*.ts"
---

# Error Handling

Detail: `.claude/docs/skill-references/extended/error-classification-recovery.md`.

- Classify errors before handling: transient (retry), permanent (fail fast), programmer (throw).
- No bare `catch` that swallows errors. Either handle, log + rethrow, or wrap with context.
- Retries need: max attempts, backoff, jitter, idempotency check.
- Circuit breakers need: failure threshold, open duration, half-open probe.
- Never log secrets or PII in error payloads.
