# Adaptive Optimization Skill

## Overview
Patterns and strategies for implementing adaptive algorithms that adjust parameters based on real-time data characteristics, enabling systems to self-tune for optimal performance.

## When to Activate
- Implementing pagination or data collection systems
- Tuning performance-critical parameters
- Designing systems that operate on variable data densities
- Building self-optimizing algorithms
- Creating dynamic rate limiting or throttling

## Core Concepts

### Adaptive Parameter Tuning
Unlike static parameters (fixed values), adaptive parameters adjust based on observed metrics to optimize for current conditions.

**Example scenarios:**
- Pagination increments (fixed 10 → dynamic 1-15 based on data density)
- Rate limiting (static → adaptive based on success rate)
- Cache TTL (fixed → dynamic based on hit rate)
- Batch size (fixed → adaptive based on processing time)

## Data Density Classification

### High-Density Data (>70% success rate)
**Characteristics:**
- Most operations yield new/useful data
- Low duplication rate
- High "hit rate"

**Optimization strategy:**
- Small increments for fine-grained control
- Fast iteration to avoid gaps
- Conservative approach to prevent missing data

**Example:**
```typescript
// Pagination in high-density region
if (successRate > 0.7) {
  increment = 1; // Small steps to avoid gaps
  delay = 100ms; // Fast iteration
}
```

### Medium-Density Data (30-70% success rate)
**Characteristics:**
- Moderate success rate
- Some duplication
- Variable data quality

**Optimization strategy:**
- Moderate increments
- Balanced speed vs coverage
- Adaptive thresholds

**Example:**
```typescript
// Balanced approach
if (successRate >= 0.3 && successRate <= 0.7) {
  increment = 5; // Moderate steps
  delay = 500ms; // Balanced timing
}
```

### Low-Density Data (<30% success rate)
**Characteristics:**
- High duplication or empty results
- Sparse useful data
- Risk of wasted operations

**Optimization strategy:**
- Large increments to skip sparse regions
- Slower iteration to avoid API limits
- Risk of gaps acceptable (low yield anyway)

**Example:**
```typescript
// Large steps in sparse regions
if (successRate < 0.3) {
  increment = 15; // Large jumps
  delay = 1000ms; // Slower to conserve resources
}
```

## Metrics to Track

### 1. Success Rate
Percentage of operations that yield useful results.

```typescript
interface SuccessMetrics {
  total: number;
  successful: number;
  rate: number; // successful / total
}

class SuccessRateTracker {
  private window: boolean[] = [];
  private maxSize: number = 10;

  record(success: boolean) {
    this.window.push(success);
    if (this.window.length > this.maxSize) {
      this.window.shift();
    }
  }

  getRate(): number {
    if (this.window.length === 0) return 0;
    const successful = this.window.filter(s => s).length;
    return successful / this.window.length;
  }
}
```

### 2. Duplicate Rate
Percentage of data that's already been seen.

```typescript
interface DuplicateMetrics {
  seen: Set<string>;
  duplicateCount: number;
  totalCount: number;
  rate: number;
}

class DuplicateTracker {
  private seen = new Set<string>();
  private duplicates = 0;
  private total = 0;

  check(id: string): boolean {
    this.total++;
    if (this.seen.has(id)) {
      this.duplicates++;
      return true; // Is duplicate
    }
    this.seen.add(id);
    return false; // Is new
  }

  getRate(): number {
    return this.total === 0 ? 0 : this.duplicates / this.total;
  }
}
```

### 3. Velocity
Rate of change in the target metric.

```typescript
class VelocityTracker {
  private values: number[] = [];
  private timestamps: number[] = [];

  record(value: number) {
    this.values.push(value);
    this.timestamps.push(Date.now());

    // Keep last 10 samples
    if (this.values.length > 10) {
      this.values.shift();
      this.timestamps.shift();
    }
  }

  getVelocity(): number {
    if (this.values.length < 2) return 0;

    const firstValue = this.values[0];
    const lastValue = this.values[this.values.length - 1];
    const firstTime = this.timestamps[0];
    const lastTime = this.timestamps[this.timestamps.length - 1];

    const timeElapsed = (lastTime - firstTime) / 1000; // seconds
    return (lastValue - firstValue) / timeElapsed; // units per second
  }
}
```

