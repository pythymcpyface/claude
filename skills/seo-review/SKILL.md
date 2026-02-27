---
name: seo-review
description: Production readiness review for SEO. Reviews meta tags, structured data, Core Web Vitals, and LLM/GEO optimization before production release. Use PROACTIVELY before releasing to production, when adding new pages, or modifying content structure.
tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# SEO Review Skill

Production readiness code review focused on Search Engine Optimization (SEO) and Generative Engine Optimization (GEO). Ensures applications are ready for production with proper meta tags, structured data, Core Web Vitals, and LLM-friendly content.

## When to Trigger (Proactive)

Automatically suggest this review when:
- PR/commit message contains: "seo", "meta", "og:", "schema", "structured data", "core web vitals"
- New pages or routes are added
- Content or layout changes affect rendering
- Performance optimizations are implemented
- Before major releases or product launches
- When modifying HTML head or meta tags
- Adding or modifying JSON-LD structured data
- Changes affecting page load performance

---

## Review Workflow

### Phase 1: Stack Detection

Detect the project's frontend framework and SEO infrastructure:

```bash
# Detect frontend frameworks
grep -r "next\|nuxt\|gatsby\|remix\|astro\|sveltekit" package.json 2>/dev/null && echo "SSR Framework detected"
grep -r "react\|vue\|angular\|svelte" package.json 2>/dev/null && echo "SPA Framework detected"

# Detect SEO libraries
grep -r "next-seo\|react-helmet\|vue-meta\|react-meta-tags" package.json 2>/dev/null

# Detect static site generation
ls next.config.js nuxt.config.js gatsby-config.js astro.config.mjs 2>/dev/null && echo "SSG capable"

# Check for sitemap/robots
find . -name "sitemap*.xml" -o -name "robots.txt" 2>/dev/null | head -5

# Detect structured data
grep -r "application/ld+json\|JSON-LD\|schema.org" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

### Phase 2: SEO Checklist

Run all checks and compile results:

#### 1. Meta Tags Review

| Check | Pattern | Status |
|-------|---------|--------|
| Title tag | Unique, descriptive title (50-60 chars) on every page | Required |
| Meta description | Unique description (150-160 chars) on every page | Required |
| Canonical URL | Canonical link to prevent duplicate content | Required |
| Open Graph tags | og:title, og:description, og:image, og:url | Required |
| Twitter Card tags | twitter:card, twitter:title, twitter:description, twitter:image | Recommended |
| Viewport meta | Responsive viewport configuration | Required |
| Robots meta | robots directive for indexing control | Recommended |
| Language/locale | hreflang for multilingual sites | Conditional |

**Search Patterns:**
```bash
# Find title tags
grep -r "<title>\|<Title>" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20
grep -r "title.*=" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20

# Find meta descriptions
grep -r "description.*meta\|meta.*description" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15
grep -r "name=\"description\"" --include="*.html" 2>/dev/null | head -15

# Find Open Graph tags
grep -r "og:\|open.*graph\|property=\"og:" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find Twitter Card tags
grep -r "twitter:\|twitter:card\|name=\"twitter:" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find canonical URLs
grep -r "canonical\|rel=\"canonical\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10

# Check for SEO libraries
grep -r "next-seo\|react-helmet\|Head\|Meta\|SEO" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
```

#### 2. Structured Data Review

| Check | Pattern | Status |
|-------|---------|--------|
| JSON-LD present | Structured data in JSON-LD format | Required |
| Schema.org types | Valid schema types (Organization, Product, Article, etc.) | Required |
| Organization schema | Organization/brand information | Recommended |
| Breadcrumb schema | Navigation breadcrumbs | Recommended |
| Product/Service schema | Product or service details (if applicable) | Conditional |
| Article/Blog schema | Article metadata (if applicable) | Conditional |
| FAQ/HowTo schema | FAQ or instructional content (if applicable) | Conditional |
| Local Business schema | Business location info (if applicable) | Conditional |
| Validation | Structured data passes Google Rich Results Test | Required |

**Search Patterns:**
```bash
# Find JSON-LD scripts
grep -r "application/ld+json\|type=\"application/ld+json\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find schema.org references
grep -r "schema.org\|@type.*Organization\|@type.*Product\|@type.*Article" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find structured data libraries
grep -r "schema-dts\|react-schemaorg\|next-seo.*JsonLd" package.json 2>/dev/null

# Check for structured data files
find . -name "*schema*" -o -name "*jsonld*" -o -name "*structured*" 2>/dev/null | head -10

