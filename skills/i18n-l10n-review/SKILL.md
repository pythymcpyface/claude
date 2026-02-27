---
name: i18n-l10n-review
description: Production readiness review for Internationalization (i18n) and Localization (l10n). Reviews RTL support, locale formatting, UTF-8 handling, translation completeness, and cultural adaptation. Use PROACTIVELY before production releases, when expanding to international markets, or implementing multi-language features.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# i18n/l10n Review Skill

Production readiness code review focused on Internationalization & Localization. Ensures code is ready for production with proper RTL (Right-to-Left) support, locale-aware formatting, UTF-8 encoding throughout, translation completeness, and cultural adaptation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "i18n", "l10n", "localization", "internationalization", "translation", "RTL", "locale", "language", "multi-language"
- New language/locale support added
- Currency or date formatting changes
- User-facing text modifications
- Expanding to new geographic markets
- Before major releases with international users
- Content management or CMS features

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's technology stack and i18n/l10n patterns:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null || echo "Unknown stack"

# Detect i18n libraries (JavaScript/TypeScript)
grep -r "i18next\|react-i18next\|next-i18next\|vue-i18n\|angular.*i18n\|formatjs\|react-intl" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --include="package.json" 2>/dev/null | head -15

# Detect i18n libraries (Python)
grep -r "babel\|gettext\|flask-babel\|django.*i18n" --include="*.py" --include="requirements.txt" 2>/dev/null | head -10

# Detect i18n libraries (Go)
grep -r "go-i18n\|gotext\|golang.org/x/text" --include="*.go" --include="go.mod" 2>/dev/null | head -10

# Detect locale files
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" -o -name "*.po" -o -name "*.mo" -o -name "*.xlf" 2>/dev/null | grep -v node_modules | head -20

# Detect RTL CSS frameworks
grep -r "rtl\|dir.*rtl\|logical.*properties\|start\|end" --include="*.css" --include="*.scss" --include="*.less" 2>/dev/null | head -15
```

### Phase 2: i18n/l10n Checklist

Run all checks and compile results:

#### 1. UTF-8 Encoding Throughout

Proper character encoding is foundational for international text support.

| Check | Pattern | Status |
|-------|---------|--------|
| Source files UTF-8 | All source files saved as UTF-8 | Required |
| Database UTF-8 | Database charset/collation UTF-8 | Required |
| HTTP headers UTF-8 | Content-Type includes charset=UTF-8 | Required |
| HTML meta charset | `<meta charset="UTF-8">` present | Required |
| File I/O UTF-8 | File read/write operations specify encoding | Required |
| API responses UTF-8 | API responses include UTF-8 charset | Required |
| Email UTF-8 | Email headers specify UTF-8 | Required |
| Log files UTF-8 | Logging configured for UTF-8 | Required |

**Search Patterns:**
```bash
# Find HTML charset declarations
grep -r "charset\|encoding" --include="*.html" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find database charset configuration
grep -r "charset\|collation\|encoding.*utf" --include="*.sql" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -15

# Find Content-Type headers
grep -r "Content-Type.*charset\|charset.*utf" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find file I/O encoding
grep -r "fs\.readFile\|fs\.writeFile\|open.*encoding\|utf-8\|utf8" --include="*.ts" --include="*.js" --include="*.py" 2/dev/null | head -15

# Find hardcoded non-ASCII characters (potential issues)
grep -rP "[^\x00-\x7F]" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -20
```

#### 2. Right-to-Left (RTL) Support

RTL languages (Arabic, Hebrew, Farsi, Urdu) require special handling.

| Check | Pattern | Status |
|-------|---------|--------|
| dir attribute support | HTML `dir` attribute dynamically set | Required |
| RTL stylesheet | Separate RTL styles or logical properties | Required |
| CSS logical properties | Uses `start`/`end` instead of `left`/`right` | Recommended |
| Mirrored icons | Directional icons flipped for RTL | Required |
| Text alignment | Text alignment adapts to direction | Required |
| Form layout | Form fields adapt to RTL flow | Required |
| Table direction | Tables support RTL direction | Required |
| Bidirectional text | Bidi isolation for mixed direction text | Recommended |

**Search Patterns:**
```bash
# Find dir attribute usage
grep -r "dir.*=.*rtl\|dir.*=.*ltr\|direction.*rtl\|documentDirection" --include="*.html" --include="*.tsx" --include="*.jsx" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find RTL-specific CSS
grep -r "\[dir.*rtl\]\.rtl\|:dir(rtl)\|dir.*rtl" --include="*.css" --include="*.scss" --include="*.less" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find logical CSS properties
grep -r "margin-inline\|padding-inline\|border-inline\|inset-inline\|text-align.*start\|text-align.*end" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -15

