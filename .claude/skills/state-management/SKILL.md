---
name: state-management
description: State management strategies for React — local state, server state, global state, URL state. Use when deciding state architecture, implementing data fetching, or managing complex state.
---

# State Management

## The State Classification Framework

Before choosing a tool, classify the state:

| Type | Scope | Tool | Example |
|------|-------|------|---------|
| **UI State** | Single component | `useState` | Modal open, input value |
| **Shared UI State** | Few components | Lift state + props / Context | Active tab, sidebar collapsed |
| **Server State** | Cached remote data | TanStack Query / SWR | User list, profile data |
| **Global App State** | Entire app | Zustand / Jotai | Auth, theme, feature flags |
| **URL State** | Navigation | `useSearchParams` / router | Filters, pagination, sort |
| **Form State** | Form lifecycle | React Hook Form / Formik | Input values, validation |

**Golden rule:** Use the simplest tool that fits. `useState` > Context > Zustand > Redux.

## Server State (TanStack Query)

This is the most common state type in frontend apps. Most "global state" is actually server state.

### Query Pattern

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Query keys as const for type safety
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// Query hook
export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => api.users.list(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Mutation hook with cache invalidation
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.users.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      toast.success('User created');
    },
    onError: (error) => {
      console.error('createUser failed:', error);
      toast.error('Failed to create user');
    },
  });
}
```

### Optimistic Updates

```typescript
export function useToggleFavorite() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.favorites.toggle,
    onMutate: async (itemId) => {
      // Cancel outgoing queries
      await queryClient.cancelQueries({ queryKey: ['items', itemId] });

      // Snapshot previous value
      const previous = queryClient.getQueryData(['items', itemId]);

      // Optimistically update
      queryClient.setQueryData(['items', itemId], (old: Item) => ({
        ...old,
        isFavorite: !old.isFavorite,
      }));

      return { previous };
    },
    onError: (_err, itemId, context) => {
      // Rollback on error
      queryClient.setQueryData(['items', itemId], context?.previous);
      toast.error('Failed to update');
    },
    onSettled: (_data, _err, itemId) => {
      // Refetch to ensure consistency
      queryClient.invalidateQueries({ queryKey: ['items', itemId] });
    },
  });
}
```

## Global App State (Zustand)

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface AuthStore {
  user: User | null;
  token: string | null;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
  isAuthenticated: () => boolean;
}

export const useAuthStore = create<AuthStore>()(
  devtools(
    persist(
      (set, get) => ({
        user: null,
        token: null,
        login: async (credentials) => {
          const { user, token } = await api.auth.login(credentials);
          set({ user, token }, false, 'auth/login');
        },
        logout: () => {
          set({ user: null, token: null }, false, 'auth/logout');
        },
        isAuthenticated: () => get().token !== null,
      }),
      { name: 'auth-storage' }
    ),
    { name: 'AuthStore' }
  )
);
```

**Zustand best practices:**
- One store per domain (auth, theme, layout) — not one mega-store
- Selectors to prevent unnecessary re-renders: `useAuthStore((s) => s.user)`
- Actions inside the store, not in components
- `devtools` middleware in development for debugging

## URL State

```typescript
import { useSearchParams } from 'react-router-dom'; // or next/navigation

function useFilters() {
  const [searchParams, setSearchParams] = useSearchParams();

  const filters = {
    query: searchParams.get('q') ?? '',
    page: Number(searchParams.get('page') ?? '1'),
    sort: (searchParams.get('sort') ?? 'newest') as SortOption,
  };

  const setFilter = (key: string, value: string) => {
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev);
      if (value) {
        next.set(key, value);
      } else {
        next.delete(key);
      }
      // Reset page when filters change
      if (key !== 'page') next.set('page', '1');
      return next;
    });
  };

  return { filters, setFilter };
}
```

**When to use URL state:** Filters, pagination, sort order, selected tabs, modal open state — anything the user might want to share via link or use browser back/forward.

## Decision Framework

```
Is it from an API?
  → Yes: TanStack Query (server state)
  → No: Continue

Should it survive page refresh?
  → Yes, in URL: useSearchParams (URL state)
  → Yes, persisted: Zustand with persist (global state)
  → No: Continue

Used by many unrelated components?
  → Yes: Zustand store (global state)
  → No: Continue

Used by parent + 1-2 children?
  → Yes: Lift state to parent (local/shared state)
  → No: useState in the component (local state)
```

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `useEffect` to sync state | Derive from source | Extra render cycle, bug-prone |
| Global store for form values | React Hook Form / local state | Forms are local by nature |
| Context for frequently updating values | Zustand with selectors | Context re-renders all consumers |
| Fetching in `useEffect` | TanStack Query | No caching, no loading/error states, race conditions |
| Prop drilling 4+ levels | Zustand or Context | Maintenance burden |

## Integration with Other Skills

- **react-patterns**: Component state handling order
- **testing-strategy**: Mocking stores and query clients in tests
- **performance-optimization**: Selector optimization, re-render prevention
