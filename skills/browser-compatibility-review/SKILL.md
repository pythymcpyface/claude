---
name: browser-compatibility-review
description: Production readiness review for Browser Compatibility. Reviews cross-browser support, responsive design, progressive enhancement, polyfills, and graceful degradation. Use PROACTIVELY before production releases, when implementing UI features, or ensuring broad device coverage.
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

### Phase 1: Stack Detection

Detect the project's technology stack and browser compatibility patterns:

```bash
# Detect frontend framework
grep -r "react\|vue\|angular\|svelte\|next\|nuxt\|sveltekit" --include="package.json" 2>/dev/null | head -5

# Detect CSS frameworks/preprocessors
grep -r "tailwind\|bootstrap\|sass\|scss\|less\|styled-components\|emotion" --include="package.json" 2>/dev/null | head -5

# Detect build tools
grep -r "webpack\|vite\|esbuild\|rollup\|parcel" --include="package.json" 2>/dev/null | head -5

# Detect browser testing tools
grep -r "browserstack\|sauce.*labs\|playwright\|cypress\|puppeteer\|selenium" --include="package.json" 2>/dev/null | head -5

# Detect browserslist configuration
cat .browserslistrc 2>/dev/null || grep "browserslist" package.json 2>/dev/null | head -10

# Detect polyfills
grep -r "core-js\|polyfill\|regenerator-runtime\|whatwg-fetch" --include="package.json" 2>/dev/null | head -5
```

### Phase 2: Browser Compatibility Checklist

Run all checks and compile results:

#### 1. Browser Support Matrix

Define and document supported browsers.

| Check | Pattern | Status |
|-------|---------|--------|
| Browserslist config | `.browserslistrc` or package.json config | Required |
| Target browsers documented | Supported browsers listed in README | Required |
| Version ranges specified | Minimum browser versions defined | Required |
| Market coverage | Targets >95% of user base | Required |
| Enterprise browsers | IE11/legacy Edge if enterprise users | Conditional |
| Mobile browsers | iOS Safari, Chrome Android specified | Required |
| Testing matrix | Actual testing on target browsers | Required |

**Search Patterns:**
```bash
# Find browserslist configuration
cat .browserslistrc 2>/dev/null
grep -A 10 "browserslist" package.json 2>/dev/null

# Find browser support documentation
grep -r "browser.*support\|supported.*browser\|compatibility" --include="*.md" 2>/dev/null | head -10

# Find target configuration
grep -r "target\|esversion\|es.*target" --include="*.json" --include="*.js" --include="*.ts" 2>/dev/null | head -10
```

#### 2. CSS Compatibility

CSS features must work across supported browsers.

| Check | Pattern | Status |
|-------|---------|--------|
| Vendor prefixes | Auto-prefixer configured | Required |
| CSS Grid | Fallbacks for older browsers | Conditional |
| Flexbox | Proper fallbacks or limited support | Recommended |
| CSS Custom Properties | Fallback values or polyfill | Conditional |
| Gap property | Flex gap fallbacks | Conditional |
| Aspect-ratio | Fallback implementations | Conditional |
| Logical properties | Physical property fallbacks for RTL | Conditional |
| Container queries | Fallback for unsupported browsers | Conditional |

**Search Patterns:**
```bash
# Find CSS files
find . -name "*.css" -o -name "*.scss" -o -name "*.less" 2>/dev/null | grep -v node_modules | head -20

# Check for modern CSS features
grep -r "display: grid\|grid-template\|gap:\|aspect-ratio\|container-type" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Check for CSS custom properties
grep -r "var(--\|--[a-z]" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -15

# Check for vendor prefixes (should be auto-generated)
grep -r "-webkit-\|-moz-\|-ms-\|-o-" --include="*.css" 2>/dev/null | head -15

# Check for PostCSS/Autoprefixer
grep -r "autoprefixer\|postcss-preset-env" --include="package.json" --include="*.config.js" 2>/dev/null | head -5
```

#### 3. JavaScript Compatibility

JavaScript features must work across supported browsers.

