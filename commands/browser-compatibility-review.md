---
description: Production readiness review for browser compatibility. Reviews cross-browser support, responsive design, progressive enhancement, polyfills, and graceful degradation before production release.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Browser Compatibility Review Command

Run a comprehensive production readiness review focused on Browser Compatibility.

## Purpose

Review code before production release to ensure:
- Cross-browser support (Chrome, Firefox, Safari, Edge)
- Responsive design for all screen sizes
- Progressive enhancement for core functionality
- Polyfills and fallbacks for older browsers
- Browser-specific quirks are handled
- Testing coverage across target browsers

## Workflow

### 1. Load the Browser Compatibility Review Skill

Read the skill definition to get the full review checklist and patterns:

```
Read: skills/browser-compatibility-review/SKILL.md
```

### 2. Detect Project Stack & Build Configuration

Identify the frontend technology stack and build tools:
```bash
ls package.json 2>/dev/null
grep -r "react\|vue\|angular\|svelte\|next\|nuxt" --include="package.json" 2>/dev/null | head -5
grep -r "webpack\|vite\|esbuild\|rollup\|parcel" --include="package.json" 2>/dev/null | head -5
cat .browserslistrc 2>/dev/null || grep "browserslist" package.json 2>/dev/null | head -10
```

### 3. Run Browser Compatibility Checks

Execute all checks in parallel:

**Browser Support:**
```bash
cat .browserslistrc 2>/dev/null
grep -A 10 "browserslist" package.json 2>/dev/null
grep -r "browser.*support\|supported.*browser" --include="*.md" 2>/dev/null | head -10
```

**CSS Compatibility:**
```bash
find . -name "*.css" -o -name "*.scss" 2>/dev/null | grep -v node_modules | head -20
grep -r "autoprefixer\|postcss-preset-env" --include="package.json" --include="*.config.js" 2>/dev/null | head -5
grep -r "display: grid\|gap:\|aspect-ratio" --include="*.css" --include="*.scss" 2>/dev/null | head -15
```

**JavaScript Compatibility:**
```bash
cat babel.config.js 2>/dev/null || cat .babelrc 2>/dev/null || echo "No Babel config"
grep -r "core-js\|polyfill\|regenerator" --include="package.json" 2>/dev/null | head -5
grep "target" tsconfig.json 2>/dev/null | head -5
```

**Responsive Design:**
```bash
grep -r "viewport" --include="*.html" --include="*.tsx" 2>/dev/null | head -10
grep -r "@media\|sm:\|md:\|lg:" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20
```

**Progressive Enhancement:**
```bash
grep -r "<noscript\|@supports\|Modernizr" --include="*.html" --include="*.tsx" --include="*.css" 2>/dev/null | head -10
grep -r "action=\|method=" --include="*.html" --include="*.tsx" 2>/dev/null | head -10
```

**Browser Quirks:**
```bash
grep -r "100vh\|safe-area\|-webkit-fill-available" --include="*.css" --include="*.scss" 2>/dev/null | head -10
grep -r "webkit\|safari\|ios" --include="*.css" 2>/dev/null | head -10
```

**Testing:**
```bash
grep -r "playwright\|cypress\|browserstack" --include="package.json" 2>/dev/null | head -5
cat playwright.config.ts 2>/dev/null | head -30
grep -r "playwright test\|cypress run" .github 2>/dev/null | head -10
```

### 4. Analyze and Score

Based on the skill checklist:
- Score each category (Browser Support, CSS, JS, Responsive, Progressive Enhancement, Quirks, Testing)
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
1. **Critical** - Must fix before production (will break for users)
2. **High** - Should fix before or immediately after release
3. **Medium** - Should add within first week
4. **Low** - Nice to have

## Usage

```
/browser-compatibility-review
```

## When to Use

- Before production releases
- When implementing UI/frontend features
- When using modern CSS features (Grid, Flexbox gap)
- When using modern JavaScript APIs
- For mobile/responsive implementations
- When adding support for new browsers
- During accessibility improvements

## Integration with Other Commands

Consider running alongside:
- `/accessibility-review` - For WCAG compliance
- `/performance-review` - For loading performance
- `/i18n-l10n-review` - For international compatibility
- `/observability-check` - For error tracking across browsers
