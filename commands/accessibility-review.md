---
description: Production readiness review for Accessibility (WCAG 2.1 AA). Reviews keyboard navigation, screen readers, color contrast, focus states, semantic HTML, ARIA labels, and inclusive design. Use PROACTIVELY before production releases, when implementing UI features, or ensuring compliance with accessibility standards.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Accessibility Review Command

Run a comprehensive production readiness review focused on Accessibility (WCAG 2.1 AA).

## Purpose

Review code before production release to ensure:
- Keyboard navigation works for all interactive elements
- Screen reader compatibility with proper ARIA implementation
- Color contrast meets WCAG 2.1 AA standards (4.5:1 for text)
- Focus states are visible and properly managed
- Semantic HTML is used correctly
- Forms are accessible with proper labels and error handling
- Media content has alternatives (captions, transcripts)
- Animations respect user preferences

## Workflow

### 1. Load the Accessibility Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/accessibility-review/SKILL.md
```

### 2. Detect Project Stack & Accessibility Tools

Identify the frontend technology stack and accessibility testing setup:
```bash
ls package.json 2>/dev/null
grep -r "react\|vue\|angular\|svelte\|next\|nuxt" --include="package.json" 2>/dev/null | head -5
grep -r "axe-core\|jest-axe\|cypress-axe\|pa11y\|lighthouse\|eslint-plugin-jsx-a11y" --include="package.json" 2>/dev/null | head -5
```

### 3. Run Accessibility Checks

Execute all checks in parallel:

**Keyboard Navigation:**
```bash
grep -r "onClick" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -30
grep -r "tabindex" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20
grep -r "modal\|dialog" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15
grep -r "onKeyDown\|onKeyUp" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15
```

**Screen Reader Support:**
```bash
grep -r "<img" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | grep -v "alt=" | head -20
grep -r "aria-\|role=" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -30
grep -r "<input\|<select\|<textarea" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "<h1\|<h2\|<h3" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20
```

**Color Contrast & Focus:**
```bash
grep -r "color:\|text-\|bg-" --include="*.css" --include="*.tsx" 2>/dev/null | head -30
grep -r ":focus\|focus:\|outline" --include="*.css" --include="*.scss" 2>/dev/null | head -20
grep -r "outline.*none\|outline:.*0" --include="*.css" 2>/dev/null | head -15
```

**Semantic HTML:**
```bash
grep -r "<div.*onClick\|<span.*onClick" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "<button" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "<a[^>]*>" --include="*.tsx" --include="*.jsx" 2>/dev/null | grep -v "href=" | head -15
```

**Forms:**
```bash
grep -r "required\|aria-required" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "aria-invalid\|aria-errormessage\|aria-describedby" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15
```

**Animations & Motion:**
```bash
grep -r "prefers-reduced-motion" --include="*.css" --include="*.scss" 2>/dev/null | head -10
grep -r "animation\|transition" --include="*.css" 2>/dev/null | head -20
```

**Testing:**
```bash
grep -r "axe\|jest-axe\|cypress-axe\|pa11y" --include="package.json" 2>/dev/null | head -5
find . -name "*a11y*" -o -name "*accessibility*" 2>/dev/null | grep -v node_modules | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Keyboard, Screen Reader, Contrast, Focus, Semantic, Forms, Media, Testing)
- Calculate overall score
- Determine pass/fail status

### 5. Generate Report

Output the formatted report with:
- Overall score and status
- Checklist results (PASS/FAIL/WARN for each item)
- Gap analysis with specific recommendations
- Code examples for missing implementations

### 6. Recommendations

Provide prioritized recommendations:
1. **Critical** - Must fix before production (WCAG A violations)
2. **High** - Should fix before or immediately after release (WCAG AA violations)
3. **Medium** - Should add within first week
4. **Low** - Nice to have (AAA improvements)

## Usage

```
/accessibility-review
```

## When to Use

- Before production releases
- When implementing UI/frontend features
- When adding forms or interactive components
- When creating modals, dropdowns, or custom widgets
- When changing colors or themes
- For public-facing applications (legal compliance)
- When WCAG compliance is required

## Integration with Other Commands

Consider running alongside:
- `/browser-compatibility-review` - For cross-browser accessibility
- `/performance-review` - For accessible loading states
- `/seo-review` - For semantic structure overlap
- `/ui-ux` - For inclusive design patterns