| Check | Pattern | Status |
|-------|---------|--------|
| Transpilation | Babel/TypeScript configured | Required |
| ES6+ features | Transpiled or polyfilled | Required |
| Async/await | Regenerator runtime included | Required |
| Optional chaining | Transpiled for older browsers | Conditional |
| Nullish coalescing | Transpiled for older browsers | Conditional |
| Promises | Polyfill for older browsers | Conditional |
| Fetch API | whatwg-fetch polyfill | Conditional |
| Object spread | Transpiled correctly | Required |

**Search Patterns:**
```bash
# Find modern JS syntax usage
grep -r "=>\|async\|await\|?.\|??\|..." --include="*.js" --include="*.ts" --include="*.tsx" 2>/dev/null | head -20

# Check for Babel configuration
cat babel.config.js 2>/dev/null || cat .babelrc 2>/dev/null || grep "babel" package.json 2>/dev/null | head -10

# Check for core-js/polyfills
grep -r "core-js\|polyfill\|regenerator" --include="*.js" --include="*.ts" 2>/dev/null | head -10

# Check TypeScript target
grep -r "target\|lib" tsconfig.json 2>/dev/null | head -10

# Check for modern APIs without polyfills
grep -r "fetch(\|Promise\|Object\.entries\|Array\.includes\|String\.includes" --include="*.js" --include="*.ts" 2>/dev/null | head -15
```

#### 4. Responsive Design

Layout must adapt to all screen sizes.

| Check | Pattern | Status |
|-------|---------|--------|
| Viewport meta tag | `<meta name="viewport">` present | Required |
| Mobile-first CSS | Base styles for mobile, media queries for larger | Recommended |
| Breakpoints defined | Consistent breakpoint system | Required |
| Fluid typography | Responsive text sizing | Recommended |
| Flexible images | max-width: 100% on images | Required |
| Touch targets | Minimum 44x44px for touch | Required |
| No horizontal scroll | Overflow-x handled | Required |
| Media queries | Proper responsive breakpoints | Required |

**Search Patterns:**
```bash
# Find viewport meta tag
grep -r "viewport" --include="*.html" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find media queries
grep -r "@media\|@screen\|breakpoint" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find responsive utilities
grep -r "sm:\|md:\|lg:\|xl:\|@media" --include="*.tsx" --include="*.jsx" --include="*.css" 2>/dev/null | head -20

# Check for fluid typography
grep -r "clamp(\|vw\|vh" --include="*.css" --include="*.scss" 2>/dev/null | head -10

# Check for touch target sizes
grep -r "min-height.*44\|min-width.*44\|padding.*touch" --include="*.css" --include="*.scss" 2>/dev/null | head -10
```

#### 5. Progressive Enhancement

Core functionality works without modern features.

| Check | Pattern | Status |
|-------|---------|--------|
| Feature detection | Modernizr or manual checks | Required |
| JavaScript fallbacks | Core content accessible without JS | Required |
| CSS fallbacks | Basic styles without Grid/Flexbox | Recommended |
| Form validation | Server-side validation as fallback | Required |
| Images | Alt text and fallback images | Required |
| Fonts | System font fallbacks | Required |
| Navigation | Works without JavaScript | Required |
| Forms | Submit without JavaScript | Required |

**Search Patterns:**
```bash
# Find feature detection
grep -r "Modernizr\|'loading' in\|'IntersectionObserver' in\|typeof.*undefined" --include="*.js" --include="*.ts" 2>/dev/null | head -15

# Find noscript fallbacks
grep -r "<noscript\|noscript>" --include="*.html" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find CSS fallbacks
grep -r "@supports\|fallback" --include="*.css" --include="*.scss" 2>/dev/null | head -10

# Check for form fallbacks
grep -r "action=\|method=\|type=\"submit\"" --include="*.html" --include="*.tsx" 2>/dev/null | head -15

# Check for font fallbacks
grep -r "font-family" --include="*.css" --include="*.scss" 2>/dev/null | head -15
```

#### 6. Browser-Specific Quirks

Handle known browser inconsistencies.

