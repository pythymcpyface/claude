---
description: Production readiness review for Internationalization (i18n) and Localization (l10n). Reviews RTL support, locale formatting, UTF-8 handling, translation completeness, and cultural adaptation. Use PROACTIVELY before production releases, when expanding to international markets, or implementing multi-language features.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# i18n/l10n Review Command

Run a comprehensive internationalization and localization review before production release.

## Purpose

Review code for i18n/l10n readiness to ensure:
- UTF-8 encoding is used throughout the stack
- RTL (Right-to-Left) languages are properly supported
- Dates, numbers, and currencies are formatted per locale
- All user-facing text is externalized for translation
- Translations are complete and accurate
- Cultural adaptations are in place
- Users can easily switch languages

## The Critical Importance

**International users expect native-quality experiences.** Poor localization leads to confused users, lost sales, and brand damage in international markets. RTL users cannot use applications without proper support. Cultural faux pas in content can cause serious reputational harm. Proper i18n/l10n opens global markets and builds trust.

## Workflow

### 1. Load the i18n/l10n Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/i18n-l10n-review/SKILL.md
```

### 2. Detect Stack and i18n Setup

Identify the technology stack and internationalization patterns:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null && echo "Stack detected"

# Detect i18n libraries
grep -r "i18next\|react-i18next\|vue-i18n\|react-intl\|formatjs\|gettext\|babel" --include="*.ts" --include="*.js" --include="*.py" --include="package.json" --include="requirements.txt" 2>/dev/null | head -15

# Find locale/translation files
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" -o -name "*.po" -o -name "*.xlf" 2>/dev/null | grep -v node_modules | head -20

# Detect RTL support
grep -r "dir.*rtl\|direction.*rtl\|RTL\|arabic\|hebrew" --include="*.ts" --include="*.js" --include="*.css" --include="*.scss" 2>/dev/null | head -10
```

### 3. Run i18n/l10n Checks

Execute checks for each category:

**UTF-8 Encoding:**
```bash
# Find HTML charset
grep -r "charset.*utf\|UTF-8" --include="*.html" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find database encoding
grep -r "charset\|collation\|utf8mb4\|encoding" --include="*.sql" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find Content-Type headers
grep -r "Content-Type.*charset" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10
```

**RTL Support:**
```bash
# Find dir attribute handling
grep -r "dir.*=.*rtl\|dir.*=.*ltr\|documentDirection" --include="*.tsx" --include="*.jsx" --include="*.ts" 2>/dev/null | head -10

# Find logical CSS properties
grep -r "margin-inline\|padding-inline\|inset-inline\|text-align.*start" --include="*.css" --include="*.scss" 2>/dev/null | head -10

# Find physical properties (anti-pattern)
grep -r "margin-left\|margin-right\|padding-left\|padding-right" --include="*.css" --include="*.scss" 2>/dev/null | head -15
```

**Locale Formatting:**
```bash
# Find date formatting
grep -r "Intl\.DateTimeFormat\|toLocaleDateString\|moment\|date-fns" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -15

# Find number/currency formatting
grep -r "Intl\.NumberFormat\|toLocaleString\|formatCurrency\|currency" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find hardcoded formats (anti-pattern)
grep -r "DD/MM/YYYY\|MM/DD/YYYY\|\\\$\s*\d" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -10
```

**String Externalization:**
```bash
# Find translation function usage
grep -r "t(\|i18n\.t\|useTranslation\|\$t(\|_\(" --include="*.tsx" --include="*.jsx" --include="*.ts" 2>/dev/null | head -20

# Find potential hardcoded strings
grep -rP ">[A-Z][a-z]+.{5,}<" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20

# Find string concatenation (anti-pattern)
grep -r "'.*'.*\+.*'.*'\|\".*\".*\+.*\".*\"" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | head -10
```

**Translation Completeness:**
```bash
# List locale files
find . -name "*.json" -path "*locale*" -o -name "*.json" -path "*lang*" 2>/dev/null | grep -v node_modules | sort

# Count keys per locale
find . -name "*.json" -path "*locale*" 2>/dev/null | grep -v node_modules | xargs -I {} sh -c 'echo "{}: $(grep -c "\".*\":" {} 2>/dev/null || echo 0)"'

# Check for empty translations
grep -r "\".*\".*:.*\"\"" --include="*.json" -path "*locale*" 2>/dev/null | head -10
```

