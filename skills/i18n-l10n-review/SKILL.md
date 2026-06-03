---
name: i18n-l10n-review
description: Production readiness review for Internationalization (i18n) and Localization (l10n). Reviews RTL support, locale formatting, UTF-8 handling, translation completeness, and cultural adaptation. Use PROACTIVELY before production releases, when expanding to international markets, or implementing multi-language features.
paths:
  - "**/locales/**"
  - "**/i18n/**"
  - "**/translations/**"
  - "**/lang/**"
  - "**/*.po"
  - "**/*.pot"
  - "**/messages/**"
  - "**/*.{json,yaml,yml}"
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

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
| Reusable code snippets and configuration templates | `references/patterns.md` |

Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

- Phase 1: Stack Detection
- Phase 2: i18n/l10n Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

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

## Integration with Other Reviews

This skill complements:
- `/api-readiness-review` - For API locale handling
- `/compliance-review` - For data localization requirements
- `/accessibility-review` - For RTL accessibility
- `/ux-review` - For cultural UX patterns
