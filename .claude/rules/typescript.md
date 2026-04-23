---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Strict Type Safety

- `strict: true` is non-negotiable. Never weaken with `skipLibCheck` as a fix for type errors.
- Zero `any` — use `unknown` with type narrowing, or generics with constraints.
- Prefer `interface` for object shapes (extendable). Use `type` only for unions, intersections, mapped types.
- Use `satisfies` operator for type-safe defaults that preserve the literal type.
- Discriminated unions for complex state: `type State = { status: 'idle' } | { status: 'loading' } | { status: 'error'; error: Error } | { status: 'success'; data: T }`.

## Type Assertions

- No `as Type` without a `// SAFETY:` comment explaining why it's correct.
- Prefer type guards (`isUser(x)`) over assertions.
- Never `as any` — this is always wrong.
- `as const` is fine and encouraged for literal types.

## Imports & Exports

- Named exports only. Default exports only for Next.js pages/layouts (framework requirement).
- Use `import type { X }` for type-only imports — reduces bundle size.
- Barrel files (`index.ts`) only at feature boundaries. Never nest barrels.
- No circular imports — if detected, restructure the dependency graph.

## Functions

- Explicit return types on exported functions and public APIs.
- Inferred return types fine for internal/private functions.
- Use function declarations (`function foo()`) for hoisting. Arrow functions for callbacks and inline.
- Prefer `readonly` parameters and properties unless mutation is intentional.

## Patterns

```typescript
// Discriminated union for async state
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'pending' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: T };

// Type guard
function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    'message' in error
  );
}

// Const assertion for config
const ROUTES = {
  home: '/',
  profile: '/profile',
  settings: '/settings',
} as const;

// satisfies for type-safe defaults
const defaultConfig = {
  theme: 'light',
  locale: 'en',
  debug: false,
} satisfies Config;
```

## Naming Conventions

- `PascalCase`: components, interfaces, types, enums
- `camelCase`: functions, variables, hooks (`useXyz`)
- `SCREAMING_SNAKE_CASE`: constants, env vars
- `is`/`has`/`should` prefix for booleans: `isLoading`, `hasPermission`, `shouldRedirect`
