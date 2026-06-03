# feature-flag-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for feature-flag-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's feature flag implementation and technology stack:

```bash
# Detect feature flag libraries/services
grep -r "launchdarkly\|ldclient\|unleash\|flagsmith\|splitio\|optimizely\|feature.*flag\|feature.*toggle" package.json requirements.txt go.mod Cargo.toml 2>/dev/null

# Detect custom flag implementations
grep -r "featureFlag\|feature_flag\|FeatureFlag\|isFeatureEnabled\|checkFlag" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Detect flag configuration files
find . -name "*flag*" -o -name "*toggle*" -o -name "*feature*" 2>/dev/null | grep -E "\.(json|yaml|yml|toml|env)" | head -10

# Detect A/B testing frameworks
grep -r "abtesting\|experiment\|optimizely\|vwo\|googleoptimize" package.json requirements.txt go.mod 2>/dev/null
```

### Phase 2: Feature Flag Readiness Checklist

Run all checks and compile results:

#### 1. Flag Naming & Organization

| Check | Pattern | Status |
|-------|---------|--------|
| Convention-based naming | Consistent format (e.g., `feature_module_name`, `module.feature-name`) | Required |
| Descriptive names | Clear purpose indication, no abbreviations | Required |
| Namespace/grouping | Flags organized by module/team/domain | Recommended |
| Environment awareness | Different values per environment (dev/staging/prod) | Required |
| Documentation | Each flag documented with purpose, owner, expiry | Required |

**Search Patterns:**
```bash
# Find flag definitions
grep -r "featureFlag\|feature_flag\|FEATURE_\|flag.*=\|toggle.*=" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Check for flag naming patterns
grep -rE "[a-z]+_[a-z_]+|[a-z]+\.[a-z.]+|[A-Z_]+_[A-Z_]+" --include="*flag*" 2>/dev/null | head -20

# Find flag documentation
find . -name "*.md" -exec grep -l "flag\|toggle\|feature" {} \; 2>/dev/null | head -10
```

#### 2. Rollout Strategy

| Check | Pattern | Status |
|-------|---------|--------|
| Gradual rollout | Percentage-based rollout (not all-or-nothing) | Required |
| Consistent user experience | Same user sees same variant (hash-based) | Required |
| User targeting | Segment-based targeting (beta users, regions) | Recommended |
| Canary releases | Small percentage first, then expand | Required |
| Rollback capability | Quick disable without redeployment | Required |
| Progressive rollout plan | Defined stages (1% → 10% → 50% → 100%) | Recommended |

**Search Patterns:**
```bash
# Find rollout/percentage logic
grep -r "rollout\|percentage\|percent\|ratio\|traffic.*split" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find user targeting/segmentation
grep -r "targeting\|segment\|cohort\|audience\|user.*group" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find hash-based consistency
grep -r "hash\|bucket\|consistent.*hash\|user.*id.*%" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find canary deployment patterns
grep -r "canary\|staged.*rollout\|gradual.*release" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.yaml" 2>/dev/null | head -10
```

#### 3. Dark Launch Patterns

| Check | Pattern | Status |
|-------|---------|--------|
| Hidden deployment | Code deployed but feature invisible to users | Required |
| Internal testing | Enable for internal users/employees first | Recommended |
| Shadow traffic | Run new code path without affecting users | Recommended |
| Feature hiding | UI elements conditionally rendered | Required |
| Monitoring before exposure | Collect metrics before user exposure | Required |

**Search Patterns:**
```bash
# Find dark launch patterns
grep -r "dark.*launch\|shadow\|hidden\|internal.*only\|employee.*only" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find conditional rendering/UI hiding
grep -r "isFeatureVisible\|showFeature\|renderIf\|displayIf\|visible.*flag" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | head -15

# Find internal/testing user checks
grep -r "isInternal\|isEmployee\|isBeta\|isTester\|internal.*user" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 4. Kill Switch & Emergency Rollback

| Check | Pattern | Status |
|-------|---------|--------|
| Instant disable | Can disable flag immediately without deploy | Required |
| Circuit breaker | Auto-disable on error threshold | Recommended |
| Admin override | Manual toggle capability for ops | Required |
| Rollback procedure | Documented process for emergency disable | Required |
| Communication plan | Stakeholders notified on flag changes | Recommended |

**Search Patterns:**
```bash
# Find kill switch patterns
grep -r "kill.*switch\|emergency\|disable.*immediate\|instant.*off" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find circuit breaker with flags
grep -r "circuit.*breaker\|errorThreshold\|auto.*disable\|fail.*safe" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find admin override patterns
grep -r "admin.*override\|manual.*toggle\|ops.*control\|force.*enable\|force.*disable" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 5. Safety Mechanisms

| Check | Pattern | Status |
|-------|---------|--------|
| Default values | Safe fallback when flag service unavailable | Required |
| Timeout handling | Non-blocking flag evaluation | Required |
| Error handling | Graceful degradation on flag errors | Required |
| Local caching | Flag values cached to reduce latency | Recommended |
| Service fallback | Use cached/default if flag service down | Required |

