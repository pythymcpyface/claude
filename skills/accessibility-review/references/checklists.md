# accessibility-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for accessibility-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's technology stack and accessibility patterns:

```bash
# Detect frontend framework
grep -r "react\|vue\|angular\|svelte\|next\|nuxt\|sveltekit" --include="package.json" 2>/dev/null | head -5

# Detect accessibility testing libraries
grep -r "axe-core\|jest-axe\|testing-library\|cypress-axe\|playwright\|pa11y\|lighthouse" --include="package.json" 2>/dev/null | head -5

# Detect UI component libraries
grep -r "radix\|headlessui\|reach-ui\|chakra\|mui\|ant-design\|bootstrap" --include="package.json" 2>/dev/null | head -5

# Detect CSS frameworks
grep -r "tailwind\|styled-components\|emotion\|css-modules" --include="package.json" 2>/dev/null | head -5

# Find accessibility configuration
grep -r "eslint-plugin-jsx-a11y\|accessibility\|a11y" --include="*.json" --include="*.js" --include="*.ts" 2>/dev/null | head -10
```

### Phase 2: Accessibility Checklist

Run all checks and compile results:

#### 1. Keyboard Navigation

All interactive elements must be accessible via keyboard.

| Check | Pattern | Status |
|-------|---------|--------|
| Tab navigation | All interactive elements in tab order | Required |
| Tabindex usage | No positive tabindex values | Required |
| Focus trap | Modals trap focus within | Required |
| Focus return | Focus returns after modal close | Required |
| Skip links | Skip to main content link | Required |
| Keyboard shortcuts | Documented and not conflicting | Conditional |
| Arrow key navigation | For composite widgets (menus, tabs) | Conditional |
| Enter/Space activation | Buttons and links activatable | Required |
| Escape key | Closes modals/dropdowns | Required |

**Search Patterns:**
```bash
# Find interactive elements without proper accessibility
grep -r "onClick\|click\|@click" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -30

# Find tabindex usage
grep -r "tabindex" --include="*.tsx" --include="*.jsx" --include="*.html" --include="*.vue" 2>/dev/null | head -20

# Find modal/dialog implementations
grep -r "modal\|dialog\|popup\|overlay" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find skip links
grep -r "skip.*link\|skip.*content\|skip.*nav" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10

# Find custom interactive components
grep -r "onKeyDown\|onKeyUp\|keydown\|keyup" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20
```

#### 2. Screen Reader Support

Content must be perceivable by screen readers.

| Check | Pattern | Status |
|-------|---------|--------|
| Alt text | All images have meaningful alt text | Required |
| Alt="" for decorative | Decorative images have empty alt | Required |
| ARIA labels | Interactive elements have accessible names | Required |
| ARIA roles | Custom components have appropriate roles | Conditional |
| ARIA states | Dynamic states announced | Required |
| Live regions | Dynamic content changes announced | Conditional |
| Form labels | All form inputs have associated labels | Required |
| Error messages | Form errors linked to inputs | Required |
| Heading hierarchy | Logical heading order (h1-h6) | Required |
| Landmarks | Main, nav, aside, header, footer | Required |

**Search Patterns:**
```bash
# Find images without alt text
grep -r "<img" --include="*.tsx" --include="*.jsx" --include="*.html" --include="*.vue" 2>/dev/null | grep -v "alt=" | head -20

# Find ARIA usage
grep -r "aria-\|role=" --include="*.tsx" --include="*.jsx" --include="*.html" --include="*.vue" 2>/dev/null | head -30

# Find form inputs without labels
grep -r "<input\|<select\|<textarea" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -30

# Find heading structure
grep -r "<h1\|<h2\|<h3\|<h4\|<h5\|<h6" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -30

# Find landmark elements
grep -r "<main\|<nav\|<aside\|<header\|<footer\|<section" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find live regions
grep -r "aria-live\|role=\"alert\|role=\"status" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

#### 3. Color Contrast

Text must have sufficient contrast against backgrounds.

| Check | Pattern | Status |
|-------|---------|--------|
| Normal text contrast | Minimum 4.5:1 ratio | Required |
| Large text contrast | Minimum 3:1 ratio | Required |
| UI component contrast | Minimum 3:1 for boundaries | Required |
| Focus indicator contrast | Minimum 3:1 against adjacent | Required |
| Link contrast | Distinguishable from surrounding text | Required |
| Color not sole indicator | Information not conveyed by color alone | Required |
| Focus visible | Clear focus indicator on all interactive elements | Required |

**Search Patterns:**
```bash
# Find color definitions
grep -r "color:\|text-\|bg-\|background" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -30