# Find physical direction properties (anti-pattern for RTL)
grep -r "margin-left\|margin-right\|padding-left\|padding-right\|left:\|right:" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find icon flipping
grep -r "transform.*scaleX\|flip.*rtl\|rotate.*rtl" --include="*.css" --include="*.scss" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Find text alignment
grep -r "text-align.*left\|text-align.*right" --include="*.css" --include="*.scss" 2>/dev/null | head -10
```

#### 3. Locale-Aware Formatting

Numbers, dates, currencies, and units must adapt to user locale.

| Check | Pattern | Status |
|-------|---------|--------|
| Date formatting | Uses Intl.DateTimeFormat or equivalent | Required |
| Number formatting | Uses Intl.NumberFormat or equivalent | Required |
| Currency formatting | Locale-aware currency display | Required |
| Time zone handling | Proper timezone conversion/display | Required |
| Unit formatting | Locale-aware unit display (km vs mi) | Recommended |
| List formatting | Locale-aware list separators | Recommended |
| Relative time | "2 hours ago" localized | Recommended |
| Plural rules | Correct plural forms per locale | Required |

**Search Patterns:**
```bash
# Find date formatting
grep -r "Intl\.DateTimeFormat\|toLocaleDateString\|toLocaleTimeString\|moment\|date-fns\|dayjs\|luxon" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -20

# Find number formatting
grep -r "Intl\.NumberFormat\|toLocaleString\|numeral\|numbro" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -15

# Find currency formatting
grep -r "currency\|Currency\|formatCurrency\|style.*currency" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -15

# Find timezone handling
grep -r "timezone\|TimeZone\|Intl\.DateTimeFormat.*timeZone\|moment-timezone\|luxon" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find plural handling
grep -r "plural\|Plural\|_plural\|one\|other\|few\|many" --include="*.json" --include="*.ts" --include="*.js" 2>/dev/null | head -20

# Find hardcoded date formats (anti-pattern)
grep -r "DD/MM/YYYY\|MM/DD/YYYY\|YYYY-MM-DD\|dd/mm/yyyy" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -10
```

#### 4. String Externalization

All user-facing text must be externalized for translation.

| Check | Pattern | Status |
|-------|---------|--------|
| No hardcoded strings | User-facing text in translation files | Required |
| Translation function | Uses t(), $t(), or equivalent | Required |
| Translation keys | Descriptive, namespaced keys | Required |
| Interpolation | Dynamic values properly interpolated | Required |
| Missing translations | No empty or missing translation keys | Required |
| Fallback handling | Graceful fallback for missing translations | Required |
| Translation context | Context provided for ambiguous strings | Recommended |
| String concatenation | No concatenated sentences | Required |

**Search Patterns:**
```bash
# Find translation function usage
grep -r "t(\|i18n\.t\|useTranslation\|\$t(\|_\(\|gettext" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find hardcoded user-facing strings (potential issues)
grep -rP ">[A-Z][a-z]+.*<" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find string concatenation (anti-pattern)
grep -r "'.*'.*\+.*'.*'\|\".*\".*\+.*\".*\"\|f\".*\{.*\}.*\"" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -15

# Find translation files
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" -o -name "translations*.json" -o -name "messages*.json" 2>/dev/null | grep -v node_modules | head -20

