---
description: Run comprehensive code quality checks on a directory or file
allowed-tools: Read, Glob, Grep, Bash(npx:*), Bash(pnpm:*), Bash(npm:*)
---

# Code Quality Review

Review code quality in: $ARGUMENTS

## Instructions

### 1. Identify target files

Find all `.ts` and `.tsx` files in the target path. Exclude `node_modules`, `dist`, `.next`, and generated files (`*.generated.*`, `*.d.ts`).

### 2. Run automated checks

```bash
# Lint
npx eslint --no-error-on-unmatched-pattern $ARGUMENTS

# Type check
npx tsc --noEmit

# Format check (don't fix, just report)
npx prettier --check $ARGUMENTS
```

### 3. Manual review checklist

For each file, verify:

- [ ] No TypeScript `any` types (use `unknown` with type guards)
- [ ] No type assertions without `// SAFETY:` comment
- [ ] Error handling: all `catch` blocks surface feedback to user
- [ ] Loading states: `isPending && !data` pattern, not bare `loading`
- [ ] Empty states: every list has an explicit empty state
- [ ] Mutations: triggers disabled during pending, `onError` shows toast
- [ ] Accessibility: semantic HTML, alt text, keyboard support
- [ ] No inline styles for layout — use Tailwind/CSS modules
- [ ] Functions under 50 lines, components under 250 lines
- [ ] Imports: no circular dependencies, no deep barrel re-exports

### 4. Report findings

Organize by severity:

**CRITICAL** (must fix before merge)
- Security vulnerabilities, data loss risks, logic errors

**WARNING** (should fix)
- Convention violations, accessibility gaps, missing error handling

**SUGGESTION** (consider improving)
- Naming, readability, minor performance gains

Include file:line references and example fixes for each finding.
