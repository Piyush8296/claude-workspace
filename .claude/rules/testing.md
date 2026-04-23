---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/tests/**"
  - "**/vitest.config.*"
  - "**/playwright.config.*"
---

# Testing Rules

## Philosophy

- **Test behavior, not implementation.** If a refactor breaks a test but not the feature, the test is wrong.
- **TDD where practical.** Write the failing test first, then implement.
- **Factory pattern for test data.** `getMockX(overrides?: Partial<X>)` — no duplicated fixtures.
- **Every new component ships with tests.** Loading, error, empty, and success states at minimum.

## Unit Tests (Vitest + React Testing Library)

### Structure

```typescript
describe('ComponentName', () => {
  // Factory at the top
  const getProps = (overrides?: Partial<Props>) => ({
    title: 'Default',
    onClick: vi.fn(),
    ...overrides,
  });

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders with default props', () => { /* ... */ });
    it('renders loading state when isPending and no data', () => { /* ... */ });
    it('renders error state with retry action', () => { /* ... */ });
    it('renders empty state when data is empty array', () => { /* ... */ });
  });

  describe('interactions', () => {
    it('calls onClick when button is pressed', async () => { /* ... */ });
    it('disables submit during pending mutation', () => { /* ... */ });
  });

  describe('edge cases', () => {
    it('handles undefined optional props gracefully', () => { /* ... */ });
  });
});
```

### Query Priority (React Testing Library)

1. `getByRole` — accessible queries first
2. `getByLabelText` — form elements
3. `getByText` — visible text
4. `getByTestId` — last resort

Never query by class name or internal component structure.

### Async Testing

```typescript
// CORRECT: wait for specific condition
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
});

// WRONG: arbitrary timeout
await new Promise(r => setTimeout(r, 1000));
```

## E2E Tests (Playwright)

- Test critical user journeys, not every permutation.
- Use `data-testid` for E2E selectors — resilient to UI changes.
- Run in CI against production build.
- Isolate test data — each test creates and cleans up its own state.

## What to Test

| Test | What |
|------|------|
| Unit | Component rendering in all states, hook logic, utility functions |
| Integration | Feature workflows, data fetching + rendering, form submission |
| E2E | Critical paths: auth, checkout, core CRUD |

## What NOT to Test

- Third-party library internals
- Implementation details (internal state, private methods)
- Exact CSS/styling output
- Static content that never changes
