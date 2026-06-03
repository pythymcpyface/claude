# compliance-review — Implementation Patterns

Reusable code snippets and configuration templates for compliance-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Consent Management (TypeScript)

```typescript
import { v4 as uuidv4 } from 'uuid';

interface ConsentRecord {
  id: string;
  userId: string;
  consentType: 'registration' | 'marketing' | 'analytics' | 'cookies';
  granted: boolean;
  version: string;
  timestamp: Date;
  ipAddress: string;
  userAgent: string;
}

class ConsentManager {
  private consentRepository: ConsentRepository;

  async recordConsent(
    userId: string,
    consentType: ConsentRecord['consentType'],
    granted: boolean,
    req: Request
  ): Promise<ConsentRecord> {
    const record: ConsentRecord = {
      id: uuidv4(),
      userId,
      consentType,
      granted,
      version: await this.getCurrentConsentVersion(consentType),
      timestamp: new Date(),
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'unknown'
    };

    await this.consentRepository.save(record);
    return record;
  }

  async hasValidConsent(userId: string, consentType: string): Promise<boolean> {
    const latestConsent = await this.consentRepository.findLatest(
      userId,
      consentType
    );

    if (!latestConsent || !latestConsent.granted) {
      return false;
    }

    // Check if consent version is current
    const currentVersion = await this.getCurrentConsentVersion(consentType);
    return latestConsent.version === currentVersion;
  }

  async withdrawConsent(
    userId: string,
    consentType: string,
    req: Request
  ): Promise<void> {
    await this.recordConsent(userId, consentType as any, false, req);

    // Take action based on consent type
    switch (consentType) {
      case 'marketing':
        await this.unsubscribeFromMarketing(userId);
        break;
      case 'analytics':
        await this.disableAnalytics(userId);
        break;
    }
  }

  async getConsentHistory(userId: string): Promise<ConsentRecord[]> {
    return this.consentRepository.findByUserId(userId);
  }
}
```

### Data Export (GDPR Portability)

```typescript
import { zip } from 'zip-a-folder';

class DataExporter {
  async exportUserData(userId: string): Promise<string> {
    const exportDir = `/tmp/exports/${userId}`;
    await fs.mkdir(exportDir, { recursive: true });

    // Collect all user data
    const userData = {
      profile: await this.getUserProfile(userId),
      orders: await this.getUserOrders(userId),
      preferences: await this.getUserPreferences(userId),
      consents: await this.getUserConsents(userId),
      sessions: await this.getUserSessions(userId)
    };

    // Write JSON export
    await fs.writeFile(
      `${exportDir}/personal_data.json`,
      JSON.stringify(userData, null, 2)
    );

    // Include related files (documents, images, etc.)
    const documents = await this.getUserDocuments(userId);
    for (const doc of documents) {
      await fs.copyFile(doc.path, `${exportDir}/documents/${doc.name}`);
    }

    // Create ZIP file
    const zipPath = `${exportDir}.zip`;
    await zip(exportDir, zipPath);

    // Cleanup
    await fs.rm(exportDir, { recursive: true });

    return zipPath;
  }
}
```

### Right to Erasure Implementation

```typescript
class DataErasureService {
  async requestErasure(userId: string, req: Request): Promise<ErasureRequest> {
    // Create erasure request
    const request = await this.erasureRequestRepo.create({
      userId,
      status: 'pending',
      requestedAt: new Date(),
      ipAddress: req.ip
    });

    // Verify identity (should be done before)
    // Start erasure process (with delay for cancellation)
    setTimeout(() => this.processErasure(request.id), 24 * 60 * 60 * 1000);

    return request;
  }

  private async processErasure(requestId: string): Promise<void> {
    const request = await this.erasureRequestRepo.findById(requestId);

    if (request.status !== 'pending') {
      return; // Cancelled or already processed
    }

    await this.erasureRequestRepo.update(requestId, { status: 'processing' });

    try {
      // Anonymize references
      await this.anonymizeUserReferences(request.userId);

      // Delete personal data
      await this.deletePersonalData(request.userId);

      // Mark as completed
      await this.erasureRequestRepo.update(requestId, {
        status: 'completed',
        completedAt: new Date()
      });

      // Audit log
      await this.auditLog('data.erasure', { userId: request.userId });
    } catch (error) {
      await this.erasureRequestRepo.update(requestId, {
        status: 'failed',
        error: error.message
      });
    }
  }

  private async anonymizeUserReferences(userId: string): Promise<void> {
    const anonymousId = `anon_${userId.slice(0, 8)}`;

    // Anonymize in orders
    await db.orders.updateMany(
      { userId },
      {
        $set: {
          userId: null,
          anonymousCustomerId: anonymousId,
          customerEmail: this.anonymizeEmail
        }
      }
    );
  }

  private anonymizeEmail(email: string): string {
    const [local, domain] = email.split('@');
    return `${local[0]}***@${domain}`;
  }
}
```

### Retention Policy Enforcement

