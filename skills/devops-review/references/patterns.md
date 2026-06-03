# devops-review — Implementation Patterns

Reusable code snippets and configuration templates for devops-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Automated Rollback (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Kubernetes
        run: kubectl apply -f k8s/

      - name: Wait for Rollout
        id: rollout
        run: |
          kubectl rollout status deployment/app --timeout=300s

      - name: Rollback on Failure
        if: failure() && steps.rollout.outcome == 'failure'
        run: |
          kubectl rollout undo deployment/app
          echo "::error::Deployment failed, rolled back automatically"
```

### Blue-Green Deployment

```yaml
# k8s/deployment.yml with blue-green strategy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
---
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  selector:
    app: myapp
    version: blue  # Switch to 'green' after successful deployment
```

### GitHub Actions with Security Scanning

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'

      - name: Run CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: javascript
      - uses: github/codeql-action/analyze@v3

  build:
    needs: security
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run build
      - run: npm test
```

### Kubernetes Health Checks

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
        - name: app
          image: myapp:latest
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

### Deployment Notifications

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    steps:
      - name: Notify Slack on Success
        if: success()
        uses: 8398a7/action-slack@v3
        with:
          status: success
          fields: repo,message,commit,author
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

      - name: Notify Slack on Failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          fields: repo,message,commit,author
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Feature Flags

```typescript
// Using LaunchDarkly or similar
import { LDClient } from 'launchdarkly-node-server-sdk';

const client = await LDClient.init(process.env.LAUNCHDARKLY_SDK_KEY);

async function handleRequest(req, res) {
  const showNewFeature = await client.variation(
    'new-feature-flag',
    { key: req.user.id },
    false
  );

  if (showNewFeature) {
    return res.json({ feature: 'new' });
  }
  return res.json({ feature: 'old' });
}
```

---

