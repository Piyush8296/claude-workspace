---
description: Auto-diagnose and fix build or compile errors iteratively
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(pnpm:*), Bash(npm:*), Bash(npx:*), Bash(node:*), Bash(git:*)
---

# Build Fix

Diagnose and fix build errors: $ARGUMENTS

## Instructions

### 1. Run the build

```bash
# Try project's build command
pnpm build 2>&1 || npm run build 2>&1
```

Capture the full error output.

### 2. Parse errors

For each error, identify:
- **File and line number**
- **Error type** (TypeScript, ESLint, import resolution, runtime)
- **Root cause** (not just the symptom)

Group errors by type. Fix in this priority order:
1. Import/module resolution errors (missing deps, wrong paths)
2. TypeScript type errors
3. ESLint errors
4. Runtime/logic errors

### 3. Fix iteratively

For each error group:

```
a. Read the failing file and surrounding context
b. Identify the root cause (not just the error line)
c. Apply the fix
d. Run build again to verify
e. If new errors appear, continue the loop
f. If the same error persists after 3 attempts, STOP and report
```

**Rules:**
- Fix root causes, not symptoms
- Never suppress errors with `@ts-ignore` or `eslint-disable` unless explicitly approved
- If a fix introduces new errors, revert and try a different approach
- Maximum 10 fix iterations before stopping

### 4. Run full verification

After build passes:

```bash
# Type check
npx tsc --noEmit

# Lint
npx eslint src/ --no-error-on-unmatched-pattern

# Tests
npx vitest run --reporter=verbose 2>&1 | tail -30
```

### 5. Commit if clean

```bash
git add -A
git diff --cached --stat
git commit -m "fix: resolve build errors"
```

### 6. Report

```
## Build Fix Summary

**Status**: FIXED / PARTIALLY FIXED / BLOCKED
**Errors found**: X
**Errors fixed**: Y
**Iterations**: Z

### Fixes Applied
- [file:line] — description of fix

### Remaining Issues (if any)
- [file:line] — why this couldn't be auto-fixed
```
