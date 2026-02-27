---
name: disaster-recovery-review
description: Production readiness review for Disaster Recovery & Business Continuity. Reviews backup strategy (3-2-1-1-0 rule), RPO/RTO testing, failover procedures, and DR documentation before production release. Use PROACTIVELY before deployments, when modifying data storage, or setting up new infrastructure.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Disaster Recovery Review Skill

Production readiness code review focused on Disaster Recovery & Business Continuity. Ensures code and infrastructure are ready for production with proper backup strategy, recovery objectives, failover procedures, and documented DR plans.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "backup", "disaster", "recovery", "failover", "database", "migration"
- Database schema changes or new tables added
- New data storage systems introduced (Redis, Elasticsearch, etc.)
- Infrastructure changes affecting data persistence
- Multi-region or HA configuration changes
- Before major version releases
- New production environment setup

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's data infrastructure to apply appropriate checks:

```bash
# Detect databases
grep -r "postgres\|mysql\|mongodb\|redis\|elasticsearch\|dynamodb" --include="*.yml" --include="*.yaml" --include="*.tf" --include="*.json" 2>/dev/null | head -10

# Detect cloud providers
grep -r "aws\|gcp\|azure\|cloudflare" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Detect backup tools
grep -r "pg_dump\|mysqldump\|mongodump\|velero\|borg\|restic\|aws backup\|snapshot" --include="*.sh" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10

# Detect infrastructure as code
find . -name "*.tf" -o -name "*.json" | xargs grep -l "backup\|snapshot\|replication" 2>/dev/null | head -10
```

### Phase 2: Disaster Recovery Checklist

Run all checks and compile results:

#### 1. 3-2-1-1-0 Backup Rule Compliance

The 3-2-1-1-0 rule ensures data resilience:
- **3** copies of data (primary + 2 backups)
- **2** different media types (disk + tape, local + cloud, etc.)
- **1** backup offsite (geographically separated)
- **1** backup offline/air-gapped (immutable, ransomware protection)
- **0** errors (verified backup integrity)

| Check | Pattern | Status |
|-------|---------|--------|
| 3 copies | Primary data + 2 backup copies | Required |
| 2 media types | Different storage mediums (disk/cloud/tape) | Required |
| 1 offsite | Geographic separation from primary | Required |
| 1 offline/air-gapped | Immutable or disconnected backup | Required |
| 0 errors | Backup verification/restore tests | Required |
| Encryption | Backups encrypted at rest and in transit | Required |

**Search Patterns:**
```bash
# Find backup configurations
find . -name "*backup*" -o -name "*snapshot*" -o -name "*dump*" 2>/dev/null | head -20

# Check for cloud backup services
grep -r "aws backup\|azure backup\|gcp snapshot\|cross-region\|replication" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for backup scripts
find . -name "backup*.sh" -o -name "*backup*.py" 2>/dev/null | head -10

# Check for immutable storage
grep -r "immutable\|object-lock\|retention\|vault\|air.*gap" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

#### 2. RPO/RTO Testing Review

| Check | Pattern | Status |
|-------|---------|--------|
| RPO defined | Recovery Point Objective documented | Required |
| RTO defined | Recovery Time Objective documented | Required |
| RPO achievable | Backup frequency <= RPO | Required |
| RTO tested | Recovery drill performed within RTO | Required |
| Data loss calculation | Max data loss understood and acceptable | Required |
| Recovery automation | Automated or semi-automated recovery | Recommended |

**Search Patterns:**
```bash
# Find RPO/RTO documentation
grep -ri "rpo\|rto\|recovery.*point\|recovery.*time\|mttr\|mtbf" --include="*.md" --include="*.txt" --include="*.yml" 2>/dev/null | head -10

# Check backup schedules
grep -r "schedule\|cron\|frequency\|daily\|hourly" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for recovery procedures
find . -name "*recovery*" -o -name "*restore*" -o -name "*drill*" 2>/dev/null | head -10
```

#### 3. Failover Procedures Review

| Check | Pattern | Status |
|-------|---------|--------|
| Manual failover doc | Step-by-step failover procedure | Required |
| Automated failover | Health-triggered automatic failover | Recommended |
| Failover testing | Failover tested in staging/DR env | Required |
| DNS switching | Procedure for DNS cutover | Required |
| Data sync verification | Replica lag monitoring before failover | Required |
| Fallback procedure | Plan to return to primary after failover | Required |

**Search Patterns:**
```bash
# Check for HA configurations
grep -r "failover\|high.*availability\|ha\|redundancy\|replica" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for load balancer configs
grep -r "loadbalancer\|load.*balancer\|alb\|nlb\|haproxy\|nginx" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10