**Cultural Adaptation:**
```bash
# Find name handling
grep -r "firstName\|lastName\|givenName\|familyName" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -15

# Find address handling
grep -r "address\|street\|city\|postal\|zip\|state" --include="*.ts" --include="*.js" 2>/dev/null | head -15

# Find phone handling
grep -r "phone\|tel\|mobile" --include="*.ts" --include="*.js" 2>/dev/null | head -10
```

**Locale Detection:**
```bash
# Find Accept-Language handling
grep -r "Accept-Language\|acceptLanguage" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find language switcher
grep -r "language.*switch\|changeLanguage\|setLocale" --include="*.tsx" --include="*.ts" --include="*.js" 2>/dev/null | head -10

# Find locale storage
grep -r "localStorage.*lang\|cookie.*lang\|user.*locale" --include="*.ts" --include="*.js" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Evaluate each category (UTF-8, RTL, Formatting, Externalization, Translation, Cultural, Detection)
- Count passed/failed/warn items per category
- Calculate category scores based on weight distribution
- Calculate overall score
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All critical i18n/l10n requirements met |
| 70-89 | NEEDS WORK | Minor i18n/l10n gaps |
| 50-69 | AT RISK | Significant gaps, international users may have issues |
| 0-49 | BLOCK | Critical gaps, not ready for international release |

**Category Weights:**
- UTF-8 Encoding: 10%
- RTL Support: 20%
- Locale-Aware Formatting: 20%
- String Externalization: 20%
- Translation Completeness: 15%
- Cultural Adaptation: 10%
- Locale Detection & Switching: 5%

### 5. Generate Report

Output the formatted report with:
- Executive summary with overall i18n/l10n posture
- Overall score and blocking status
- Supported locales detected
- RTL support status
- Checklist results (PASS/FAIL/WARN/N/A for each item)
- Gap analysis with specific code examples
- Prioritized recommendations
- Quick reference implementation patterns

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Implement RTL support for target RTL languages
2. [CRITICAL] Externalize all hardcoded user-facing strings
3. [CRITICAL] Ensure currency formatting is locale-aware
4. [HIGH] Implement proper plural rules with ICU MessageFormat
5. [HIGH] Verify translation key parity across all locales
6. [HIGH] Implement locale-aware date/time formatting

**Short-term (Within 1 week):**
7. [HIGH] Add locale-aware address and phone formatting
8. [HIGH] Use CSS logical properties instead of physical
9. [MEDIUM] Implement locale-aware first day of week
10. [MEDIUM] Add name formatting flexibility (family/given order)

**Long-term:**
11. [LOW] Set up professional translation workflow
12. [LOW] Add translation management system integration
13. [LOW] Conduct cultural review of content
14. [LOW] Implement locale-specific SEO

## Usage

```
/i18n-l10n-review
```

## When to Use

- Before releasing to international markets
- When adding multi-language support
- When implementing RTL language support
- Before major releases with international users
- When adding currency or date formatting features
- When modifying user-facing text
- During architecture reviews for global features
- Before expanding to new geographic regions

## Blocking Conditions

This command will **recommend blocking** production release if:
- No RTL support when targeting Arabic/Hebrew/Farsi/Urdu markets
- Hardcoded user-facing strings throughout
- Currency not locale-aware when handling international payments
- Missing translations for declared supported locales
- UTF-8 encoding issues in any layer
- No language switcher when supporting multiple languages

## Integration with Other Commands

Run alongside other production readiness checks:
- `/api-readiness-review` - For API locale handling
- `/compliance-review` - For data localization requirements
- `/accessibility-review` - For RTL accessibility
- `/quality-check` - For code quality

## Example Output

```
═══════════════════════════════════════════════════════════════
      I18N/L10N PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: ecommerce-platform
Stack: React/TypeScript with Node.js
Supported Locales: en, es, fr, de, ar
RTL Support: Partial (CSS only)
Date: 2026-02-27

OVERALL SCORE: 58/100 [AT RISK]

───────────────────────────────────────────────────────────────
              EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

i18n/l10n Posture: SIGNIFICANT GAPS
- RTL: CSS logical properties not used
- Formatting: Currency hardcoded to USD
- Translations: Arabic 60% complete
- Externalization: Hardcoded strings in 23 components

RECOMMENDATION: Address critical gaps before international release

═══════════════════════════════════════════════════════════════
```