**Search Patterns:**
```bash
# Find default value patterns
grep -r "default.*value\|fallback\|fallbackValue\|defaultValue" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find timeout configurations
grep -r "timeout\|Timeout\|TIMEOUT" --include="*flag*" 2>/dev/null | head -10

# Find error handling for flags
grep -r "catch.*flag\|try.*flag\|flag.*error\|flag.*catch" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find caching patterns
grep -r "cache.*flag\|flag.*cache\|memoize.*flag" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 6. Performance Impact

| Check | Pattern | Status |
|-------|---------|--------|
| Low latency evaluation | Flag check < 10ms | Required |
| Async evaluation | Non-blocking flag fetch | Recommended |
| Request batching | Multiple flags in single request | Recommended |
| Edge evaluation | Flags evaluated at CDN/edge | Recommended |
| No N+1 queries | Flag data not fetched per-item | Required |

**Search Patterns:**
```bash
# Find async flag evaluation
grep -r "async.*flag\|await.*flag\|getFlag.*async\|Promise.*flag" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find batching patterns
grep -r "batch\|bulk.*flag\|getFlags\|allFlags\|getAllFlags" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find performance metrics
grep -r "flag.*latency\|flag.*timing\|flag.*duration\|flag.*ms" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

#### 7. Testing Coverage

| Check | Pattern | Status |
|-------|---------|--------|
| Flag-on tests | Tests run with flag enabled | Required |
| Flag-off tests | Tests run with flag disabled | Required |
| Edge case tests | Invalid flag states, timeouts, errors | Required |
| Integration tests | End-to-end with flag variations | Recommended |
| A/B test validation | Statistical significance verified | Recommended |

**Search Patterns:**
```bash
# Find flag-related tests
find . -name "*.test.*" -o -name "*.spec.*" | xargs grep -l "flag\|toggle\|feature" 2>/dev/null | head -15

# Find flag mock/stub patterns
grep -r "mockFlag\|stubFlag\|fakeFlag\|flag.*mock\|flag.*stub" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10

# Find flag state tests
grep -r "flagEnabled\|flagDisabled\|withFlag\|withoutFlag" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15
```

#### 8. Lifecycle Management

| Check | Pattern | Status |
|-------|---------|--------|
| Flag ownership | Each flag has assigned owner | Required |
| Expiration dates | Temporary flags have removal dates | Required |
| Cleanup process | Old flags regularly removed | Required |
| Audit trail | Flag changes logged with who/when/why | Required |
| Change notifications | Stakeholders notified on changes | Recommended |

