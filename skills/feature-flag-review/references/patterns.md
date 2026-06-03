# feature-flag-review — Implementation Patterns

Reusable code snippets and configuration templates for feature-flag-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