| Check | Pattern | Status |
|-------|---------|--------|
| Safari flexbox | Flexbox bugs addressed | Required |
| iOS Safari | 100vh, safe-area-inset handled | Required |
| iOS date inputs | Date picker compatibility | Conditional |
| Samsung Internet | Known quirks handled | Recommended |
| IE11 | Conditional if supported | Conditional |
| Edge legacy | -ms- prefixes if needed | Conditional |
| Firefox forms | Form styling quirks | Recommended |
| Chrome scroll | Smooth scroll behavior | Recommended |

**Search Patterns:**
```bash
# Find Safari-specific fixes
grep -r "webkit\|safari\|ios" --include="*.css" --include="*.scss" --include="*.js" 2>/dev/null | head -15

# Find iOS-specific fixes
grep -r "100vh\|safe-area\|-webkit-fill-available\|-webkit-touch-callout" --include="*.css" --include="*.scss" 2>/dev/null | head -15

# Find IE-specific fixes
grep -r "ie\|ms-\|trident" --include="*.css" --include="*.scss" --include="*.js" 2>/dev/null | head -10

# Find date input handling
grep -r "type=\"date\"\|type=\"time\"\|datetime-local" --include="*.html" --include="*.tsx" 2>/dev/null | head -10
```

#### 7. Testing Coverage

Verify compatibility through testing.

| Check | Pattern | Status |
|-------|---------|--------|
| BrowserStack/Sauce Labs | Cross-browser testing service | Recommended |
| E2E tests | Playwright/Cypress on multiple browsers | Required |
| Visual regression | Percy/Chromatic for UI consistency | Recommended |
| Device testing | Real device testing | Recommended |
| Emulator testing | iOS Simulator, Android Emulator | Required |
| Automated CI | Browser tests in CI pipeline | Required |
| Manual testing checklist | Documented testing process | Required |

