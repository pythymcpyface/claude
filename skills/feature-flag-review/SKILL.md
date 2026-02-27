---
name: feature-flag-review
description: Production readiness review for Feature Flag management. Reviews gradual rollout strategies, dark launches, kill switches, safety mechanisms, performance impact, and lifecycle management before production release. Use PROACTIVELY before releases with feature flags, when implementing new flags, or modifying flag configurations.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Feature Flag Review Skill

Production readiness code review focused on Feature Flag Management & Progressive Delivery. Ensures code is ready for production with proper rollout strategies, safety mechanisms, and lifecycle management.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "feature flag", "feature toggle", "flag", "toggle", "switch", "canary", "rollout", "dark launch"
- New feature flag implementations or flag service integrations
- Flag configuration changes or targeting rule modifications
- Before production releases with feature-flagged functionality
- When adding A/B testing or experimentation code
- Changes to flag management systems (LaunchDarkly, Unleash, Flagsmith)

---

## Review Workflow

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
| Flag Naming & Organization | 5% |
| Rollout Strategy | 15% |
| Dark Launch | 5% |
| Kill Switch & Rollback | 25% |
| Safety Mechanisms | 15% |
| Performance | 10% |
| Testing Coverage | 15% |
| Lifecycle Management | 10% |

---

## Quick Reference: Implementation Patterns

### Gradual Rollout (TypeScript)

```typescript
// Percentage-based rollout with consistent user experience
export function isFeatureEnabled(
  flagKey: string,
  userId: string,
  rolloutPercentage: number
): boolean {
  // Hash user ID for consistent bucketing
  const hash = createHash('md5').update(`${flagKey}:${userId}`).digest('hex');
  const bucket = (parseInt(hash.substring(0, 8), 16) % 100);
  return bucket < rolloutPercentage;
}

// Progressive rollout stages
const ROLLOUT_STAGES = {
  'feature:new-checkout': {
    stage1: { percentage: 1, date: '2026-03-01' },   // Canary
    stage2: { percentage: 10, date: '2026-03-08' },  // Early adopters
    stage3: { percentage: 50, date: '2026-03-15' },  // Half traffic
    stage4: { percentage: 100, date: '2026-03-22' }  // Full rollout
  }
};
```

### Dark Launch (TypeScript)

```typescript
// Deploy code but hide from users
export async function processOrder(order: Order): Promise<OrderResult> {
  const isNewFlowEnabled = await isFeatureEnabled('feature:new-order-flow', order.userId);

  // Always run new flow for monitoring (shadow mode)
  if (isNewFlowEnabled || isInternalUser(order.userId)) {
    const newResult = await newOrderFlow(order);

    // Only return new result for enabled users
    if (isNewFlowEnabled) {
      return newResult;
    }

    // Shadow mode: run new flow but return old result
    logger.info('Shadow mode: new order flow executed', {
      orderId: order.id,
      newResultSuccess: newResult.success
    });
  }

  return legacyOrderFlow(order);
}

function isInternalUser(userId: string, userEmail?: string): boolean {
  return INTERNAL_USER_IDS.includes(userId) ||
         (userEmail?.endsWith('@company.com') ?? false);
}
```

### Kill Switch (TypeScript)

```typescript
// Instant disable without redeployment
export class FeatureFlagService {
  private killSwitches = new Map<string, boolean>();

  // Can be triggered via admin API, config change, or circuit breaker
  activateKillSwitch(flagKey: string): void {
    this.killSwitches.set(flagKey, true);
    logger.error('Kill switch activated', { flagKey });
    metrics.increment('feature_flag.kill_switch_activated', { flag: flagKey });
    alertTeam(`Kill switch activated for ${flagKey}`);
  }

  async isFeatureEnabled(flagKey: string, user: User): Promise<boolean> {
    // Check kill switch first
    if (this.killSwitches.get(flagKey)) {
      logger.warn('Feature blocked by kill switch', { flagKey, userId: user.id });
      return this.getFallbackValue(flagKey);
    }

    try {
      return await this.evaluateFlag(flagKey, user);
    } catch (error) {
      logger.error('Flag evaluation failed', { flagKey, error });
      return this.getFallbackValue(flagKey);
    }
  }
}
```

### Circuit Breaker with Flags (TypeScript)

