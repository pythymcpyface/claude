# Workflow Templates

Pre-configured workflow templates for common development scenarios. Templates optimize the development process by skipping unnecessary phases and focusing on what matters for each type of feature.

## Available Templates

### 1. CRUD Operations (`crud`)
**Use for**: Standard create/read/update/delete features
**Complexity**: Low
**Time**: 1-2 hours
**Best for**: Blog posts, user profiles, product listings, etc.

**Optimizations**:
- Skips codebase exploration (reuses existing patterns)
- Lightweight architecture phase (copies similar features)
- Template-based specs
- Focus on rapid implementation

**Usage**:
```bash
/feature-dev --template=crud "Add blog posts management"
```

---

### 2. API Integration (`api-integration`)
**Use for**: Connecting to external services
**Complexity**: Medium
**Time**: 3-4 hours
**Best for**: Payment APIs, email services, third-party integrations

**Includes**:
- API documentation review
- Error handling and retry logic
- Circuit breaker implementation
- Caching strategy
- Comprehensive resilience testing

**Usage**:
```bash
/feature-dev --template=api-integration "Connect to Stripe payment API"
```

---

### 3. Security-Critical (`security-critical`)
**Use for**: Authentication, authorization, sensitive data handling
**Complexity**: High
**Time**: 6-8 hours
**Best for**: 2FA, OAuth, payment processing, PII handling

**Includes**:
- Threat modeling (STRIDE analysis)
- Comprehensive security review
- Compliance checks (GDPR, PCI-DSS, HIPAA)
- Audit logging
- Incident response planning
- Security validation phase

**Usage**:
```bash
/feature-dev --template=security-critical "Add two-factor authentication"
```

---

### 4. Data Migration (`data-migration`)
**Use for**: Schema changes, database migrations, data transformations
**Complexity**: High
**Time**: 8-12 hours
**Risk**: Critical
**Best for**: Database migrations, schema refactoring, data consolidation

**Includes**:
- Zero-downtime strategy (dual-write)
- Rollback plan with automated triggers
- Data validation and reconciliation
- Gradual cutover (10% → 25% → 50% → 100%)
- Performance testing
- Comprehensive monitoring

**Usage**:
```bash
/feature-dev --template=data-migration "Migrate from MySQL to PostgreSQL"
```

---

## How Templates Work

### Template Structure

Each template is a JSON file that configures:

1. **Phase Configuration**: Which phases to run, skip, or optimize
2. **Duration Estimates**: Expected time for each phase
3. **Focus Areas**: What to prioritize in each phase
4. **Quality Gates**: Test coverage, security checks, compliance
5. **Documentation**: Required documentation artifacts
6. **Monitoring**: Metrics and alerts to set up

### Using Templates

#### Basic Usage
```bash
/feature-dev --template=<template-name> "<feature description>"
```

#### Without Template (Standard Workflow)
```bash
/feature-dev "<feature description>"
# Runs all phases with full exploration
```

#### Template Override
```bash
/feature-dev --template=crud --skip-phase=4 "Add comments"
# Uses CRUD template but skips Phase 4 (specs)
```

---

## Template Selection Guide

### Decision Tree

```
Is it a CRUD operation?
├─ Yes → Use `crud` template
└─ No
   └─ Does it integrate with external API?
      ├─ Yes → Use `api-integration` template
      └─ No
         └─ Is it security-critical?
            ├─ Yes → Use `security-critical` template
            └─ No
               └─ Is it a data migration?
                  ├─ Yes → Use `data-migration` template
                  └─ No → Use standard workflow (no template)
```

### By Complexity

| Complexity | Templates | Time Savings |
|------------|-----------|--------------|
| Low | `crud` | 40% faster |
| Medium | `api-integration` | 25% faster |
| High | `security-critical`, `data-migration` | 15% faster (but prevents disasters) |

### By Risk

| Risk | Templates | Focus |
|------|-----------|-------|
| Low | `crud` | Speed |
| Medium | `api-integration` | Resilience |
| High | `security-critical` | Security |
| Critical | `data-migration` | Data integrity |

---

## Creating Custom Templates

### 1. Copy Existing Template
```bash
cp templates/workflows/crud.json templates/workflows/my-custom.json
```

### 2. Modify Configuration
Edit the JSON file to adjust:
- Phase enablement
- Duration estimates
- Focus areas
- Quality gates
- Documentation requirements

### 3. Test Template
```bash
/feature-dev --template=my-custom "Test feature"
```

