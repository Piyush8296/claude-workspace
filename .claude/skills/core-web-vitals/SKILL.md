---
name: core-web-vitals
description: Deep-dive into Core Web Vitals — LCP, INP, CLS diagnosis and fix recipes for React/Next.js. Specific patterns for each metric with measurement tools, thresholds, and real-world fixes. Use when pages are slow, Lighthouse scores are low, or search ranking is affected by performance.
---

# Core Web Vitals

## The Three Metrics That Affect Search Ranking

| Metric | Measures | Good | Needs Work | Poor |
|--------|----------|------|------------|------|
| **LCP** (Largest Contentful Paint) | Loading speed | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | Responsiveness | ≤ 200ms | ≤ 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | ≤ 0.1 | ≤ 0.25 | > 0.25 |

## LCP — Largest Contentful Paint

**What it measures:** How fast the biggest visible element loads (hero image, headline, video poster).

### Diagnosis

```bash
# Run Lighthouse to identify LCP element
npx lighthouse http://localhost:3000 --output=json --quiet | \
  jq '.audits["largest-contentful-paint"]'

# Check which element is the LCP
npx lighthouse http://localhost:3000 --output=json --quiet | \
  jq '.audits["largest-contentful-paint-element"].details'
```

### Fix Recipes

**Hero image is the LCP element:**
```tsx
// BEFORE: lazy-loaded hero (kills LCP)
<Image src="/hero.jpg" alt="..." loading="lazy" />

// AFTER: preloaded, priority hero
<Image
  src="/hero.webp"              // Modern format
  alt="Product hero showing the dashboard"
  width={1200}
  height={600}
  priority                       // Preloads in <head>
  fetchPriority="high"           // Browser fetch priority
  sizes="100vw"                  // Full-width
  placeholder="blur"             // Instant placeholder
  blurDataURL={heroBlurDataUrl}  // Base64 blur
/>
```

**Headline text is the LCP element:**
```css
/* Preload the heading font */
<link rel="preload" href="/fonts/heading.woff2" as="font" type="font/woff2" crossorigin />

@font-face {
  font-family: 'Heading';
  src: url('/fonts/heading.woff2') format('woff2');
  font-display: swap;    /* Show fallback immediately */
}
```

**Server response is slow:**
```typescript
// Switch from SSR to SSG/ISR for static content
// app/products/[slug]/page.tsx
export const revalidate = 3600;  // ISR: regenerate every hour

// Or generate at build time
export async function generateStaticParams() {
  const products = await getAllProducts();
  return products.map((p) => ({ slug: p.slug }));
}
```

**Render-blocking resources:**
```tsx
// Move non-critical JS to dynamic imports
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false,
});

// Defer third-party scripts
<Script src="https://analytics.example.com" strategy="lazyOnload" />
```

## INP — Interaction to Next Paint

**What it measures:** Delay between user interaction (click, tap, keypress) and the next visual update.

### Diagnosis

INP is hard to catch in lab tests — it requires real user interactions.

```typescript
// Add web-vitals monitoring
import { onINP } from 'web-vitals';

onINP((metric) => {
  console.log('INP:', metric.value, 'ms');
  console.log('Element:', metric.attribution?.interactionTarget);
  console.log('Type:', metric.attribution?.interactionType);
  // Send to analytics
});
```

### Fix Recipes

**Heavy computation blocking the main thread:**
```typescript
// BEFORE: synchronous filter on 10K items
function handleSearch(query: string) {
  const results = allItems.filter(item =>
    item.name.toLowerCase().includes(query.toLowerCase())
  );
  setResults(results);  // Blocks paint until done
}

// AFTER: debounce + startTransition
import { startTransition } from 'react';

const debouncedQuery = useDebounce(query, 150);

useEffect(() => {
  startTransition(() => {
    const results = allItems.filter(item =>
      item.name.toLowerCase().includes(debouncedQuery.toLowerCase())
    );
    setResults(results);
  });
}, [debouncedQuery]);
```

**Large re-renders on interaction:**
```tsx
// BEFORE: entire list re-renders on selection
function ItemList({ items, selectedId, onSelect }) {
  return items.map(item => (
    <Item
      key={item.id}
      item={item}
      isSelected={item.id === selectedId}
      onSelect={onSelect}
    />
  ));
}

// AFTER: memoize individual items
const MemoItem = memo(function Item({ item, isSelected, onSelect }) {
  return (
    <div
      role="option"
      aria-selected={isSelected}
      onClick={() => onSelect(item.id)}
    >
      {item.name}
    </div>
  );
});
```