**Search Patterns:**
```bash
# Find browser testing configuration
grep -r "browserstack\|saucelabs\|playwright\|cypress" --include="package.json" 2>/dev/null | head -10

# Find test configurations
cat playwright.config.ts 2>/dev/null | head -30
cat cypress.config.ts 2>/dev/null | head -30

# Find CI browser test steps
grep -r "playwright test\|cypress run\|browserstack" .github .gitlab-ci.yml Jenkinsfile 2>/dev/null | head -10

# Find visual regression tools
grep -r "percy\|chromatic\|applitools\|screener" --include="package.json" 2>/dev/null | head -5
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific browser compatibility gap
2. **Why it matters**: User experience and market reach impact
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      BROWSER COMPATIBILITY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected frontend stack]
Build Tool: [Vite/Webpack/etc]
Target Browsers: [from browserslist]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

BROWSER SUPPORT MATRIX
  [PASS] Browserslist configured
  [PASS] Target browsers documented
  [WARN] No IE11 fallbacks (if enterprise users)
  [PASS] Mobile browsers specified
  [FAIL] No actual testing on Safari

CSS COMPATIBILITY
  [PASS] Autoprefixer configured
  [WARN] CSS Grid without fallbacks
  [PASS] CSS custom properties with fallbacks
  [FAIL] Gap property in Flexbox (no fallback)
  [PASS] Vendor prefixes auto-generated

JAVASCRIPT COMPATIBILITY
  [PASS] Babel transpilation configured
  [PASS] ES6+ features transpiled
  [PASS] Async/await with regenerator
  [WARN] Optional chaining (no IE11 support)
  [FAIL] Fetch API without polyfill

RESPONSIVE DESIGN
  [PASS] Viewport meta tag present
  [PASS] Mobile-first CSS approach
  [PASS] Consistent breakpoints
  [PASS] Fluid typography
  [WARN] Touch targets under 44px
  [PASS] No horizontal scroll

PROGRESSIVE ENHANCEMENT
  [FAIL] No feature detection
  [WARN] No noscript fallbacks
  [PASS] Form server-side validation
  [PASS] Image alt text present
  [PASS] Font fallbacks defined
  [FAIL] Navigation requires JavaScript

BROWSER QUIRKS
  [WARN] iOS 100vh issue not addressed
  [PASS] Safari flexbox fixes present
  [FAIL] iOS date inputs not handled
  [N/A]  IE11 not supported

TESTING COVERAGE
  [PASS] Playwright configured
  [PASS] Multi-browser E2E tests
  [WARN] No visual regression testing
  [FAIL] No real device testing
  [PASS] CI browser tests enabled

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Fetch API Without Polyfill
  Impact: Breaks in IE11 and older browsers
  Fix: Add whatwg-fetch polyfill
  File: src/polyfills.ts (create)

  // For babel-polyfill or core-js approach:
  import 'whatwg-fetch';

  // Or in package.json:
  {
    "browserslist": {
      "production": [
        ">0.2%",
        "not dead",
        "not op_mini all"
      ]
    }
  }

  // In babel.config.js:
  module.exports = {
    presets: [
      ['@babel/preset-env', {
        useBuiltIns: 'usage',
        corejs: 3
      }]
    ]
  };

[CRITICAL] Navigation Requires JavaScript
  Impact: Users without JS cannot navigate the site
  Fix: Implement progressive enhancement for navigation
  File: src/components/Navigation.tsx

  // BEFORE (JS-only navigation):
  function Navigation() {
    return (
      <nav>
        <button onClick={() => navigate('/home')}>Home</button>
        <button onClick={() => navigate('/about')}>About</button>
      </nav>
    );
  }

  // AFTER (progressive enhancement):
  function Navigation() {
    return (
      <nav>
        <a href="/home" onClick={(e) => { e.preventDefault(); navigate('/home'); }}>
          Home
        </a>
        <a href="/about" onClick={(e) => { e.preventDefault(); navigate('/about'); }}>
          About
        </a>
      </nav>
    );
  }

  // Add noscript fallback in HTML:
  <noscript>
    <style>
      .js-nav { display: none !important; }
      .no-js-nav { display: block !important; }
    </style>
  </noscript>

[HIGH] CSS Grid Without Fallbacks
  Impact: Layout breaks in older browsers
  Fix: Add @supports fallbacks
  File: src/styles/layout.css

  /* BEFORE (Grid only): */
  .grid-container {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
  }

  /* AFTER (with fallbacks): */
  .grid-container {
    /* Flexbox fallback */
    display: flex;
    flex-wrap: wrap;
    margin: -10px;
  }

  .grid-container > * {
    flex: 1 1 300px;
    margin: 10px;
  }

  /* Modern Grid for supporting browsers */
  @supports (display: grid) {
    .grid-container {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      margin: 0;
    }

    .grid-container > * {
      margin: 0;
    }
  }

[HIGH] iOS 100vh Issue Not Addressed
  Impact: Mobile Safari address bar causes layout issues
  Fix: Use -webkit-fill-available or CSS environment variables
  File: src/styles/layout.css

  /* BEFORE (problematic): */
  .full-height {
    height: 100vh;
  }

  /* AFTER (iOS-safe): */
  .full-height {
    height: 100vh;
    height: -webkit-fill-available;
    height: fill-available;
  }

  /* Or with CSS environment variables: */
  .full-height {
    min-height: 100vh;
    min-height: calc(100vh - env(safe-area-inset-top) - env(safe-area-inset-bottom));
  }

[HIGH] Gap Property in Flexbox Without Fallback
  Impact: Breaks in Safari <14.1, older browsers
  Fix: Use margins instead of gap for broader support
  File: src/styles/components.css

  /* BEFORE (gap property): */
  .flex-container {
    display: flex;
    gap: 20px;
  }

  /* AFTER (margin fallback): */
  .flex-container {
    display: flex;
    margin: -10px;
  }

  .flex-container > * {
    margin: 10px;
  }

  /* Or with @supports: */
  .flex-container {
    display: flex;
    margin: -10px;
  }

  .flex-container > * {
    margin: 10px;
  }

  @supports (gap: 10px) {
    .flex-container {
      gap: 20px;
      margin: 0;
    }

    .flex-container > * {
      margin: 0;
    }
  }

[MEDIUM] Touch Targets Under 44px
  Impact: Poor mobile usability, fails WCAG guidelines
  Fix: Increase touch target sizes
  File: src/styles/buttons.css

  /* BEFORE: */
  .button {
    padding: 8px 16px;
  }

  /* AFTER: */
  .button {
    padding: 12px 16px;
    min-height: 44px;
    min-width: 44px;
  }

  /* Or use pseudo-element for hit area: */
  .button {
    position: relative;
    padding: 8px 16px;
  }

  .button::before {
    content: '';
    position: absolute;
    top: -8px;
    left: -8px;
    right: -8px;
    bottom: -8px;
  }

[MEDIUM] No Feature Detection
  Impact: Features fail silently in unsupported browsers
  Fix: Add feature detection before using modern APIs
  File: src/utils/featureDetection.ts (create)

  // Feature detection utilities
  export const supports = {
    intersectionObserver: 'IntersectionObserver' in window,
    resizeObserver: 'ResizeObserver' in window,
    webp: document.createElement('canvas').toDataURL('image/webp').indexOf('data:image/webp') === 0,
    touch: 'ontouchstart' in window,
    serviceWorker: 'serviceWorker' in navigator,
    webGL: (() => {
      try {
        const canvas = document.createElement('canvas');
        return !!(canvas.getContext('webgl') || canvas.getContext('experimental-webgl'));
      } catch (e) {
        return false;
      }
    })(),
    localStorage: (() => {
      try {
        localStorage.setItem('test', 'test');
        localStorage.removeItem('test');
        return true;
      } catch (e) {
        return false;
      }
    })(),
  };

  // Usage:
  if (supports.intersectionObserver) {
    const observer = new IntersectionObserver(callback);
  } else {
    // Fallback: load all images immediately
    loadAllImages();
  }

[MEDIUM] iOS Date Inputs Not Handled
  Impact: Poor date picker experience on iOS
  Fix: Use format placeholder or custom date picker
  File: src/components/DateInput.tsx

  // BEFORE:
  <input type="date" />

  // AFTER (with placeholder for iOS):
  <input
    type="date"
    placeholder="YYYY-MM-DD"
    pattern="\d{4}-\d{2}-\d{2}"
  />

  // Or detect iOS and use text input:
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);

  <input
    type={isIOS ? 'text' : 'date'}
    placeholder="YYYY-MM-DD"
  />

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add fetch polyfill for older browsers
2. [CRITICAL] Implement progressive enhancement for navigation
3. [HIGH] Add CSS Grid fallbacks for older browsers
4. [HIGH] Fix iOS Safari 100vh issue
5. [HIGH] Add Flexbox gap fallbacks
6. [MEDIUM] Increase touch target sizes to 44px minimum
7. [MEDIUM] Add feature detection for modern APIs
8. [MEDIUM] Handle iOS date input quirks

After Production:
1. Set up BrowserStack for cross-browser testing
2. Add visual regression testing (Percy/Chromatic)
3. Test on real iOS and Android devices
4. Add IE11 support if enterprise users require it
5. Implement lazy loading with IntersectionObserver fallback
6. Add WebP image format with JPEG fallback
7. Set up automated browser compatibility monitoring

═══════════════════════════════════════════════════════════════
```