# Find translation key definitions
grep -r "\"[a-zA-Z0-9_\.]+\":" --include="*.json" -path "*locale*" --include="*.json" -path "*lang*" 2>/dev/null | head -30
```

#### 5. Translation Completeness

All supported locales must have complete translations.

| Check | Pattern | Status |
|-------|---------|--------|
| Locale coverage | All declared locales have translation files | Required |
| Key parity | Same keys across all locale files | Required |
| Placeholder consistency | Same placeholders across translations | Required |
| Translation quality | Professional translations (not machine) | Recommended |
| Translation updates | Process for keeping translations current | Required |
| ICU Message Format | Proper ICU format for complex messages | Required |

**Search Patterns:**
```bash
# List all locale files
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" 2>/dev/null | grep -v node_modules | sort

# Count keys per locale
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" 2>/dev/null | grep -v node_modules | xargs -I {} sh -c 'echo "{}: $(grep -c "\".*\":" {} 2>/dev/null || echo 0)"'

# Find placeholder patterns
grep -r "{{.*}}\|{.*}\|%s\|%d" --include="*.json" -path "*locale*" 2>/dev/null | head -20

# Check for empty translations
grep -r "\".*\".*:.*\"\"" --include="*.json" -path "*locale*" 2>/dev/null | head -10
```

#### 6. Cultural Adaptation

Content must be culturally appropriate for target markets.

| Check | Pattern | Status |
|-------|---------|--------|
| Color symbolism | Colors appropriate for culture | Recommended |
| Iconography | Icons culturally appropriate | Recommended |
| Name formatting | Name order varies by culture (family/given) | Required |
| Address formatting | Address formats vary by country | Required |
| Phone formatting | Phone number formats vary | Required |
| Paper size | Document sizes (A4 vs Letter) | Recommended |
| First day of week | Calendar starts on different days | Required |
| Reading patterns | Content layout respects reading direction | Required |

**Search Patterns:**
```bash
# Find name field handling
grep -r "firstName\|lastName\|givenName\|familyName\|fullName\|displayName" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find address formatting
grep -r "address\|street\|city\|state\|postal\|zip\|country" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -20

# Find phone formatting
grep -r "phone\|tel\|mobile\|cellular" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find calendar/date picker configuration
grep -r "firstDayOfWeek\|weekStartsOn\|calendar" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -10

# Find locale configuration
grep -r "locale\|language\|culture\|region" --include="*.ts" --include="*.js" --include="*.json" 2>/dev/null | head -20
```

#### 7. Locale Detection & Switching

Users must be able to access content in their preferred language.

| Check | Pattern | Status |
|-------|---------|--------|
| Accept-Language header | Server respects Accept-Language | Required |
| User preference stored | Language preference persisted | Required |
| Language switcher | UI for changing language | Required |
| URL-based locale | Optional: locale in URL path/subdomain | Recommended |
| Cookie-based locale | Language preference in cookie | Recommended |
| Default fallback | Fallback locale for unsupported languages | Required |
| Instant update | Language change without page reload | Recommended |

**Search Patterns:**
```bash
# Find Accept-Language handling
grep -r "Accept-Language\|accept.*language\|acceptLanguage" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -10

# Find language switcher
grep -r "language.*switch\|changeLanguage\|setLocale\|switchLang" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find language storage
grep -r "localStorage.*lang\|cookie.*lang\|sessionStorage.*lang\|user.*language\|user.*locale" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find i18n initialization
grep -r "i18n\.init\|createInstance\|initI18n\|setupI18n" --include="*.ts" --include="*.js" 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific i18n/l10n gap
2. **Why it matters**: User experience and market impact
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      I18N/L10N PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Supported Locales: [list of locales]
RTL Support: [Yes/No/Partial]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

UTF-8 ENCODING
  [PASS] HTML meta charset declared
  [WARN] Database charset not UTF-8mb4
  [PASS] API responses include charset
  [FAIL] File I/O not specifying encoding
  [PASS] Email templates UTF-8

RTL SUPPORT
  [FAIL] No dir attribute handling
  [FAIL] No RTL stylesheet
  [WARN] Using physical CSS properties (left/right)
  [FAIL] Icons not mirrored for RTL
  [N/A]  Bidirectional text handling (no mixed content)

LOCALE FORMATTING
  [PASS] Date formatting with Intl.DateTimeFormat
  [WARN] Number formatting hardcoded
  [FAIL] Currency not locale-aware
  [PASS] Timezone handling implemented
  [WARN] Plural rules not implemented

