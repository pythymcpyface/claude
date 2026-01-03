# Consolidate Algorithm Command

## Purpose
Detect multiple implementations of the same algorithm across a codebase, analyze differences, consolidate them into a single source of truth, and migrate all call sites.

## Problem Solved
Multiple implementations of the same algorithm across systems cause:
- **Divergence**: Implementations drift apart over time
- **Bugs**: Fixes applied to one implementation but not others
- **Maintenance Overhead**: Changes must be replicated across all versions
- **Testing Complexity**: Each implementation needs separate test coverage

## Common Examples
- Rating algorithms (Glicko-2, ELO) implemented in multiple services
- Signal generation logic duplicated across live trading, backtesting, and batch processing
- Data normalization/filtering with inconsistent implementations
- AI analysis logic duplicated across components

## Usage
```
/consolidate-algorithm [algorithm-name] [canonical-source-path]
```

**Arguments:**
- `algorithm-name`: Name of the algorithm to consolidate (e.g., "glicko-2", "signal-generation")
- `canonical-source-path`: (Optional) Path to the most authoritative implementation. If not provided, Claude will analyze all implementations and recommend one.

## Workflow

### Step 1: Detection
Detect all implementations of the specified algorithm in the codebase.

**Search strategies:**
- Function/class name matching (case-insensitive)
- Code similarity analysis
- Comment/documentation references
- Import/usage pattern analysis

**Output:**
```
Found 4 implementations of "glicko-2":
1. src/services/ratings/glicko.ts (312 lines, well-tested)
2. workers/batch/calculateRatings.ts (87 lines, no tests)
3. rust-engine/src/ratings.rs (245 lines, benchmarked)
4. scripts/backfill-ratings.js (156 lines, deprecated?)
```

### Step 2: Analysis
Analyze differences between implementations.

**Comparison criteria:**
- **Algorithm correctness**: Which matches reference implementation?
- **Test coverage**: Which has comprehensive tests?
- **Performance**: Benchmarks and optimization
- **Type safety**: TypeScript vs JavaScript vs Rust
- **Dependencies**: External library usage
- **Documentation**: Inline comments and references
- **Recency**: Last modified date

**Output:**
```
Implementation Comparison:

┌─────────────────────┬──────────┬──────────┬────────────┬─────────┐
│ Implementation      │ Tests    │ Type Safe│ Performance│ Correct │
├─────────────────────┼──────────┼──────────┼────────────┼─────────┤
│ glicko.ts           │ 15 tests │ ✓        │ Medium     │ ✓       │
│ calculateRatings.ts │ None     │ ✗        │ Slow       │ ✗ (bug) │
│ ratings.rs          │ 8 tests  │ ✓        │ Fast       │ ✓       │
│ backfill-ratings.js │ 2 tests  │ ✗        │ Medium     │ ✓       │
└─────────────────────┴──────────┴──────────┴────────────┴─────────┘

Recommendation: Use glicko.ts as canonical (most tested, type-safe, correct)
Alternative: ratings.rs for performance-critical paths
```

### Step 3: Identify Canonical Implementation
Based on analysis, identify or validate the canonical implementation.

**Selection criteria (prioritized):**
1. **Correctness**: Matches reference implementation
2. **Test coverage**: Comprehensive tests
3. **Type safety**: Strong typing
4. **Documentation**: Well-documented with references
5. **Maintainability**: Clean code, follows patterns
6. **Performance**: Acceptable speed (optimize later if needed)

**If user provided canonical-source:**
- Validate it's suitable
- Warn about any issues
- Proceed with user choice

**If Claude selects:**
- Explain rationale
- Ask for user confirmation
- Allow override

### Step 4: Extract to Shared Service
Create a shared service/utility with the canonical implementation.

**For TypeScript/JavaScript:**
```
src/services/shared/[algorithm-name]/
├── index.ts              # Main implementation
├── types.ts              # Type definitions
├── constants.ts          # Algorithm constants
├── __tests__/
│   ├── reference.test.ts # Reference validation tests
│   ├── parity.test.ts    # Parity with old implementations
│   └── edge-cases.test.ts
└── README.md             # Algorithm documentation
```

**For Rust:**
```
src/services/shared/[algorithm-name]/
├── mod.rs                # Rust implementation
├── lib.rs                # Public API
├── tests/
│   ├── reference.rs
│   └── parity.rs
└── README.md
```