---

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

## Quick Reference: Implementation Patterns

### Browserslist Configuration

```json
// package.json
{
  "browserslist": {
    "production": [
      ">0.5%",
      "last 2 versions",
      "Firefox ESR",
      "not dead",
      "not IE 11"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

```
// .browserslistrc
> 0.5%
last 2 versions
Firefox ESR
not dead
not IE 11
iOS >= 13
Safari >= 13
```

### CSS Fallbacks

```css
/* Flexbox gap fallback */
.flex-with-gap {
  display: flex;
  margin: -10px;
}

.flex-with-gap > * {
  margin: 10px;
}

@supports (gap: 10px) {
  .flex-with-gap {
    gap: 20px;
    margin: 0;
  }

  .flex-with-gap > * {
    margin: 0;
  }
}

/* CSS Grid fallback */
.grid-layout {
  display: flex;
  flex-wrap: wrap;
}

.grid-layout > * {
  flex: 1 1 300px;
  margin: 10px;
}

@supports (display: grid) {
  .grid-layout {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
  }

  .grid-layout > * {
    margin: 0;
  }
}

/* CSS Custom Properties fallback */
:root {
  --primary-color: #007bff;
}

.button {
  /* Fallback first */
  background-color: #007bff;
  /* Then modern */
  background-color: var(--primary-color);
}
```

### JavaScript Polyfills

```typescript
// polyfills.ts
import 'core-js/stable';
import 'regenerator-runtime/runtime';