# Find theme/color configuration
cat tailwind.config.js 2>/dev/null | head -50
grep -r "primary\|secondary\|accent" --include="*.css" --include="*.scss" --include="tailwind.config.js" 2>/dev/null | head -20

# Find focus styles
grep -r ":focus\|focus:\|focus-visible\|outline" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find disabled states (may rely on color alone)
grep -r ":disabled\|disabled:\|aria-disabled" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -15
```

#### 4. Focus Management

Focus must be visible and properly managed.

| Check | Pattern | Status |
|-------|---------|--------|
| Focus visible | All interactive elements show focus | Required |
| Focus indicator style | Clear visual indicator (not just color change) | Required |
| Focus order | Logical tab order follows visual order | Required |
| Focus trap in modals | Focus contained within open modal | Required |
| Focus restoration | Focus returns to trigger after modal close | Required |
| No focus outline removal | outline: none only with replacement | Required |
| Autofocus used sparingly | Only for critical flows | Conditional |

**Search Patterns:**
```bash
# Find focus removal without replacement
grep -r "outline.*none\|outline:.*0\|no-underline" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find focus styles
grep -r ":focus\|focus:\|focus-visible\|ring\|outline" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -30

# Find autofocus usage
grep -r "autofocus\|autoFocus" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10

# Find modal focus management
grep -r "FocusTrap\|focus-trap\|inert\|aria-modal" --include="*.tsx" --include="*.jsx" --include="*.js" 2>/dev/null | head -15
```

#### 5. Semantic HTML

Use appropriate HTML elements for their intended purpose.

| Check | Pattern | Status |
|-------|---------|--------|
| Buttons for actions | `<button>` for interactive actions | Required |
| Links for navigation | `<a>` for navigation | Required |
| Lists for collections | `<ul>`, `<ol>`, `<dl>` for lists | Required |
| Tables for data | `<table>` only for tabular data | Required |
| Figure for images | `<figure>` with `<figcaption>` | Recommended |
| Proper nesting | Elements correctly nested | Required |
| No div/span for interactivity | Use semantic elements instead | Required |
| Form elements | Proper form structure with submit | Required |

**Search Patterns:**
```bash
# Find divs/spans with click handlers (potential semantic issues)
grep -r "<div.*onClick\|<span.*onClick" --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Find anchor elements without href
grep -r "<a[^>]*>" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | grep -v "href=" | head -15

# Find buttons missing type
grep -r "<button" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | grep -v "type=" | head -15

# Find table usage
grep -r "<table\|<th\|<td" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find list usage
grep -r "<ul\|<ol\|<li\|<dl\|<dt\|<dd" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15
```

#### 6. Forms & Inputs

Forms must be accessible and provide clear feedback.

| Check | Pattern | Status |
|-------|---------|--------|
| Labels associated | All inputs have associated labels | Required |
| Required indication | Required fields clearly marked | Required |
| Error identification | Errors linked to inputs via aria-describedby | Required |
| Error messages | Clear, helpful error messages | Required |
| Success feedback | Form submission feedback | Required |
| Input purpose | autocomplete attributes for common fields | Recommended |
| Field validation | Real-time or on-submit validation | Required |
| Help text | Supplementary help available | Recommended |

**Search Patterns:**
```bash
# Find form elements
grep -r "<form\|<input\|<select\|<textarea\|<label" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -40

# Find required fields
grep -r "required\|aria-required" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find error handling
grep -r "error\|invalid\|aria-invalid\|aria-errormessage" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find autocomplete usage
grep -r "autocomplete\|autoComplete" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find form validation
grep -r "validate\|validation\|onSubmit\|handleSubmit" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
```

#### 7. Media & Animations

Media content must be accessible and animations controllable.

| Check | Pattern | Status |
|-------|---------|--------|
| Video captions | All videos have captions | Required |
| Audio descriptions | Videos have audio descriptions | Conditional |
| Transcripts | Audio content has transcripts | Required |
| No auto-play | Media doesn't auto-play with sound | Required |
| Pause/stop controls | Animations can be paused | Required |
| Motion preference | Respects prefers-reduced-motion | Required |
| Flashing content | No more than 3 flashes per second | Required |

**Search Patterns:**
```bash
# Find video/audio elements
grep -r "<video\|<audio\|<iframe.*youtube\|<iframe.*vimeo" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find animation/transition usage
grep -r "animation\|transition\|@keyframes" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -20

