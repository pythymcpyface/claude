---
name: browser-compatibility-review
description: Production readiness review for Browser Compatibility. Reviews cross-browser support, responsive design, progressive enhancement, polyfills, and graceful degradation. Use PROACTIVELY before production releases, when implementing UI features, or ensuring broad device coverage.
paths:
  - "**/*.{html,htm}"
  - "**/*.{jsx,tsx,vue,svelte}"
  - "**/*.{css,scss,sass,less}"
  - "**/browserslist*"
  - "**/.browserslistrc"
  - "**/postcss.config.*"
  - "**/babel.config.*"
  - "**/.babelrc*"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Browser Compatibility Review Skill

Production readiness code review focused on Browser Compatibility. Ensures code is ready for production with proper cross-browser support, responsive design, progressive enhancement strategies, and graceful degradation for older browsers.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "browser", "compatibility", "responsive", "mobile", "cross-browser", "IE", "Safari", "polyfill", "fallback"
- UI/frontend changes affecting layout or interactions
- CSS changes (new properties, Grid, Flexbox, custom properties)
- JavaScript features using modern APIs
- Form implementations
- Mobile or tablet-specific features
- Accessibility improvements
- Before major releases with broad user base

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
- Phase 2: Browser Compatibility Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for broad browser deployment |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant compatibility issues |
| 0-49 | BLOCK | Critical gaps, will break for many users |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Browser Support Matrix | 10% |
| CSS Compatibility | 20% |
| JavaScript Compatibility | 20% |
| Responsive Design | 20% |
| Progressive Enhancement | 15% |
| Browser Quirks | 10% |
| Testing Coverage | 5% |

---

## Integration with Other Reviews

This skill complements:
- `/accessibility-review` - For WCAG compliance and assistive technology
- `/performance-review` - For loading performance across devices
- `/i18n-l10n-review` - For international browser compatibility
- `/api-readiness-review` - For API client compatibility
