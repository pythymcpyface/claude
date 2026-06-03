# seo-review — Implementation Patterns

Reusable code snippets and configuration templates for seo-review. Copy and adapt to project context; do not paste verbatim without verifying stack.

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

