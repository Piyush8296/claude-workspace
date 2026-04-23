---
name: css-architecture
description: CSS architecture, Tailwind patterns, responsive design, design tokens, and styling best practices. Use when implementing designs, setting up styling infrastructure, or debugging layout issues.
---

# CSS Architecture

## Styling Strategy Decision

| Approach | When | Trade-offs |
|----------|------|------------|
| **Tailwind CSS** | Most components, rapid iteration | Verbose JSX, but zero unused CSS |
| **CSS Modules** | Complex animations, stateful styles | Scoped by default, slightly more setup |
| **CSS Custom Properties** | Theme tokens, dynamic values | Great for runtime theming |
| **Inline `style`** | Only truly dynamic values | `style={{ '--progress': `${pct}%` }}` |

## Tailwind CSS Patterns

### Class Order Convention

Follow a consistent order for readability:

```
layout > position > sizing > spacing > typography > visual > state > responsive
```

```tsx
<div className="
  flex items-center gap-4        {/* layout */}
  relative                        {/* position */}
  w-full max-w-md h-12           {/* sizing */}
  px-4 py-2 mt-6                 {/* spacing */}
  text-sm font-medium text-gray-900  {/* typography */}
  bg-white rounded-lg shadow-sm border  {/* visual */}
  hover:shadow-md focus:ring-2   {/* state */}
  md:max-w-lg lg:gap-6           {/* responsive */}
">
```

### Extracting Repeated Patterns

```typescript
// GOOD: Extract into a component (preserves tree-shaking)
function Badge({ variant, children }: BadgeProps) {
  const styles = {
    info: 'bg-blue-50 text-blue-700 ring-blue-600/20',
    success: 'bg-green-50 text-green-700 ring-green-600/20',
    warning: 'bg-yellow-50 text-yellow-800 ring-yellow-600/20',
    error: 'bg-red-50 text-red-700 ring-red-600/20',
  };

  return (
    <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${styles[variant]}`}>
      {children}
    </span>
  );
}

// AVOID: @apply in CSS (breaks tree-shaking)
// .badge { @apply inline-flex items-center rounded-md ... }
```

### Conditional Classes

```typescript
import { clsx } from 'clsx'; // or classnames
import { twMerge } from 'tailwind-merge';

// Utility for safe Tailwind class merging
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage
<button
  className={cn(
    'rounded-lg px-4 py-2 font-medium transition-colors',
    variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
    variant === 'ghost' && 'bg-transparent text-gray-700 hover:bg-gray-100',
    disabled && 'opacity-50 cursor-not-allowed',
  )}
/>
```

## Design Tokens

```css
/* globals.css */
:root {
  /* Spacing scale */
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-4: 1rem;     /* 16px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */

  /* Color tokens (semantic) */
  --color-text-primary: theme('colors.gray.900');
  --color-text-secondary: theme('colors.gray.600');
  --color-bg-primary: theme('colors.white');
  --color-bg-secondary: theme('colors.gray.50');
  --color-border: theme('colors.gray.200');
  --color-accent: theme('colors.blue.600');

  /* Elevation */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

/* Dark mode overrides */
.dark {
  --color-text-primary: theme('colors.gray.100');
  --color-bg-primary: theme('colors.gray.900');
  --color-border: theme('colors.gray.700');
}
```

## Responsive Patterns

### Mobile-First Breakpoints

```tsx
{/* Stack on mobile, row on desktop */}
<div className="flex flex-col gap-4 md:flex-row md:items-center">

{/* Full width on mobile, constrained on desktop */}
<div className="w-full md:max-w-md lg:max-w-lg">

{/* Hide on mobile, show on desktop */}
<nav className="hidden md:flex">

{/* Different grid columns per breakpoint */}
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
```

### Container Query Pattern

```tsx
<div className="@container">
  <div className="flex flex-col @md:flex-row @lg:grid @lg:grid-cols-3">
    {/* Responds to container width, not viewport */}
  </div>
</div>
```

## Z-Index Scale

```css
:root {
  --z-base: 0;
  --z-dropdown: 10;
  --z-sticky: 20;
  --z-overlay: 30;
  --z-modal: 40;
  --z-toast: 50;
}
```

Never use arbitrary z-index values. Always use the scale.

## Animation & Motion

```css
/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```tsx
// Transition utilities
<div className="transition-colors duration-150 ease-in-out">
<div className="transition-transform duration-200 hover:scale-105">
<div className="animate-pulse">  {/* Loading skeleton */}
```

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `style={{ marginTop: 20 }}` | `className="mt-5"` | No inline styles for layout |
| `!important` | Fix specificity at source | Maintenance nightmare |
| `px` for font sizes | `rem` | Accessibility (user font scaling) |
| Magic numbers | Design tokens / theme values | Consistency |
| `outline: none` | `outline: none` + custom `ring-2` | Accessibility |
| `@apply` for everything | Component extraction | Preserves tree-shaking |
| CSS-in-JS runtime | Tailwind / CSS Modules | Zero-runtime is better |

## Checklist

- [ ] Mobile-first responsive
- [ ] Tested at all breakpoints
- [ ] Touch targets ≥ 44x44px
- [ ] Color contrast ≥ 4.5:1
- [ ] Focus styles visible
- [ ] `prefers-reduced-motion` respected
- [ ] No horizontal scroll on any viewport
- [ ] Design tokens used (no magic numbers)
- [ ] Z-index uses the scale

## Integration with Other Skills

- **react-patterns**: Styling in component structure
- **accessibility**: Color contrast, focus styles, motion preferences
- **performance-optimization**: CSS bundle size, rendering performance
