---
name: design-intelligence
description: Design intelligence database using Claude Design and Google Stitch for generating production-grade UI. Use when creating mockups, prototypes, design systems, or converting descriptions to high-fidelity screens. Covers style selection, palette generation, typography pairing, and design-to-code export.
---

# Design Intelligence

## Tool Selection

Two primary AI design tools for frontend teams:

| Tool | Best For | Code Export | Access |
|------|----------|-------------|--------|
| **Claude Design** | Prototypes, presentations, design system enforcement, iterative refinement via conversation | React, HTML/CSS | Claude Pro/Max/Team/Enterprise |
| **Google Stitch** | Multi-screen generation, rapid iteration, full app flows from natural language | HTML, CSS, Tailwind, Vue, Angular, Flutter, SwiftUI | Free (Google account) |

### When to Use Claude Design
- You need designs that match your existing codebase and design system
- Iterative refinement through conversation ("make the CTA more prominent")
- Generating presentations and visual prototypes alongside code
- Your team uses Claude for everything already

### When to Use Google Stitch
- Generating entire multi-screen flows from a single prompt (up to 5 screens)
- Rapid exploration with model selection (Gemini Pro for quality, Flash for speed)
- You need exports in frameworks beyond React (Vue, Angular, Flutter, SwiftUI)
- Free access with no usage caps

## Design System Generation Workflow

### Step 1: Define Design Tokens

Generate a complete token set from your brand identity:

```css
:root {
  /* Color Tokens */
  --color-primary-50:  #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  --color-primary-900: #1e3a5f;

  --color-accent-400:  #fbbf24;
  --color-accent-500:  #f59e0b;

  --color-neutral-50:  #fafafa;
  --color-neutral-100: #f5f5f5;
  --color-neutral-200: #e5e5e5;
  --color-neutral-500: #737373;
  --color-neutral-800: #262626;
  --color-neutral-900: #171717;

  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error:   #ef4444;
  --color-info:    #3b82f6;

  /* Typography Tokens */
  --font-display: 'Space Grotesk', sans-serif;
  --font-body:    'Inter', sans-serif;
  --font-mono:    'JetBrains Mono', monospace;

  /* Spacing Scale (8px grid) */
  --space-1:  0.25rem;   /* 4px  */
  --space-2:  0.5rem;    /* 8px  */
  --space-3:  0.75rem;   /* 12px */
  --space-4:  1rem;      /* 16px */
  --space-6:  1.5rem;    /* 24px */
  --space-8:  2rem;      /* 32px */
  --space-12: 3rem;      /* 48px */
  --space-16: 4rem;      /* 64px */
  --space-24: 6rem;      /* 96px */

  /* Border Radius */
  --radius-sm:   0.25rem;
  --radius-md:   0.5rem;
  --radius-lg:   0.75rem;
  --radius-xl:   1rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm:  0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md:  0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg:  0 10px 15px -3px rgb(0 0 0 / 0.1);
  --shadow-xl:  0 20px 25px -5px rgb(0 0 0 / 0.1);
}
```

### Step 2: Analyze Product + Audience

Before designing, determine:

| Factor | Impact on Design |
|--------|------------------|
| **Audience age** | Younger = bolder colors, larger touch targets; Older = higher contrast, larger text |
| **Product type** | SaaS = data-dense, clean; Consumer = emotional, visual; Enterprise = conservative, trustworthy |
| **Device primary** | Mobile-first = thumb zones, bottom nav; Desktop = sidebar nav, multi-column |
| **Brand personality** | Playful = rounded, colorful; Serious = sharp, monochrome; Luxury = thin fonts, dark |

### Step 3: Select Style Direction

Match the aesthetic to the product:

| Product Type | Recommended Style | Font Pairing | Palette Approach |
|--------------|-------------------|--------------|------------------|
| Developer tool | Brutalist / Monospace | JetBrains Mono + IBM Plex Sans | Dark bg, neon accents |
| Health app | Organic / Soft | Nunito + Source Sans 3 | Greens, warm neutrals |
| Fintech | Corporate Modern | Space Grotesk + Inter | Blues, grays, trust-building |
| E-commerce | Visual / Bold | Cabinet Grotesk + Satoshi | Product-color-driven |
| Creative agency | Editorial / Expressive | Playfair Display + Work Sans | Black/white + one bold accent |
| B2B SaaS | Clean / Efficient | Inter + DM Sans | Blue primary, gray neutrals |

## Component Design Patterns

### Card Component

```tsx
function ProductCard({ product }: { product: Product }) {
  return (
    <article className="group relative overflow-hidden rounded-xl border bg-white shadow-sm transition-all hover:shadow-lg hover:-translate-y-1">
      <div className="aspect-[4/3] overflow-hidden">
        <img
          src={product.image}
          alt={product.name}
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
          loading="lazy"
        />
      </div>
      <div className="p-4 space-y-2">
        <span className="text-xs font-medium uppercase tracking-wider text-primary-600">
          {product.category}
        </span>
        <h3 className="font-display text-lg font-semibold leading-tight">
          {product.name}
        </h3>
        <p className="text-sm text-neutral-600 line-clamp-2">
          {product.description}
        </p>
        <div className="flex items-center justify-between pt-2">
          <span className="text-lg font-bold">${product.price}</span>
          <button className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-primary-700 focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2">
            Add to Cart
          </button>
        </div>
      </div>
    </article>
  );
}
```

### Dashboard Layout

```tsx
function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen bg-neutral-50">
      {/* Sidebar */}
      <aside className="hidden w-64 flex-shrink-0 border-r bg-white lg:block">
        <nav className="flex h-full flex-col gap-1 p-4">
          {/* Nav items */}
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto">
        <header className="sticky top-0 z-10 flex h-16 items-center border-b bg-white/80 backdrop-blur px-6">
          {/* Top bar */}
        </header>
        <div className="p-6">
          {children}
        </div>
      </main>
    </div>
  );
}
```

## Pre-Delivery Design QA Checklist

- [ ] **Contrast ratio**: All text meets 4.5:1 (AA) minimum
- [ ] **Touch targets**: All interactive elements 44x44px minimum on mobile
- [ ] **Responsive breakpoints**: Tested at 375, 768, 1024, 1440px
- [ ] **Focus indicators**: Visible ring on every focusable element
- [ ] **Hover states**: Every button, card, and link has hover feedback
- [ ] **Loading states**: Skeleton screens matching content shape
- [ ] **Empty states**: Helpful message with illustration and CTA
- [ ] **Error states**: Clear message, retry action, supportive tone
- [ ] **Dark mode**: Proper color token inversion if supported
- [ ] **Motion**: `prefers-reduced-motion` media query respected
- [ ] **Typography hierarchy**: Clear visual distinction between h1/h2/h3/body/caption
- [ ] **Spacing consistency**: All values from the spacing scale, no magic numbers

## Integration with Other Skills

- **frontend-design**: Aesthetic direction, typography, micro-interactions
- **css-architecture**: Implementation with Tailwind/CSS Modules
- **accessibility**: Contrast, focus, ARIA for design components
- **react-patterns**: Component structure for design system components