**Long event handlers:**
```typescript
// BEFORE: heavy work in click handler
async function handleSubmit() {
  validateForm();          // 50ms
  transformData();         // 100ms
  await submitToAPI();     // Network
  updateLocalState();      // 30ms
  showSuccessToast();      // 10ms
}  // Total: 190ms+ before any paint

// AFTER: yield to browser between steps
async function handleSubmit() {
  setIsSubmitting(true);   // Paint: show loading

  // Yield to let the loading state paint
  await new Promise(resolve => setTimeout(resolve, 0));

  const data = transformData();
  await submitToAPI(data);
  updateLocalState();
  showSuccessToast();
}
```

## CLS — Cumulative Layout Shift

**What it measures:** How much the page layout shifts unexpectedly while loading.

### Diagnosis

```typescript
import { onCLS } from 'web-vitals';

onCLS((metric) => {
  console.log('CLS:', metric.value);
  metric.entries.forEach((entry) => {
    console.log('Shifted element:', entry.sources?.[0]?.node);
  });
});
```

### Fix Recipes

**Images without dimensions:**
```tsx
// BEFORE: no dimensions = layout shift when image loads
<img src="/photo.jpg" alt="..." />

// AFTER: explicit dimensions prevent shift
<Image src="/photo.jpg" alt="..." width={800} height={600} />

// For responsive images with unknown aspect ratio:
<div style={{ aspectRatio: '16/9', position: 'relative' }}>
  <Image src="/photo.jpg" alt="..." fill style={{ objectFit: 'cover' }} />
</div>
```

**Dynamic content injected above viewport:**
```tsx
// BEFORE: banner appears and pushes everything down
{showBanner && <Banner />}  // CLS when banner loads

// AFTER: reserve space with min-height
<div style={{ minHeight: showBanner ? 'auto' : 0 }}>
  {showBanner && <Banner />}
</div>

// OR: use CSS containment
<div style={{ contentVisibility: 'auto', containIntrinsicSize: '0 60px' }}>
  {showBanner && <Banner />}
</div>
```

**Web fonts causing reflow:**
```css
@font-face {
  font-family: 'Body';
  src: url('/fonts/body.woff2') format('woff2');
  font-display: swap;              /* Show fallback immediately */
  size-adjust: 105%;               /* Match fallback metrics */
  ascent-override: 95%;
  descent-override: 22%;
  line-gap-override: 0%;
}
```

## Measurement Tools

| Tool | Lab / Field | Best For |
|------|-------------|----------|
| Lighthouse | Lab | Quick local audits |
| Chrome DevTools Performance | Lab | Trace individual interactions |
| PageSpeed Insights | Field + Lab | Real CrUX data + Lighthouse |
| web-vitals (npm) | Field | Production monitoring |
| Chrome UX Report (CrUX) | Field | 28-day real user data |

## Production Monitoring Setup

```typescript
// lib/web-vitals.ts
import { onLCP, onINP, onCLS } from 'web-vitals';

function sendToAnalytics(metric: { name: string; value: number; id: string }) {
  // Send to your analytics endpoint
  navigator.sendBeacon('/api/vitals', JSON.stringify({
    name: metric.name,
    value: Math.round(metric.value),
    id: metric.id,
    page: window.location.pathname,
    timestamp: Date.now(),
  }));
}

export function initWebVitals() {
  onLCP(sendToAnalytics);
  onINP(sendToAnalytics);
  onCLS(sendToAnalytics);
}
```

## Checklist

- [ ] LCP element identified and optimized (preload, priority, modern format)
- [ ] Hero fonts preloaded with `font-display: swap`
- [ ] No render-blocking third-party scripts
- [ ] Heavy components code-split with `dynamic()`
- [ ] Event handlers don't block main thread > 100ms
- [ ] All images have explicit width/height or aspect-ratio
- [ ] No content injected above fold without reserved space
- [ ] Web fonts use `size-adjust` to match fallback metrics
- [ ] web-vitals monitoring in production
- [ ] Lighthouse score > 90 on all key pages

## Integration with Other Skills

- **performance-optimization**: Bundle splitting, lazy loading, virtualization
- **seo-fundamentals**: Page speed directly affects search ranking
- **css-architecture**: Font loading, responsive images
- **react-patterns**: Component patterns that affect rendering performance
