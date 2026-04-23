---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces. Use when building landing pages, dashboards, marketing sites, or any UI that needs to look polished and intentional — not generic AI-generated.
---

# Frontend Design

## Core Principle

**No generic AI slop.** Every interface you build should have a clear aesthetic direction, intentional typography, and a constrained color palette. If it looks like every other AI-generated page, it's wrong.

## Aesthetic Direction

Before writing any code, pick ONE bold direction:

| Style | Characteristics | Good For |
|-------|----------------|----------|
| **Brutalist** | Raw, bold typography, thick borders, monospace, high contrast | Developer tools, creative agencies |
| **Editorial** | Large serif headlines, generous whitespace, magazine feel | Blogs, media, content platforms |
| **Luxury** | Thin fonts, dark backgrounds, subtle animations, restrained palette | Premium products, fashion, finance |
| **Retro-Futuristic** | Neon accents, dark UI, glowing borders, space-age typography | Gaming, crypto, tech startups |
| **Organic** | Soft gradients, rounded corners, warm colors, natural imagery | Health, wellness, food, education |
| **Corporate Modern** | Clean sans-serif, blue/gray palette, structured grid, data-dense | B2B SaaS, enterprise, dashboards |

## Typography Rules

### Font Selection
- **Never use Arial, Inter, or system-ui alone** — they scream "I didn't think about this"
- Pick ONE display/heading font and ONE body font
- Contrast matters: pair a serif heading with a sans-serif body, or vice versa

### Recommended Pairings

| Heading | Body | Vibe |
|---------|------|------|
| **Playfair Display** | Source Sans 3 | Editorial, elegant |
| **Space Grotesk** | Inter | Modern tech |
| **Fraunces** | Work Sans | Friendly, warm |
| **JetBrains Mono** | IBM Plex Sans | Developer, brutalist |
| **Instrument Serif** | DM Sans | Premium, clean |
| **Cabinet Grotesk** | Satoshi | Startup, fresh |

### Scale

```css
/* Type scale: 1.250 (Major Third) */
--text-xs:   0.8rem;    /* 12.8px */
--text-sm:   1rem;      /* 16px   */
--text-base: 1.25rem;   /* 20px   */
--text-lg:   1.563rem;  /* 25px   */
--text-xl:   1.953rem;  /* 31.25px */
--text-2xl:  2.441rem;  /* 39px   */
--text-3xl:  3.052rem;  /* 48.8px */
--text-hero: 4.768rem;  /* 76.3px */
```

## Color Palette

### Constraint: 1 Primary + 1 Accent + Neutrals

Don't use 8 colors. Constraint breeds distinction.

```css
:root {
  /* Primary: your brand */
  --color-primary: #2563eb;
  --color-primary-light: #3b82f6;
  --color-primary-dark: #1d4ed8;

  /* Accent: for CTAs, highlights, emphasis */
  --color-accent: #f59e0b;
  --color-accent-light: #fbbf24;

  /* Neutrals: the backbone */
  --color-bg: #fafafa;
  --color-surface: #ffffff;
  --color-text: #111827;
  --color-text-secondary: #6b7280;
  --color-border: #e5e7eb;
}
```

### Dark Mode

Invert the neutrals, keep the hues. Reduce saturation slightly for eye comfort.

## Micro-Interactions

**Every interactive element needs a response.** Dead-feeling UIs are the hallmark of AI-generated pages.

```css
/* Button hover: lift + shadow */
.btn {
  transition: transform 150ms ease, box-shadow 150ms ease;
}
.btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.btn:active {
  transform: translateY(0);
}

/* Card hover: subtle lift */
.card {
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.1);
}

/* Link hover: underline animation */
.link {
  text-decoration: none;
  background-image: linear-gradient(currentColor, currentColor);
  background-size: 0 1px;
  background-position: 0 100%;
  background-repeat: no-repeat;
  transition: background-size 300ms ease;
}
.link:hover {
  background-size: 100% 1px;
}

/* Focus: ring, not outline */
:focus-visible {
  outline: none;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.4);
  border-radius: 4px;
}
```

## Loading States

**Skeleton screens, never spinners.** Skeletons preview the content shape. Spinners say "I have no idea what's coming."

```tsx
function CardSkeleton() {
  return (
    <div className="animate-pulse space-y-3 rounded-lg border p-4">
      <div className="h-4 w-3/4 rounded bg-gray-200" />
      <div className="h-3 w-1/2 rounded bg-gray-200" />
      <div className="h-24 w-full rounded bg-gray-200" />
      <div className="flex gap-2">
        <div className="h-8 w-20 rounded bg-gray-200" />
        <div className="h-8 w-20 rounded bg-gray-200" />
      </div>
    </div>
  );
}
```

## Layout Patterns

### Hero Section
- Headline: max 8 words, large display font
- Sub-headline: max 20 words, body font, lighter weight
- CTA: one primary button, one ghost/link secondary
- Visual: image, illustration, or gradient — not a wall of text

### Content Grid
- Cards: consistent height via `grid-template-rows: subgrid` or fixed aspect ratios
- Gap: `1.5rem` (24px) minimum between cards
- Responsive: 1 column mobile, 2 tablet, 3-4 desktop

### Spacing System
- Use an 8px grid: 8, 16, 24, 32, 48, 64, 96, 128
- Section padding: 64px mobile, 96px desktop
- Between elements: 16-24px
- Between sections: 48-96px

## Pre-Delivery Checklist

Before presenting any UI work:

- [ ] Aesthetic direction is intentional and consistent
- [ ] Typography: display font + body font, proper hierarchy
- [ ] Color: constrained palette, proper contrast (4.5:1+)
- [ ] Every button/link has hover + focus + active states
- [ ] Loading: skeleton screens, not spinners
- [ ] Empty states: helpful message + CTA
- [ ] Responsive: tested at 375px, 768px, 1024px, 1440px
- [ ] Touch targets: 44px minimum on mobile
- [ ] Animations respect `prefers-reduced-motion`
- [ ] No orphaned text (single words on a line)

## Anti-Patterns

| Generic AI Look | Distinctive Design |
|-----------------|--------------------|
| System font stack only | Intentional font pairing |
| 5+ colors everywhere | 1 primary + 1 accent + neutrals |
| No hover states | Micro-interactions on every interactive |
| Spinner for loading | Skeleton matching content shape |
| Generic stock imagery | Illustrations, gradients, or custom graphics |
| Equal spacing everywhere | Rhythmic spacing with clear hierarchy |
| Centered everything | Asymmetric layouts with tension |

## Integration with Other Skills

- **react-patterns**: Component structure for design components
- **css-architecture**: Tailwind/CSS Modules implementation
- **accessibility**: Contrast, focus, motion preferences
- **performance-optimization**: Image optimization, font loading
