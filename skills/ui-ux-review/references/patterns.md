# ui-ux-review — Implementation Patterns

Reusable code snippets and configuration templates for ui-ux-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

