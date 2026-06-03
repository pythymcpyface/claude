---
name: accessibility-review
description: Production readiness review for Accessibility (WCAG 2.1 AA). Reviews keyboard navigation, screen readers, color contrast, focus states, semantic HTML, ARIA labels, and inclusive design. Use PROACTIVELY before production releases, when implementing UI features, or ensuring compliance with accessibility standards.
paths:
  - "**/*.html"
  - "**/*.{jsx,tsx}"
  - "**/*.vue"
  - "**/*.svelte"
  - "**/components/**"
  - "**/pages/**"
  - "**/views/**"
  - "**/*.{css,scss,sass}"
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Accessibility Review Skill

Production readiness code review focused on Accessibility (WCAG 2.1 AA). Ensures code is ready for production with proper keyboard navigation, screen reader support, color contrast ratios, focus management, semantic HTML, and ARIA implementation.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "accessibility", "a11y", "WCAG", "ARIA", "screen reader", "keyboard", "contrast", "focus", "semantic", "inclusive"
- UI/frontend changes affecting user interactions
- Form implementations
- Navigation components
- Modal/dialog implementations
- Custom interactive components (dropdowns, tabs, accordions)
- Color/theme changes
- Before major releases with public-facing features

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
- Phase 2: Accessibility Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production, meets WCAG 2.1 AA |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant accessibility barriers |
| 0-49 | BLOCK | Critical barriers, legal/compliance risk |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Keyboard Navigation | 20% |
| Screen Reader Support | 25% |
| Color Contrast | 15% |
| Focus Management | 15% |
| Semantic HTML | 10% |
| Forms & Inputs | 10% |
| Media & Animations | 3% |
| Testing Coverage | 2% |

---

## Integration with Other Reviews

This skill complements:
- `/browser-compatibility-review` - For cross-browser accessibility support
- `/performance-review` - For accessible loading states
- `/i18n-l10n-review` - For localized accessibility content
- `/seo-review` - For semantic structure overlap
- `/ui-ux` - For inclusive design patterns
