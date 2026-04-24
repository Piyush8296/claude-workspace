---
name: api-layer
description: API client architecture for React and Next.js — typed fetch wrappers, interceptors, retry with backoff, request cancellation, pagination patterns, file uploads, and Next.js API route handlers. Use when building API clients, data fetching layers, or integrating with backends.
---

# API Layer

## Architecture

Never scatter raw `fetch()` calls across components. Build a typed API client that handles auth, errors, retries, and cancellation in one place.

```
Component → TanStack Query hook → API client function → fetchClient (interceptors) → fetch()
```

## Typed Fetch Client

```typescript
// lib/api/client.ts
import { env } from '@/lib/env';

interface FetchOptions extends Omit<RequestInit, 'body'> {
  body?: unknown;
  params?: Record<string, string | number | undefined>;
  timeout?: number;
}

class ApiError extends Error {
  constructor(
    public status: number,
    public statusText: string,
    public data: unknown,
    public url: string,
  ) {
    super(`${status} ${statusText}: ${url}`);
    this.name = 'ApiError';
  }

  get isUnauthorized() { return this.status === 401; }
  get isForbidden() { return this.status === 403; }
  get isNotFound() { return this.status === 404; }
  get isRateLimit() { return this.status === 429; }
  get isServerError() { return this.status >= 500; }
}

async function fetchClient<T>(path: string, options: FetchOptions = {}): Promise<T> {
  const { body, params, timeout = 10_000, headers: customHeaders, ...rest } = options;

  // Build URL with query params
  const url = new URL(path, env.API_BASE_URL);
  if (params) {
    Object.entries(params).forEach(([k, v]) => {
      if (v !== undefined) url.searchParams.set(k, String(v));
    });
  }

  // Timeout via AbortController
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeout);

  try {
    const res = await fetch(url.toString(), {
      ...rest,
      signal: controller.signal,
      headers: {
        'Content-Type': 'application/json',
        ...customHeaders,
      },
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!res.ok) {
      const data = await res.json().catch(() => null);
      throw new ApiError(res.status, res.statusText, data, url.toString());
    }

    // Handle 204 No Content
    if (res.status === 204) return undefined as T;

    return res.json() as Promise<T>;
  } finally {
    clearTimeout(timer);
  }
}

export { fetchClient, ApiError };
export type { FetchOptions };
```

## Auth Interceptor

```typescript
// lib/api/auth-interceptor.ts
import { getSession } from '@/lib/auth';
import { fetchClient, ApiError } from './client';
import type { FetchOptions } from './client';

let isRefreshing = false;
let refreshPromise: Promise<string> | null = null;

async function getValidToken(): Promise<string | null> {
  const session = await getSession();
  if (!session?.accessToken) return null;

  // If token is expired and not already refreshing
  if (session.isExpired && !isRefreshing) {
    isRefreshing = true;
    refreshPromise = refreshToken(session.refreshToken)
      .finally(() => { isRefreshing = false; refreshPromise = null; });
  }

  // If a refresh is in progress, wait for it
  if (refreshPromise) return refreshPromise;

  return session.accessToken;
}

export async function authedFetch<T>(path: string, options: FetchOptions = {}): Promise<T> {
  const token = await getValidToken();

  return fetchClient<T>(path, {
    ...options,
    headers: {
      ...options.headers,
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
}
```

## Retry with Exponential Backoff

```typescript
// lib/api/retry.ts
interface RetryConfig {
  maxRetries?: number;
  baseDelay?: number;
  retryOn?: (error: unknown) => boolean;
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  config: RetryConfig = {},
): Promise<T> {
  const { maxRetries = 3, baseDelay = 1000, retryOn = defaultRetryCondition } = config;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries || !retryOn(error)) throw error;

      const delay = baseDelay * Math.pow(2, attempt) + Math.random() * 500;
      await new Promise((r) => setTimeout(r, delay));
    }
  }

  throw new Error('Retry exhausted'); // Unreachable, satisfies TS
}

function defaultRetryCondition(error: unknown): boolean {
  if (error instanceof ApiError) {
    return error.isServerError || error.isRateLimit;
  }
  return error instanceof TypeError; // Network error
}
```

## Request Cancellation

```typescript
// Cancel on component unmount (TanStack Query does this automatically)
// For manual fetch calls:

function useApiCall() {
  const controllerRef = useRef<AbortController | null>(null);

  const execute = useCallback(async (url: string) => {
    // Cancel previous in-flight request
    controllerRef.current?.abort();
    controllerRef.current = new AbortController();

    return fetchClient(url, { signal: controllerRef.current.signal });
  }, []);

  // Cancel on unmount
  useEffect(() => () => { controllerRef.current?.abort(); }, []);

  return execute;
}
```

## Pagination Patterns

```typescript
// Cursor-based (preferred for infinite scroll)
interface CursorPage<T> {
  items: T[];
  nextCursor: string | null;
  hasMore: boolean;
}

function useInfiniteItems() {
  return useInfiniteQuery({
    queryKey: ['items'],
    queryFn: ({ pageParam }) =>
      authedFetch<CursorPage<Item>>('/api/items', { params: { cursor: pageParam, limit: 20 } }),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (last) => last.hasMore ? last.nextCursor : undefined,
  });
}

// Offset-based (for numbered pages)
interface OffsetPage<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}

function usePagedItems(page: number) {
  return useQuery({
    queryKey: ['items', { page }],
    queryFn: () => authedFetch<OffsetPage<Item>>('/api/items', { params: { page, pageSize: 20 } }),
  });
}
```

## Next.js API Route Handlers

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = createUserSchema.parse(body);  // Validate input
    const user = await db.users.create({ data });
    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ errors: error.flatten() }, { status: 400 });
    }
    console.error('POST /api/users failed:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
```

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| Raw `fetch()` in components | Typed `fetchClient` in api layer | Centralized error handling, auth, retry |
| No timeout on requests | `AbortController` with timeout | Prevents hung requests |
| Silent retry forever | Retry with max attempts + backoff | Prevents thundering herd |
| `any` for API responses | Zod schema validation | Runtime type safety |
| Ignoring AbortError | `if (error.name !== 'AbortError') throw error` | Don't show error on cancel |

## Integration with Other Skills

- **state-management**: TanStack Query hooks call api-layer functions
- **error-handling**: ApiError class feeds into error boundaries
- **auth-patterns**: Auth interceptor for token management
- **security-audit**: Input validation, CSRF, header security
