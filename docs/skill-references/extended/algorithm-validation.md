# Algorithm Validation Skill

## Overview
Comprehensive validation strategies for ensuring algorithm correctness and preventing regression when consolidating or modifying critical business logic.

## When to Activate
- Consolidating duplicate algorithm implementations
- Migrating algorithms between languages (TypeScript → Rust)
- Optimizing performance-critical code
- Refactoring complex business logic
- Implementing mathematical or statistical algorithms

## 5-Layer Validation Strategy

### Layer 1: Reference Validation
Compare against known good outputs from academic references or official implementations.

```typescript
test('glicko-2 matches reference implementation', () => {
  // From Glickman's paper (2012)
  const referenceInput = { rating: 1500, rd: 200, vol: 0.06 };
  const referenceOutput = { rating: 1464, rd: 151.4, vol: 0.05999 };

  const result = calculateGlicko2(referenceInput);
  expect(result).toBeCloseTo(referenceOutput, precision: 1);
});
```

**When to use:**
- Implementing academic algorithms (Glicko-2, PageRank, etc.)
- Standardized calculations (tax, interest, cryptography)
- Any algorithm with published test cases

### Layer 2: Implementation Parity
Validate different implementations (TypeScript vs Rust) produce identical results.

```typescript
test('typescript and rust implementations match', async () => {
  const input = generateRandomTestCases(100);

  const tsResults = input.map(i => calculateGlickoTS(i));
  const rsResults = await callRustService(input);

  expect(tsResults).toEqual(rsResults);
});
```

**When to use:**
- Multiple implementations in different languages
- Comparing old vs new implementation
- Validating microservice vs monolith logic

### Layer 3: Regression Prevention
Ensure changes don't break existing behavior.

```typescript
test('maintains backward compatibility', () => {
  const historicalData = loadHistoricalResults();

  for (const [input, expectedOutput] of historicalData) {
    const result = newImplementation(input);
    expect(result).toEqual(expectedOutput);
  }
});
```

**When to use:**
- Refactoring existing algorithms
- Performance optimizations
- Bug fixes that shouldn't change behavior

### Layer 4: Edge Case Coverage
Test boundary conditions and corner cases.

```typescript
test('handles edge cases correctly', () => {
  // New player (no history)
  expect(calculate({ rating: null })).toBeDefined();

  // Perfect win streak
  expect(calculate({ wins: 100, losses: 0 })).toBeLessThan(maxRating);

  // Division by zero
  expect(calculate({ rd: 0 })).not.toThrow();
});
```

**Edge cases to consider:**
- Null/undefined inputs
- Zero values
- Maximum/minimum values
- Empty arrays/objects
- Single-item collections
- Very large numbers
- Negative numbers where unexpected

### Layer 5: Performance Benchmarking
Track that optimizations actually improve speed.

```typescript
test('optimization improves performance', () => {
  const input = generateLargeDataset(10000);

  const oldTime = benchmark(() => oldImplementation(input));
  const newTime = benchmark(() => newImplementation(input));

  expect(newTime).toBeLessThan(oldTime * 0.8); // 20% faster
});
```

**Benchmarking best practices:**
- Use realistic data sizes
- Run multiple iterations (warm-up)
- Measure both average and p95/p99
- Test with different input characteristics

## Parity Test Pattern

When consolidating duplicate implementations:

```typescript
describe('Algorithm Consolidation Parity', () => {
  // Test 1: All implementations produce same result
  test('all implementations match', () => {
    const input = standardTestCases();

    const resultA = implementationA(input);
    const resultB = implementationB(input);
    const resultC = implementationC(input);

    expect(resultA).toEqual(resultB);
    expect(resultB).toEqual(resultC);
  });

  // Test 2: Consolidated version matches canonical
  test('consolidated matches canonical', () => {
    const canonical = identifyCanonicalImplementation();
    const consolidated = newSharedService(input);

    expect(consolidated).toEqual(canonical);
  });
});
```

## Validation Checklist

### Pre-Implementation
- [ ] Identify reference implementation or academic source
- [ ] Collect known good test cases
- [ ] Document expected behavior and edge cases
- [ ] Identify all existing implementations to consolidate

### During Implementation
- [ ] Write reference validation tests first
- [ ] Implement algorithm with clear documentation
- [ ] Add edge case tests
- [ ] Benchmark performance

### Post-Implementation
- [ ] Verify parity with all old implementations
- [ ] Run regression tests on historical data
- [ ] Performance comparison meets targets
- [ ] Update all call sites
- [ ] Remove old implementations

## Common Validation Patterns

### Floating Point Comparison
```typescript
// DON'T: Direct equality
expect(result).toBe(0.3); // May fail due to floating point

// DO: Use tolerance
expect(result).toBeCloseTo(0.3, precision: 2);
```