# Find breadcrumb implementations
grep -r "breadcrumb\|BreadcrumbList" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10
```

#### 3. Core Web Vitals Review

| Check | Pattern | Status |
|-------|---------|--------|
| Largest Contentful Paint (LCP) | LCP < 2.5 seconds | Required |
| First Input Delay (FID) | FID < 100 milliseconds | Required |
| Cumulative Layout Shift (CLS) | CLS < 0.1 | Required |
| Image optimization | Next/Image, lazy loading, responsive images | Required |
| Font loading | Font display strategy, preload fonts | Required |
| Code splitting | Dynamic imports, bundle optimization | Required |
| Caching headers | Appropriate cache-control headers | Required |
| Compression | Gzip/Brotli compression enabled | Required |
| Critical CSS | Above-the-fold CSS prioritized | Recommended |
| Preload hints | Preload critical resources | Recommended |

**Search Patterns:**
```bash
# Find image optimization
grep -r "next/image\|Image.*from\|loading=\"lazy\"" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20
grep -r "<img.*loading\|<img.*srcset" --include="*.html" 2>/dev/null | head -10

# Find font loading
grep -r "font-display\|@font-face\|next/font" --include="*.tsx" --include="*.jsx" --include="*.css" --include="*.scss" 2>/dev/null | head -15

# Find code splitting
grep -r "import(\|lazy\|Suspense\|dynamic.*import" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -15

# Check for performance config
find . -name "next.config.js" -o -name "lighthouse*.js" -o -name ".lighthouserc*" 2>/dev/null | head -5

# Find preload/prefetch hints
grep -r "rel=\"preload\"\|rel=\"prefetch\"" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -10

# Check bundle analysis
grep -r "bundle-analyzer\|webpack-bundle-analyzer" package.json 2>/dev/null
```

#### 4. LLM/GEO SEO Review (Generative Engine Optimization)

| Check | Pattern | Status |
|-------|---------|--------|
| Clear page structure | Semantic HTML5 elements (header, nav, main, article, footer) | Required |
| Descriptive headings | Logical H1-H6 hierarchy | Required |
| FAQ sections | Frequently asked questions for AI to reference | Recommended |
| About/Author info | Clear authorship and expertise signals | Recommended |
| Content freshness | Last modified dates, update timestamps | Recommended |
| Entity clarity | Clear organization/person/entity information | Required |
| Contextual content | Comprehensive, contextual information | Required |
| Accessible content | ARIA labels, semantic markup | Required |
| Fast loading | Performance optimized for AI crawlers | Required |
| Clean URLs | Descriptive, readable URL structure | Recommended |

**Search Patterns:**
```bash
# Find semantic HTML
grep -r "<header\|<nav\|<main\|<article\|<section\|<aside\|<footer" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find heading structure
grep -r "<h1\|<h2\|<h3\|<h4\|<h5\|<h6" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find FAQ implementations
grep -r "FAQ\|faq\|Frequently.*Asked\|Question.*Answer" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Find author/about information
grep -r "author\|Author\|about.*us\|About.*Us" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15

# Check for accessibility
grep -r "aria-\|role=\|alt=\"\|aria-label" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -20

# Find timestamp/date information
grep -r "datePublished\|dateModified\|lastUpdated\|updatedAt" --include="*.tsx" --include="*.jsx" --include="*.html" 2>/dev/null | head -15
```

#### 5. Technical SEO Review

| Check | Pattern | Status |
|-------|---------|--------|
| Sitemap.xml | XML sitemap present and submitted | Required |
| Robots.txt | Robots file with appropriate directives | Required |
| HTTPS | All pages served over HTTPS | Required |
| Mobile-friendly | Responsive design for mobile | Required |
| URL structure | Clean, descriptive URLs | Required |
| 404 handling | Custom 404 page | Required |
| Redirects | Proper redirect implementation (301/302) | Required |
| Internal linking | Logical internal link structure | Recommended |
| External links | rel="noopener noreferrer" on external links | Recommended |

**Search Patterns:**
```bash
# Find sitemap
find . -name "sitemap*.xml" -o -name "sitemap*.ts" -o -name "sitemap*.js" 2>/dev/null | head -10

# Find robots.txt
find . -name "robots.txt" -o -name "robots*.ts" 2>/dev/null | head -5

# Check for 404 pages
find . -name "*404*" -o -name "*not*found*" 2>/dev/null | head -10
grep -r "404\|not.*found\|Not.*Found" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# Find redirect configurations
grep -r "redirect\|Redirect" --include="*.js" --include="*.ts" --include="*.json" 2>/dev/null | head -15

# Check for next.js redirects
find . -name "next.config.js" | xargs grep -A 10 "redirects" 2>/dev/null | head -20
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific SEO gap
2. **Why it matters**: Impact on search rankings and AI visibility
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         SEO PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Framework: [detected framework]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

META TAGS
  [PASS] Title tags present on all pages
  [FAIL] Missing meta descriptions on 3 pages
  [PASS] Open Graph tags configured
  [WARN] Twitter Card tags incomplete

