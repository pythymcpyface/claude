---
name: ui-ux-review
description: Production readiness review for UI/UX quality. Reviews responsive design, loading states, error messages, empty states, consistency, accessibility, and design system compliance. Use PROACTIVELY before production releases, when implementing UI features, or ensuring quality user experience.
tools: Read, Grep, Glob, Bash, AskUserQuestion
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

## Quick Reference: Implementation Patterns

### Responsive Design (Tailwind)

```tsx
// Mobile-first responsive component
function ResponsiveCard({ title, description }) {
  return (
    <div className="
      p-4 md:p-6 lg:p-8
      text-sm md:text-base lg:text-lg
      grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3
      gap-4 md:gap-6
    ">
      <h2 className="text-lg md:text-xl lg:text-2xl font-semibold">
        {title}
      </h2>
      <p className="text-gray-600">{description}</p>
    </div>
  );
}
```

### Loading States

```tsx
// Button with loading state
function SubmitButton({ isLoading, onClick }) {
  return (
    <button
      onClick={onClick}
      disabled={isLoading}
      aria-busy={isLoading}
      className="btn btn-primary"
    >
      {isLoading ? (
        <>
          <Spinner className="animate-spin mr-2" aria-hidden="true" />
          <span className="sr-only">Loading...</span>
          Submitting...
        </>
      ) : (
        'Submit'
      )}
    </button>
  );
}

// Skeleton loader
function ContentSkeleton() {
  return (
    <div className="animate-pulse space-y-4" aria-hidden="true">
      <div className="h-4 bg-gray-200 rounded w-3/4" />
      <div className="h-4 bg-gray-200 rounded w-1/2" />
      <div className="h-32 bg-gray-200 rounded" />
    </div>
  );
}
```

### Error Handling UX

```tsx
// Form field with inline validation
function FormField({ label, error, ...props }) {
  const id = useId();
  const errorId = `${id}-error`;

  return (
    <div className="form-field">
      <label htmlFor={id} className="block mb-1 font-medium">
        {label}
      </label>
      <input
        id={id}
        aria-invalid={!!error}
        aria-describedby={error ? errorId : undefined}
        className={cn(
          "w-full px-3 py-2 border rounded",
          error ? "border-red-500" : "border-gray-300"
        )}
        {...props}
      />
      {error && (
        <p id={errorId} className="mt-1 text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}

// Toast notification
function showErrorToast(message: string) {
  toast.error(message, {
    duration: 5000,
    action: {
      label: 'Dismiss',
      onClick: () => toast.dismiss()
    }
  });
}
```

### Empty States

```tsx
// Empty list state
function EmptyList({ onAdd }) {
  return (
    <div className="empty-state text-center py-12">
      <InboxIcon className="mx-auto h-12 w-12 text-gray-400" aria-hidden="true" />
      <h3 className="mt-4 text-lg font-medium text-gray-900">No items yet</h3>
      <p className="mt-2 text-gray-500">Get started by creating your first item.</p>
      <button
        onClick={onAdd}
        className="mt-4 btn btn-primary"
      >
        <PlusIcon className="mr-2 h-4 w-4" aria-hidden="true" />
        Add Item
      </button>
    </div>
  );
}

// No search results
function NoResults({ query, onClear }) {
  return (
    <div className="empty-state text-center py-12">
      <SearchIcon className="mx-auto h-12 w-12 text-gray-400" aria-hidden="true" />
      <h3 className="mt-4 text-lg font-medium text-gray-900">No results found</h3>
      <p className="mt-2 text-gray-500">
        We couldn't find anything matching "{query}"
      </p>
      <button
        onClick={onClear}
        className="mt-4 text-primary-600 hover:underline"
      >
        Clear search and try again
      </button>
    </div>
  );
}
```

### Accessibility

```tsx
// Accessible icon button
function IconButton({ icon: Icon, label, onClick }) {
  return (
    <button
      onClick={onClick}
      aria-label={label}
      className="p-2 rounded-full hover:bg-gray-100 focus-visible:ring-2 focus-visible:ring-primary-500"
    >
      <Icon className="h-5 w-5" aria-hidden="true" />
    </button>
  );
}

// Skip link
function SkipLink() {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary-600 focus:text-white focus:rounded"
    >
      Skip to main content
    </a>
  );
}

// Reduced motion support (CSS)
// In global CSS:
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### Focus Management

```css
/* Visible focus indicators */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
  border-radius: 4px;
}

/* High contrast focus for buttons */
button:focus-visible,
a:focus-visible {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.5);
}

/* Remove default when using focus-visible */
:focus:not(:focus-visible) {
  outline: none;
}
```

### Design Tokens

```css
/* CSS Custom Properties as design tokens */
:root {
  /* Colors */
  --color-primary-50: #eff6ff;
  --color-primary-500: #3b82f6;
  --color-primary-900: #1e3a8a;

  /* Spacing (8px grid) */
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */

  /* Typography */
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;

  /* Border radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

---

## Integration with Other Reviews

This skill complements:
- `/browser-compatibility-review` - For cross-browser UI support
- `/performance-review` - For loading performance
- `/seo-review` - For meta tags and structured data
- `/observability-check` - For error tracking and monitoring
