# browser-compatibility-review — Implementation Patterns

Reusable code snippets and configuration templates for browser-compatibility-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

