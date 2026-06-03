# ui-ux-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for ui-ux-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's technology stack and UI patterns:

```bash
# Detect frontend framework
grep -r "react\|vue\|angular\|svelte\|next\|nuxt\|sveltekit" --include="package.json" 2>/dev/null | head -5

# Detect component libraries
grep -r "@mui\|@chakra\|antd\|@ant-design\|@radix\|shadcn\|@headlessui\|mantine" --include="package.json" 2>/dev/null | head -5

# Detect CSS frameworks
grep -r "tailwind\|bootstrap\|@emotion\|styled-components\|css-modules\|sass\|scss" --include="package.json" 2>/dev/null | head -5

# Detect accessibility tools
grep -r "axe-core\|jest-axe\|eslint-plugin-jsx-a11y\|@testing-library\|cypress-axe\|pa11y" --include="package.json" 2>/dev/null | head -5

# Detect UI testing tools
grep -r "storybook\|chromatic\|percy" --include="package.json" 2>/dev/null | head -5
```

### Phase 2: UI/UX Checklist

Run all checks and compile results:

#### 1. Responsive Design

Layout must adapt to all screen sizes and devices.

| Check | Pattern | Status |
|-------|---------|--------|
| Viewport meta tag | `<meta name="viewport">` present | Required |
| Mobile-first CSS | Base styles for mobile, media queries for larger | Recommended |
| Breakpoints defined | Consistent breakpoint system (sm/md/lg/xl/2xl) | Required |
| Fluid typography | Responsive text sizing (clamp, vw, rem) | Recommended |
| Flexible images | max-width: 100%, responsive images | Required |
| Touch targets | Minimum 44x44px for touch | Required |
| No horizontal scroll | Overflow-x handled on all containers | Required |
| Responsive tables | Horizontal scroll or card layout on mobile | Required |
| Safe area insets | env(safe-area-inset-*) for notched devices | Conditional |

**Search Patterns:**
```bash
# Find viewport meta tag
grep -r "viewport" --include="*.html" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find media queries and breakpoints
grep -r "@media\|sm:\|md:\|lg:\|xl:\|2xl:\|breakpoint" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find fluid typography
grep -r "clamp(\|calc(.*rem\|calc(.*vw" --include="*.css" --include="*.scss" 2>/dev/null | head -10

# Check for touch target sizes
grep -r "min-height.*44\|min-width.*44\|padding.*touch\|tap-highlight" --include="*.css" --include="*.scss" 2>/dev/null | head -10

# Find responsive images
grep -r "srcset\|sizes=\|picture\|object-fit" --include="*.html" --include="*.tsx" 2>/dev/null | head -10

# Check for safe area insets
grep -r "safe-area-inset\|env(safe-area" --include="*.css" --include="*.scss" 2>/dev/null | head -5
```

#### 2. Loading States

Users must receive feedback during async operations.

| Check | Pattern | Status |
|-------|---------|--------|
| Skeleton loaders | Skeleton/shimmer for content loading | Required |
| Spinner/progress | Loading indicators for actions | Required |
| Button loading state | Disabled + spinner during submission | Required |
| Page loading | Initial page load feedback | Required |
| Image loading | Placeholder or blur-up for images | Recommended |
| Lazy loading feedback | IntersectionObserver with fallback | Recommended |
| Optimistic updates | Immediate feedback before server response | Recommended |
| Loading boundaries | Error boundaries for loading failures | Required |

**Search Patterns:**
```bash
# Find skeleton/loader components
grep -r "Skeleton\|Loader\|Spinner\|Progress\|Loading\|loading" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find button loading states
grep -r "isLoading\|isSubmitting\|loading\|disabled.*loading\|aria-busy" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find suspense/lazy loading
grep -r "Suspense\|lazy(\|React\.lazy\|defineAsyncComponent\|await.*import" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -15

# Find image loading patterns
grep -r "onLoad\|onError\|loading=\"lazy\"\|placeholder\|blur" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find error boundaries
grep -r "ErrorBoundary\|componentDidCatch\|getDerivedStateFromError" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10
```

#### 3. Error Handling UX

Errors must be communicated clearly and actionable.

| Check | Pattern | Status |
|-------|---------|--------|
| Inline validation | Real-time form field validation | Required |
| Error messages | User-friendly, actionable error text | Required |
| Error boundaries | Graceful UI failure handling | Required |
| Toast notifications | Non-blocking error feedback | Recommended |
| Error pages | 404, 500, generic error pages | Required |
| Retry mechanisms | User can retry failed operations | Required |
| Form error summary | Summary of all form errors | Recommended |
| Network error handling | Offline/timeout feedback | Required |