STRUCTURED DATA
  [FAIL] No JSON-LD structured data found
  [FAIL] Missing Organization schema
  [WARN] No breadcrumb schema

CORE WEB VITALS
  [PASS] Image optimization with Next/Image
  [FAIL] No font-display strategy
  [PASS] Code splitting implemented
  [WARN] Missing preload hints for critical CSS

LLM/GEO SEO
  [PASS] Semantic HTML structure
  [FAIL] No FAQ sections
  [WARN] Missing author/attribution info
  [PASS] Accessible content with ARIA labels

TECHNICAL SEO
  [PASS] Sitemap.xml present
  [PASS] Robots.txt configured
  [FAIL] Missing custom 404 page
  [WARN] No redirect configuration

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Missing JSON-LD Structured Data
  Impact: Search engines cannot understand page content, no rich results
  Fix: Add JSON-LD structured data to all pages
  File: src/components/StructuredData.tsx

  export function StructuredData() {
    const schema = {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "Your Company",
      "url": "https://example.com",
      "logo": "https://example.com/logo.png",
      "sameAs": [
        "https://twitter.com/yourcompany",
        "https://linkedin.com/company/yourcompany"
      ]
    };

    return (
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
      />
    );
  }

[HIGH] Missing Meta Descriptions
  Impact: Poor click-through rates in search results
  Fix: Add unique meta descriptions to all pages
  File: src/app/layout.tsx or pages/_app.tsx

  export const metadata: Metadata = {
    title: 'Page Title | Your Brand',
    description: 'Unique, compelling description (150-160 chars) that includes target keywords and encourages clicks.',
    openGraph: {
      title: 'Page Title | Your Brand',
      description: 'Same or similar description for social sharing',
      images: ['/og-image.png'],
    },
  };

[HIGH] No Font Display Strategy
  Impact: Layout shifts, poor CLS score, slower perceived load
  Fix: Add font-display: swap or use next/font
  File: src/app/layout.tsx

  import { Inter } from 'next/font/google';

  const inter = Inter({
    subsets: ['latin'],
    display: 'swap',
    variable: '--font-inter',
  });

  export default function RootLayout({ children }) {
    return (
      <html lang="en" className={inter.variable}>
        <body>{children}</body>
      </html>
    );
  }

[MEDIUM] No FAQ Sections
  Impact: AI search engines (ChatGPT, Perplexity) cannot reference your content
  Fix: Add FAQ sections with FAQPage schema
  File: src/components/FAQ.tsx

  export function FAQ() {
    const faqs = [
      {
        question: "What is your service?",
        answer: "Detailed answer that AI can reference..."
      }
    ];

    const faqSchema = {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": faqs.map(faq => ({
        "@type": "Question",
        "name": faq.question,
        "acceptedAnswer": {
          "@type": "Answer",
          "text": faq.answer
        }
      }))
    };

    return (
      <>
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }} />
        <section>
          <h2>Frequently Asked Questions</h2>
          {faqs.map((faq, i) => (
            <div key={i}>
              <h3>{faq.question}</h3>
              <p>{faq.answer}</p>
            </div>
          ))}
        </section>
      </>
    );
  }