STRING EXTERNALIZATION
  [FAIL] Hardcoded strings in components
  [PASS] Translation function used
  [WARN] Non-descriptive translation keys
  [PASS] Interpolation implemented
  [FAIL] Missing fallback handling

TRANSLATION COMPLETENESS
  [PASS] All locales have files
  [FAIL] Key mismatch between locales
  [PASS] Placeholders consistent
  [WARN] Machine translations detected
  [PASS] ICU format used

CULTURAL ADAPTATION
  [WARN] Name formatting Western-only
  [FAIL] Address formatting US-only
  [WARN] Phone formatting limited
  [FAIL] First day of week hardcoded

LOCALE DETECTION
  [PASS] Accept-Language handled
  [PASS] Language switcher present
  [PASS] Preference stored in cookie
  [WARN] No URL-based locale

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] No RTL Support
  Impact: Arabic, Hebrew, Farsi, Urdu users cannot use the app
  Fix: Implement RTL support with dir attribute and logical properties
  File: src/App.tsx

  // BEFORE (no RTL support):
  <div className="app">
    <Header />
    <main>{children}</main>
  </div>

  // AFTER (RTL support):
  import { useTranslation } from 'react-i18next';

  function App() {
    const { i18n } = useTranslation();
    const isRTL = ['ar', 'he', 'fa', 'ur'].includes(i18n.language);

    useEffect(() => {
      document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
      document.documentElement.lang = i18n.language;
    }, [i18n.language, isRTL]);

    return (
      <div className="app" dir={isRTL ? 'rtl' : 'ltr'}>
        <Header />
        <main>{children}</main>
      </div>
    );
  }

  File: src/styles/rtl.css (create)

  /* Use logical properties instead of physical */
  .sidebar {
    /* BEFORE: physical properties */
    margin-left: 20px;
    padding-right: 16px;
    border-left: 1px solid #ccc;

    /* AFTER: logical properties */
    margin-inline-start: 20px;
    padding-inline-end: 16px;
    border-inline-start: 1px solid #ccc;
  }

  /* RTL-specific overrides if needed */
  [dir="rtl"] .arrow-icon {
    transform: scaleX(-1);
  }

[CRITICAL] Currency Not Locale-Aware
  Impact: Users see wrong currency symbols and formats
  Fix: Use Intl.NumberFormat for currency
  File: src/utils/formatCurrency.ts

  // BEFORE (hardcoded):
  function formatPrice(amount: number) {
    return '$' + amount.toFixed(2);
  }

  // AFTER (locale-aware):
  function formatPrice(
    amount: number,
    currency: string = 'USD',
    locale: string = 'en-US'
  ): string {
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: currency,
    }).format(amount);
  }

  // Usage:
  formatPrice(1234.56, 'EUR', 'de-DE');  // "1.234,56 €"
  formatPrice(1234.56, 'JPY', 'ja-JP');  // "¥1,235"
  formatPrice(1234.56, 'USD', 'en-US');  // "$1,234.56"

[CRITICAL] Hardcoded Strings in Components
  Impact: Cannot translate application
  Fix: Externalize all user-facing strings
  File: src/components/UserProfile.tsx

  // BEFORE (hardcoded):
  function UserProfile({ user }) {
    return (
      <div>
        <h1>User Profile</h1>
        <p>Welcome, {user.name}!</p>
        <button>Save Changes</button>
        <span>Last login: {user.lastLogin}</span>
      </div>
    );
  }

  // AFTER (externalized):
  import { useTranslation } from 'react-i18next';

  function UserProfile({ user }) {
    const { t } = useTranslation('userProfile');

    return (
      <div>
        <h1>{t('title')}</h1>
        <p>{t('welcome', { name: user.name })}</p>
        <button>{t('saveButton')}</button>
        <span>{t('lastLogin', { date: formatDate(user.lastLogin) })}</span>
      </div>
    );
  }

  File: public/locales/en/userProfile.json
  {
    "title": "User Profile",
    "welcome": "Welcome, {{name}}!",
    "saveButton": "Save Changes",
    "lastLogin": "Last login: {{date}}"
  }

  File: public/locales/ar/userProfile.json
  {
    "title": "الملف الشخصي",
    "welcome": "مرحباً، {{name}}!",
    "saveButton": "حفظ التغييرات",
    "lastLogin": "آخر تسجيل دخول: {{date}}"
  }