**Search Patterns:**
```bash
# Find error components and patterns
grep -r "Error\|error\|ErrorMessage\|Alert\|Toast\|Notification" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find form validation
grep -r "onError\|setError\|errors\|validation\|isValid\|validate" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find error pages
find . -name "*404*" -o -name "*error*" -o -name "*Error*" 2>/dev/null | grep -v node_modules | head -10

# Find toast/notification libraries
grep -r "toast\|notification\|snackbar\|alert\|react-hot-toast\|sonner" --include="package.json" 2>/dev/null | head -5

# Find network error handling
grep -r "offline\|network\|timeout\|retry\|catch.*error" --include="*.ts" --include="*.tsx" 2>/dev/null | head -15
```

#### 4. Empty States

Empty content must provide guidance to users.

| Check | Pattern | Status |
|-------|---------|--------|
| Empty list state | Message + CTA for empty lists | Required |
| No results state | Message + suggestions for no search results | Required |
| Empty dashboard | Onboarding or getting started guide | Required |
| Empty inbox/messages | Friendly message + action suggestion | Required |
| No data state | Clear explanation when data unavailable | Required |
| First-run experience | Onboarding for new users | Recommended |
| Zero state illustrations | Visual elements for empty states | Recommended |

**Search Patterns:**
```bash
# Find empty state components
grep -r "Empty\|empty\|NoData\|no-data\|NoResults\|no-results\|zero.*state" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -15

# Find onboarding components
grep -r "Onboarding\|GettingStarted\|Welcome\|FirstRun\|Tutorial" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find conditional rendering for empty states
grep -r "length === 0\|\.length < 1\|!data\|isEmpty" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15
```

#### 5. Visual Consistency

UI elements must be consistent across the application.

| Check | Pattern | Status |
|-------|---------|--------|
| Design tokens | CSS variables or theme tokens for colors, spacing | Required |
| Typography scale | Consistent font sizes and line heights | Required |
| Spacing system | Consistent margin/padding (4px or 8px grid) | Required |
| Color palette | Defined primary, secondary, semantic colors | Required |
| Component variants | Consistent button, input, card styles | Required |
| Icon consistency | Single icon library, consistent sizing | Required |
| Border radius | Consistent rounded corners | Recommended |
| Shadow/elevation | Consistent depth system | Recommended |

**Search Patterns:**
```bash
# Find design tokens/theme
grep -r "--.*color\|--.*spacing\|--.*font\|--.*radius\|theme\.colors\|theme\.spacing" --include="*.css" --include="*.scss" --include="*.ts" 2>/dev/null | head -20

# Find tailwind/theme config
cat tailwind.config.js 2>/dev/null | head -50
cat tailwind.config.ts 2>/dev/null | head -50

# Find CSS variables
grep -r ":root\|--[a-z]" --include="*.css" --include="*.scss" 2>/dev/null | head -15

# Find icon library usage
grep -r "lucide\|react-icons\|@heroicons\|feather\|font-awesome\|fortawesome" --include="package.json" 2>/dev/null | head -5

# Find spacing patterns
grep -r "p-\|m-\|padding:\|margin:\|gap-" --include="*.tsx" --include="*.css" 2>/dev/null | head -15
```

#### 6. Accessibility (WCAG 2.1 AA)

Application must be accessible to all users.

| Check | Pattern | Status |
|-------|---------|--------|
| Semantic HTML | Proper heading hierarchy, landmarks | Required |
| ARIA labels | aria-label, aria-labelledby for interactive elements | Required |
| Keyboard navigation | All interactive elements focusable and operable | Required |
| Focus management | Visible focus indicators, focus trapping | Required |
| Screen reader support | alt text, aria-live, sr-only classes | Required |
| Color contrast | 4.5:1 for text, 3:1 for large text | Required |
| Focus visible | Clear focus indicators (not just color) | Required |
| Skip links | Skip to main content link | Recommended |
| Form labels | Associated labels for all inputs | Required |
| Motion preferences | Respects prefers-reduced-motion | Required |

