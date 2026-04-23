---
name: react-patterns
description: Modern React component architecture, composition patterns, hooks, and rendering strategies. Use when building UI components, refactoring component structure, or choosing between patterns.
---

# React Patterns

## Component Architecture

### File Structure (Co-location)

```
src/components/UserCard/
  UserCard.tsx          # Component implementation
  UserCard.test.tsx     # Tests
  UserCard.stories.tsx  # Storybook (optional)
  index.ts              # Barrel export
```

### Component Template

```typescript
import { type ReactNode } from 'react';

interface UserCardProps {
  /** User's display name */
  name: string;
  /** Optional avatar URL */
  avatarUrl?: string;
  /** Slot for action buttons */
  actions?: ReactNode;
}

export function UserCard({ name, avatarUrl, actions }: UserCardProps) {
  return (
    <article className="flex items-center gap-4 rounded-lg border p-4">
      <img
        src={avatarUrl ?? '/default-avatar.png'}
        alt={`${name}'s avatar`}
        className="h-12 w-12 rounded-full object-cover"
      />
      <div className="flex-1 min-w-0">
        <h3 className="truncate font-medium">{name}</h3>
      </div>
      {actions && <div className="flex gap-2">{actions}</div>}
    </article>
  );
}
```

Conventions:
- Named export, never default
- Props interface in same file with JSDoc
- Semantic HTML (`<article>`, `<h3>`, not `<div>`)
- Composition via slot props (`actions`, `children`, `header`)
- Defensive defaults for optional props

### Component Size Limits

- **Max 250 lines** per component file
- **Max 50 lines** per function
- If exceeding, extract sub-components or custom hooks

## State Handling Order (Golden Rule)

Every component that fetches data MUST handle states in this exact order:

```typescript
function UserList() {
  const { data, isPending, error, refetch } = useUsers();

  // 1. Error FIRST
  if (error) {
    return <ErrorState error={error} onRetry={refetch} />;
  }

  // 2. Loading ONLY when no data
  if (isPending && !data) {
    return <UserListSkeleton />;
  }

  // 3. Empty state
  if (!data?.length) {
    return (
      <EmptyState
        icon="users"
        title="No users yet"
        description="Invite your first team member"
        action={{ label: 'Invite', onClick: openInviteModal }}
      />
    );
  }

  // 4. Success
  return (
    <ul role="list" className="divide-y">
      {data.map((user) => (
        <li key={user.id}>
          <UserCard user={user} />
        </li>
      ))}
    </ul>
  );
}
```

**Why this order?**
- Error before loading: prevents showing stale error under a spinner
- `isPending && !data`: prevents flash of loading on refetch when cached data exists
- Empty before success: explicit handling, not just a missing list

## Composition Patterns

### Compound Components

```typescript
function Tabs({ children, defaultValue }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue);
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div role="tablist">{children}</div>
    </TabsContext.Provider>
  );
}

function TabTrigger({ value, children }: TabTriggerProps) {
  const { activeTab, setActiveTab } = useTabsContext();
  return (
    <button
      role="tab"
      aria-selected={activeTab === value}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
}

function TabContent({ value, children }: TabContentProps) {
  const { activeTab } = useTabsContext();
  if (activeTab !== value) return null;
  return <div role="tabpanel">{children}</div>;
}

// Usage
<Tabs defaultValue="profile">
  <TabTrigger value="profile">Profile</TabTrigger>
  <TabTrigger value="settings">Settings</TabTrigger>
  <TabContent value="profile"><ProfileForm /></TabContent>
  <TabContent value="settings"><SettingsForm /></TabContent>
</Tabs>
```

### Render Props (Headless Components)

```typescript
interface ToggleRenderProps {
  isOn: boolean;
  toggle: () => void;
}

function Toggle({ children }: { children: (props: ToggleRenderProps) => ReactNode }) {
  const [isOn, setIsOn] = useState(false);
  return <>{children({ isOn, toggle: () => setIsOn((v) => !v) })}</>;
}

// Usage
<Toggle>
  {({ isOn, toggle }) => (
    <button onClick={toggle}>{isOn ? 'ON' : 'OFF'}</button>
  )}
</Toggle>
```

### Custom Hooks for Logic Extraction

```typescript
function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);

  return debounced;
}

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(
    () => window.matchMedia(query).matches
  );

  useEffect(() => {
    const mql = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener('change', handler);
    return () => mql.removeEventListener('change', handler);
  }, [query]);

  return matches;
}
```

## Mutation Patterns

```typescript
function DeleteButton({ itemId, onDeleted }: DeleteButtonProps) {
  const { mutate: deleteItem, isPending } = useDeleteItem({
    onSuccess: () => {
      toast.success('Item deleted');
      onDeleted?.();
    },
    onError: (error) => {
      console.error('deleteItem failed:', error);
      toast.error('Failed to delete item. Please try again.');
    },
  });

  return (
    <button
      onClick={() => deleteItem(itemId)}
      disabled={isPending}
      aria-busy={isPending}
      className="btn-danger"
    >
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}
```

**Non-negotiable rules:**
- `disabled={isPending}` — prevent double-clicks
- `aria-busy={isPending}` — screen reader feedback
- `onError` always shows toast AND logs with context
- Trigger text reflects state

## Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `if (loading) return <Spinner />` | `if (isPending && !data) return <Skeleton />` | Prevents flash on refetch |
| `<div onClick={...}>` | `<button onClick={...}>` | Keyboard + screen reader accessible |
| `key={index}` on dynamic list | `key={item.id}` | Stable identity for reconciliation |
| God component (500+ lines) | Extract hooks + sub-components | Testable, readable, maintainable |
| `useEffect` for derived state | `useMemo` or compute inline | Avoids unnecessary render cycle |
| `any` in component props | Proper generics or `unknown` | Type safety |

## Checklist

Before completing any component:

- [ ] Named export with typed props interface
- [ ] State order: Error → Loading (no data) → Empty → Success
- [ ] Semantic HTML elements
- [ ] Keyboard accessible
- [ ] Under 250 lines
- [ ] Tests cover all 4 states
- [ ] Mutations have disabled state + error handling

## Integration with Other Skills

- **state-management**: When to lift state vs. use stores
- **testing-strategy**: Factory pattern for component tests
- **accessibility**: ARIA patterns for interactive components
- **css-architecture**: Styling approach for the component