```typescript
import CircuitBreaker from 'opossum';

// Circuit breaker for flag service
const flagBreaker = new CircuitBreaker(
  async (flagKey: string, user: User) => {
    return await ldClient.variation(flagKey, user, false);
  },
  {
    timeout: 100,              // 100ms timeout
    errorThresholdPercentage: 50,
    resetTimeout: 30000        // Try again after 30s
  }
);

// Fallback to cached/default when circuit is open
flagBreaker.fallback((flagKey: string) => {
  logger.warn('Flag service circuit open, using fallback', { flagKey });
  return getCachedFlagValue(flagKey) ?? getDefaultFlagValue(flagKey);
});

export const getFeatureFlag = (flagKey: string, user: User) =>
  flagBreaker.fire(flagKey, user);
```

### Flag Caching (TypeScript)

```typescript
// In-memory cache with TTL
interface CachedFlag {
  value: boolean;
  expiry: number;
}

class FlagCache {
  private cache = new Map<string, CachedFlag>();
  private defaultTtl = 60000; // 1 minute

  get(key: string, userId: string): boolean | null {
    const cacheKey = `${key}:${userId}`;
    const cached = this.cache.get(cacheKey);

    if (cached && cached.expiry > Date.now()) {
      return cached.value;
    }

    this.cache.delete(cacheKey);
    return null;
  }

  set(key: string, userId: string, value: boolean, ttl?: number): void {
    const cacheKey = `${key}:${userId}`;
    this.cache.set(cacheKey, {
      value,
      expiry: Date.now() + (ttl ?? this.defaultTtl)
    });
  }

  // Invalidate all flags for a user
  invalidateUser(userId: string): void {
    for (const key of this.cache.keys()) {
      if (key.endsWith(`:${userId}`)) {
        this.cache.delete(key);
      }
    }
  }
}
```

### LaunchDarkly Integration (TypeScript)

```typescript
import { LDClient, LDUser, init } from 'launchdarkly-node-server-sdk';

let ldClient: LDClient;

export async function initFeatureFlags(): Promise<void> {
  ldClient = init(process.env.LAUNCHDARKLY_SDK_KEY!);
  await ldClient.waitForInitialization();
  logger.info('LaunchDarkly initialized');
}

export async function isFeatureEnabled(
  flagKey: string,
  user: LDUser,
  defaultValue: boolean = false
): Promise<boolean> {
  try {
    return await ldClient.variation(flagKey, user, defaultValue);
  } catch (error) {
    logger.error('LaunchDarkly variation failed', { flagKey, error });
    return defaultValue;
  }
}

// Get all flags for a user (batching)
export async function getAllFlags(user: LDUser): Promise<Record<string, any>> {
  try {
    const allFlags = await ldClient.allFlagsState(user);
    return allFlags.allValues();
  } catch (error) {
    logger.error('Failed to get all flags', { error });
    return getDefaultFlags();
  }
}
```

### Unleash Integration (TypeScript)

```typescript
import { UnleashClient } from 'unleash-client';

const unleash = new UnleashClient({
  url: process.env.UNLEASH_URL!,
  appName: process.env.SERVICE_NAME!,
  environment: process.env.NODE_ENV!,
  customHeaders: {
    Authorization: process.env.UNLEASH_API_KEY!
  }
});

unleash.start();

export function isFeatureEnabled(
  flagName: string,
  context: { userId: string; email?: string }
): boolean {
  return unleash.isEnabled(flagName, context, false);
}

export function getVariant(
  flagName: string,
  context: { userId: string }
): { name: string; payload?: any } {
  return unleash.getVariant(flagName, context);
}
```

### Flagsmith Integration (Python)

```python
from flagsmith import Flagsmith

flagsmith = Flagsmith(
    environment_key=os.environ.get("FLAGSMITH_ENV_KEY"),
    api_url=os.environ.get("FLAGSMITH_API_URL")
)

def is_feature_enabled(flag_name: str, user_id: str, default: bool = False) -> bool:
    """Check if a feature flag is enabled for a user."""
    try:
        flags = flagsmith.get_identity_flags(user_id, traits={})
        return flags.is_feature_enabled(flag_name) or default
    except Exception as e:
        logger.error(f"Flagsmith flag check failed: {flag_name}", error=str(e))
        return default

def get_all_flags(user_id: str) -> dict:
    """Get all flags for a user (batching)."""
    try:
        flags = flagsmith.get_identity_flags(user_id, traits={})
        return flags.get_flags()
    except Exception as e:
        logger.error("Failed to get all flags", error=str(e))
        return get_default_flags()
```

### Go Implementation

