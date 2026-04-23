---
name: seo-fundamentals
description: Frontend SEO for React and Next.js — Metadata API, meta tags, canonical URLs, Open Graph, Twitter cards, robots.txt, sitemap, SSR/SSG/ISR rendering strategy, heading hierarchy, and crawlability. Use when building pages, setting up metadata, or optimizing for search visibility.
---

# SEO Fundamentals

## The Frontend Developer's SEO Checklist

SEO isn't a marketing afterthought — it's structural. If you ship a client-rendered page with no meta tags, Google indexes an empty shell. This skill covers what frontend engineers need to get right in code for both React and Next.js projects.

## Meta Tags — Next.js (App Router)

### Static Metadata

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

### Dynamic Metadata

```typescript
// app/products/[slug]/page.tsx
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const product = await getProduct(params.slug);

  return {
    title: `${product.name} | YourBrand`,
    description: product.summary.slice(0, 155),
    alternates: {
      canonical: `https://yourdomain.com/products/${params.slug}`,
    },
    openGraph: {
      title: product.name,
      description: product.summary.slice(0, 155),
      url: `https://yourdomain.com/products/${params.slug}`,
      siteName: 'YourBrand',
      images: [{ url: product.ogImage, width: 1200, height: 630, alt: product.name }],
      type: 'website',
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.summary.slice(0, 155),
      images: [product.ogImage],
    },
    robots: { index: product.isPublished, follow: true },
  };
}
```

### Layout-Level Defaults

```typescript
// app/layout.tsx — site-wide defaults inherited by all pages
export const metadata: Metadata = {
  metadataBase: new URL('https://yourdomain.com'),
  title: {
    default: 'YourBrand',
    template: '%s | YourBrand',  // Child pages: title: 'About' → 'About | YourBrand'
  },
  description: 'Default site description.',
  openGraph: { siteName: 'YourBrand', locale: 'en_US', type: 'website' },
  twitter: { card: 'summary_large_image', creator: '@yourbrand' },
  robots: { index: true, follow: true },
};
```

## Meta Tags — React (Vite / CRA)

For plain React apps without Next.js, manage `<head>` tags with a lightweight custom hook — no external dependency needed:

```typescript
// hooks/useSEO.ts
import { useEffect } from 'react';

interface SEOProps {
  title: string;
  description: string;
  canonical?: string;
  ogImage?: string;
  ogType?: string;
  noindex?: boolean;
}

export function useSEO({ title, description, canonical, ogImage, ogType = 'website', noindex = false }: SEOProps) {
  useEffect(() => {
    document.title = title;

    const setMeta = (property: string, content: string) => {
      let el = document.querySelector(`meta[property="${property}"], meta[name="${property}"]`) as HTMLMetaElement;
      if (!el) {
        el = document.createElement('meta');
        el.setAttribute(property.startsWith('og:') || property.startsWith('twitter:') ? 'property' : 'name', property);
        document.head.appendChild(el);
      }
      el.content = content;
    };

    const setLink = (rel: string, href: string) => {
      let el = document.querySelector(`link[rel="${rel}"]`) as HTMLLinkElement;
      if (!el) {
        el = document.createElement('link');
        el.rel = rel;
        document.head.appendChild(el);
      }
      el.href = href;
    };

    setMeta('description', description);
    setMeta('og:title', title);
    setMeta('og:description', description);
    setMeta('og:type', ogType);
    setMeta('twitter:card', 'summary_large_image');
    setMeta('twitter:title', title);
    setMeta('twitter:description', description);

    if (canonical) {
      setLink('canonical', canonical);
      setMeta('og:url', canonical);
    }
    if (ogImage) {
      setMeta('og:image', ogImage);
      setMeta('twitter:image', ogImage);
    }
    if (noindex) {
      setMeta('robots', 'noindex, nofollow');
    }
  }, [title, description, canonical, ogImage, ogType, noindex]);
}
```

```tsx
// Usage in any page component
function ProductPage({ product }: { product: Product }) {
  useSEO({
    title: `${product.name} | YourBrand`,
    description: product.summary.slice(0, 155),
    canonical: `https://yourdomain.com/products/${product.slug}`,
    ogImage: product.ogImage,
  });

  return <div>{/* page content */}</div>;
}
```

**Important for React SPAs:** Client-rendered meta tags work for social previews (Twitter, Facebook crawlers execute JS) but are unreliable for Google ranking. If SEO matters, use SSR (Next.js, Remix) or pre-rendering (react-snap, Prerender.io).

## Rendering Strategy & Crawlability

| Strategy | Framework | Crawlable? | When to Use |
|----------|-----------|-----------|-------------|
| **SSG** | Next.js (`generateStaticParams`) | Yes — best | Marketing, blog, docs |
| **SSR** | Next.js (default server components) | Yes | Dynamic SEO pages |
| **ISR** | Next.js (`revalidate = 3600`) | Yes | Updated content, many pages |
| **Pre-rendering** | React + react-snap / Prerender.io | Yes | SPA that needs basic SEO |
| **CSR** | React (plain Vite/CRA) | No | Dashboards, auth-gated areas |

```typescript
// Next.js: SSG
export async function generateStaticParams() {
  const products = await getAllProducts();
  return products.map((p) => ({ slug: p.slug }));
}

