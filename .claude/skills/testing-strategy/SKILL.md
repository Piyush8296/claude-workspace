---
name: testing-strategy
description: Testing methodology, factory patterns, mocking strategies, and TDD workflow for React + TypeScript. Use when writing tests, setting up test infrastructure, or planning test coverage.
---

# Testing Strategy

## Philosophy

- **Test behavior, not implementation.** Refactors should never break tests unless behavior changes.
- **TDD when practical.** Write the failing test first. Red → Green → Refactor.
- **Factory pattern for all test data.** `getMockX(overrides?)` — no duplicated fixtures.
- **Test the contract.** Props in, rendered output + callbacks out.

## Test Pyramid

```
         /\        E2E (Playwright)
        /  \       Critical paths only: auth, checkout, core CRUD
       /    \      ~10% of tests
      /------\     Integration
     /        \    Feature workflows, API + rendering
    /          \   ~20% of tests
   /------------\  Unit
  /              \ Components, hooks, utilities
 /                \ ~70% of tests
```

## Factory Pattern

### Props Factory

```typescript
import { type ComponentProps } from 'react';

const getDefaultProps = (
  overrides?: Partial<ComponentProps<typeof UserCard>>
) => ({
  name: 'Jane Doe',
  email: 'jane@example.com',
  role: 'admin' as const,
  onEdit: vi.fn(),
  onDelete: vi.fn(),
  ...overrides,
});
```

### Data Factory

```typescript
let idCounter = 0;

export function getMockUser(overrides?: Partial<User>): User {
  idCounter += 1;
  return {
    id: `user-${idCounter}`,
    name: 'Test User',
    email: `test${idCounter}@example.com`,
    role: 'viewer',
    createdAt: new Date('2024-01-01').toISOString(),
    ...overrides,
  };
}

export function getMockUsers(count: number, overrides?: Partial<User>): User[] {
  return Array.from({ length: count }, () => getMockUser(overrides));
}
```

### Query Result Factory

```typescript
export function getMockQueryResult<T>(data: T, overrides?: Partial<UseQueryResult<T>>) {
  return {
    data,
    isPending: false,
    isError: false,
    error: null,
    refetch: vi.fn(),
    ...overrides,
  };
}

// Usage
vi.mocked(useUsers).mockReturnValue(
  getMockQueryResult(getMockUsers(3))
);

// Loading state
vi.mocked(useUsers).mockReturnValue(
  getMockQueryResult(undefined, { isPending: true, data: undefined })
);
```

## Component Test Structure

```typescript
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('UserCard', () => {
  const user = userEvent.setup();

  const getProps = (overrides?: Partial<UserCardProps>) => ({
    name: 'Jane Doe',
    onEdit: vi.fn(),
    ...overrides,
  });

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders user name', () => {
    render(<UserCard {...getProps()} />);
    expect(screen.getByText('Jane Doe')).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', async () => {
    const onEdit = vi.fn();
    render(<UserCard {...getProps({ onEdit })} />);

    await user.click(screen.getByRole('button', { name: /edit/i }));

    expect(onEdit).toHaveBeenCalledOnce();
  });

  it('shows loading skeleton when data is pending', () => {
    render(<UserCard {...getProps()} isLoading />);
    expect(screen.getByTestId('user-card-skeleton')).toBeInTheDocument();
  });
});
```

## Hook Testing

```typescript
import { renderHook, act } from '@testing-library/react';

describe('useCounter', () => {
  it('increments count', () => {
    const { result } = renderHook(() => useCounter({ initial: 0 }));

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('respects max value', () => {
    const { result } = renderHook(() => useCounter({ initial: 9, max: 10 }));

    act(() => {
      result.current.increment();
      result.current.increment(); // Should not exceed max
    });

    expect(result.current.count).toBe(10);
  });
});
```

## Mocking Strategies

### Module Mocking

```typescript
// Mock at module level
vi.mock('@/hooks/useUsers', () => ({
  useUsers: vi.fn(),
}));

// Type-safe mock access
const mockUseUsers = vi.mocked(useUsers);

// Configure per test
mockUseUsers.mockReturnValue(getMockQueryResult(getMockUsers(3)));
```

### API Mocking (MSW)

```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json(getMockUsers(3));
  }),
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(getMockUser(body), { status: 201 });
  }),
];

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Coverage Targets

| Area | Target | Notes |
|------|--------|-------|
| Utilities | 95%+ | Pure functions, easy to test fully |
| Hooks | 90%+ | All branches including error paths |
| Components | 80%+ | All states: loading, error, empty, success |
| Pages/Routes | 70%+ | Integration level, key user flows |
| E2E | Critical paths | Auth, checkout, core CRUD only |

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| Testing mock behavior | Testing rendered output | Mock is not the product |
| `await sleep(1000)` | `await waitFor(() => ...)` | Deterministic, not timing-dependent |
| Snapshot tests for logic | Explicit assertions | Snapshots don't explain intent |
| Testing `useState` directly | Testing through UI interaction | Implementation detail |
| One mega test file | Focused describe blocks | Easier to debug failures |

## Integration with Other Skills

- **react-patterns**: Test all 4 component states
- **systematic-debugging**: Write reproducing test before fixing bugs
- **state-management**: Mocking stores and query clients
