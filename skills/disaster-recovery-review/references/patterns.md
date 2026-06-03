# disaster-recovery-review — Implementation Patterns

Reusable code snippets and configuration templates for disaster-recovery-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