[MEDIUM] Missing Custom 404 Page
  Impact: Poor user experience, lost link equity
  Fix: Create custom 404 page with navigation
  File: src/app/not-found.tsx or pages/404.tsx

  export default function NotFound() {
    return (
      <main>
        <h1>Page Not Found</h1>
        <p>The page you're looking for doesn't exist.</p>
        <Link href="/">Return Home</Link>
      </main>
    );
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Add JSON-LD structured data to all pages
2. [HIGH] Add unique meta descriptions to every page
3. [HIGH] Implement font-display strategy
4. [HIGH] Add FAQ sections for AI search visibility
5. [MEDIUM] Create custom 404 page
6. [MEDIUM] Add Twitter Card meta tags
7. [MEDIUM] Implement breadcrumb schema

After Production:
1. Set up Google Search Console and submit sitemap
2. Test structured data with Rich Results Test
3. Run Lighthouse audits for Core Web Vitals
4. Monitor search rankings and click-through rates
5. Implement A/B testing for meta descriptions
6. Add more FAQ content for AI search optimization

═══════════════════════════════════════════════════════════════
```

---

## Scoring

| Score | Status | Action |
|-------|--------|--------|
| 90-100 | PASS | Ready for production |
| 70-89 | NEEDS WORK | Address gaps before release |
| 50-69 | AT RISK | Significant gaps, review required |
| 0-49 | BLOCK | Critical gaps, do not release |

### Weight Distribution

| Category | Weight |
|----------|--------|
| Meta Tags | 30% |
| Structured Data | 25% |
| Core Web Vitals | 25% |
| LLM/GEO SEO | 20% |

---

## Quick Reference: Implementation Patterns

### Next.js SEO with next-seo

```typescript
// src/app/layout.tsx or pages/_app.tsx
import { DefaultSeo } from 'next-seo';

export default function App({ Component, pageProps }) {
  return (
    <>
      <DefaultSeo
        title="Your Brand"
        titleTemplate="%s | Your Brand"
        description="Default description for your website"
        canonical="https://example.com"
        openGraph={{
          type: 'website',
          locale: 'en_US',
          url: 'https://example.com',
          siteName: 'Your Brand',
          images: [
            {
              url: '/og-image.png',
              width: 1200,
              height: 630,
              alt: 'Your Brand',
            },
          ],
        }}
        twitter={{
          handle: '@yourhandle',
          site: '@yoursite',
          cardType: 'summary_large_image',
        }}
      />
      <Component {...pageProps} />
    </>
  );
}
```

### JSON-LD Structured Data

```typescript
// src/components/StructuredData.tsx
export function OrganizationSchema() {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Your Company",
    "url": "https://example.com",
    "logo": "https://example.com/logo.png",
    "contactPoint": {
      "@type": "ContactPoint",
      "telephone": "+1-800-555-0199",
      "contactType": "customer service"
    },
    "sameAs": [
      "https://twitter.com/yourcompany",
      "https://linkedin.com/company/yourcompany",
      "https://facebook.com/yourcompany"
    ]
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export function ArticleSchema({ title, description, author, datePublished, image }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": title,
    "description": description,
    "author": {
      "@type": "Person",
      "name": author
    },
    "datePublished": datePublished,
    "image": image
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
```

### Core Web Vitals Optimization

```typescript
// next.config.js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
  },
  experimental: {
    optimizeCss: true,
  },
};

// src/app/layout.tsx
import { Inter } from 'next/font/google';
import '../styles/globals.css';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

### Image Optimization

```typescript
// Optimized image with Next.js
import Image from 'next/image';

export function OptimizedImage() {
  return (
    <Image
      src="/hero.jpg"
      alt="Descriptive alt text for SEO and accessibility"
      width={1200}
      height={630}
      priority // For above-the-fold images
      placeholder="blur"
      blurDataURL="data:image/jpeg;base64,..."
    />
  );
}

// Lazy-loaded image
export function LazyImage() {
  return (
    <Image
      src="/content.jpg"
      alt="Descriptive alt text"
      width={800}
      height={600}
      loading="lazy"
    />
  );
}
```

### FAQ with Schema

```typescript
// src/components/FAQ.tsx
export function FAQSection() {
  const faqs = [
    {
      question: "What services do you offer?",
      answer: "We offer comprehensive solutions including..."
    },
    {
      question: "How much does it cost?",
      answer: "Our pricing is based on..."
    }
  ];

  const faqSchema = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": faqs.map(faq => ({
      "@type": "Question",
      "name": faq.question,
      "acceptedAnswer": {
        "@type": "Answer",
        "text": faq.answer
      }
    }))
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
      />
      <section aria-labelledby="faq-heading">
        <h2 id="faq-heading">Frequently Asked Questions</h2>
        {faqs.map((faq, index) => (
          <div key={index}>
            <h3>{faq.question}</h3>
            <p>{faq.answer}</p>
          </div>
        ))}
      </section>
    </>
  );
}
```

### Semantic HTML Structure

```typescript
// src/app/page.tsx
export default function HomePage() {
  return (
    <>
      <header>
        <nav aria-label="Main navigation">
          <a href="/">Home</a>
          <a href="/about">About</a>
          <a href="/services">Services</a>
          <a href="/contact">Contact</a>
        </nav>
      </header>

      <main>
        <article>
          <h1>Main Page Title</h1>
          <section>
            <h2>Section Heading</h2>
            <p>Content with clear structure...</p>
          </section>

          <aside>
            <h3>Related Information</h3>
            <p>Supplementary content...</p>
          </aside>
        </article>
      </main>

      <footer>
        <p>&copy; 2026 Your Company</p>
        <address>
          Contact: <a href="mailto:info@example.com">info@example.com</a>
        </address>
      </footer>
    </>
  );
}
```

### Sitemap Generation

```typescript
// src/app/sitemap.ts (Next.js 13+)
import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: 'https://example.com',
      lastModified: new Date(),
      changeFrequency: 'yearly',
      priority: 1,
    },
    {
      url: 'https://example.com/about',
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.8,
    },
    {
      url: 'https://example.com/services',
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.5,
    },
  ];
}
```

---

## Integration with Other Reviews

This skill complements:
- `/performance-review` - For load testing and resource optimization
- `/browser-compatibility-review` - For cross-browser support
- `/observability-check` - For monitoring and analytics
- `/quality-check` - For code quality and linting
- `/api-readiness-review` - For API design and documentation
