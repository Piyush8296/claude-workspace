---
description: Generate and run Playwright end-to-end tests from user flow descriptions
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(npx playwright*), Bash(pnpm:*), Bash(npm:*), Bash(node:*)
argument-hint: <user-flow-description>
---

# E2E Test Generator

Generate E2E test for: $ARGUMENTS

## Instructions

### 1. Understand the user flow

Break the description into discrete steps:
- Where does the user start? (URL/page)
- What actions do they take? (click, type, navigate)
- What do they expect to see? (text, elements, redirects)
- What's the success criteria?

### 2. Check Playwright setup

```bash
# Verify Playwright is available
npx playwright --version 2>/dev/null || echo "Playwright not installed"

# Check for existing config
ls playwright.config.* 2>/dev/null || echo "No Playwright config found"

# Check for existing E2E tests
find . -path '*/e2e/*.spec.*' -o -path '*/e2e/*.test.*' 2>/dev/null | head -5
```

If Playwright isn't set up, create a basic config:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  baseURL: 'http://localhost:3000',
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'pnpm dev',
    port: 3000,
    reuseExistingServer: true,
  },
});
```

### 3. Generate the test

Follow these patterns:

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Flow: <description>', () => {
  test('should complete the flow successfully', async ({ page }) => {
    // Navigate
    await page.goto('/<start-page>');

    // Act
    await page.getByRole('button', { name: /sign in/i }).click();
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: /submit/i }).click();

    // Assert
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible();
  });

  test('should handle error state', async ({ page }) => {
    // Test the unhappy path
  });
});
```

**Selector priority:**
1. `getByRole` — accessible selectors first
2. `getByLabel` — form inputs
3. `getByText` — visible content
4. `getByTestId` — last resort

### 4. Run the test

```bash
npx playwright test <test-file> --reporter=list
```

### 5. Debug failures

If tests fail:
- Check if the dev server is running
- Verify selectors match actual page content
- Add `await page.pause()` for interactive debugging
- Check the trace: `npx playwright show-trace test-results/*/trace.zip`

### 6. Report

- Tests generated (count)
- Tests passed / failed
- User flows covered
- Suggested additional flows to test
