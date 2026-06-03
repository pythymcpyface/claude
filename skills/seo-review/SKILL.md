---
name: seo-review
description: Production readiness review for SEO. Reviews meta tags, structured data, Core Web Vitals, and LLM/GEO optimization before production release. Use PROACTIVELY before releasing to production, when adding new pages, or modifying content structure.
paths:
  - "**/*.{html,htm}"
  - "**/*.{jsx,tsx,vue,svelte}"
  - "**/pages/**"
  - "**/app/**/page.{ts,tsx,js,jsx}"
  - "**/app/**/layout.{ts,tsx,js,jsx}"
  - "**/sitemap*"
  - "**/robots.txt"
  - "**/*.mdx"
  - "**/seo/**"
  - "**/meta*"
tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
---

# SEO Review Skill

Production readiness code review focused on Search Engine Optimization (SEO) and Generative Engine Optimization (GEO). Ensures applications are ready for production with proper meta tags, structured data, Core Web Vitals, and LLM-friendly content.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "seo", "meta", "og:", "schema", "structured data", "core web vitals"
- New pages or routes are added
- Content or layout changes affect rendering
- Performance optimizations are implemented
- Before major releases or product launches
- When modifying HTML head or meta tags
- Adding or modifying JSON-LD structured data
- Changes affecting page load performance

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
- Phase 2: SEO Checklist
- Phase 3: Gap Analysis
- Phase 4: Output Report

Walk through each phase using `references/checklists.md` for the detailed checks.

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Meta Tags | 30% |
| Structured Data | 25% |
| Core Web Vitals | 25% |
| LLM/GEO SEO | 20% |

---

## Integration with Other Reviews

This skill complements:
- `/performance-review` - For load testing and resource optimization
- `/browser-compatibility-review` - For cross-browser support
- `/observability-check` - For monitoring and analytics
- `/quality-check` - For code quality and linting
- `/api-readiness-review` - For API design and documentation
