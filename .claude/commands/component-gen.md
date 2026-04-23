---
description: Scaffold a new React component with test, story, and types
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(mkdir:*)
argument-hint: <ComponentName>
---

# Component Generator

Generate component: $ARGUMENTS

## Instructions

### 1. Determine component location

- If the component name includes a path (e.g., `features/auth/LoginForm`), use that path
- Otherwise, place in `src/components/$ARGUMENTS/`
- Check if the component already exists — if so, ask before overwriting

### 2. Create the component file

**`<ComponentName>.tsx`**

```typescript
import { type ComponentProps } from 'react';

interface <ComponentName>Props {
  // TODO: Define props
}

export function <ComponentName>({ ...props }: <ComponentName>Props) {
  return (
    <div data-testid="<component-name>">
      {/* TODO: Implement */}
    </div>
  );
}
```

Follow these conventions:
- Named export (no default export)
- Props interface defined in same file
- `data-testid` for testing
- Semantic HTML
- TypeScript strict — no `any`

### 3. Create the test file

**`<ComponentName>.test.tsx`**

```typescript
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { <ComponentName> } from './<ComponentName>';

const getDefaultProps = (overrides?: Partial<ComponentProps<typeof <ComponentName>>>) => ({
  // Default props
  ...overrides,
});

describe('<ComponentName>', () => {
  it('renders without crashing', () => {
    render(<<ComponentName> {...getDefaultProps()} />);
    expect(screen.getByTestId('<component-name>')).toBeInTheDocument();
  });

  it('handles empty state', () => {
    // TODO: Test empty state
  });

  it('handles loading state', () => {
    // TODO: Test loading state
  });

  it('handles error state', () => {
    // TODO: Test error state
  });
});
```

### 4. Create barrel export

**`index.ts`**

```typescript
export { <ComponentName> } from './<ComponentName>';
export type { <ComponentName>Props } from './<ComponentName>';
```

### 5. Summary

After generating, print:
- Files created (with paths)
- Next steps: implement the component logic, fill in props, write real tests
- Remind about the `react-patterns` skill for component architecture guidance