**Search Patterns:**
```bash
# Find ARIA usage
grep -r "aria-\|role=\|tabIndex\|tabindex" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find alt text on images
grep -r "<img\|Image.*alt\|img.*alt" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find form labels
grep -r "<label\|htmlFor\|aria-label.*input\|Label" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find focus management
grep -r "focus\|onFocus\|onBlur\|autoFocus\|ref.*focus" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Find skip links
grep -r "skip\|skip-link\|skip.*content\|main.*content" --include="*.tsx" --include="*.html" 2>/dev/null | head -10

# Find reduced motion
grep -r "prefers-reduced-motion\|reduced.*motion" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -10

# Find accessibility testing
grep -r "jest-axe\|axe\|a11y\|accessibility" --include="*.test.*" --include="*.spec.*" 2>/dev/null | head -10
```

#### 7. Design System Compliance

Components must follow design system patterns.

| Check | Pattern | Status |
|-------|---------|--------|
| Component library usage | Consistent use of chosen library (MUI, Chakra, etc.) | Required |
| Custom component documentation | Documented patterns for custom components | Recommended |
| Token usage | Colors, spacing from design tokens | Required |
| Component composition | Proper composition over customization | Recommended |
| Theme configuration | Proper theme setup and customization | Required |
| Storybook documentation | Components documented in Storybook | Recommended |
| Visual regression tests | Chromatic/Percy for UI consistency | Recommended |

