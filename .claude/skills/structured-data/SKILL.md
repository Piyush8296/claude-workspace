---
name: structured-data
description: JSON-LD structured data and schema markup for React/Next.js — Organization, Article, Product, FAQ, BreadcrumbList, HowTo, WebSite with search. Also covers GEO/AEO optimization for AI search engines (Google AI Overviews, Perplexity, ChatGPT). Use when adding rich snippets, building product pages, or optimizing for AI search.
---

# Structured Data & Schema Markup

## Why This Matters

Structured data tells search engines (and AI search) what your content IS, not just what it says. A product page with JSON-LD gets rich snippets (price, rating, availability). Without it, you're just another blue link.

## JSON-LD Implementation in React

### Next.js Pattern

```typescript
// components/JsonLd.tsx
interface JsonLdProps {
  data: Record<string, unknown>;
}

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

### Organization Schema (Site-wide)

```typescript
// app/layout.tsx
const organizationSchema = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'YourBrand',
  url: 'https://yourdomain.com',
  logo: 'https://yourdomain.com/logo.png',
  sameAs: [
    'https://twitter.com/yourbrand',
    'https://linkedin.com/company/yourbrand',
    'https://github.com/yourbrand',
  ],
  contactPoint: {
    '@type': 'ContactPoint',
    email: 'support@yourdomain.com',
    contactType: 'customer support',
  },
};

<JsonLd data={organizationSchema} />
```

### WebSite with Search (Sitelinks Searchbox)

```typescript
const websiteSchema = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'YourBrand',
  url: 'https://yourdomain.com',
  potentialAction: {
    '@type': 'SearchAction',
    target: {
      '@type': 'EntryPoint',
      urlTemplate: 'https://yourdomain.com/search?q={search_term_string}',
    },
    'query-input': 'required name=search_term_string',
  },
};
```

### Article / Blog Post

```typescript
function articleSchema(post: BlogPost) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    image: post.coverImage,
    datePublished: post.publishedAt,
    dateModified: post.updatedAt,
    author: {
      '@type': 'Person',
      name: post.author.name,
      url: post.author.profileUrl,
    },
    publisher: {
      '@type': 'Organization',
      name: 'YourBrand',
      logo: { '@type': 'ImageObject', url: 'https://yourdomain.com/logo.png' },
    },
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://yourdomain.com/blog/${post.slug}`,
    },
  };
}
```

### Product

```typescript
function productSchema(product: Product) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    image: product.images,
    description: product.description,
    brand: { '@type': 'Brand', name: 'YourBrand' },
    sku: product.sku,
    offers: {
      '@type': 'Offer',
      price: product.price,
      priceCurrency: 'USD',
      availability: product.inStock
        ? 'https://schema.org/InStock'
        : 'https://schema.org/OutOfStock',
      url: `https://yourdomain.com/products/${product.slug}`,
    },
    aggregateRating: product.ratingCount > 0 ? {
      '@type': 'AggregateRating',
      ratingValue: product.averageRating,
      reviewCount: product.ratingCount,
    } : undefined,
  };
}
```

### FAQ

```typescript
function faqSchema(faqs: Array<{ question: string; answer: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((faq) => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  };
}
```

### BreadcrumbList

```typescript
function breadcrumbSchema(items: Array<{ name: string; url: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: item.url,
    })),
  };
}

// Usage
<JsonLd data={breadcrumbSchema([
  { name: 'Home', url: 'https://yourdomain.com' },
  { name: 'Products', url: 'https://yourdomain.com/products' },
  { name: product.name, url: `https://yourdomain.com/products/${product.slug}` },
])} />
```

## GEO / AEO — AI Search Optimization

Google AI Overviews, Perplexity, and ChatGPT search don't just crawl — they extract and cite. To appear in AI answers:

### Citability Patterns

```html
<!-- Clear, factual statements that AI can quote -->
<p>React 18 introduced concurrent rendering, enabling features like
   Suspense for data fetching and automatic batching of state updates.</p>

<!-- Definition-style content AI loves to cite -->
<dl>
  <dt>Server Components</dt>
  <dd>React components that render on the server, reducing client bundle size
      by keeping server-only code out of the browser.</dd>
</dl>

<!-- Structured comparison tables -->
<table>
  <thead><tr><th>Feature</th><th>SSG</th><th>SSR</th><th>CSR</th></tr></thead>
  <tbody>...</tbody>
</table>
```

### Content Structure for AI Extraction

- Lead with the answer, then explain (inverted pyramid)
- Use definition lists for terminology
- Tables for comparisons — AI models parse tables well
- Number your steps in how-to content
- Include "last updated" dates for freshness signals

## Validation

```bash
# Test with Google's Rich Results Test
# https://search.google.com/test/rich-results

# Validate JSON-LD syntax
find src/ -name '*.tsx' -exec grep -l 'application/ld+json' {} \; | head -10

# Check for common schema errors
grep -rn 'application/ld+json' src/ --include='*.tsx' -A 5 | grep -E '@type|@context'
```

## Checklist

- [ ] Organization schema on layout (site-wide)
- [ ] WebSite schema with SearchAction on homepage
- [ ] Article schema on all blog posts
- [ ] Product schema on product pages (with price, availability, rating)
- [ ] FAQ schema on FAQ sections
- [ ] BreadcrumbList on deep pages
- [ ] JSON-LD validates in Rich Results Test
- [ ] Content structured for AI citability

## Integration with Other Skills

- **seo-fundamentals**: Meta tags, canonical URLs, OG tags
- **react-patterns**: Component for JsonLd injection
- **accessibility**: Semantic HTML also helps structured data extraction