// Next.js: ISR
export const revalidate = 3600;

// Next.js: Force SSR
export const dynamic = 'force-dynamic';
```

**Rule:** Any page that needs to rank in search MUST use SSG, SSR, ISR, or pre-rendering. Pure CSR is invisible to crawlers.

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

**Rules:** One `<h1>` per page. Sequential hierarchy. Headings describe structure, not visual styling.

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
// Next.js: app/sitemap.ts
import type { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getAllProducts();
  return [
    { url: 'https://yourdomain.com', lastModified: new Date(), priority: 1.0 },
    { url: 'https://yourdomain.com/about', priority: 0.5 },
    ...products.map((p) => ({
      url: `https://yourdomain.com/products/${p.slug}`,
      lastModified: p.updatedAt,
      changeFrequency: 'weekly' as const,
      priority: 0.8,
    })),
  ];
}
```

For plain React, generate `sitemap.xml` as a static file in `public/` or via a build script.

## Image SEO

```tsx
// Next.js: uses next/image
import Image from 'next/image';

<Image
  src="/products/widget.webp"
  alt="Blue widget with USB-C port"  // Descriptive, not "product image"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>

// Hero / LCP image: preloaded
<Image src="/hero.webp" alt="..." width={1200} height={600} priority placeholder="blur" />

// Plain React: use native <img> with lazy loading
<img
  src="/products/widget.webp"
  alt="Blue widget with USB-C port"
  width={800}
  height={600}
  loading="lazy"
  decoding="async"
/>
```

## Internal Linking

```tsx
// Next.js
import Link from 'next/link';
<Link href="/pricing">view pricing plans</Link>

// React Router
import { Link } from 'react-router-dom';
<Link to="/pricing">view pricing plans</Link>

// BAD: generic anchor text
<a href="/pricing">click here</a>
```

- Every important page reachable within 3 clicks from homepage
- Breadcrumbs on deep pages (`Home > Products > Widget`)
- No orphan pages (pages with zero internal links)

## Audit Checklist

```bash
# Next.js: find pages missing metadata export
find src/app -name 'page.tsx' -exec grep -L 'metadata\|generateMetadata' {} \; 2>/dev/null

# React: find pages missing useSEO hook
grep -rL 'useSEO\|<Helmet\|document.title' src/pages/ --include='*.tsx' 2>/dev/null

# Both: find missing alt text
grep -rn '<img\|<Image' src/ --include='*.tsx' | grep -v 'alt=' | head -10

# Both: find pages with no h1
for f in $(find src -name 'page.tsx' -o -name 'Page.tsx' -o -name '*.page.tsx' 2>/dev/null); do
  grep -qL '<h1' "$f" && echo "MISSING H1: $f"
done

# Verify robots.txt exists
[ -f public/robots.txt ] && echo "robots.txt: OK" || echo "MISSING: public/robots.txt"
```

## Integration with Other Skills

- **structured-data**: JSON-LD schemas for rich snippets
- **core-web-vitals**: Page speed directly affects search ranking
- **accessibility**: Semantic HTML benefits both a11y and SEO
- **react-patterns**: Server Component / SSR patterns
