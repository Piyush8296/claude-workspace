---
description: Test-driven development workflow — red, green, refactor, commit
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(npx vitest*), Bash(npx jest*), Bash(pnpm:*), Bash(git:*)
argument-hint: <feature-or-function-name>
---

# TDD Workflow

Develop with TDD: $ARGUMENTS

## Instructions

### 1. Understand the requirement

Clarify with the user if needed:
- What should this feature/function do?
- What are the inputs and expected outputs?
- What edge cases matter?

### 2. RED — Write a failing test

Create the test file first. The test should:
- Describe the expected behavior in plain English
- Use factory functions for test data: `getProps()`, `getMockX()`
- Cover the happy path AND at least one edge case
- Use accessible queries: `getByRole` > `getByText` > `getByTestId`

```bash
# Run the test — it MUST fail
npx vitest run <test-file> --reporter=verbose
```

If the test passes without implementation, the test is wrong. Rewrite it.

### 3. GREEN — Write minimal code to pass

Implement the minimum code that makes the test pass:
- No extra features
- No premature optimization
- No refactoring yet
- Just make it green

```bash
# Verify it passes
npx vitest run <test-file> --reporter=verbose
```

### 4. REFACTOR — Clean up while green

Now improve the code:
- Extract helper functions
- Improve naming
- Remove duplication
- Apply project patterns (check relevant skills)

```bash
# Tests must still pass after refactoring
npx vitest run <test-file> --reporter=verbose
```

### 5. Expand coverage

Add more test cases:
- Error states
- Loading states
- Empty states
- Boundary values
- Invalid inputs

Repeat RED → GREEN → REFACTOR for each new case.

### 6. Commit

```bash
git add -A
git commit -m "feat: implement $ARGUMENTS with TDD"
```

### 7. Report

Summarize:
- Tests written (count)
- All passing? (yes/no)
- Edge cases covered
- Files created/modified