```go
package featureflags

import (
	"context"
	"time"

	ld "github.com/launchdarkly/go-server-sdk/v6"
	"github.com/launchdarkly/go-server-sdk/v6/ldcomponents"
)

type FlagService struct {
	client    *ld.LDClient
	cache     *FlagCache
	defaults  map[string]bool
}

func NewFlagService(sdkKey string) (*FlagService, error) {
	client, err := ld.MakeClient(sdkKey, 5*time.Second)
	if err != nil {
		return nil, err
	}

	return &FlagService{
		client:   client,
		cache:    NewFlagCache(60 * time.Second),
		defaults: make(map[string]bool),
	}, nil
}

func (s *FlagService) IsEnabled(ctx context.Context, flagKey string, userID string, defaultValue bool) bool {
	// Check cache first
	if cached, ok := s.cache.Get(flagKey, userID); ok {
		return cached
	}

	// Evaluate flag
	user := ld.NewUserBuilder(userID).Build()
	result, _ := s.client.BoolVariation(flagKey, user, defaultValue)

	// Cache result
	s.cache.Set(flagKey, userID, result)
	return result
}

// Kill switch support
func (s *FlagService) IsEnabledWithKillSwitch(ctx context.Context, flagKey string, userID string) bool {
	if s.isKillSwitchActive(flagKey) {
		s.log.Warn("Kill switch active", "flag", flagKey)
		return s.defaults[flagKey]
	}
	return s.IsEnabled(ctx, flagKey, userID, s.defaults[flagKey])
}
```

### Testing Patterns (TypeScript)

```typescript
// Test utility for flag mocking
export function mockFlag(flagKey: string, enabled: boolean): void {
  jest.spyOn(featureFlagService, 'isFeatureEnabled')
    .mockImplementation(async (key: string) => {
      if (key === flagKey) return enabled;
      return false;
    });
}

export function mockFlagError(flagKey: string, error: Error): void {
  jest.spyOn(featureFlagService, 'isFeatureEnabled')
    .mockImplementation(async (key: string) => {
      if (key === flagKey) throw error;
      return false;
    });
}

// Test cases
describe('Feature: New Checkout', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should use new checkout when flag is enabled', async () => {
    mockFlag('feature:new-checkout', true);

    const result = await processCheckout(mockOrder);

    expect(result.flow).toBe('new');
    expect(result.checkoutVersion).toBe('2.0');
  });

  it('should use legacy checkout when flag is disabled', async () => {
    mockFlag('feature:new-checkout', false);

    const result = await processCheckout(mockOrder);

    expect(result.flow).toBe('legacy');
    expect(result.checkoutVersion).toBe('1.0');
  });

  it('should fallback to legacy on flag service error', async () => {
    mockFlagError('feature:new-checkout', new Error('Service unavailable'));

    const result = await processCheckout(mockOrder);

    expect(result.flow).toBe('legacy');
    expect(logger.warn).toHaveBeenCalledWith(
      expect.stringContaining('fallback'),
      expect.any(Object)
    );
  });

  it('should respect rollout percentage consistently', () => {
    const userIds = Array.from({ length: 100 }, (_, i) => `user-${i}`);
    const results = userIds.map(userId =>
      isFeatureEnabled('feature:rollout-test', userId, 30)
    );

    const enabledCount = results.filter(Boolean).length;
    expect(enabledCount).toBeGreaterThanOrEqual(25);
    expect(enabledCount).toBeLessThanOrEqual(35);

    // Consistency check: same user always gets same result
    const firstResult = isFeatureEnabled('feature:rollout-test', 'user-1', 30);
    for (let i = 0; i < 10; i++) {
      expect(isFeatureEnabled('feature:rollout-test', 'user-1', 30)).toBe(firstResult);
    }
  });
});
```

### Flag Registry Documentation

```markdown
# Feature Flag Registry

## Active Flags

### `feature:new-checkout`
- **Description**: New checkout flow with saved payment methods
- **Owner**: payments-team@company.com
- **Slack**: #payments-alerts
- **Created**: 2026-01-15
- **Expires**: 2026-04-15
- **Jira**: PAY-1234
- **Rollout Plan**: 1% → 10% → 50% → 100%
- **Metrics Dashboard**: [Grafana Link]

### `feature:dark-mode`
- **Description**: Dark mode theme for dashboard
- **Owner**: frontend-team@company.com
- **Created**: 2026-02-01
- **Expires**: 2026-05-01
- **Status**: 50% rollout

## Expired Flags (To Be Removed)

### `feature:old-feature` (Expired: 2026-01-01)
- **Action Required**: Remove flag and clean up code
- **Issue**: CLEANUP-123
```

---

## Integration with Other Reviews

This skill complements:
- `/observability-check` - For flag usage metrics and monitoring
- `/error-resilience-review` - For circuit breakers and fallbacks
- `/api-readiness-review` - For API versioning with flags
- `/devops-review` - For deployment safety with flags
- `/quality-check` - For flag implementation quality
