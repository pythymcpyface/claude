---
description: Production readiness review for Disaster Recovery & Business Continuity. Reviews backup strategy (3-2-1-1-0 rule), RPO/RTO testing, failover procedures, and DR documentation before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Disaster Recovery Review Command

Run a comprehensive production readiness review focused on Disaster Recovery & Business Continuity.

## Purpose

Review code and infrastructure before production release to ensure:
- 3-2-1-1-0 backup rule compliance (3 copies, 2 media types, 1 offsite, 1 offline, 0 errors)
- RPO/RTO defined and tested (Recovery Point/Time Objectives)
- Failover procedures documented and tested
- DR runbooks and communication plans in place
- Regular DR drills scheduled

## Workflow

### 1. Load the Disaster Recovery Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/disaster-recovery-review/SKILL.md
```

### 2. Detect Project Stack

Identify the data infrastructure and cloud provider:
```bash
# Database detection
grep -r "postgres\|mysql\|mongodb\|redis\|elasticsearch\|dynamodb" --include="*.yml" --include="*.yaml" --include="*.tf" --include="*.json" 2>/dev/null | head -10

# Cloud provider detection
grep -r "aws\|gcp\|azure" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Backup tool detection
grep -r "pg_dump\|mysqldump\|velero\|restic\|backup\|snapshot" --include="*.sh" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

### 3. Run Disaster Recovery Checks

Execute all checks in parallel:

**3-2-1-1-0 Backup Rule:**
```bash
# Find backup configurations
find . -name "*backup*" -o -name "*snapshot*" 2>/dev/null | head -20

# Check for cloud backup/replication
grep -r "cross-region\|replication\|aws backup\|snapshot\|immutable\|object-lock" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -20

# Check for backup verification
grep -r "verify\|restore\|integrity.*check" --include="*.sh" --include="*.yml" 2>/dev/null | head -10
```

**RPO/RTO Testing:**
```bash
# Find RPO/RTO documentation
grep -ri "rpo\|rto\|recovery.*point\|recovery.*time" --include="*.md" --include="*.yml" 2>/dev/null | head -10

# Check backup schedules
grep -r "schedule\|cron\|frequency\|daily\|hourly" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for recovery procedures
find . -name "*recovery*" -o -name "*restore*" -o -name "*drill*" 2>/dev/null | head -10
```

**Failover Procedures:**
```bash
# Check for HA/failover configs
grep -r "failover\|high.*availability\|replica\|read.*replica" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for load balancer configs
grep -r "loadbalancer\|alb\|nlb\|haproxy" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

**DR Runbooks:**
```bash
# Find DR documentation
find . -name "*runbook*" -o -name "*dr-*" -o -name "*disaster*" 2>/dev/null | head -10

# Check for documentation
grep -ri "runbook\|disaster\|recovery\|playbook" --include="*.md" 2>/dev/null | head -10

# Check for contact/escalation info
grep -ri "on-call\|pagerduty\|escalation\|contact" --include="*.md" --include="*.yml" 2>/dev/null | head -10
```

**Communication Plans:**
```bash
# Check for status page integration
grep -r "statuspage\|status.*page\|incident" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Check for postmortem process
grep -ri "postmortem\|post.*incident\|blameless" --include="*.md" 2>/dev/null | head -10
```

**DR Drills:**
```bash
# Check for DR drill records
find . -name "*drill*" -o -name "*exercise*" -o -name "*game*day*" 2>/dev/null | head -10

# Check for chaos engineering
grep -r "chaos\|gremlin\|failure.*injection" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Backup Rule, RPO/RTO, Failover, Runbooks, Communication, Drills)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code/infrastructure examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must fix before production (no air-gapped backup, no RTO testing)
2. **High** - Should fix before or immediately after release (missing runbooks, untested failover)
3. **Medium** - Should add within first week (communication templates, drill schedule)
4. **Low** - Nice to have (chaos engineering, advanced monitoring)

## Usage

```
/disaster-recovery-review
```

## When to Use

- Before production deployments
- When adding new data stores (databases, caches, queues)
- When modifying backup or replication configurations
- After infrastructure changes affecting data persistence
- During DR planning and compliance audits
- Before major version releases
- When setting up new production environments

## Integration with Other Commands

Consider running alongside:
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For logging, metrics, alerting
- `/quality-check` - For lint, types, tests
- `/security-review` - For security vulnerabilities
- `/review-pr` - For comprehensive PR review
