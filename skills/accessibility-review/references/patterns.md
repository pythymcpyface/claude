# accessibility-review — Implementation Patterns

Reusable code snippets and configuration templates for accessibility-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

## Quick Reference: Implementation Patterns

### Skip Link

```html
<!-- First element after body open -->
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<main id="main-content">
  <!-- Page content -->
</main>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px 16px;
  z-index: 100;
  transition: top 0.2s;
}

.skip-link:focus {
  top: 0;
}
```

### Accessible Modal

```tsx
import { Dialog, Transition } from '@headlessui/react';
import { useRef } from 'react';

function Modal({ isOpen, onClose, title, children }) {
  const initialFocusRef = useRef(null);

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog
        as="div"
        className="modal"
        onClose={onClose}
        initialFocus={initialFocusRef}
      >
        <div className="modal-backdrop" aria-hidden="true" />

        <div className="modal-container">
          <DialogPanel className="modal-content">
            <DialogTitle as="h2" className="modal-title">
              {title}
            </DialogTitle>

            <div className="modal-body">{children}</div>

            <button ref={initialFocusRef} onClick={onClose}>
              Close
            </button>
          </DialogPanel>
        </div>
      </Dialog>
    </Transition>
  );
}
```

### Accessible Form with Errors

```tsx
function FormField({ id, label, error, required, ...props }) {
  const errorId = `${id}-error`;
  const hintId = `${id}-hint`;

  return (
    <div className="form-field">
      <label htmlFor={id}>
        {label}
        {required && (
          <>
            <span aria-hidden="true" className="required">*</span>
            <span className="sr-only">(required)</span>
          </>
        )}
      </label>

      <input
        id={id}
        aria-required={required}
        aria-invalid={!!error}
        aria-describedby={`${error ? errorId : ''} ${props.hint ? hintId : ''}`.trim() || undefined}
        {...props}
      />

      {props.hint && (
        <p id={hintId} className="hint">
          {props.hint}
        </p>
      )}

      {error && (
        <p id={errorId} className="error" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
```

### Accessible Tabs

```tsx
import { Tab } from '@headlessui/react';

function Tabs({ tabs, panels }) {
  return (
    <Tab.Group>
      <Tab.List className="tab-list" aria-label="Content sections">
        {tabs.map((tab) => (
          <Tab key={tab.id} className="tab">
            {tab.label}
          </Tab>
        ))}
      </Tab.List>

      <Tab.Panels>
        {panels.map((panel, idx) => (
          <Tab.Panel key={idx} className="tab-panel">
            {panel.content}
          </Tab.Panel>
        ))}
      </Tab.Panels>
    </Tab.Group>
  );
}

// Manual implementation:
function ManualTabs({ tabs }) {
  const [selectedIndex, setSelectedIndex] = useState(0);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowLeft':
        setSelectedIndex((prev) => (prev - 1 + tabs.length) % tabs.length);
        break;
      case 'ArrowRight':
        setSelectedIndex((prev) => (prev + 1) % tabs.length);
        break;
      case 'Home':
        setSelectedIndex(0);
        break;
      case 'End':
        setSelectedIndex(tabs.length - 1);
        break;
    }
  };

  return (
    <div>
      <div role="tablist" aria-label="Sections" onKeyDown={handleKeyDown}>
        {tabs.map((tab, idx) => (
          <button
            key={tab.id}
            role="tab"
            aria-selected={selectedIndex === idx}
            aria-controls={`${tab.id}-panel`}
            tabIndex={selectedIndex === idx ? 0 : -1}
            onClick={() => setSelectedIndex(idx)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {tabs.map((tab, idx) => (
        <div
          key={tab.id}
          id={`${tab.id}-panel`}
          role="tabpanel"
          aria-labelledby={tab.id}
          hidden={selectedIndex !== idx}
        >
          {tab.content}
        </div>
      ))}
    </div>
  );
}
```

### Focus Visible Styles

```css
/* Modern focus-visible approach */
:focus {
  outline: none;
}

:focus-visible {
  outline: 3px solid #2563eb;
  outline-offset: 2px;
  border-radius: 2px;
}

/* High contrast focus for buttons */
button:focus-visible,
a:focus-visible {
  outline: 3px solid currentColor;
  outline-offset: 2px;
}

/* Skip outline reset for mouse users */
.using-mouse :focus {
  outline: none;
}
```

```js
// Detect mouse vs keyboard usage
document.addEventListener('keydown', (e) => {
  if (e.key === 'Tab') {
    document.body.classList.remove('using-mouse');
  }
});

document.addEventListener('mousedown', () => {
  document.body.classList.add('using-mouse');
});
```

### Reduced Motion Support

```css
/* Respect user preference for reduced motion */
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

/* Or conditionally apply animations */
.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
}

@media (prefers-reduced-motion: reduce) {
  .animate-fade-in {
    animation: none;
    opacity: 1;
  }
}
```

### Screen Reader Only Content

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Not sr-only but visually subtle */
.visual-only {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
}
```

```html
<!-- Icon button with screen reader text -->
<button aria-label="Close dialog">
  <span aria-hidden="true">&times;</span>
  <span class="sr-only">Close dialog</span>
</button>

<!-- Hidden label for form field -->
<label for="search" class="sr-only">Search</label>
<input type="search" id="search" placeholder="Search..." />
```

### Accessible Error Summary

```tsx
function ErrorSummary({ errors }) {
  if (errors.length === 0) return null;

  return (
    <div
      role="alert"
      aria-live="polite"
      className="error-summary"
      tabIndex={-1}
      ref={summaryRef}
    >
      <h2>Please correct the following errors:</h2>
      <ul>
        {errors.map((error) => (
          <li key={error.fieldId}>
            <a href={`#${error.fieldId}`}>{error.message}</a>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