[HIGH] Key Mismatch Between Locales
  Impact: Missing translations cause errors or fallback text
  Fix: Ensure all locales have same keys
  File: scripts/checkTranslations.js (create)

  const fs = require('fs');
  const path = require('path');

  function checkTranslationKeys() {
    const localesDir = './public/locales';
    const locales = fs.readdirSync(localesDir);

    // Get all keys from reference locale (en)
    const referenceKeys = getKeys(path.join(localesDir, 'en'));
    const issues = [];

    for (const locale of locales) {
      if (locale === 'en') continue;

      const localeKeys = getKeys(path.join(localesDir, locale));
      const missing = referenceKeys.filter(k => !localeKeys.includes(k));
      const extra = localeKeys.filter(k => !referenceKeys.includes(k));

      if (missing.length > 0) {
        issues.push(`${locale}: Missing keys: ${missing.join(', ')}`);
      }
      if (extra.length > 0) {
        issues.push(`${locale}: Extra keys: ${extra.join(', ')}`);
      }
    }

    if (issues.length > 0) {
      console.error('Translation key issues found:');
      issues.forEach(i => console.error(`  - ${i}`));
      process.exit(1);
    }

    console.log('All translation keys are in sync!');
  }

[HIGH] Address Formatting US-Only
  Impact: International users cannot enter correct addresses
  Fix: Implement locale-aware address formatting
  File: src/components/AddressForm.tsx

  import { useTranslation } from 'react-i18next';

  const ADDRESS_FORMATS = {
    'en-US': {
      fields: ['street', 'city', 'state', 'zip'],
      labels: { state: 'State', zip: 'ZIP Code' }
    },
    'en-GB': {
      fields: ['street', 'city', 'postcode'],
      labels: { postcode: 'Postcode' }
    },
    'de-DE': {
      fields: ['street', 'postcode', 'city'],
      labels: { postcode: 'PLZ' }
    },
    'ja-JP': {
      fields: ['postcode', 'prefecture', 'city', 'street'],
      labels: { postcode: '郵便番号', prefecture: '都道府県' }
    }
  };

  function AddressForm({ locale = 'en-US' }) {
    const { t } = useTranslation('address');
    const format = ADDRESS_FORMATS[locale] || ADDRESS_FORMATS['en-US'];

    return (
      <form>
        {format.fields.map(field => (
          <input
            key={field}
            name={field}
            placeholder={format.labels[field] || t(field)}
          />
        ))}
      </form>
    );
  }

[MEDIUM] Plural Rules Not Implemented
  Impact: Incorrect grammar in pluralized messages
  Fix: Use ICU MessageFormat for plurals
  File: public/locales/en/messages.json

  // BEFORE (no plural handling):
  {
    "itemsCount": "{{count}} items"
  }

  // AFTER (ICU plurals):
  {
    "itemsCount": "{{count, plural, one{# item} other{# items}}}"
  }

  // Complex example with ordinal:
  {
    "position": "{{pos, selectordinal, one{#st} two{#nd} few{#rd} other{#th}}} place"
  }

  // Usage:
  t('itemsCount', { count: 1 })   // "1 item"
  t('itemsCount', { count: 5 })   // "5 items"