# Find motion preference handling
grep -r "prefers-reduced-motion\|reduced-motion" --include="*.css" --include="*.scss" --include="*.tsx" 2>/dev/null | head -10

# Find auto-play usage
grep -r "autoplay\|autoPlay" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

#### 8. Testing Coverage

Verify accessibility through testing.

| Check | Pattern | Status |
|-------|---------|--------|
| Automated testing | axe-core or similar integrated | Required |
| Unit tests | Accessibility properties tested | Recommended |
| E2E tests | Keyboard navigation tested | Recommended |
| Screen reader testing | Manual screen reader testing | Required |
| Color contrast testing | Automated contrast checking | Required |
| CI integration | Accessibility tests in CI pipeline | Required |

**Search Patterns:**
```bash
# Find accessibility testing libraries
grep -r "axe\|jest-axe\|cypress-axe\|playwright.*a11y\|pa11y\|lighthouse" --include="package.json" 2>/dev/null | head -10

# Find accessibility test files
find . -name "*a11y*" -o -name "*accessibility*" 2>/dev/null | grep -v node_modules | head -10

# Find ESLint accessibility plugins
grep -r "jsx-a11y\|eslint.*a11y" --include="*.json" --include="*.js" --include="*.yaml" 2>/dev/null | head -10

# Find CI accessibility testing
grep -r "axe\|lighthouse\|pa11y\|a11y" .github 2>/dev/null | head -10
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific accessibility gap
2. **Why it matters**: User impact and WCAG criterion
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
      ACCESSIBILITY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected frontend stack]
Target: WCAG 2.1 AA
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

KEYBOARD NAVIGATION
  [PASS] Tab navigation implemented
  [WARN] Focus trap in modals incomplete
  [PASS] Skip link present
  [FAIL] No escape key handler for dropdowns
  [PASS] Enter/Space activation works

SCREEN READER SUPPORT
  [FAIL] Images missing alt text (12 instances)
  [PASS] Form labels associated
  [WARN] ARIA roles incomplete on tabs
  [PASS] Heading hierarchy correct
  [FAIL] Error messages not announced

COLOR CONTRAST
  [PASS] Text contrast meets 4.5:1
  [FAIL] Focus indicator low contrast
  [WARN] Link color similar to body text
  [PASS] Color not sole indicator

FOCUS MANAGEMENT
  [FAIL] outline: none without replacement
  [PASS] Focus visible on buttons
  [FAIL] Focus not restored after modal close
  [WARN] Focus order inconsistent in sidebar

SEMANTIC HTML
  [FAIL] Div used for button (3 instances)
  [PASS] Links have href attributes
  [PASS] Lists used correctly
  [WARN] Table missing caption

FORMS & INPUTS
  [PASS] All inputs have labels
  [FAIL] Required fields not indicated
  [FAIL] Errors not linked to inputs
  [PASS] Autocomplete on email field

MEDIA & ANIMATIONS
  [N/A]  No video content
  [PASS] Respects prefers-reduced-motion
  [WARN] Carousel auto-advances

TESTING COVERAGE
  [PASS] axe-core in test suite
  [FAIL] No screen reader testing
  [PASS] CI accessibility checks
  [WARN] Limited keyboard E2E tests

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Images Missing Alt Text
  Impact: Screen reader users cannot understand image content
  WCAG: 1.1.1 Non-text Content (Level A)
  Fix: Add meaningful alt text to all informative images
  Files: src/components/Gallery.tsx, src/components/Avatar.tsx

  <!-- BEFORE (non-compliant): -->
  <img src="/profile.jpg" />
  <img src="/chart.png" />

  <!-- AFTER (compliant): -->
  <img src="/profile.jpg" alt="User profile photo" />
  <img src="/chart.png" alt="Sales increased 25% from Q1 to Q2" />

  <!-- Decorative images: -->
  <img src="/decoration.svg" alt="" role="presentation" />

[CRITICAL] Focus Not Restored After Modal Close
  Impact: Keyboard users lose position, frustrating experience
  WCAG: 2.4.3 Focus Order (Level A)
  Fix: Return focus to trigger element when modal closes
  File: src/components/Modal.tsx

  // BEFORE (non-compliant):
  const closeModal = () => setIsOpen(false);

  // AFTER (compliant):
  const triggerRef = useRef<HTMLButtonElement>(null);

  const closeModal = () => {
    setIsOpen(false);
    // Restore focus to trigger element
    triggerRef.current?.focus();
  };

  // Or use a focus management library:
  import { useFocusTrap } from '@headlessui/react';

  function Modal({ isOpen, onClose }) {
    return (
      <Dialog onClose={onClose}>
        <FocusTrap>
          <DialogPanel>
            {/* Modal content */}
          </DialogPanel>
        </FocusTrap>
      </Dialog>
    );
  }

[CRITICAL] Errors Not Linked to Inputs
  Impact: Screen reader users don't know which field has error
  WCAG: 3.3.1 Error Identification (Level A)
  Fix: Use aria-describedby to link errors to inputs
  File: src/components/Form.tsx

  // BEFORE (non-compliant):
  <div>
    <label htmlFor="email">Email</label>
    <input id="email" type="email" />
    {error && <span className="error">Invalid email</span>}
  </div>

  // AFTER (compliant):
  <div>
    <label htmlFor="email">Email</label>
    <input
      id="email"
      type="email"
      aria-invalid={error ? 'true' : 'false'}
      aria-describedby={error ? 'email-error' : undefined}
    />
    {error && (
      <span id="email-error" className="error" role="alert">
        Invalid email
      </span>
    )}
  </div>

[HIGH] Div Used for Button
  Impact: Not keyboard accessible, no button role announced
  WCAG: 4.1.2 Name, Role, Value (Level A)
  Fix: Use semantic button element
  File: src/components/Actions.tsx

  <!-- BEFORE (non-compliant): -->
  <div onClick={handleClick} className="btn">
    Submit
  </div>

  <!-- AFTER (compliant): -->
  <button onClick={handleClick} type="button" className="btn">
    Submit
  </button>

  <!-- If div is required, add full ARIA: -->
  <div
    role="button"
    tabIndex={0}
    onClick={handleClick}
    onKeyDown={(e) => e.key === 'Enter' && handleClick()}
    className="btn"
  >
    Submit
  </div>

[HIGH] Focus Indicator Low Contrast
  Impact: Keyboard users cannot see focused element
  WCAG: 2.4.7 Focus Visible (Level AA)
  Fix: Ensure focus indicator has 3:1 contrast minimum
  File: src/styles/focus.css

  /* BEFORE (insufficient): */
  button:focus {
    outline: 1px solid lightgray;
  }

  /* AFTER (compliant): */
  button:focus-visible {
    outline: 3px solid #2563eb;
    outline-offset: 2px;
  }

  /* Or use box-shadow for more visibility: */
  button:focus-visible {
    outline: none;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.5);
  }

[HIGH] Required Fields Not Indicated
  Impact: Users don't know which fields are required
  WCAG: 3.3.2 Labels or Instructions (Level A)
  Fix: Visually and programmatically indicate required fields
  File: src/components/FormField.tsx

  // BEFORE (non-compliant):
  <label htmlFor="email">Email</label>
  <input id="email" required />

  // AFTER (compliant):
  <label htmlFor="email">
    Email <span aria-hidden="true" className="required">*</span>
  </label>
  <input
    id="email"
    required
    aria-required="true"
  />
  <span className="sr-only">(required)</span>

[MEDIUM] No Escape Key Handler for Dropdowns
  Impact: Keyboard users cannot easily close dropdowns
  WCAG: 4.1.2 Name, Role, Value (Level A)
  Fix: Add escape key handler
  File: src/components/Dropdown.tsx

  // Add escape handler:
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        setIsOpen(false);
        triggerRef.current?.focus();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen]);

[MEDIUM] Link Color Similar to Body Text
  Impact: Users cannot distinguish links from regular text
  WCAG: 1.4.1 Use of Color (Level A)
  Fix: Add underline or other visual distinction
  File: src/styles/typography.css

  /* BEFORE (insufficient): */
  a {
    color: #1a1a1a;
  }

  /* AFTER (compliant): */
  a {
    color: #0066cc;
    text-decoration: underline;
  }

  a:hover, a:focus {
    text-decoration-thickness: 2px;
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add alt text to all images
2. [CRITICAL] Implement focus restoration for modals
3. [CRITICAL] Link form errors to inputs with aria-describedby
4. [HIGH] Replace div buttons with semantic buttons
5. [HIGH] Improve focus indicator contrast
6. [HIGH] Indicate required fields visually and programmatically
7. [MEDIUM] Add escape key handler for dropdowns
8. [MEDIUM] Improve link visibility

After Production:
1. Conduct full screen reader testing (NVDA, VoiceOver, JAWS)
2. Add keyboard navigation E2E tests
3. Set up automated accessibility monitoring
4. Create internal accessibility guidelines
5. Train developers on WCAG requirements
6. Schedule periodic accessibility audits

═══════════════════════════════════════════════════════════════
```

---

