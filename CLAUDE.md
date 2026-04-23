# Claude Workspace — Frontend Engineering

## Quick Facts

- **Stack**: React 18+, TypeScript 5+ (strict), Next.js 14+, Tailwind CSS
- **State**: Zustand (client) / TanStack Query (server) / URL params (filters)
- **Testing**: Vitest + React Testing Library + Playwright
- **Build**: pnpm, Vite / Turbopack, ESLint 9 flat + Prettier

## Commands

```bash
pnpm dev          # Dev server
pnpm build        # Production build
pnpm test         # Unit tests
pnpm test:e2e     # E2E tests (Playwright)
pnpm lint         # Lint + format
pnpm typecheck    # tsc --noEmit
```

## Code Style

- Zero `any` — use `unknown` + type guards. `interface` over `type`.
- Early returns, max 2 nesting levels. Named exports only.
- State order: Error → Loading (no data) → Empty → Success.
- Mutations: `disabled={isPending}` + `onError` shows toast.
- NEVER swallow errors silently. Semantic HTML first.

## Git

- Branch: `<type>/<ticket>-<slug>` — Commits: Conventional Commits
- PRs: squash merge, link ticket, separate commits per unrelated file

## Skill → File Mapping

| Files touched | Auto-loaded skill |
|---------------|-------------------|
| `src/components/**` | `react-patterns`, `frontend-design` |
| `src/hooks/**`, `src/stores/**` | `state-management` |
| `**/*.test.*`, `**/*.spec.*` | `testing-strategy` |
| `**/*.css`, `tailwind.config.*` | `css-architecture` |
| `src/app/**`, `src/pages/**` | `performance-optimization` |
| Any UI component | `accessibility` |
| Bug investigation | `systematic-debugging` |
| Security concern | `security-audit` |
| Design/mockup work | `design-intelligence` |

## Agent Delegation

| Concern | Agent | Model |
|---------|-------|-------|
| Code quality | `code-reviewer` | Sonnet |
| Performance | `performance-auditor` | Sonnet |
| Accessibility | `accessibility-auditor` | Sonnet |
| Refactoring | `refactor-planner` | Sonnet |
| Documentation | `doc-generator` | Haiku |
| Architecture | `architecture-reviewer` | Sonnet |
| Test coverage | `test-writer` | Sonnet |
| Full health check | `orchestrator` | Opus |