**Dual implementation (TypeScript + Rust):**
- TypeScript for application logic
- Rust for performance-critical paths
- FFI bindings or microservice API

### Step 5: Generate Type Definitions and API Contracts
Create clear interfaces for the consolidated algorithm.

```typescript
// types.ts
export interface GlickoInput {
  rating: number;
  rd: number; // Rating deviation
  vol: number; // Volatility
  matches: Match[];
}

export interface GlickoOutput {
  rating: number;
  rd: number;
  vol: number;
  confidence: number;
}

export interface Match {
  opponentRating: number;
  opponentRd: number;
  outcome: 'win' | 'loss' | 'draw';
}

// index.ts
/**
 * Calculate Glicko-2 rating.
 * @see http://www.glicko.net/glicko/glicko2.pdf
 */
export function calculateGlicko2(input: GlickoInput): GlickoOutput {
  // Canonical implementation
}
```

### Step 6: Update All Call Sites
Replace all usages with calls to the shared service.

**Migration strategy:**
```typescript
// Old (in calculateRatings.ts):
function calculateRating(player) {
  // Local implementation (87 lines)
}

// New (after consolidation):
import { calculateGlicko2 } from '@/services/shared/glicko-2';

function calculateRating(player) {
  return calculateGlicko2({
    rating: player.rating,
    rd: player.rd,
    vol: player.volatility,
    matches: player.recentMatches
  });
}
```

**For each call site:**
1. Identify the function call pattern
2. Map old parameters to new interface
3. Update imports
4. Refactor calling code if needed
5. Add type annotations

### Step 7: Create Parity Tests
Validate that consolidation doesn't change behavior.

```typescript
// __tests__/parity.test.ts
import { calculateGlicko2 } from '../index';
import { oldImplementation1 } from '@/test-fixtures/old-implementations';
import { oldImplementation2 } from '@/test-fixtures/old-implementations';

describe('Consolidation Parity', () => {
  const testCases = loadHistoricalTestData();

  test('matches old implementation 1', () => {
    testCases.forEach(({ input, expected }) => {
      const newResult = calculateGlicko2(input);
      const oldResult = oldImplementation1(input);

      expect(newResult).toEqual(oldResult);
    });
  });

  test('matches reference implementation', () => {
    // From Glickman's paper
    const referenceTests = [
      {
        input: { rating: 1500, rd: 200, vol: 0.06, matches: [...] },
        expected: { rating: 1464.06, rd: 151.52, vol: 0.05999 }
      }
    ];

    referenceTests.forEach(({ input, expected }) => {
      const result = calculateGlicko2(input);
      expect(result.rating).toBeCloseTo(expected.rating, 1);
      expect(result.rd).toBeCloseTo(expected.rd, 1);
      expect(result.vol).toBeCloseTo(expected.vol, 4);
    });
  });
});
```

### Step 8: Generate Removal Checklist
Create a checklist for safely removing duplicate implementations.

```markdown
## Removal Checklist

### Phase 1: Validation (Week 1)
- [x] Consolidated implementation created
- [x] All parity tests passing
- [x] All call sites updated
- [ ] Deployed to staging environment
- [ ] Smoke tests pass on staging
- [ ] Performance benchmarks acceptable

### Phase 2: Monitoring (Week 2)
- [ ] Monitor error rates (should be unchanged)
- [ ] Monitor performance metrics (should improve or stay same)
- [ ] Check for algorithm divergence in logs
- [ ] User-reported issues (should be none related to this change)

### Phase 3: Cleanup (Week 3)
- [ ] Remove old implementation from calculateRatings.ts
- [ ] Remove old implementation from backfill-ratings.js
- [ ] Keep Rust implementation (used for performance)
- [ ] Archive old test fixtures
- [ ] Update documentation

### Files to Delete
- [ ] workers/batch/calculateRatings.ts (lines 45-132)
- [ ] scripts/backfill-ratings.js
- [ ] src/utils/old-glicko.ts
- [ ] __tests__/old-implementations/

### Files to Keep
- [x] src/services/shared/glicko-2/ (canonical)
- [x] rust-engine/src/ratings.rs (performance path)
```

### Step 9: Report Consolidation Summary
Generate a comprehensive report of the consolidation.