**Search Patterns:**
```bash
# Find flag metadata/ownership
grep -r "owner\|Owner\|OWNED_BY\|created.*by\|expires\|expiry" --include="*flag*" 2>/dev/null | head -15

# Find cleanup/removal patterns
grep -r "cleanup\|remove.*flag\|delete.*flag\|expire.*flag\|sunset" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find audit/logging
grep -r "audit\|flag.*change\|flag.*log\|flag.*history" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific feature flag gap
2. **Why it matters**: Impact on production safety and operations
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
     FEATURE FLAG PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Flag System: [LaunchDarkly/Unleash/Flagsmith/Custom]
Total Flags Detected: [count]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

FLAG NAMING & ORGANIZATION
  [PASS] Convention-based naming (snake_case)
  [FAIL] No flag documentation found
  [WARN] No namespace grouping

ROLLOUT STRATEGY
  [PASS] Gradual rollout implemented
  [PASS] Hash-based user consistency
  [FAIL] No rollback capability
  [WARN] No progressive rollout plan documented

DARK LAUNCH
  [PASS] Feature hiding implemented
  [FAIL] No internal testing phase
  [PASS] Monitoring before exposure

KILL SWITCH & ROLLBACK
  [FAIL] No instant disable capability
  [FAIL] No circuit breaker for flag errors
  [PASS] Admin override available
  [WARN] No rollback procedure documented

SAFETY MECHANISMS
  [PASS] Default values configured
  [FAIL] No timeout on flag evaluation
  [PASS] Error handling present
  [FAIL] No local caching

PERFORMANCE
  [PASS] Low latency evaluation (<5ms)
  [FAIL] Synchronous flag fetch (blocking)
  [WARN] No request batching

TESTING
  [PASS] Flag-on tests present
  [FAIL] No flag-off tests
  [FAIL] No edge case tests

LIFECYCLE
  [FAIL] No flag ownership defined
  [FAIL] No expiration dates
  [WARN] No cleanup process

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Instant Disable Capability
  Impact: Cannot quickly disable problematic features in production
  Fix: Add kill switch with admin override
  File: src/services/feature-flags.ts

  // Add kill switch pattern
  const flagWithKillSwitch = {
    'feature:new-checkout': {
      enabled: true,
      killSwitch: () => process.env.KILLSWITCH_NEW_CHECKOUT === 'true',
      fallback: false
    }
  };

  export function isFeatureEnabled(flagName: string, userId?: string): boolean {
    const flag = flags[flagName];
    if (!flag) return false;

    // Check kill switch first
    if (flag.killSwitch?.()) {
      return flag.fallback ?? false;
    }

    return evaluateFlag(flag, userId);
  }

[CRITICAL] No Rollback Capability
  Impact: Must redeploy to disable features, slow incident response
  Fix: Implement runtime flag configuration
  File: src/config/feature-flags.ts

  // Use remote config for instant rollback
  import { LDClient } from 'launchdarkly-node-client-sdk';

  const ldClient = await LDClient.init(process.env.LD_CLIENT_KEY);

  export async function isFeatureEnabled(flagKey: string, user: User): Promise<boolean> {
    try {
      return await ldClient.variation(flagKey, user, false);
    } catch (error) {
      logger.error('Flag evaluation failed', { flagKey, error });
      return getDefaultValue(flagKey); // Fallback
    }
  }

[HIGH] No Flag Documentation
  Impact: Team unaware of flag purposes, ownership, and expiry
  Fix: Create flag registry with metadata
  File: docs/feature-flags.md

  ## Feature Flag Registry

  | Flag Key | Description | Owner | Created | Expires | Status |
  |----------|-------------|-------|---------|---------|--------|
  | `feature:new-checkout` | New checkout flow | @payments-team | 2026-01-15 | 2026-04-15 | Active |
  | `feature:dark-mode` | Dark mode UI | @frontend-team | 2026-02-01 | 2026-05-01 | Active |

[HIGH] No Timeout on Flag Evaluation
  Impact: Slow flag service can block entire request
  Fix: Add timeout wrapper for flag evaluation
  File: src/services/feature-flags.ts

  export async function getFlagWithTimeout(
    flagKey: string,
    user: User,
    timeoutMs: number = 100
  ): Promise<boolean> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const value = await Promise.race([
        ldClient.variation(flagKey, user, false),
        new Promise<boolean>((_, reject) =>
          controller.signal.addEventListener('abort', () =>
            reject(new Error('Flag evaluation timeout'))
          )
        )
      ]);
      return value;
    } catch (error) {
      logger.warn('Flag evaluation failed or timed out', { flagKey });
      return getDefaultValue(flagKey);
    } finally {
      clearTimeout(timeout);
    }
  }

[HIGH] No Flag-Off Tests
  Impact: Code paths with disabled flags not tested, hidden bugs
  Fix: Add test cases for both flag states
  File: tests/feature-flags.test.ts

  describe('Checkout Feature Flag', () => {
    it('should use new checkout when flag is enabled', async () => {
      mockFlag('feature:new-checkout', true);
      const result = await processCheckout(order);
      expect(result.flow).toBe('new');
    });

    it('should use legacy checkout when flag is disabled', async () => {
      mockFlag('feature:new-checkout', false);
      const result = await processCheckout(order);
      expect(result.flow).toBe('legacy');
    });

    it('should fallback to legacy on flag error', async () => {
      mockFlagError('feature:new-checkout', new Error('Service down'));
      const result = await processCheckout(order);
      expect(result.flow).toBe('legacy');
    });
  });

[MEDIUM] No Local Caching
  Impact: Repeated flag evaluations add latency
  Fix: Add in-memory cache with TTL
  File: src/services/feature-flags.ts

  const flagCache = new Map<string, { value: boolean; expiry: number }>();

  export async function getCachedFlag(
    flagKey: string,
    user: User,
    ttlMs: number = 60000
  ): Promise<boolean> {
    const cacheKey = `${flagKey}:${user.id}`;
    const cached = flagCache.get(cacheKey);

    if (cached && cached.expiry > Date.now()) {
      return cached.value;
    }

    const value = await getFlagWithTimeout(flagKey, user);
    flagCache.set(cacheKey, { value, expiry: Date.now() + ttlMs });
    return value;
  }

[MEDIUM] No Flag Ownership
  Impact: No accountability, orphaned flags accumulate
  Fix: Add ownership metadata to flag definitions
  File: src/config/feature-flags.ts

  export const FEATURE_FLAGS = {
    'feature:new-checkout': {
      enabled: true,
      owner: 'payments-team@company.com',
      slackChannel: '#payments-alerts',
      created: '2026-01-15',
      expires: '2026-04-15',
      jira: 'PAY-1234'
    }
  } as const;

───────────────────────────────────────────────────────────────
                    RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement instant disable/kill switch capability
2. [CRITICAL] Add runtime flag configuration for rollback
3. [HIGH] Create flag documentation with ownership
4. [HIGH] Add timeout to all flag evaluations
5. [HIGH] Add tests for flag-off states
6. [MEDIUM] Implement local caching for flags
7. [MEDIUM] Add ownership metadata to all flags

After Production:
1. Set up flag usage analytics and dashboards
2. Implement automated flag cleanup alerts
3. Add circuit breaker for flag service failures
4. Create progressive rollout automation
5. Set up A/B test statistical analysis

═══════════════════════════════════════════════════════════════
```

---