[MEDIUM] First Day of Week Hardcoded
  Impact: Calendar starts on wrong day for some locales
  Fix: Use locale-aware first day of week
  File: src/utils/calendarConfig.ts

  const FIRST_DAY_OF_WEEK = {
    'en-US': 0,  // Sunday
    'en-GB': 1,  // Monday
    'de-DE': 1,  // Monday
    'ar-SA': 0,  // Sunday
    'he-IL': 0,  // Sunday
    'fa-IR': 6,  // Saturday
  };

  function getFirstDayOfWeek(locale: string): number {
    // Use Intl.Locale if available
    if ('getWeekInfo' in Intl.Locale.prototype) {
      const localeObj = new Intl.Locale(locale);
      return localeObj.getWeekInfo().firstDay;
    }
    return FIRST_DAY_OF_WEEK[locale] ?? 0;
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Implement RTL support for Arabic, Hebrew, Farsi, Urdu
2. [CRITICAL] Make currency formatting locale-aware
3. [CRITICAL] Externalize all hardcoded strings
4. [HIGH] Ensure translation key parity across locales
5. [HIGH] Implement locale-aware address formatting
6. [HIGH] Add plural rules with ICU MessageFormat
7. [MEDIUM] Use logical CSS properties throughout
8. [MEDIUM] Implement locale-aware first day of week

After Production:
1. Set up professional translation service
2. Add locale-specific validation (phone, postal codes)
3. Implement locale-specific content negotiation
4. Add translation management system integration
5. Set up automated translation completeness checks
6. Conduct cultural review of all content
7. Add locale-specific SEO optimization

═══════════════════════════════════════════════════════════════
```

---

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for international production |
| 70-89 | NEEDS WORK | Address gaps before international release |
| 50-69 | AT RISK | Significant i18n/l10n issues, review required |
| 0-49 | BLOCK | Critical gaps, not ready for international users |

### Weight Distribution

| Category | Weight |
|----------|--------|
| UTF-8 Encoding | 10% |
| RTL Support | 20% |
| Locale Formatting | 20% |
| String Externalization | 20% |
| Translation Completeness | 15% |
| Cultural Adaptation | 10% |
| Locale Detection & Switching | 5% |

---

## Quick Reference: Implementation Patterns

### RTL Support (React)

```tsx
import { useTranslation } from 'react-i18next';
import { useEffect } from 'react';

// RTL language codes
const RTL_LANGUAGES = ['ar', 'he', 'fa', 'ur', 'yi', 'ps', 'sd'];

function useRTL() {
  const { i18n } = useTranslation();

  const isRTL = RTL_LANGUAGES.includes(i18n.language);

  useEffect(() => {
    document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
    document.documentElement.lang = i18n.language;
  }, [i18n.language, isRTL]);

  return isRTL;
}

// Usage in component
function App() {
  const isRTL = useRTL();

  return (
    <div className="app" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Components */}
    </div>
  );
}
```

### Locale-Aware Date Formatting

```typescript
// Date formatting with timezone
function formatDate(
  date: Date | string,
  options: Intl.DateTimeFormatOptions = {},
  locale: string = 'en-US'
): string {
  const defaultOptions: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options
  };

  return new Intl.DateTimeFormat(locale, defaultOptions).format(new Date(date));
}

// Relative time (e.g., "2 hours ago")
function formatRelativeTime(
  date: Date,
  locale: string = 'en-US'
): string {
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
  const diff = date.getTime() - Date.now();
  const seconds = Math.round(diff / 1000);
  const minutes = Math.round(seconds / 60);
  const hours = Math.round(minutes / 60);
  const days = Math.round(hours / 24);

  if (Math.abs(days) > 0) return rtf.format(days, 'day');
  if (Math.abs(hours) > 0) return rtf.format(hours, 'hour');
  if (Math.abs(minutes) > 0) return rtf.format(minutes, 'minute');
  return rtf.format(seconds, 'second');
}

// Usage:
formatDate(new Date(), {}, 'de-DE');  // "27. Februar 2026"
formatDate(new Date(), {}, 'ja-JP');  // "2026年2月27日"
formatRelativeTime(new Date(Date.now() - 3600000), 'es');  // "hace 1 hora"
```

### Locale-Aware Number & Currency Formatting

```typescript
// Number formatting
function formatNumber(
  value: number,
  locale: string = 'en-US',
  options: Intl.NumberFormatOptions = {}
): string {
  return new Intl.NumberFormat(locale, options).format(value);
}

// Currency formatting
function formatCurrency(
  amount: number,
  currency: string = 'USD',
  locale: string = 'en-US'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(amount);
}

// Unit formatting
function formatUnit(
  value: number,
  unit: Intl.NumberFormatOptions['unit'],
  locale: string = 'en-US'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'unit',
    unit,
  }).format(value);
}

