---
name: seo-fundamentals
description: Frontend SEO for Next.js — Metadata API, canonical URLs, Open Graph, Twitter cards, robots.txt, sitemap, SSR/SSG/ISR rendering strategy, heading hierarchy, and crawlability. Use when building pages, setting up metadata, or optimizing for search visibility.
---

# SEO Fundamentals

## The Frontend Developer's SEO Checklist

SEO isn't a marketing afterthought — it's structural. If you ship a client-rendered page with no meta tags, Google indexes an empty shell. This skill covers what frontend engineers need to get right in Next.js code.

## Meta Tags (Every Page)

### Static Metadata (Simple Pages)

```typescript
// app/about/page.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'About Us | YourBrand',
  description: 'Learn about our mission, team, and values.',
  alternates: {
    canonical: 'https://yourdomain.com/about',
  },
  openGraph: {
    title: 'About Us | YourBrand',
    description: 'Learn about our mission, team, and values.',
    url: 'https://yourdomain.com/about',
    siteName: 'YourBrand',
    images: [{ url: '/og/about.png', width: 1200, height: 630, alt: 'About YourBrand' }],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'About Us | YourBrand',
    description: 'Learn about our mission, team, and values.',
    images: ['/og/about.png'],
  },
};
```

### Dynamic Metadata (Data-Driven Pages)

```typescript
// app/products/[slug]/page.tsx
import type { Metadata } from 'next';

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const product = await getProduct(params.slug);

  return {
    title: `${product.name} | YourBrand`,
    description: product.summary.slice(0, 155),  // Max 155 chars
    alternates: {
      canonical: `https://yourdomain.com/products/${params.slug}`,
    },
    openGraph: {
      title: product.name,
      description: product.summary.slice(0, 155),
      url: `https://yourdomain.com/products/${params.slug}`,
      siteName: 'YourBrand',
      images: [{
        url: product.ogImage,
        width: 1200,
        height: 630,
        alt: product.name,
      }],
      type: 'website',
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.summary.slice(0, 155),
      images: [product.ogImage],
    },
    robots: {
      index: product.isPublished,
      follow: true,
    },
  };
}
```

### Layout-Level Defaults

```typescript
// app/layout.tsx — site-wide defaults inherited by all pages
import type { Metadata } from 'next';

export const metadata: Metadata = {
  metadataBase: new URL('https://yourdomain.com'),
  title: {
    default: 'YourBrand',
    template: '%s | YourBrand',  // Pages just set title: 'About' → 'About | YourBrand'
  },
  description: 'Default site description for pages that don\'t set their own.',
  openGraph: {
    siteName: 'YourBrand',
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    creator: '@yourbrand',
  },
  robots: {
    index: true,
    follow: true,
  },
};
```

## Rendering Strategy & Crawlability

| Strategy | Crawlable? | Next.js Config | When to Use |
|----------|-----------|----------------|-------------|
| **SSG** | Yes — best | `generateStaticParams()` | Marketing, blog, docs |
| **SSR** | Yes | Default server components | Dynamic SEO pages (products, profiles) |
| **ISR** | Yes | `export const revalidate = 3600` | Frequently updated, many pages |
| **CSR** | No | `'use client'` with no SSR | Dashboards, authenticated areas |

```typescript
// SSG: pre-render at build time
export async function generateStaticParams() {
  const products = await getAllProducts();
  return products.map((p) => ({ slug: p.slug }));
}

// ISR: regenerate every hour
export const revalidate = 3600;

// Force dynamic (SSR every request)
export const dynamic = 'force-dynamic';
```

**Rule:** Any page that needs to rank in search MUST use SSG, SSR, or ISR. Client-only rendering is invisible to crawlers.

## Heading Hierarchy

```html
<!-- CORRECT: sequential, single h1 -->
<h1>Product Name</h1>
  <h2>Features</h2>
    <h3>Feature A</h3>
    <h3>Feature B</h3>
  <h2>Pricing</h2>
    <h3>Free Plan</h3>
    <h3>Pro Plan</h3>

<!-- WRONG: skipped levels, multiple h1 -->
<h1>Product Name</h1>
<h1>Features</h1>                   <!-- Two h1s -->
  <h4>Feature A</h4>               <!-- Jumped from h1 to h4 -->
```

**Rules:**
- Exactly ONE `<h1>` per page
- Sequential hierarchy — never skip levels
- Headings describe content structure, not visual styling

## Robots.txt & Sitemap

```txt
# public/robots.txt
User-agent: *
Allow: /
Disallow: /api/
Disallow: /admin/
Disallow: /_next/

Sitemap: https://yourdomain.com/sitemap.xml
```

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getAllProducts();
  const productUrls = products.map((p) => ({
    url: `https://yourdomain.com/products/${p.slug}`,
    lastModified: p.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.8,
  }));

  return [
    { url: 'https://yourdomain.com', lastModified: new Date(), priority: 1.0 },
    { url: 'https://yourdomain.com/about', priority: 0.5 },
    ...productUrls,
  ];
}
```

## Image SEO

```tsx
import Image from 'next/image';

// Below-fold: lazy loaded
<Image
  src="/products/widget.webp"
  alt="Blue widget with USB-C port"  // Descriptive, not "product image"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>

// Hero / LCP image: preloaded
<Image
  src="/hero.webp"
  alt="Dashboard showing real-time analytics"
  width={1200}
  height={600}
  priority                           // Adds <link rel="preload"> to <head>
  placeholder="blur"
  blurDataURL={heroBlurUrl}
  sizes="100vw"
/>
```

## Internal Linking

```tsx
import Link from 'next/link';

// GOOD: descriptive anchor text
<Link href="/pricing">view pricing plans</Link>

// BAD: generic anchor text
<Link href="/pricing">click here</Link>
```

- Every important page reachable within 3 clicks from homepage
- Breadcrumbs on deep pages (`Home > Products > Widget`)
- No orphan pages (pages with zero internal links)

## Audit Checklist

```bash
# Find pages missing metadata export
find src/app -name 'page.tsx' -exec grep -L 'metadata\|generateMetadata' {} \; 2>/dev/null

# Find missing alt text
grep -rn '<Image' src/ --include='*.tsx' | grep -v 'alt=' | head -10

# Find pages with no h1
for f in $(find src/app -name 'page.tsx'); do
  grep -qL '<h1' "$f" && echo "MISSING H1: $f"
done

# Verify robots.txt and sitemap exist
[ -f public/robots.txt ] && echo "robots.txt: OK" || echo "MISSING: public/robots.txt"
[ -f app/sitemap.ts ] || [ -f src/app/sitemap.ts ] && echo "sitemap: OK" || echo "MISSING: app/sitemap.ts"
```

## Integration with Other Skills

- **structured-data**: JSON-LD schemas for rich snippets
- **core-web-vitals**: Page speed directly affects search ranking
- **accessibility**: Semantic HTML benefits both a11y and SEO
- **react-patterns**: Server Component patterns for SSR/SSG
