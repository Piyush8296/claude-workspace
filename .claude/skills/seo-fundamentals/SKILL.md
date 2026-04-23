---
name: seo-fundamentals
description: Frontend SEO for React and Next.js — meta tags, canonical URLs, Open Graph, Twitter cards, robots.txt, sitemap, SSR vs CSR implications, heading hierarchy, and crawlability. Use when building pages, setting up metadata, or optimizing for search visibility.
---

# SEO Fundamentals

## The Frontend Developer's SEO Checklist

SEO isn't a marketing afterthought — it's structural. If you ship a React SPA with no SSR and no meta tags, Google indexes an empty `<div id="root">`. This skill covers what frontend engineers need to get right in code.

## Meta Tags (Every Page)

### Next.js App Router (Metadata API)

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

### Manual `<head>` (Vite / CRA)

```tsx
import { Helmet } from 'react-helmet-async';

function ProductPage({ product }: { product: Product }) {
  return (
    <>
      <Helmet>
        <title>{product.name} | YourBrand</title>
        <meta name="description" content={product.summary.slice(0, 155)} />
        <link rel="canonical" href={`https://yourdomain.com/products/${product.slug}`} />
        <meta property="og:title" content={product.name} />
        <meta property="og:description" content={product.summary.slice(0, 155)} />
        <meta property="og:image" content={product.ogImage} />
        <meta property="og:url" content={`https://yourdomain.com/products/${product.slug}`} />
        <meta property="og:type" content="website" />
        <meta name="twitter:card" content="summary_large_image" />
      </Helmet>
      {/* Page content */}
    </>
  );
}
```

## Rendering Strategy & Crawlability

| Strategy | Crawlable? | When to Use |
|----------|-----------|-------------|
| **SSG** (Static Generation) | Yes — best for SEO | Marketing pages, blog posts, docs |
| **SSR** (Server Rendering) | Yes | Dynamic pages with SEO needs (products, profiles) |
| **ISR** (Incremental Static) | Yes | Frequently updated content with many pages |
| **CSR** (Client-only SPA) | No — Google sees empty div | Internal tools, dashboards, authenticated areas |

**Rule:** Any page that needs to rank in search MUST be SSG, SSR, or ISR. Never CSR.

## Heading Hierarchy

```html
<!-- CORRECT: sequential, single h1 -->
<h1>Product Name</h1>              <!-- One per page -->
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
// app/sitemap.ts (Next.js)
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
// GOOD: optimized, accessible, crawlable
<Image
  src="/products/widget.webp"       // Modern format
  alt="Blue widget with USB-C port"  // Descriptive, not "product image"
  width={800}
  height={600}                       // Prevents CLS
  loading="lazy"                     // Below fold
  sizes="(max-width: 768px) 100vw, 50vw"  // Responsive
/>

// For hero/LCP images:
<Image ... priority loading="eager" fetchPriority="high" />
```

## Internal Linking

- Use descriptive anchor text: `<a href="/pricing">view pricing plans</a>` not `<a href="/pricing">click here</a>`
- Every important page reachable within 3 clicks from homepage
- Breadcrumbs on deep pages (`Home > Products > Widget`)
- No orphan pages (pages with zero internal links)

## Audit Checklist

```bash
# Find pages missing meta descriptions
grep -rL 'description' src/app/**/page.tsx 2>/dev/null | head -10

# Find missing alt text
grep -rn '<img\|<Image' src/ --include='*.tsx' | grep -v 'alt=' | head -10

# Find pages with no h1
for f in $(find src/app -name 'page.tsx'); do
  grep -qL '<h1\|<H1' "$f" && echo "MISSING H1: $f"
done

# Check robots.txt exists
[ -f public/robots.txt ] && echo "OK" || echo "MISSING: public/robots.txt"
```

## Integration with Other Skills

- **structured-data**: JSON-LD schemas for rich snippets
- **core-web-vitals**: Page speed directly affects search ranking
- **accessibility**: Semantic HTML benefits both a11y and SEO
- **react-patterns**: SSR/SSG component patterns