// Usage:
formatNumber(1234567.89, 'de-DE');              // "1.234.567,89"
formatCurrency(1234.56, 'EUR', 'de-DE');         // "1.234,56 €"
formatCurrency(1234.56, 'JPY', 'ja-JP');         // "¥1,235"
formatUnit(100, 'kilometer', 'en-US');           // "100 km"
formatUnit(100, 'kilometer', 'en-GB');           // "100 km"
```

### Translation with Interpolation & Plurals

```typescript
// i18next configuration
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        translation: {
          welcome: "Welcome, {{name}}!",
          itemsCount: "{{count, plural, one{# item} other{# items}}}",
          lastLogin: "Last login: {{date, datetime}}",
          greeting: "Hello {{gender, select, male{Mr.} female{Ms.} other{}}}",
        }
      },
      ar: {
        translation: {
          welcome: "مرحباً، {{name}}!",
          itemsCount: "{{count, plural, zero{# عناصر} one{# عنصر} two{# عنصرين} few{# عناصر} many{# عنصراً} other{# عنصر}}}",
          lastLogin: "آخر تسجيل دخول: {{date, datetime}}",
        }
      }
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
      format: (value, format, lng) => {
        if (format === 'datetime') {
          return new Intl.DateTimeFormat(lng).format(value);
        }
        return value;
      }
    }
  });

// Usage in component
function WelcomeMessage({ user }) {
  const { t } = useTranslation();

  return (
    <div>
      <h1>{t('welcome', { name: user.name })}</h1>
      <p>{t('itemsCount', { count: user.cartItems })}</p>
      <p>{t('lastLogin', { date: new Date(user.lastLogin) })}</p>
    </div>
  );
}
```

### CSS Logical Properties

```css
/* BEFORE: Physical properties (problematic for RTL) */
.sidebar {
  margin-left: 20px;
  padding-right: 16px;
  border-left: 1px solid #ccc;
  float: left;
  text-align: left;
}

.arrow-icon {
  margin-right: 8px;
}

/* AFTER: Logical properties (RTL-compatible) */
.sidebar {
  margin-inline-start: 20px;      /* margin-left in LTR, margin-right in RTL */
  padding-inline-end: 16px;        /* padding-right in LTR, padding-left in RTL */
  border-inline-start: 1px solid #ccc;
  float: inline-start;            /* left in LTR, right in RTL */
  text-align: start;              /* left in LTR, right in RTL */
}

.arrow-icon {
  margin-inline-end: 8px;
}

/* RTL-specific overrides when needed */
[dir="rtl"] .arrow-forward {
  transform: scaleX(-1);
}

/* Use CSS logical properties for positioning */
.modal {
  inset-inline-start: 50%;
  inset-block-start: 50%;
  transform: translate(-50%, -50%);
}
```

### Locale Detection & Storage

```typescript
// Server-side locale detection
function detectLocale(req: Request): string {
  const acceptLanguage = req.headers['accept-language'];
  const supportedLocales = ['en', 'es', 'fr', 'de', 'ar', 'ja'];
  const fallbackLocale = 'en';

  // Parse Accept-Language header
  const locales = acceptLanguage?.split(',')
    .map(l => l.split(';')[0].trim().substring(0, 2))
    .filter(l => supportedLocales.includes(l)) ?? [];

  return locales[0] || fallbackLocale;
}

// Client-side locale management
class LocaleManager {
  private static STORAGE_KEY = 'user_locale';

  static getStoredLocale(): string | null {
    return localStorage.getItem(this.STORAGE_KEY);
  }

  static setLocale(locale: string): void {
    localStorage.setItem(this.STORAGE_KEY, locale);
    document.documentElement.lang = locale;
  }

  static detectBrowserLocale(supportedLocales: string[]): string {
    const browserLang = navigator.language.substring(0, 2);
    return supportedLocales.includes(browserLang) ? browserLang : 'en';
  }

  static getInitialLocale(supportedLocales: string[]): string {
    return this.getStoredLocale()
      || this.detectBrowserLocale(supportedLocales);
  }
}
```

---

## Integration with Other Reviews

This skill complements:
- `/api-readiness-review` - For API locale handling
- `/compliance-review` - For data localization requirements
- `/accessibility-review` - For RTL accessibility
- `/ux-review` - For cultural UX patterns