# Check for database replication
grep -r "replication\|read.*replica\|streaming.*rep\|logical.*rep" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

#### 4. DR Runbooks & Documentation

| Check | Pattern | Status |
|-------|---------|--------|
| DR runbook | Comprehensive disaster recovery guide | Required |
| Contact list | Escalation contacts and on-call info | Required |
| System inventory | All systems and dependencies documented | Required |
| Recovery procedures | Step-by-step recovery for each system | Required |
| Dependencies map | Service dependencies understood | Required |
| Version control | DR docs in git, reviewed regularly | Required |

**Search Patterns:**
```bash
# Find DR documentation
find . -name "*runbook*" -o -name "*dr-*" -o -name "*disaster*" 2>/dev/null | head -10

# Check for documentation
grep -ri "runbook\|disaster\|recovery\|incident\|playbook" --include="*.md" 2>/dev/null | head -10

# Check for contact/escalation info
grep -ri "on-call\|pagerduty\|escalation\|contact" --include="*.md" --include="*.yml" 2>/dev/null | head -10
```

#### 5. Communication Plans

| Check | Pattern | Status |
|-------|---------|--------|
| Stakeholder notification | Template for outage communication | Required |
| Customer communication | Template for status page updates | Required |
| Internal escalation | Clear escalation path and thresholds | Required |
| Status page integration | Automated or manual status page updates | Recommended |
| Post-incident review | Blameless postmortem process | Required |

**Search Patterns:**
```bash
# Check for communication templates
find . -name "*template*" -o -name "*communication*" 2>/dev/null | head -10

# Check for status page integration
grep -r "statuspage\|status.*page\|incident.*io\|pagerduty" --include="*.yml" --include="*.yaml" --include="*.tf" 2>/dev/null | head -10
```

#### 6. DR Drills & Testing

| Check | Pattern | Status |
|-------|---------|--------|
| Regular DR drills | Scheduled disaster recovery exercises | Required |
| Drill frequency | At least annual, quarterly recommended | Required |
| Drill documentation | Results and lessons learned recorded | Required |
| Tabletop exercises | Simulated disaster scenarios discussed | Recommended |
| Chaos engineering | Failure injection testing (optional) | Recommended |