```typescript
import cron from 'node-cron';

interface RetentionPolicy {
  dataType: string;
  retentionPeriod: number; // days
  action: 'delete' | 'anonymize' | 'archive';
}

const RETENTION_POLICIES: RetentionPolicy[] = [
  { dataType: 'access_logs', retentionPeriod: 90, action: 'delete' },
  { dataType: 'deleted_users', retentionPeriod: 30, action: 'delete' },
  { dataType: 'inactive_sessions', retentionPeriod: 30, action: 'delete' },
  { dataType: 'audit_logs', retentionPeriod: 2555, action: 'archive' }, // 7 years
];

class RetentionManager {
  start() {
    // Run daily at 3 AM
    cron.schedule('0 3 * * *', () => this.runRetentionCleanup());
  }

  private async runRetentionCleanup(): Promise<void> {
    logger.info('Starting retention cleanup');

    for (const policy of RETENTION_POLICIES) {
      try {
        const cutoff = new Date(
          Date.now() - policy.retentionPeriod * 24 * 60 * 60 * 1000
        );

        switch (policy.dataType) {
          case 'access_logs':
            await this.cleanupAccessLogs(cutoff, policy.action);
            break;
          case 'deleted_users':
            await this.cleanupDeletedUsers(cutoff, policy.action);
            break;
          // ... other data types
        }
      } catch (error) {
        logger.error(`Retention cleanup failed for ${policy.dataType}`, error);
      }
    }

    logger.info('Retention cleanup completed');
  }

  private async cleanupAccessLogs(
    cutoff: Date,
    action: string
  ): Promise<void> {
    const result = await db.accessLogs.deleteMany({
      timestamp: { $lt: cutoff }
    });
    logger.info(`Deleted ${result.count} access logs`);
  }

  private async cleanupDeletedUsers(
    cutoff: Date,
    action: string
  ): Promise<void> {
    const result = await db.users.deleteMany({
      deletedAt: { $lt: cutoff }
    });
    logger.info(`Hard deleted ${result.count} users`);
  }
}
```

### Cookie Consent Banner

```typescript
// ConsentBanner.tsx
import { useState, useEffect } from 'react';

interface ConsentPreferences {
  necessary: boolean; // Always true
  analytics: boolean;
  marketing: boolean;
  functional: boolean;
}

export function ConsentBanner() {
  const [showBanner, setShowBanner] = useState(false);
  const [preferences, setPreferences] = useState<ConsentPreferences>({
    necessary: true,
    analytics: false,
    marketing: false,
    functional: false
  });

  useEffect(() => {
    const consent = localStorage.getItem('cookieConsent');
    if (!consent) {
      setShowBanner(true);
    } else {
      const parsed = JSON.parse(consent);
      setPreferences(parsed);
      applyConsent(parsed);
    }
  }, []);

  const handleAcceptAll = () => {
    const allAccepted = {
      necessary: true,
      analytics: true,
      marketing: true,
      functional: true
    };
    saveConsent(allAccepted);
  };

  const handleAcceptSelected = () => {
    saveConsent(preferences);
  };

  const handleRejectAll = () => {
    const onlyNecessary = {
      necessary: true,
      analytics: false,
      marketing: false,
      functional: false
    };
    saveConsent(onlyNecessary);
  };

  const saveConsent = async (prefs: ConsentPreferences) => {
    localStorage.setItem('cookieConsent', JSON.stringify(prefs));
    setShowBanner(false);
    applyConsent(prefs);

    // Record consent on server
    await fetch('/api/consent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: 'cookies',
        preferences: prefs,
        version: '1.0'
      })
    });
  };

  const applyConsent = (prefs: ConsentPreferences) => {
    if (prefs.analytics) {
      initializeAnalytics();
    }
    if (prefs.marketing) {
      initializeMarketingPixels();
    }
  };

  if (!showBanner) return null;

  return (
    <div className="consent-banner" role="dialog" aria-label="Cookie consent">
      <div className="consent-content">
        <h2>We value your privacy</h2>
        <p>
          We use cookies to enhance your experience. Choose which cookies
          you allow us to use.
        </p>

        <div className="consent-options">
          <label>
            <input type="checkbox" checked disabled />
            Necessary (always required)
          </label>
          <label>
            <input
              type="checkbox"
              checked={preferences.analytics}
              onChange={(e) =>
                setPreferences({ ...preferences, analytics: e.target.checked })
              }
            />
            Analytics
          </label>
          <label>
            <input
              type="checkbox"
              checked={preferences.marketing}
              onChange={(e) =>
                setPreferences({ ...preferences, marketing: e.target.checked })
              }
            />
            Marketing
          </label>
        </div>

        <div className="consent-actions">
          <button onClick={handleRejectAll}>Reject All</button>
          <button onClick={handleAcceptSelected}>Accept Selected</button>
          <button onClick={handleAcceptAll}>Accept All</button>
        </div>

        <a href="/privacy">Privacy Policy</a>
      </div>
    </div>
  );
}
```

### API Data Filtering

```typescript
import { pick, omit } from 'lodash';

// Define what fields are exposed at each level
const FIELD_SETS = {
  public: ['id', 'name', 'avatarUrl'],
  profile: ['id', 'name', 'email', 'avatarUrl', 'createdAt', 'preferences'],
  admin: ['id', 'name', 'email', 'avatarUrl', 'role', 'lastLogin', 'createdAt'],
  self: ['id', 'name', 'email', 'avatarUrl', 'phone', 'address', 'preferences',
         'createdAt', 'updatedAt']
};

class UserDataFilter {
  filterForContext(
    user: User,
    context: { viewerId?: string; viewerRole?: string }
  ): Partial<User> {
    // Self access - full data
    if (context.viewerId === user.id) {
      return pick(user, FIELD_SETS.self);
    }

    // Admin access
    if (context.viewerRole === 'admin') {
      return pick(user, FIELD_SETS.admin);
    }

    // Public access
    return pick(user, FIELD_SETS.public);
  }

  filterForAPI(
    data: any,
    sensitivity: 'public' | 'authenticated' | 'internal'
  ): any {
    const sensitiveFields = ['password', 'passwordHash', 'ssn', 'creditCard',
                            'apiKey', 'secret'];

    if (sensitivity === 'public') {
      return omit(data, [...sensitiveFields, 'email', 'phone', 'address']);
    }

    if (sensitivity === 'authenticated') {
      return omit(data, sensitiveFields);
    }

    return data;
  }
}
```

---