```markdown
# Algorithm Consolidation Report: glicko-2

**Date:** 2025-12-29
**Algorithm:** Glicko-2 Rating System
**Implementations Found:** 4
**Canonical Source:** src/services/shared/glicko-2/

## Summary
Successfully consolidated 4 implementations of Glicko-2 rating algorithm into a single, well-tested shared service. Eliminated 2 buggy implementations and reduced code duplication by ~400 lines.

## Implementations Analyzed
1. ✅ src/services/ratings/glicko.ts → **Canonical** (most correct, well-tested)
2. ⚠️ workers/batch/calculateRatings.ts → Removed (had bug in RD calculation)
3. ✅ rust-engine/src/ratings.rs → Kept (performance optimization)
4. ⚠️ scripts/backfill-ratings.js → Removed (deprecated, no tests)

## Key Differences Found
- **Bug in calculateRatings.ts**: RD calculation used wrong constant (0.5 vs 0.3)
- **Performance**: Rust version 15x faster (0.03ms vs 0.5ms per calculation)
- **Type Safety**: Only glicko.ts had full TypeScript types

## Validation Results
- ✅ Reference tests: 5/5 passing (matches Glickman 2012 paper)
- ✅ Parity tests: 1,247/1,247 passing (historical data)
- ✅ Edge cases: 23/23 passing
- ✅ Performance: Within 5% of original

## Call Sites Updated
1. TradingEngine.ts (lines 234-245)
2. BatchWorker.ts (lines 89-102)
3. ItemSummary.tsx (lines 156-167)
4. AlertWorker.ts (lines 45-52)

Total: 4 call sites, 0 errors

## Benefits
- **Single Source of Truth**: All code uses same algorithm
- **Bug Fix**: Eliminated RD calculation bug
- **Reduced Duplication**: -387 lines of code
- **Better Testing**: Consolidated test suite (48 tests)
- **Type Safety**: Full TypeScript coverage

## Next Steps
1. Monitor error rates for 1 week
2. Performance benchmarks in production
3. Delete old implementations (see removal checklist)
4. Update architecture documentation

## Risks & Mitigations
- **Risk**: Breaking changes to existing behavior
  - *Mitigation*: Comprehensive parity tests, gradual rollout
- **Risk**: Performance regression
  - *Mitigation*: Benchmarks show 5% improvement, can fallback to Rust if needed
```

## Files Created

The command will create the following files:

1. **Consolidated Implementation**
   - `src/services/shared/[algorithm-name]/index.ts`
   - `src/services/shared/[algorithm-name]/types.ts`
   - `src/services/shared/[algorithm-name]/constants.ts`
   - `src/services/shared/[algorithm-name]/README.md`

2. **Tests**
   - `src/services/shared/[algorithm-name]/__tests__/reference.test.ts`
   - `src/services/shared/[algorithm-name]/__tests__/parity.test.ts`
   - `src/services/shared/[algorithm-name]/__tests__/edge-cases.test.ts`

3. **Documentation**
   - `CONSOLIDATION_REPORT_[algorithm-name].md` (in project root)
   - `REMOVAL_CHECKLIST_[algorithm-name].md` (in project root)

## Benefits

1. **Single Source of Truth**: All code uses the same, validated algorithm
2. **Reduced Bugs**: Fixes applied once affect all usages
3. **Easier Testing**: One test suite instead of multiple
4. **Better Maintainability**: Changes made in one place
5. **Type Safety**: Consistent interfaces across codebase
6. **Performance**: Opportunity to optimize once for all use cases

## Time Savings

- **Manual consolidation**: ~8-12 hours (detection, analysis, migration, testing)
- **With this command**: ~1-2 hours (review and validation)
- **ROI**: 5x (per the analysis report)

## Example Usage

```bash
# Consolidate Glicko-2 rating implementations
/consolidate-algorithm glicko-2

# Consolidate with specific canonical source
/consolidate-algorithm signal-generation src/services/signals/generator.ts

# Consolidate aspect filtering
/consolidate-algorithm aspect-filter
```

## Notes

- **Always review before deleting**: The command generates a removal checklist but doesn't delete old code automatically
- **Gradual rollout**: Use feature flags for high-risk consolidations
- **Performance testing**: Benchmark before and after, especially for critical paths
- **Team coordination**: Notify team members who work on affected code
