---
description: Production readiness review for documentation. Reviews runbooks, architecture diagrams, on-call guides, API docs, and operational documentation before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Documentation Review Command

Run a comprehensive production readiness review focused on Documentation completeness and quality.

## Purpose

Review documentation before production release to ensure:
- Complete runbooks with incident response procedures
- Accurate architecture diagrams in version control
- Comprehensive on-call guides with escalation paths
- Up-to-date API documentation
- Clear README and setup instructions
- Operational documentation for deployment and maintenance

## Workflow

### 1. Load the Documentation Review Skill

Read the skill definition to get the full review checklist and templates:

```
Read: skills/documentation-review/SKILL.md
```

### 2. Discover Documentation Files

Find all documentation in the project:

```bash
# Find all documentation files
find . -type f \( -name "*.md" -o -name "*.rst" -o -name "*.txt" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -50

# Find architecture diagrams
find . -type f \( -name "*.drawio" -o -name "*.mermaid" -o -name "*.plantuml" \
  -o -name "*architecture*" -o -name "*diagram*" \) 2>/dev/null | head -20

# Find API specs
find . -type f \( -name "openapi*.yaml" -o -name "openapi*.json" \
  -o -name "swagger*.yaml" -o -name "swagger*.json" \) 2>/dev/null
```

### 3. Run Documentation Checks

Execute checks in parallel:

**Runbooks:**
```bash
grep -r "incident\|troubleshoot\|escalation\|on-call\|runbook" \
  --include="*.md" 2>/dev/null | head -30
grep -r "contact\|pagerduty\|ops-genie\|slack.*channel" \
  --include="*.md" 2>/dev/null | head -20
```

**Architecture:**
```bash
find . -type f \( -name "*.drawio" -o -name "*.mermaid" -o -name "*.plantuml" \) \
  -not -path "*/node_modules/*" 2>/dev/null
grep -r "architecture\|diagram\|data.*flow\|sequence" \
  --include="*.md" 2>/dev/null | head -20
```

**On-Call Guides:**
```bash
grep -r "on-call\|oncall\|escalation\|rotation" \
  --include="*.md" 2>/dev/null | head -30
grep -r "SLO\|SLI\|metric\|dashboard" \
  --include="*.md" 2>/dev/null | head -20
```

**API Documentation:**
```bash
find . -name "openapi*" -o -name "swagger*" 2>/dev/null | head -10
grep -r "endpoint\|rate.*limit\|authentication" \
  --include="*.md" 2>/dev/null | head -20
```

**README & Setup:**
```bash
find . -name "README*" -not -path "*/node_modules/*" 2>/dev/null | head -20
grep -r "install\|setup\|getting.*started\|quick.*start" \
  --include="*.md" 2>/dev/null | head -20
```

**Freshness Check:**
```bash
# Find docs older than 90 days
find . -name "*.md" -mtime +90 -not -path "*/node_modules/*" 2>/dev/null | head -20
```

### 4. Analyze and Score

Based on the skill checklist, evaluate each category:
- Runbooks (25% weight)
- Architecture Diagrams (20% weight)
- On-Call Guides (20% weight)
- API Documentation (15% weight)
- README & Setup (10% weight)
- Operational Docs (10% weight)

Calculate overall score and determine status:
- 90-100: PASS - Ready for production
- 70-89: NEEDS WORK - Address gaps before release
- 50-69: AT RISK - Significant documentation debt
- 0-49: BLOCK - Critical documentation missing

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Templates and examples for missing documentation
- Documentation inventory with freshness indicators

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must complete before production
2. **High** - Should complete before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/documentation-review
```

## When to Use

- Before production releases
- After major architectural changes
- When onboarding new team members
- Before go-live milestones
- After incident post-mortems
- During quarterly documentation audits

## Integration with Other Commands

Consider running alongside:
- `/observability-check` - For monitoring readiness
- `/disaster-recovery-review` - For DR procedures
- `/devops-review` - For deployment documentation
- `/api-readiness-review` - For API completeness