### 4. Share with Team
Commit the template to version control:
```bash
git add templates/workflows/my-custom.json
git commit -m "feat: add custom workflow template"
```

---

## Template Configuration Reference

### Phase Configuration

```json
{
  "phase_X_name": {
    "enabled": true,           // Run this phase?
    "lightweight": true,       // Use lightweight version?
    "duration": "10min",       // Expected duration
    "skip_reason": "...",      // Why skipping (if enabled=false)
    "focus": ["..."],          // What to focus on
    "checklist": ["..."]       // Required tasks
  }
}
```

### Quality Gates

```json
{
  "quality_gates": {
    "test_coverage": "85%",
    "required_tests": ["..."],
    "security_checks": ["..."],
    "compliance_checks": ["..."]
  }
}
```

### Documentation

```json
{
  "documentation": {
    "required": [
      "API documentation",
      "Architecture diagram",
      "Runbook"
    ]
  }
}
```

---

## Best Practices

### 1. Choose the Right Template
- Don't force-fit a template if it doesn't match
- Standard workflow is fine for unique features
- Templates are optimizations, not requirements

### 2. Customize as Needed
- Use `--skip-phase` to skip unnecessary phases
- Use `--extend-phase` to add extra validation
- Templates are starting points, not rigid rules

### 3. Update Templates
- Learn from experience
- Update duration estimates
- Add new quality gates
- Share improvements with team

### 4. Create Project-Specific Templates
- E-commerce: `checkout-flow`, `product-catalog`
- SaaS: `tenant-isolation`, `billing-integration`
- Mobile: `offline-sync`, `push-notifications`

---

## Metrics & Improvement

### Track Template Effectiveness

After using a template, record:
- Actual time vs estimated time
- Quality gate pass rate
- Issues found in production
- Developer satisfaction

### Continuous Improvement

Review templates quarterly:
- Update duration estimates
- Add new quality gates
- Remove unnecessary steps
- Create new templates for common patterns

---

## Examples

### Example 1: Simple CRUD
```bash
/feature-dev --template=crud "Add product reviews"

# Workflow:
# Phase 0: Spec workflow (lightweight) - 15 min
# Phase 1: Discovery - 5 min
# Phase 2: Exploration - SKIPPED (reuse patterns)
# Phase 3: Architecture (lightweight) - 10 min
# Phase 4: Specs (template-based) - 10 min
# Phase 5: Implementation - 45 min
# Total: ~1.5 hours (vs 3 hours standard)
```

### Example 2: API Integration
```bash
/feature-dev --template=api-integration "Connect to SendGrid email API"

# Workflow:
# Phase 0: Spec workflow - 20 min
# Phase 1: Discovery - 10 min
# Phase 2: Exploration (API docs) - 15 min
# Phase 3: Architecture (resilience) - 20 min
# Phase 4: Specs (comprehensive) - 20 min
# Phase 5: Implementation - 2 hours
# Total: ~3.5 hours (vs 5 hours standard)
```

### Example 3: Security-Critical
```bash
/feature-dev --template=security-critical "Add OAuth 2.0 authentication"

# Workflow:
# Phase 0: Spec workflow (comprehensive) - 30 min
# Phase 1: Discovery - 15 min
# Phase 2: Exploration (security review) - 30 min
# Phase 3: Architecture (threat modeling) - 45 min
# Phase 4: Specs (comprehensive) - 45 min
# Phase 5: Implementation - 3.5 hours
# Phase 6: Security validation - 1 hour
# Total: ~7 hours (vs 10+ hours with issues)
```

---

## Troubleshooting

### Template Not Found
```bash
Error: Template 'xyz' not found

Solution: Check available templates:
ls -la .claude/templates/workflows/
```

### Template Validation Failed
```bash
Error: Template 'crud' validation failed: missing required field 'phases'

Solution: Validate JSON syntax:
cat .claude/templates/workflows/crud.json | jq .
```

### Phase Skipped Unexpectedly
```bash
Warning: Phase 2 skipped due to template configuration

Solution: Check template configuration:
cat .claude/templates/workflows/crud.json | jq '.phases.phase_2_exploration'
```

---

## See Also

- [Feature Development Command](../../commands/feature-dev.md)
- [Spec Workflow Skill](../../skills/spec-workflow/skill.md)
- [Quality Gates](../../scripts/quality-gate.sh)
- [Wildcard Ideas](../../WILDCARD-IDEAS.md)