**Search Patterns:**
```bash
# Check for DR drill records
find . -name "*drill*" -o -name "*exercise*" -o -name "*game*day*" 2>/dev/null | head -10

# Check for chaos engineering
grep -r "chaos\|gremlin\|chaos.*monkey\|failure.*injection" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific DR gap
2. **Why it matters**: Impact on business continuity
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      DISASTER RECOVERY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Database: [detected databases]
Cloud: [detected providers]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

3-2-1-1-0 BACKUP RULE
  [PASS] 3 copies of data maintained
  [PASS] 2 media types (EBS + S3)
  [PASS] 1 offsite backup (cross-region replication)
  [FAIL] No offline/air-gapped backup
  [FAIL] Backup verification not automated
  [PASS] Backups encrypted at rest

RPO/RTO TESTING
  [PASS] RPO defined (1 hour)
  [PASS] RTO defined (4 hours)
  [PASS] Backup frequency matches RPO
  [FAIL] Recovery drill not performed
  [WARN] Recovery automation partial

FAILOVER PROCEDURES
  [PASS] Manual failover documented
  [PASS] Automated failover configured
  [FAIL] Failover not tested in 6 months
  [PASS] DNS switching procedure exists
  [WARN] Fallback procedure incomplete

DR RUNBOOKS
  [FAIL] No comprehensive DR runbook
  [PASS] Contact list maintained
  [WARN] System inventory outdated
  [FAIL] Recovery procedures missing for Redis

COMMUNICATION PLANS
  [PASS] Stakeholder notification template
  [PASS] Status page integration
  [FAIL] No post-incident review process

DR DRILLS
  [FAIL] No scheduled DR drills
  [N/A]  No tabletop exercises documented
  [N/A]  No chaos engineering

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No Air-Gapped Backup
  Impact: Vulnerable to ransomware, cannot recover from total cloud outage
  Fix: Implement immutable backups or air-gapped copy
  File: infrastructure/backup.tf

  resource "aws_s3_bucket" "backup_airgap" {
    bucket = "app-backups-airgap"

    versioning {
      enabled = true
    }

    object_lock_configuration {
      object_lock_enabled = "Enabled"
    }
  }

  resource "aws_s3_bucket_object_lock_configuration" "backup" {
    bucket = aws_s3_bucket.backup_airgap.id

    rule {
      default_retention {
        mode  = "COMPLIANCE"
        days  = 30
      }
    }
  }

[CRITICAL] Recovery Drill Not Performed
  Impact: Cannot verify RTO is achievable, unknown recovery gaps
  Fix: Schedule and execute quarterly DR drills
  File: docs/dr-drill-checklist.md

  ## DR Drill Checklist
  - [ ] Notify stakeholders of drill
  - [ ] Failover to DR region
  - [ ] Verify data integrity (compare record counts)
  - [ ] Run smoke tests on all services
  - [ ] Measure actual RTO
  - [ ] Document issues encountered
  - [ ] Failback to primary
  - [ ] Post-drill review meeting

[HIGH] No Comprehensive DR Runbook
  Impact: Extended downtime during incident due to confusion
  Fix: Create detailed DR runbook with step-by-step procedures
  File: docs/disaster-recovery-runbook.md

  # Disaster Recovery Runbook

  ## Severity Classification
  - P0: Complete production outage
  - P1: Critical service degradation
  - P2: Single component failure

  ## Immediate Actions (0-15 min)
  1. Assess scope of disaster
  2. Notify incident commander
  3. Begin stakeholder communication
  4. Start incident log

  ## Recovery Actions (15-60 min)
  1. Activate DR environment
  2. Restore latest backup to DR
  3. Verify data integrity
  4. Update DNS to DR endpoints
  5. Run smoke tests

  ## Validation (60-120 min)
  1. Verify all services operational
  2. Check data consistency
  3. Monitor for cascading failures
  4. Customer communication update

[HIGH] Failover Not Tested Recently
  Impact: Failover may not work when needed
  Fix: Schedule quarterly failover tests
  Recommendation: Use Chaos Engineering tools for automated testing

[MEDIUM] No Post-Incident Review Process
  Impact: Repeated incidents, no learning from failures
  Fix: Implement blameless postmortem process
  File: docs/postmortem-template.md

  ## Postmortem Template
  - Incident summary
  - Timeline of events
  - Root cause analysis
  - Impact assessment
  - Action items with owners
  - Lessons learned

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement air-gapped/immutable backup
2. [CRITICAL] Perform initial recovery drill to validate RTO
3. [HIGH] Create comprehensive DR runbook
4. [HIGH] Test failover in staging environment
5. [MEDIUM] Establish post-incident review process

After Production:
1. Schedule quarterly DR drills
2. Implement chaos engineering for automated failure testing
3. Create tabletop exercise scenarios
4. Add automated backup verification
5. Document all system dependencies

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
| 3-2-1-1-0 Backup Rule | 30% |
| RPO/RTO Testing | 25% |
| Failover Procedures | 20% |
| DR Runbooks | 15% |
| Communication Plans | 5% |
| DR Drills | 5% |

---

## Quick Reference: Implementation Patterns

### 3-2-1-1-0 Backup Strategy (AWS)

```hcl
# infrastructure/backup.tf

# Primary backup (copy 2) - Same region, different storage
resource "aws_db_snapshot" "daily" {
  db_instance_identifier = aws_db_instance.main.id
  lifecycle {
    create_before_destroy = true
  }
}

# Cross-region backup (copy 3, offsite)
resource "aws_db_snapshot_copy" "cross_region" {
  source_snapshot_id = aws_db_snapshot.daily.id
  destination_region = "us-west-2"

  tags = {
    BackupType = "offsite"
  }
}

