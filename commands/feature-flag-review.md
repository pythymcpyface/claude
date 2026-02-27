---
description: Production readiness review for Feature Flag management. Reviews gradual rollout strategies, dark launches, kill switches, safety mechanisms, performance impact, and lifecycle management before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Feature Flag Review Command

Run a comprehensive production readiness review focused on feature flag management, progressive delivery, and safe rollout strategies.

## Purpose

Review feature flags before production release to ensure:
- Gradual rollout strategies are properly implemented
- Kill switches and emergency rollback capabilities exist
- Dark launch patterns are used for safe testing
- Safety mechanisms (fallbacks, timeouts, caching) are in place
- Performance impact is minimized
- Testing covers all flag states
- Lifecycle management prevents flag accumulation

## Workflow

### 1. Load the Feature Flag Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/feature-flag-review/SKILL.md
```

### 2. Detect Feature Flag Stack

Identify the feature flag system and implementation:
```bash
# Detect feature flag libraries/services
grep -r "launchdarkly\|ldclient\|unleash\|flagsmith\|splitio\|optimizely" package.json requirements.txt go.mod 2>/dev/null

# Detect custom flag implementations
grep -r "featureFlag\|feature_flag\|isFeatureEnabled\|checkFlag" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Detect flag configuration files
find . -name "*flag*" -o -name "*toggle*" -o -name "*feature*" 2>/dev/null | grep -E "\.(json|yaml|yml|toml|env)" | head -10
```

### 3. Run Feature Flag Readiness Checks

Execute all checks in parallel:

**Flag Naming & Organization:**
```bash
# Find flag definitions
grep -r "featureFlag\|feature_flag\|FEATURE_\|flag.*=" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find flag documentation
find . -name "*.md" -exec grep -l "flag\|toggle\|feature" {} \; 2>/dev/null | head -10
```

**Rollout Strategy:**
```bash
# Find rollout/percentage logic
grep -r "rollout\|percentage\|percent\|traffic.*split" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find hash-based consistency
grep -r "hash\|bucket\|consistent.*hash\|user.*id.*%" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15
```

**Kill Switch & Rollback:**
```bash
# Find kill switch patterns
grep -r "kill.*switch\|emergency\|instant.*off\|disable.*immediate" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find admin override patterns
grep -r "admin.*override\|manual.*toggle\|force.*enable\|force.*disable" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Safety Mechanisms:**
```bash
# Find default value patterns
grep -r "default.*value\|fallback\|fallbackValue\|defaultValue" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find timeout configurations
grep -r "timeout\|Timeout" --include="*flag*" 2>/dev/null | head -10

# Find caching patterns
grep -r "cache.*flag\|flag.*cache" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

**Testing Coverage:**
```bash
# Find flag-related tests
find . -name "*.test.*" -o -name "*.spec.*" | xargs grep -l "flag\|toggle\|feature" 2>/dev/null | head -15

# Find flag state tests
grep -r "flagEnabled\|flagDisabled\|withFlag\|withoutFlag" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -15
```

**Lifecycle Management:**
```bash
# Find flag metadata/ownership
grep -r "owner\|Owner\|expires\|expiry\|sunset" --include="*flag*" 2>/dev/null | head -15

# Find audit/logging
grep -r "audit\|flag.*change\|flag.*history" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Rollout, Kill Switch, Safety, Performance, Testing, Lifecycle)
- Calculate overall score (weighted: 20% / 25% / 20% / 10% / 15% / 10%)
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All critical checks pass |
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
1. [CRITICAL] Implement kill switch for instant disable
2. [CRITICAL] Add runtime flag configuration for rollback
3. [HIGH] Add timeout to all flag evaluations
4. [HIGH] Add tests for flag-off states
5. [HIGH] Document all flags with ownership

**Short-term (Within 1 week):**
6. [MEDIUM] Implement local caching for flags
7. [MEDIUM] Add circuit breaker for flag service
8. [MEDIUM] Create progressive rollout plan
9. [MEDIUM] Add flag change notifications

**Long-term:**
10. [LOW] Set up flag usage analytics
11. [LOW] Implement automated flag cleanup
12. [LOW] Add A/B test statistical analysis

## Usage

```
/feature-flag-review
```

## When to Use

- Before releasing features with feature flags
- When implementing new feature flags
- When modifying flag configurations or targeting rules
- When adding A/B testing or experimentation code
- Before major releases with feature-flagged functionality
- When integrating flag management systems (LaunchDarkly, Unleash, Flagsmith)
- During code reviews for feature flag implementation
- When auditing existing feature flag usage

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For flag usage metrics and monitoring
- `/error-resilience-review` - For circuit breakers and fallbacks
- `/api-readiness-review` - For API versioning with flags
- `/devops-review` - For deployment safety
- `/quality-check` - For code quality validation
- `/review-pr` - For comprehensive PR review
