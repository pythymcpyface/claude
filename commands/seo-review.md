---
description: Production readiness review for SEO. Reviews meta tags, structured data, Core Web Vitals, and LLM/GEO optimization before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# SEO Review Command

Run a comprehensive production readiness review focused on Search Engine Optimization (SEO) and Generative Engine Optimization (GEO).

## Purpose

Review SEO before production release to ensure:
- Meta tags are complete and optimized for search and social
- Structured data enables rich results in search engines
- Core Web Vitals meet Google's performance thresholds
- Content is optimized for LLM-powered search (ChatGPT, Perplexity, Google SGE)
- Technical SEO best practices are followed

## Workflow

### 1. Load the SEO Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/seo-review/SKILL.md
```

### 2. Detect SEO Stack

Identify the frontend framework and SEO infrastructure:
```bash
# Detect SSR frameworks
grep -r "next\|nuxt\|gatsby\|remix\|astro\|sveltekit" package.json 2>/dev/null && echo "SSR Framework"

# Detect SPA frameworks
grep -r "react\|vue\|angular\|svelte" package.json 2>/dev/null && echo "SPA Framework"

# Detect SEO libraries
grep -r "next-seo\|react-helmet\|vue-meta" package.json 2>/dev/null

# Check for sitemap/robots
find . -name "sitemap*.xml" -o -name "robots.txt" 2>/dev/null | head -5
```

### 3. Run SEO Checks

Execute all checks in parallel:

**Meta Tags:**
```bash
# Find title tags
grep -r "<title>\|<Title>\|title.*=" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find meta descriptions
grep -r "description.*meta\|meta.*description\|name=\"description\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find Open Graph tags
grep -r "og:\|property=\"og:\|open.*graph" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find Twitter Card tags
grep -r "twitter:\|twitter:card\|name=\"twitter:" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find canonical URLs
grep -r "canonical\|rel=\"canonical\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

**Structured Data:**
```bash
# Find JSON-LD scripts
grep -r "application/ld+json\|type=\"application/ld+json\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find schema.org references
grep -r "schema.org\|@type.*Organization\|@type.*Product\|@type.*Article" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find breadcrumb implementations
grep -r "breadcrumb\|BreadcrumbList" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

**Core Web Vitals:**
```bash
# Find image optimization
grep -r "next/image\|Image.*from\|loading=\"lazy\"" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "<img.*loading\|<img.*srcset" --include="*.html" 2>/dev/null | head -10

# Find font loading
grep -r "font-display\|@font-face\|next/font" --include="*.tsx" --include="*.jsx" --include="*.css" --include="*.scss" 2>/dev/null | head -15

# Find code splitting
grep -r "import(\|lazy\|Suspense\|dynamic.*import" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find preload/prefetch hints
grep -r "rel=\"preload\"\|rel=\"prefetch\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

**LLM/GEO SEO:**
```bash
# Find semantic HTML
grep -r "<header\|<nav\|<main\|<article\|<section\|<footer" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find heading structure
grep -r "<h1\|<h2\|<h3" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find FAQ implementations
grep -r "FAQ\|faq\|Frequently.*Asked\|Question.*Answer" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Check for accessibility
grep -r "aria-\|role=\|alt=\"\|aria-label" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20
```

**Technical SEO:**
```bash
# Find sitemap
find . -name "sitemap*.xml" -o -name "sitemap*.ts" -o -name "sitemap*.js" 2>/dev/null | head -10

# Find robots.txt
find . -name "robots.txt" -o -name "robots*.ts" 2>/dev/null | head -5

# Check for 404 pages
find . -name "*404*" -o -name "*not*found*" 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Meta Tags, Structured Data, Core Web Vitals, LLM/GEO SEO)
- Calculate overall score (weighted: 30% / 25% / 25% / 20%)
- Determine pass/fail status

**Scoring:**
| Score | Status | Condition |
|-------|--------|-----------|
| 90-100 | PASS | All required checks pass |
| 70-89 | NEEDS WORK | Minor gaps, mostly complete |
| 50-69 | AT RISK | Significant gaps found |
| 0-49 | BLOCK | Critical gaps, do not release |

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:

**Immediate (Must fix before production):**
1. [CRITICAL] Add JSON-LD structured data to all pages
2. [HIGH] Add unique meta descriptions to every page
3. [HIGH] Implement font-display strategy
4. [HIGH] Add FAQ sections for AI search visibility

**Short-term (Within 1 week):**
5. [MEDIUM] Create custom 404 page
6. [MEDIUM] Add Twitter Card meta tags
7. [MEDIUM] Implement breadcrumb schema
8. [MEDIUM] Add author/attribution information

**Long-term:**
9. [LOW] Set up Google Search Console
10. [LOW] Implement A/B testing for meta descriptions
11. [LOW] Add more FAQ content for AI optimization

## Usage

```
/seo-review
```

## When to Use

- Before releasing to production
- When adding new pages or routes
- When modifying content or layout
- Before major product launches
- When optimizing for search rankings
- When implementing structured data
- When improving Core Web Vitals scores
- When optimizing for AI-powered search (ChatGPT, Perplexity, Google SGE)

## Integration with Other Commands

Consider running alongside:
- `/performance-review` - For load testing and performance optimization
- `/browser-compatibility-review` - For cross-browser support
- `/observability-check` - For monitoring and analytics
- `/quality-check` - For lint, types, tests
- `/review-pr` - For comprehensive PR review
