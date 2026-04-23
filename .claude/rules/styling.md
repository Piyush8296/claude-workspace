---
paths:
  - "**/*.css"
  - "**/*.scss"
  - "**/*.module.css"
  - "**/*.module.scss"
  - "**/tailwind.config.*"
  - "**/postcss.config.*"
---

# Styling Rules

## General Principles

- Utility-first (Tailwind) for rapid iteration. CSS Modules for complex, stateful styles.
- No inline `style` props for layout or spacing — only for truly dynamic values (e.g., `style={{ '--progress': value }}`).
- No `!important` — fix specificity at the source.
- Mobile-first responsive: `min-width` breakpoints, not `max-width`.

## Tailwind CSS

- Follow the class order convention: layout → sizing → spacing → typography → visual → state.
- Extract repeated utility combinations into components, not `@apply` (preserves tree-shaking).
- Use design tokens via `theme()` — no magic numbers for colors, spacing, or typography.
- Custom values in `tailwind.config` — never arbitrary values (`[13px]`) unless truly one-off.
- Dark mode via `dark:` variant — respect `prefers-color-scheme`.

## CSS Modules

- One module per component: `ComponentName.module.css`.
- `camelCase` class names: `.errorMessage` not `.error-message` (JS import compatibility).
- Compose shared styles: `composes: base from './shared.module.css'`.
- No global selectors inside modules — defeats the purpose.

## Responsive Design

- Breakpoints: `sm` (640px), `md` (768px), `lg` (1024px), `xl` (1280px), `2xl` (1536px).
- Test all layouts at each breakpoint.
- Touch targets minimum 44x44px on mobile.
- No horizontal scroll on any viewport width.

## Accessibility

- Color contrast ≥ 4.5:1 for normal text, ≥ 3:1 for large text.
- Focus styles visible and distinct — never `outline: none` without replacement.
- `prefers-reduced-motion: reduce` — disable/reduce all animations.
- `prefers-color-scheme` — respect system preference.

## Anti-Patterns

- No CSS-in-JS runtime (styled-components/emotion) in new code — use Tailwind or CSS Modules.
- No global CSS except for CSS reset and CSS custom properties.
- No z-index wars — use a z-index scale: `base(0)`, `dropdown(10)`, `sticky(20)`, `modal(30)`, `toast(40)`.
- No pixel values for font sizes — use `rem`.
