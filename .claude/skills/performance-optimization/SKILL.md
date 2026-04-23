---
name: performance-optimization
description: Frontend performance patterns — Core Web Vitals, bundle optimization, React rendering, lazy loading, memoization. Use when optimizing load times, investigating performance issues, or auditing before launch.
---

# Performance Optimization

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |

## Bundle Optimization

### Code Splitting

```typescript
import { lazy, Suspense } from 'react';

// Route-level splitting (mandatory)
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

// Component-level splitting (for heavy components)
const MarkdownEditor = lazy(() => import('./components/MarkdownEditor'));
const ChartWidget = lazy(() => import('./components/ChartWidget'));

// Always wrap with Suspense + meaningful fallback
<Suspense fallback={<DashboardSkeleton />}>
  <Dashboard />
</Suspense>
```

### Tree-Shaking

```typescript
// BAD: imports entire library
import _ from 'lodash';
_.debounce(fn, 300);

// GOOD: imports only what's needed
import debounce from 'lodash/debounce';
debounce(fn, 300);

// BEST: use native or lightweight alternative
function debounce<T extends (...args: unknown[]) => void>(fn: T, ms: number) {
  let timer: ReturnType<typeof setTimeout>;
  return (...args: Parameters<T>) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
}
```

### Import Analysis

```bash
# Analyze bundle composition
npx vite-bundle-visualizer    # Vite
npx @next/bundle-analyzer     # Next.js

# Find heavy dependencies
du -sh node_modules/* | sort -rh | head -20
```

## React Rendering Optimization

### When to Memoize

```typescript
// MEMOIZE: Expensive computation
const sortedItems = useMemo(
  () => items.sort((a, b) => b.date - a.date),
  [items]
);

// MEMOIZE: Referential stability for child components
const handleSubmit = useCallback(
  (data: FormData) => {
    submitMutation.mutate(data);
  },
  [submitMutation.mutate]
);

// DON'T MEMOIZE: Simple computation
// const fullName = useMemo(() => `${first} ${last}`, [first, last]);
const fullName = `${first} ${last}`; // Just compute it

// DON'T MEMOIZE: Primitive props
// const title = useMemo(() => 'Hello', []);
const title = 'Hello'; // Primitives are already stable
```

**Rule of thumb:** Profile first, memoize second. `useMemo`/`useCallback` add complexity — use only when measured impact.

### Preventing Unnecessary Re-renders

```typescript
// BAD: New object every render
<UserCard style={{ marginTop: 16 }} />

// GOOD: Stable reference
const cardStyle = { marginTop: 16 } as const; // Outside component
<UserCard style={cardStyle} />

// BAD: Inline function creates new reference
<List onItemClick={(id) => navigate(`/item/${id}`)} />

// GOOD: Stable callback
const handleItemClick = useCallback(
  (id: string) => navigate(`/item/${id}`),
  [navigate]
);
<List onItemClick={handleItemClick} />
```

### Virtualization for Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 64, // Estimated row height
    overscan: 5,
  });

  return (
    <div ref={parentRef} className="h-[600px] overflow-auto">
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: 0,
              transform: `translateY(${virtualItem.start}px)`,
              height: `${virtualItem.size}px`,
              width: '100%',
            }}
          >
            <ItemRow item={items[virtualItem.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Use virtualization when:** List has 100+ items, or items are complex components.

## Image Optimization

```tsx
// Next.js Image (automatic optimization)
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero banner showing the product dashboard"
  width={1200}
  height={600}
  priority          // LCP image: preload it
  placeholder="blur" // Show blur while loading
/>

// Non-Next.js: native lazy loading
<img
  src="/photo.jpg"
  alt="Team photo"
  loading="lazy"               // Browser-native lazy loading
  decoding="async"             // Non-blocking decode
  width={400}
  height={300}                 // Always set dimensions (CLS prevention)
/>
```

## Font Loading

```css
/* Preload critical fonts */
<link rel="preload" href="/fonts/inter-var.woff2" as="font" type="font/woff2" crossorigin>

@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-display: swap; /* Show fallback immediately, swap when loaded */
  font-weight: 100 900;
}
```

## Network Performance

```typescript
// Parallel fetching instead of sequential
// BAD: waterfall
const user = await fetchUser(id);
const posts = await fetchPosts(id);
const comments = await fetchComments(id);

// GOOD: parallel
const [user, posts, comments] = await Promise.all([
  fetchUser(id),
  fetchPosts(id),
  fetchComments(id),
]);

// Prefetching on hover
function NavLink({ href, children }: NavLinkProps) {
  const queryClient = useQueryClient();
  
  return (
    <Link
      href={href}
      onMouseEnter={() => {
        queryClient.prefetchQuery({
          queryKey: ['page', href],
          queryFn: () => fetchPageData(href),
        });
      }}
    >
      {children}
    </Link>
  );
}
```

## Performance Checklist

- [ ] Route-level code splitting for all pages
- [ ] Images optimized: lazy loading, proper dimensions, modern formats
- [ ] Fonts: preloaded, `font-display: swap`
- [ ] No unnecessary re-renders (profile with React DevTools)
- [ ] Long lists virtualized (100+ items)
- [ ] API calls parallelized where possible
- [ ] Third-party scripts deferred/async
- [ ] Bundle analyzed for unnecessary dependencies
- [ ] CLS: all images/embeds have dimensions
- [ ] LCP element identified and optimized

## Integration with Other Skills

- **react-patterns**: Component structure affects rendering
- **state-management**: Store selectors prevent re-renders
- **css-architecture**: CSS strategy affects paint performance
