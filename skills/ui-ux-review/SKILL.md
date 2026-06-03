---
name: ui-ux-review
description: Production readiness review for UI/UX quality. Reviews responsive design, loading states, error messages, empty states, consistency, accessibility, and design system compliance. Use PROACTIVELY before production releases, when implementing UI features, or ensuring quality user experience.
paths:
  - "**/*.{jsx,tsx,vue,svelte}"
  - "**/components/**"
  - "**/pages/**"
  - "**/views/**"
  - "**/screens/**"
  - "**/*.{css,scss,sass}"
  - "**/design-system/**"
  - "**/ui/**"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# UI/UX Review Skill

Production readiness code review focused on UI/UX quality. Ensures code is ready for production with proper responsive design, loading states, error handling UX, empty states, visual consistency, accessibility compliance, and design system adherence.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "ui", "ux", "design", "responsive", "mobile", "loading", "error", "empty", "accessibility", "a11y", "wcag"
- UI/frontend changes affecting user experience
- Component implementations or modifications
- Form implementations
- Page layouts or routing changes
- Design system updates
- Mobile or tablet-specific features
- Before major releases with user-facing changes

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
- Phase 2: UI/UX Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production with excellent UX |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant UX issues, review required |
| 0-49 | BLOCK | Critical UX gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Responsive Design | 20% |
| Loading States | 15% |
| Error Handling UX | 15% |
| Empty States | 10% |
| Consistency | 15% |
| Accessibility | 15% |
| Design System | 10% |

---

## Integration with Other Reviews

This skill complements:
- `/browser-compatibility-review` - For cross-browser UI support
- `/performance-review` - For loading performance
- `/seo-review` - For meta tags and structured data
- `/observability-check` - For error tracking and monitoring