// Or selective polyfills:
import 'core-js/features/promise';
import 'core-js/features/array/includes';
import 'core-js/features/object/entries';
import 'whatwg-fetch';
import 'intersection-observer';

// Feature detection with fallback
async function loadPolyfills() {
  if (typeof window.IntersectionObserver === 'undefined') {
    await import('intersection-observer');
  }
}
```

### iOS Safari Fixes

```css
/* 100vh fix for iOS Safari */
.full-height {
  height: 100vh;
  height: -webkit-fill-available;
}

/* Safe area insets for notched devices */
.footer {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Prevent zoom on input focus (iOS) */
input[type="text"],
input[type="email"],
input[type="password"],
textarea,
select {
  font-size: 16px;
}

/* Disable callout on long press */
.no-callout {
  -webkit-touch-callout: none;
}

/* Smooth scroll with fallback */
.smooth-scroll {
  scroll-behavior: smooth;
}

@supports not (scroll-behavior: smooth) {
  .smooth-scroll {
    /* Fallback handled by JS */
  }
}
```

### Progressive Enhancement

```html
<!-- Noscript fallback -->
<noscript>
  <div class="noscript-warning">
    Please enable JavaScript for the best experience.
  </div>
  <style>
    .js-only { display: none !important; }
    .no-js { display: block !important; }
  </style>
</noscript>

<!-- Form with server-side fallback -->
<form action="/submit" method="POST">
  <input type="email" name="email" required>
  <button type="submit">Submit</button>
</form>

<!-- Image with fallback -->
<picture>
  <source srcset="image.webp" type="image/webp">
  <source srcset="image.jpg" type="image/jpeg">
  <img src="image.jpg" alt="Description" loading="lazy">
</picture>

<!-- Font fallbacks */
body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
               Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans',
               'Helvetica Neue', sans-serif;
}
```

### Feature Detection

```typescript
// Feature detection utilities
const features = {
  // Check for IntersectionObserver
  intersectionObserver: 'IntersectionObserver' in window &&
                        'IntersectionObserverEntry' in window &&
                        'intersectionRatio' in window.IntersectionObserverEntry.prototype,

  // Check for ResizeObserver
  resizeObserver: 'ResizeObserver' in window,

  // Check for smooth scroll
  smoothScroll: 'scrollBehavior' in document.documentElement.style,

  // Check for passive event listeners
  passiveEvents: (() => {
    let supportsPassive = false;
    try {
      const opts = Object.defineProperty({}, 'passive', {
        get() { supportsPassive = true; }
      });
      window.addEventListener('test', null, opts);
    } catch (e) {}
    return supportsPassive;
  })(),

  // Check for WebP support
  webp: document.createElement('canvas').toDataURL('image/webp').indexOf('data:image/webp') === 0,
};

// Usage with fallback
if (features.intersectionObserver) {
  const observer = new IntersectionObserver(callback, {
    rootMargin: '50px',
    threshold: 0.1
  });
  elements.forEach(el => observer.observe(el));
} else {
  // Fallback: load all images
  elements.forEach(el => loadImage(el));
}
```

### Responsive Touch Targets

```css
/* Minimum touch target size */
.button,
.link,
input,
select,
textarea {
  min-height: 44px;
  min-width: 44px;
}

/* Or use padding to achieve minimum */
.small-button {
  padding: 12px 16px; /* Ensures 44px height */
}

/* Touch target expansion via pseudo-element */
.icon-button {
  position: relative;
  width: 24px;
  height: 24px;
}

.icon-button::before {
  content: '';
  position: absolute;
  top: -10px;
  left: -10px;
  right: -10px;
  bottom: -10px;
}
```

---

## Integration with Other Reviews

This skill complements:
- `/accessibility-review` - For WCAG compliance and assistive technology
- `/performance-review` - For loading performance across devices
- `/i18n-l10n-review` - For international browser compatibility
- `/api-readiness-review` - For API client compatibility