### Array/Object Comparison
```typescript
// Deep equality
expect(result).toEqual(expected);

// Partial matching
expect(result).toMatchObject({
  rating: expect.any(Number),
  rd: expect.any(Number)
});
```

### Property-Based Testing
```typescript
import { fc } from 'fast-check';

test('algorithm properties hold for random inputs', () => {
  fc.assert(
    fc.property(
      fc.integer({ min: 0, max: 3000 }),
      fc.integer({ min: 1, max: 350 }),
      (rating, rd) => {
        const result = calculateGlicko2({ rating, rd, vol: 0.06 });

        // Properties that should always hold
        expect(result.rating).toBeGreaterThan(0);
        expect(result.rd).toBeGreaterThan(0);
        expect(result.vol).toBeGreaterThan(0);
      }
    )
  );
});
```

### Snapshot Testing (Use Sparingly)
```typescript
test('output structure matches snapshot', () => {
  const result = complexAlgorithm(input);
  expect(result).toMatchSnapshot();
});
```

**Warning:** Only use snapshots for complex structures where manual assertions are impractical. Update carefully.

## Migration Workflow

### Step 1: Capture Current Behavior
```typescript
// Before refactoring, capture current outputs
const historicalTestCases = currentUsers.map(user => ({
  input: { userId: user.id, matches: user.matches },
  output: oldCalculateRating(user)
}));

// Save to file
fs.writeFileSync('migration-test-data.json', JSON.stringify(historicalTestCases));
```

### Step 2: Implement New Version
```typescript
// Implement new consolidated version
function newCalculateRating(input) {
  // New implementation
}
```

### Step 3: Validate Parity
```typescript
test('new implementation matches old behavior', () => {
  const testCases = JSON.parse(fs.readFileSync('migration-test-data.json'));

  for (const { input, output } of testCases) {
    const newOutput = newCalculateRating(input);
    expect(newOutput).toEqual(output);
  }
});
```

### Step 4: Gradual Rollout
```typescript
// Feature flag for gradual migration
function calculateRating(input) {
  if (featureFlags.useNewRatingAlgorithm) {
    return newCalculateRating(input);
  }
  return oldCalculateRating(input);
}

// Shadow mode: run both, log differences
function calculateRatingWithShadow(input) {
  const oldResult = oldCalculateRating(input);
  const newResult = newCalculateRating(input);

  if (!isEqual(oldResult, newResult)) {
    logger.warn('Algorithm divergence detected', {
      input,
      oldResult,
      newResult,
      diff: calculateDiff(oldResult, newResult)
    });
  }

  return oldResult; // Still using old in shadow mode
}
```

## Error Analysis

When tests fail, systematically analyze:

```typescript
test('detailed error analysis', () => {
  const input = { rating: 1500, rd: 200, vol: 0.06 };
  const expected = { rating: 1464, rd: 151.4, vol: 0.05999 };
  const actual = calculateGlicko2(input);

  // Calculate deltas
  const ratingDelta = Math.abs(actual.rating - expected.rating);
  const rdDelta = Math.abs(actual.rd - expected.rd);
  const volDelta = Math.abs(actual.vol - expected.vol);

  // Report which fields diverged
  if (ratingDelta > 1) {
    console.log(`Rating divergence: ${ratingDelta} (expected: ${expected.rating}, actual: ${actual.rating})`);
  }

  expect(ratingDelta).toBeLessThan(1);
  expect(rdDelta).toBeLessThan(0.5);
  expect(volDelta).toBeLessThan(0.00001);
});
```

## Documentation Requirements

Every validated algorithm should include:

```typescript
/**
 * Calculate Glicko-2 rating based on match outcomes.
 *
 * @reference Glickman, M. (2012). "Example of the Glicko-2 system"
 * @see http://www.glicko.net/glicko/glicko2.pdf
 *
 * @validation
 * - Reference test cases from Glickman's paper (2012)
 * - Parity tests with Rust implementation
 * - Regression tests on 10,000 historical ratings
 *
 * @performance O(n) where n = number of matches
 * @benchmark ~0.5ms per rating calculation (tested with 100 matches)
 *
 * @param input - Player rating data and match results
 * @returns Updated rating, RD, and volatility
 */
export function calculateGlicko2(input: RatingInput): RatingOutput {
  // Implementation
}
```

## Success Criteria

An algorithm is considered validated when:
- [ ] All 5 validation layers pass
- [ ] Performance benchmarks meet targets
- [ ] Edge cases documented and tested
- [ ] Reference implementation cited (if applicable)
- [ ] Parity with all old implementations verified
- [ ] Regression tests on production data pass
- [ ] Code review approved
- [ ] Documentation complete