**Search Patterns:**
```bash
# Find component library imports
grep -r "from '@mui\|from '@chakra\|from 'antd\|from '@radix\|from '@/components/ui" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20

# Find theme configuration
grep -r "ThemeProvider\|createTheme\|extendTheme\|theme.*config" --include="*.tsx" --include="*.ts" 2>/dev/null | head -15

# Find Storybook
cat .storybook/main.js 2>/dev/null || cat .storybook/main.ts 2>/dev/null | head -20
find . -name "*.stories.*" 2>/dev/null | grep -v node_modules | head -10

# Find design token files
find . -name "tokens.*" -o -name "theme.*" -o -name "variables.*" 2>/dev/null | grep -v node_modules | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific UI/UX gap
2. **Why it matters**: Impact on user experience
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         UI/UX PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Framework: [detected framework]
Component Library: [detected library]
CSS Framework: [detected CSS framework]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

RESPONSIVE DESIGN
  [PASS] Viewport meta tag present
  [PASS] Breakpoints defined
  [WARN] Fluid typography not implemented
  [PASS] Touch targets meet 44px minimum
  [FAIL] No safe area insets for notched devices
  [PASS] No horizontal scroll

LOADING STATES
  [PASS] Skeleton loaders present
  [FAIL] No button loading states
  [WARN] No image loading placeholders
  [PASS] Error boundary implemented
  [FAIL] No optimistic updates

ERROR HANDLING UX
  [PASS] Inline form validation
  [WARN] Error messages could be more actionable
  [PASS] Toast notifications configured
  [PASS] 404 and error pages present
  [FAIL] No retry mechanism for failed requests

EMPTY STATES
  [PASS] Empty list states defined
  [FAIL] No "no results" state for search
  [WARN] No first-run onboarding
  [PASS] Empty dashboard guidance

CONSISTENCY
  [PASS] Design tokens defined
  [PASS] Typography scale consistent
  [PASS] Spacing system follows 8px grid
  [WARN] Inconsistent border radius
  [PASS] Single icon library used

ACCESSIBILITY
  [PASS] Semantic HTML structure
  [FAIL] Missing ARIA labels on icon buttons
  [PASS] Keyboard navigation works
  [FAIL] Focus indicators too subtle
  [PASS] Color contrast meets WCAG AA
  [FAIL] No prefers-reduced-motion support

DESIGN SYSTEM
  [PASS] Component library used consistently
  [PASS] Theme configured properly
  [WARN] No Storybook documentation
  [N/A]  Visual regression tests (no Chromatic)

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Missing ARIA Labels on Icon Buttons
  Impact: Screen reader users cannot identify button purpose
  Fix: Add aria-label to all icon-only buttons
  File: src/components/IconButton.tsx

  // BEFORE (inaccessible):
  <button onClick={handleClick}>
    <TrashIcon />
  </button>

  // AFTER (accessible):
  <button
    onClick={handleClick}
    aria-label="Delete item"
    title="Delete item"
  >
    <TrashIcon aria-hidden="true" />
  </button>

[CRITICAL] No prefers-reduced-motion Support
  Impact: Motion can cause discomfort for vestibular disorders
  Fix: Wrap animations in reduced-motion media query
  File: src/styles/animations.css

  /* BEFORE (always animates): */
  .fade-in {
    animation: fadeIn 0.3s ease-in;
  }

  /* AFTER (respects preferences): */
  .fade-in {
    animation: fadeIn 0.3s ease-in;
  }

  @media (prefers-reduced-motion: reduce) {
    .fade-in {
      animation: none;
      opacity: 1;
    }
  }

[HIGH] No Button Loading States
  Impact: Users may click multiple times, causing duplicate actions
  Fix: Add loading state with disabled and spinner
  File: src/components/Button.tsx

  // BEFORE (no feedback):
  <button onClick={handleSubmit}>
    Submit
  </button>

  // AFTER (with loading state):
  <button
    onClick={handleSubmit}
    disabled={isLoading}
    aria-busy={isLoading}
  >
    {isLoading ? (
      <>
        <Spinner size="sm" aria-hidden="true" />
        <span className="sr-only">Loading...</span>
        Submitting...
      </>
    ) : (
      'Submit'
    )}
  </button>

[HIGH] No Search "No Results" State
  Impact: Users don't know if search completed or found nothing
  Fix: Add empty state for search results
  File: src/components/SearchResults.tsx

  // Add after search results check:
  {searchResults.length === 0 && searchQuery && !isSearching ? (
    <div className="empty-state">
      <SearchIcon className="empty-state-icon" aria-hidden="true" />
      <h3>No results found</h3>
      <p>We couldn't find anything matching "{searchQuery}"</p>
      <p>Try:</p>
      <ul>
        <li>Checking your spelling</li>
        <li>Using fewer keywords</li>
        <li>Searching for something more general</li>
      </ul>
    </div>
  ) : (
    <ResultsList results={searchResults} />
  )}

[HIGH] Focus Indicators Too Subtle
  Impact: Keyboard users cannot easily track focus position
  Fix: Add visible focus indicators
  File: src/styles/focus.css

  /* Create visible focus styles */
  :focus-visible {
    outline: 2px solid var(--color-primary);
    outline-offset: 2px;
    border-radius: 4px;
  }

  /* For buttons and interactive elements */
  button:focus-visible,
  a:focus-visible,
  input:focus-visible,
  select:focus-visible,
  textarea:focus-visible {
    outline: 2px solid var(--color-primary);
    outline-offset: 2px;
  }

  /* Remove default outline when using focus-visible */
  :focus:not(:focus-visible) {
    outline: none;
  }

[MEDIUM] No Retry Mechanism for Failed Requests
  Impact: Users must refresh page when requests fail
  Fix: Add retry button for failed operations
  File: src/components/RetryableContent.tsx

  function RetryableContent({ data, error, isLoading, retry }) {
    if (isLoading) return <Skeleton />;
    if (error) {
      return (
        <div className="error-state" role="alert">
          <ExclamationIcon aria-hidden="true" />
          <p>Failed to load content</p>
          <button onClick={retry} className="retry-button">
            <RefreshIcon aria-hidden="true" />
            Try again
          </button>
        </div>
      );
    }
    return <Content data={data} />;
  }

[MEDIUM] No Safe Area Insets for Notched Devices
  Impact: Content may be hidden behind notch/home indicator
  Fix: Add safe area insets
  File: src/styles/layout.css

  /* Safe area insets for iOS */
  .app-container {
    padding-top: env(safe-area-inset-top);
    padding-bottom: env(safe-area-inset-bottom);
    padding-left: env(safe-area-inset-left);
    padding-right: env(safe-area-inset-right);
  }

  /* Fixed bottom elements */
  .bottom-bar {
    padding-bottom: calc(16px + env(safe-area-inset-bottom));
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add ARIA labels to all icon-only buttons
2. [CRITICAL] Implement prefers-reduced-motion support
3. [HIGH] Add loading states to all async buttons
4. [HIGH] Create "no results" empty state for search
5. [HIGH] Improve focus indicator visibility
6. [MEDIUM] Add retry mechanism for failed requests
7. [MEDIUM] Add safe area insets for notched devices

After Production:
1. Set up Storybook for component documentation
2. Add visual regression testing (Chromatic/Percy)
3. Implement first-run onboarding experience
4. Add image loading placeholders/blur-up
5. Create comprehensive error message guidelines
6. Add optimistic updates for better perceived performance

═══════════════════════════════════════════════════════════════
```

---