### 4. Window Size
Rolling average window (typically 5-10 samples).

```typescript
class RollingWindow<T> {
  private window: T[] = [];

  constructor(private maxSize: number = 5) {}

  push(value: T) {
    this.window.push(value);
    if (this.window.length > this.maxSize) {
      this.window.shift();
    }
  }

  average(): number {
    if (this.window.length === 0) return 0;
    const sum = this.window.reduce((acc, val) => acc + Number(val), 0);
    return sum / this.window.length;
  }

  getAll(): T[] {
    return [...this.window];
  }
}
```

## Adaptive Algorithm Template

```typescript
interface AdaptiveConfig {
  highThreshold: number;  // e.g., 0.7
  lowThreshold: number;   // e.g., 0.3
  minIncrement: number;   // e.g., 1
  maxIncrement: number;   // e.g., 15
  windowSize: number;     // e.g., 5
}

class AdaptiveOptimizer {
  private metrics: RollingWindow<number>;
  private config: AdaptiveConfig;

  constructor(config: AdaptiveConfig) {
    this.config = config;
    this.metrics = new RollingWindow(config.windowSize);
  }

  recordMetric(value: number) {
    this.metrics.push(value);
  }

  getAdjustment(): 'reduce' | 'increase' | 'maintain' {
    const avgMetric = this.metrics.average();

    if (avgMetric > this.config.highThreshold) {
      return 'reduce'; // High density, smaller steps
    } else if (avgMetric < this.config.lowThreshold) {
      return 'increase'; // Low density, larger steps
    }
    return 'maintain';
  }

  getIncrement(): number {
    const adjustment = this.getAdjustment();
    const avgMetric = this.metrics.average();

    if (adjustment === 'reduce') {
      // High density: use minimum increment
      return this.config.minIncrement;
    } else if (adjustment === 'increase') {
      // Low density: use maximum increment
      return this.config.maxIncrement;
    } else {
      // Medium density: interpolate
      const range = this.config.maxIncrement - this.config.minIncrement;
      const position = (avgMetric - this.config.lowThreshold) /
                      (this.config.highThreshold - this.config.lowThreshold);
      const increment = this.config.maxIncrement - (position * range);
      return Math.round(increment);
    }
  }
}
```

## Phase Transitions

Adaptive systems often go through distinct phases as they collect data.

### 1. Discovery Phase
**Goal:** Wide exploration, accept higher variance

**Characteristics:**
- Large increments to cover ground quickly
- Higher tolerance for gaps
- Collecting initial metrics

**Strategy:**
```typescript
class DiscoveryPhase {
  isComplete(metrics: Metrics): boolean {
    // Complete when we have sufficient data
    return metrics.sampleSize >= 20;
  }

  getIncrement(): number {
    return 10; // Large steps for exploration
  }
}
```

### 2. Adaptive Phase
**Goal:** Fine-tune based on metrics, reduce variance

**Characteristics:**
- Dynamic increments based on density
- Adjust thresholds as needed
- Optimize for efficiency

**Strategy:**
```typescript
class AdaptivePhase {
  private optimizer: AdaptiveOptimizer;

  getIncrement(metrics: Metrics): number {
    this.optimizer.recordMetric(metrics.successRate);
    return this.optimizer.getIncrement();
  }
}
```

### 3. Boundary Refinement
**Goal:** Conservative adjustments, maximum safety

**Characteristics:**
- Small increments near boundaries
- Prevent overshooting limits
- Ensure complete coverage

**Strategy:**
```typescript
class BoundaryRefinementPhase {
  isNearBoundary(current: number, boundary: number): boolean {
    const distance = Math.abs(boundary - current);
    return distance < 100; // Within 100 units of boundary
  }

  getIncrement(current: number, boundary: number): number {
    if (this.isNearBoundary(current, boundary)) {
      return 1; // Small steps near boundary
    }
    return 5; // Normal steps otherwise
  }
}
```

## Stop Conditions

Define when to stop the adaptive process.

