# Claude Workspace — Frontend Engineering

> Production-grade Claude Code configuration for frontend teams. Drop into any project, get senior-level AI pair programming immediately.

## Quick Facts

- **Primary Stack**: React 18+, TypeScript 5+, Next.js 14+
- **Styling**: Tailwind CSS / CSS Modules (configurable)
- **State**: Zustand / TanStack Query (server state)
- **Testing**: Vitest + React Testing Library + Playwright
- **Build**: Vite / Turbopack
- **Package Manager**: pnpm (fallback: npm)
- **Lint**: ESLint 9+ flat config + Prettier
- **CI**: GitHub Actions

## Key Directories

- `src/components/` — React components (co-located tests + stories)
- `src/hooks/` — Custom React hooks
- `src/lib/` — Shared utilities, API clients, constants
- `src/app/` or `src/pages/` — Route-level components
- `src/stores/` — State management
- `src/types/` — Shared TypeScript types/interfaces
- `tests/e2e/` — Playwright end-to-end tests
- `public/` — Static assets

## Code Style (Non-Negotiable)

- TypeScript `strict: true` — zero tolerance for `any`; use `unknown` + type guards
- `interface` over `type` unless unions/intersections are needed
- Early returns over nested conditionals — max 2 nesting levels
- Composition over inheritance — always
- Pure functions by default — side effects only in hooks/event handlers
- Named exports only — no default exports except pages/layouts
- Barrel files (`index.ts`) only at feature boundaries, never deep nesting

## Git Conventions

- **Branch**: `<type>/<ticket>-<slug>` (e.g., `feat/PROJ-42-avatar-upload`)
- **Commits**: Conventional Commits — `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- **PRs**: Squash merge, title matches commit format, link to ticket
- **Separate commits per file** when touching unrelated concerns

## Critical Rules

### State Handling Order (Every Component)
1. Error → show `<ErrorBoundary>` or inline error with retry
2. Loading (no data) → show skeleton/spinner
3. Empty → show contextual empty state with CTA
4. Success → render data

### Mutations
- Disable trigger during async — `disabled={isPending}`
- Show loading indicator on trigger — `aria-busy={isPending}`
- `onError` always surfaces feedback to user (toast + console.error)
- Optimistic updates where UX demands it

### Error Handling
- NEVER swallow errors silently
- Error boundaries at route and feature level
- All `try/catch` must surface to user OR re-throw
- Log with context: operation name, resource ID, user-facing message

### Accessibility (Non-Negotiable)
- Semantic HTML first — `<button>`, `<nav>`, `<main>`, `<section>`
- Every interactive element keyboard-accessible
- All images have descriptive `alt` (decorative = `alt=""`)
- Color contrast ≥ 4.5:1 (AA) — test with axe-core
- Focus management on route changes and modals

## Skill Activation

Before implementing ANY task, check if relevant skills apply:

- Building components → `react-patterns` skill
- Managing state → `state-management` skill
- Writing tests → `testing-strategy` skill
- Styling work → `css-architecture` skill
- Performance issues → `performance-optimization` skill
- Accessibility work → `accessibility` skill
- Debugging → `systematic-debugging` skill

## Common Commands

```bash
pnpm dev              # Start dev server
pnpm build            # Production build
pnpm test             # Run unit tests (Vitest)
pnpm test:e2e         # Run E2E tests (Playwright)
pnpm lint             # Lint + format check
pnpm typecheck        # tsc --noEmit
pnpm storybook        # Component explorer
```

## Agent Delegation

For specialized reviews, delegate to purpose-built agents:

- Code quality concerns → `code-reviewer` agent
- Performance bottlenecks → `performance-auditor` agent
- Accessibility compliance → `accessibility-auditor` agent
- Refactoring decisions → `refactor-planner` agent