# Air-gapped backup (offline/immutable)
resource "aws_s3_bucket" "immutable_backups" {
  bucket = "app-immutable-backups"

  object_lock_configuration {
    object_lock_enabled = "Enabled"
  }
}

resource "aws_backup_plan" "daily" {
  name = "daily-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)"  # Daily at 5 AM UTC

    copy_action {
      destination_vault_arn = aws_backup_vault.dr.arn
    }
  }
}
```

### Backup Verification Script

```bash
#!/bin/bash
# scripts/verify-backup.sh

set -e

echo "Starting backup verification..."

# 1. Restore backup to temporary instance
TEMP_INSTANCE="verify-$(date +%s)"
pg_restore --create --dbname=postgres --host=$TEMP_HOST ./latest_backup.dump

# 2. Verify data integrity
RECORD_COUNT=$(psql -h $TEMP_HOST -c "SELECT COUNT(*) FROM users" -t)

if [ "$RECORD_COUNT" -lt 100 ]; then
  echo "ERROR: Record count too low: $RECORD_COUNT"
  exit 1
fi

# 3. Run data integrity checks
psql -h $TEMP_HOST -c "SELECT verify_data_integrity()"

# 4. Cleanup
dropdb -h $TEMP_HOST $TEMP_INSTANCE

echo "Backup verification complete. Status: OK"
```

### Failover Procedure (Kubernetes)

```yaml
# k8s/failover.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: failover-procedure
data:
  procedure.md: |
    # Manual Failover Procedure

    ## Pre-Failover Checks
    1. Verify replica lag < 1 second
    2. Check DR region health
    3. Notify stakeholders

    ## Execute Failover
    1. `kubectl config use-context dr-cluster`
    2. `kubectl scale deployment app --replicas=3`
    3. `kubectl apply -f k8s/dr/`
    4. Update DNS: `./scripts/dns-failover.sh`

    ## Post-Failover
    1. Run smoke tests
    2. Monitor error rates
    3. Update status page
```

### RPO/RTO Monitoring

```yaml
# prometheus/alerts.yml
groups:
  - name: dr-alerts
    rules:
      - alert: BackupTooOld
        expr: time() - backup_last_success_timestamp > 86400
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Backup is older than 24 hours"
          description: "RPO may be violated"

      - alert: ReplicaLagHigh
        expr: pg_replication_lag_seconds > 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Database replica lag exceeds 30 seconds"
          description: "Failover may result in data loss"
```

### DR Runbook Template

```markdown
# Disaster Recovery Runbook

## Quick Reference
- **RPO**: 1 hour (max data loss)
- **RTO**: 4 hours (max downtime)
- **DR Region**: us-west-2
- **On-Call**: PagerDuty - #platform-oncall

## Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| P0 | Complete outage | Immediate |
| P1 | Critical degradation | 15 min |
| P2 | Single component failure | 1 hour |

## Recovery Procedures

### Database Recovery
1. Identify latest valid backup
2. Restore to DR instance
3. Verify data integrity
4. Update application config

### Application Recovery
1. Scale DR deployment
2. Update DNS to DR endpoints
3. Run smoke tests
4. Enable maintenance mode on primary

### Communication Template
Subject: [P0] Production Outage - [Service Name]

Current Status: Investigating
Impact: [Describe user impact]
Next Update: [15/30 minutes]

## Contacts
- Incident Commander: @ic-role
- Platform: #incident-response
- Executives: @exec-notification
```

### DR Drill Checklist

```markdown
# DR Drill Checklist

## Pre-Drill (T-1 week)
- [ ] Schedule drill with team
- [ ] Prepare drill scenario
- [ ] Notify stakeholders
- [ ] Verify DR environment ready

## During Drill
- [ ] Start timer (RTO measurement)
- [ ] Execute failover procedure
- [ ] Verify all services operational
- [ ] Run full test suite
- [ ] Measure actual recovery time
- [ ] Document any issues

## Post-Drill
- [ ] Failback to primary
- [ ] Team debrief
- [ ] Document lessons learned
- [ ] Create improvement tickets
- [ ] Update runbooks based on findings
```

---

## Integration with Other Reviews

This skill complements:
- `/devops-review` - For CI/CD and deployment safety
- `/observability-check` - For monitoring and alerting
- `/security-review` - For security vulnerabilities
- `/quality-check` - For code quality