```typescript
enum StopReason {
  TARGET_COVERAGE_ACHIEVED = 'target_coverage_achieved',
  EXTERNAL_LIMIT = 'external_limit',
  DATA_EXHAUSTED = 'data_exhausted',
  QUALITY_THRESHOLD_BREACHED = 'quality_threshold_breached',
  USER_CANCELLED = 'user_cancelled',
}

class StopConditionChecker {
  check(state: SystemState): StopReason | null {
    // Target coverage achieved
    if (state.coverage >= state.targetCoverage) {
      return StopReason.TARGET_COVERAGE_ACHIEVED;
    }

    // External limit detected (API rate limit)
    if (state.rateLimitHit) {
      return StopReason.EXTERNAL_LIMIT;
    }

    // Data exhausted (no new items)
    if (state.consecutiveEmptyResults >= 5) {
      return StopReason.DATA_EXHAUSTED;
    }

    // Quality threshold breached (too many errors)
    if (state.errorRate > 0.5) {
      return StopReason.QUALITY_THRESHOLD_BREACHED;
    }

    return null; // Continue
  }
}
```

## Complete Example: Adaptive Pagination

```typescript
interface PaginationState {
  currentPage: number;
  increment: number;
  itemsCollected: number;
  targetItems: number;
}

class AdaptivePagination {
  private state: PaginationState;
  private optimizer: AdaptiveOptimizer;
  private successTracker: SuccessRateTracker;
  private duplicateTracker: DuplicateTracker;
  private stopChecker: StopConditionChecker;

  constructor(targetItems: number) {
    this.state = {
      currentPage: 1,
      increment: 5, // Start with moderate increment
      itemsCollected: 0,
      targetItems,
    };

    this.optimizer = new AdaptiveOptimizer({
      highThreshold: 0.7,
      lowThreshold: 0.3,
      minIncrement: 1,
      maxIncrement: 15,
      windowSize: 5,
    });

    this.successTracker = new SuccessRateTracker();
    this.duplicateTracker = new DuplicateTracker();
    this.stopChecker = new StopConditionChecker();
  }

  async fetchPage(page: number): Promise<Item[]> {
    // Fetch data for the page
    const items = await api.getItems({ page, perPage: 50 });
    return items;
  }

  async run() {
    while (true) {
      // Fetch current page
      const items = await this.fetchPage(this.state.currentPage);

      // Track metrics
      const newItems = items.filter(item => !this.duplicateTracker.check(item.id));
      const hasNewData = newItems.length > 0;
      this.successTracker.record(hasNewData);

      // Collect items
      this.state.itemsCollected += newItems.length;

      // Update metrics for optimizer
      const successRate = this.successTracker.getRate();
      this.optimizer.recordMetric(successRate);

      // Check stop conditions
      const stopReason = this.stopChecker.check({
        coverage: this.state.itemsCollected / this.state.targetItems,
        targetCoverage: 1.0,
        consecutiveEmptyResults: hasNewData ? 0 : this.state.consecutiveEmpty++,
        errorRate: 0, // Track separately
        rateLimitHit: false, // Track separately
      });

      if (stopReason) {
        console.log(`Stopping: ${stopReason}`);
        break;
      }

      // Adapt increment
      this.state.increment = this.optimizer.getIncrement();

      // Move to next page
      this.state.currentPage += this.state.increment;

      console.log(`Page ${this.state.currentPage}, increment: ${this.state.increment}, success rate: ${successRate.toFixed(2)}`);
    }

    return {
      itemsCollected: this.state.itemsCollected,
      pagesScanned: this.state.currentPage,
    };
  }
}
```

## Best Practices

1. **Start Conservative**: Begin with moderate parameters, adjust as data arrives
2. **Use Rolling Windows**: Avoid over-reacting to single data points
3. **Define Clear Thresholds**: High, medium, low density ranges
4. **Monitor Metrics**: Log adjustments for debugging and tuning
5. **Test Boundaries**: Ensure behavior is correct at extremes
6. **Gradual Changes**: Avoid sudden jumps in parameters
7. **Safety Limits**: Always have min/max bounds

## Common Pitfalls

1. **Too Aggressive**: Large increments can miss data
2. **Too Conservative**: Small increments waste time in sparse regions
3. **Insufficient Data**: Making decisions with too few samples
4. **Ignoring Variance**: Not accounting for data variability
5. **No Stop Conditions**: Infinite loops when data is exhausted
