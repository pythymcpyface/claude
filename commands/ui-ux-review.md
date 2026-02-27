---
description: Production readiness review for UI/UX quality. Reviews responsive design, loading states, error messages, empty states, consistency, accessibility, and design system compliance. Use PROACTIVELY before production releases, when implementing UI features, or ensuring quality user experience.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# UI/UX Review Command

Run a comprehensive production readiness review focused on UI/UX quality.

## Purpose

Review code before production release to ensure:
- Responsive design for all screen sizes
- Loading states and feedback for async operations
- Error handling with clear, actionable messages
- Empty states with helpful guidance
- Visual consistency across components
- Accessibility compliance (WCAG 2.1 AA)
- Design system adherence

## Workflow

### 1. Load the UI/UX Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/ui-ux-review/SKILL.md
```

### 2. Detect Project Stack & UI Framework

Identify the frontend technology stack and design patterns:
```bash
ls package.json 2>/dev/null
grep -r "react\|vue\|angular\|svelte\|next\|nuxt\|sveltekit" --include="package.json" 2>/dev/null | head -5
grep -r "@mui\|@chakra\|antd\|@radix\|tailwind\|bootstrap\|styled-components" --include="package.json" 2>/dev/null | head -5
grep -r "axe-core\|jest-axe\|eslint-plugin-jsx-a11y" --include="package.json" 2>/dev/null | head -5
```

### 3. Run UI/UX Checks

Execute all checks in parallel:

**Responsive Design:**
```bash
grep -r "viewport" --include="*.html" --include="*.tsx" 2>/dev/null | head -10
grep -r "@media\|sm:\|md:\|lg:\|breakpoint" --include="*.css" --include="*.tsx" 2>/dev/null | head -20
grep -r "min-height.*44\|min-width.*44" --include="*.css" 2>/dev/null | head -10
```

**Loading States:**
```bash
grep -r "Skeleton\|Loader\|Spinner\|isLoading\|isSubmitting" --include="*.tsx" 2>/dev/null | head -20
grep -r "Suspense\|lazy(\|ErrorBoundary" --include="*.tsx" 2>/dev/null | head -10
```

**Error Handling:**
```bash
grep -r "Error\|error\|Toast\|Alert\|validation" --include="*.tsx" 2>/dev/null | head -20
find . -name "*404*" -o -name "*error*" 2>/dev/null | grep -v node_modules | head -10
```

**Empty States:**
```bash
grep -r "Empty\|NoData\|NoResults\|length === 0" --include="*.tsx" 2>/dev/null | head -15
grep -r "Onboarding\|GettingStarted\|Welcome" --include="*.tsx" 2>/dev/null | head -10
```

**Consistency:**
```bash
cat tailwind.config.js 2>/dev/null | head -50
grep -r "--.*color\|--.*spacing\|theme\." --include="*.css" --include="*.ts" 2>/dev/null | head -20
```

**Accessibility:**
```bash
grep -r "aria-\|role=\|tabIndex" --include="*.tsx" 2>/dev/null | head -20
grep -r "alt=\|aria-label" --include="*.tsx" 2>/dev/null | head -15
grep -r "prefers-reduced-motion" --include="*.css" 2>/dev/null | head -5
grep -r "jest-axe\|a11y" --include="*.test.*" 2>/dev/null | head -10
```

**Design System:**
```bash
grep -r "from '@mui\|from '@chakra\|from '@/components/ui" --include="*.tsx" 2>/dev/null | head -20
cat .storybook/main.js 2>/dev/null | head -20
find . -name "*.stories.*" 2>/dev/null | grep -v node_modules | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Responsive, Loading, Errors, Empty States, Consistency, Accessibility, Design System)
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
1. **Critical** - Must fix before production (accessibility, blocking UX issues)
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/ui-ux-review
```

## When to Use

- Before production releases
- When implementing UI/frontend features
- When adding forms or interactive components
- For responsive design implementations
- When updating design systems or components
- During accessibility improvements
- Before user testing sessions

## Integration with Other Commands

Consider running alongside:
- `/browser-compatibility-review` - For cross-browser support
- `/performance-review` - For loading performance
- `/seo-review` - For meta tags and structured data
- `/observability-check` - For error tracking
