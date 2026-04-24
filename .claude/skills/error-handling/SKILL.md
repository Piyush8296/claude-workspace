---
name: error-handling
description: Production error handling architecture for React and Next.js — Error boundary hierarchies, custom error classes, global error normalization, Sentry integration, fallback UI strategies, toast vs inline vs full-page error patterns, and error recovery. Use when building error UIs, setting up monitoring, or handling failures gracefully.
---

# Error Handling

## The Error Handling Hierarchy

Errors should be caught at the closest meaningful boundary, not at the top of the tree.

```
App Error Boundary (crash recovery, "something went wrong" page)
  └─ Route Error Boundary (per-page, Next.js error.tsx)
       └─ Feature Error Boundary (per-feature section)
            └─ Component-level try/catch (inline error UI)
                 └─ Query/Mutation onError (toast notifications)
```

## Custom Error Classes

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true,  // Expected vs unexpected
    public context?: Record<string, unknown>,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public fields: Record<string, string[]>) {
    super(message, 'VALIDATION_ERROR', 400);
    this.name = 'ValidationError';
  }
}

export class AuthError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 'AUTH_ERROR', 401);
    this.name = 'AuthError';
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, 'NOT_FOUND', 404);
    this.name = 'NotFoundError';
  }
}
```

## Error Normalizer

```typescript
// lib/errors/normalize.ts
import { AppError } from './errors';

export function normalizeError(error: unknown): AppError {
  // Already normalized
  if (error instanceof AppError) return error;

  // API errors
  if (error instanceof Response || (error && typeof error === 'object' && 'status' in error)) {
    const e = error as { status: number; statusText?: string };
    return new AppError(
      e.statusText ?? 'Request failed',
      'API_ERROR',
      e.status,
    );
  }

  // Network errors
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return new AppError('Network error — check your connection', 'NETWORK_ERROR', 0);
  }

  // Abort errors (not real errors)
  if (error instanceof DOMException && error.name === 'AbortError') {
    return new AppError('Request cancelled', 'ABORT_ERROR', 0, true);
  }

  // Unknown errors
  const message = error instanceof Error ? error.message : 'An unexpected error occurred';
  return new AppError(message, 'UNKNOWN_ERROR', 500, false);
}
```

## Error Boundaries

### Next.js App Router (error.tsx)

```typescript
// app/error.tsx — catches errors in the entire app
'use client';

export default function GlobalError({ error, reset }: { error: Error; reset: () => void }) {
  useEffect(() => {
    // Report to error tracker
    captureException(error);
  }, [error]);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4">
      <h1 className="text-2xl font-bold">Something went wrong</h1>
      <p className="text-gray-600">{error.message}</p>
      <button onClick={reset} className="rounded bg-blue-600 px-4 py-2 text-white">
        Try again
      </button>
    </div>
  );
}
```

```typescript
// app/dashboard/error.tsx — route-level, doesn't crash the entire app
'use client';

export default function DashboardError({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div className="rounded-lg border border-red-200 bg-red-50 p-6">
      <h2 className="font-semibold text-red-800">Dashboard failed to load</h2>
      <p className="text-sm text-red-600">{error.message}</p>
      <button onClick={reset} className="mt-3 text-sm text-red-700 underline">Retry</button>
    </div>
  );
}
```

### React Error Boundary (Class Component)

```typescript
// components/ErrorBoundary.tsx
import { Component, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback: ReactNode | ((error: Error, reset: () => void) => ReactNode);
  onError?: (error: Error, info: { componentStack: string }) => void;
}

interface State { error: Error | null; }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    this.props.onError?.(error, { componentStack: info.componentStack ?? '' });
  }

  reset = () => this.setState({ error: null });

  render() {
    if (this.state.error) {
      const { fallback } = this.props;
      return typeof fallback === 'function'
        ? fallback(this.state.error, this.reset)
        : fallback;
    }
    return this.props.children;
  }
}
```

## Error Display Patterns

| Error Type | Display | When |
|-----------|---------|------|
| **Toast** | Ephemeral notification, auto-dismiss | Mutation failures, network hiccups, non-blocking |
| **Inline** | Below the field or component | Validation errors, field-level issues |
| **Banner** | Top of section, dismissible | Partial page failure, degraded functionality |
| **Full page** | Replaces entire content | Unrecoverable errors, auth failures, 500s |

```tsx
// Toast: mutation error
const { mutate } = useMutation({
  mutationFn: updateUser,
  onError: (error) => {
    const normalized = normalizeError(error);
    toast.error(normalized.message);
    captureException(error);
  },
});

// Inline: form validation
{errors.email && (
  <p role="alert" className="text-sm text-red-600">{errors.email}</p>
)}

// Banner: degraded feature
{featureError && (
  <div role="alert" className="rounded border border-yellow-300 bg-yellow-50 p-3">
    <p className="text-sm text-yellow-800">Some features unavailable. <button onClick={retry}>Retry</button></p>
  </div>
)}
```

## Error Tracking (Sentry)

```typescript
// lib/monitoring.ts
import * as Sentry from '@sentry/nextjs';

export function captureException(error: unknown, context?: Record<string, unknown>) {
  const normalized = normalizeError(error);

  // Don't report operational errors (expected failures)
  if (normalized.isOperational && normalized.statusCode < 500) return;

  Sentry.captureException(error, {
    tags: { errorCode: normalized.code },
    extra: { ...normalized.context, ...context },
  });
}

export function setUserContext(user: { id: string; email: string }) {
  Sentry.setUser({ id: user.id, email: user.email });
}
```

## Rules

- NEVER `catch (e) {}` — empty catch is a bug factory
- NEVER `catch (e) { console.log(e) }` — user sees nothing
- ALWAYS show user feedback for errors they caused (validation, auth)
- ALWAYS log + track unexpected errors (5xx, unknown)
- ALWAYS provide a recovery path (retry button, navigation, refresh)
- AbortError is not a real error — don't show it to users

## Integration with Other Skills

- **api-layer**: ApiError class, error normalization
- **react-patterns**: Error state in the state handling order
- **accessibility**: `role="alert"` on error messages, focus management
- **testing-strategy**: Test error states, error boundary rendering
