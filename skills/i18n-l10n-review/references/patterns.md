# i18n-l10n-review — Implementation Patterns

Reusable code snippets and configuration templates for i18n-l10n-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

