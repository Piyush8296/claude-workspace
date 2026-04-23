---
description: Guided migration between patterns, libraries, or approaches
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(npx:*), Bash(pnpm:*), Bash(find:*), Bash(wc:*)
argument-hint: <from-pattern> <to-pattern>
---

# Migration Assistant

Migrate: $ARGUMENTS

## Instructions

### 1. Assess scope

```bash
# Find all files using the old pattern
grep -rn "<old-pattern>" src/ --include='*.ts' --include='*.tsx' | wc -l
grep -rn "<old-pattern>" src/ --include='*.ts' --include='*.tsx' --files-with-matches
```

Report:
- Total occurrences
- Files affected
- Areas of the codebase impacted

### 2. Risk assessment

Classify risk:
- **LOW**: Internal utility, full test coverage, isolated
- **MEDIUM**: Shared component, partial tests, known consumers
- **HIGH**: Core abstraction, minimal tests, unknown dependents

### 3. Create migration plan

For each step:
1. What changes
2. How to verify it works
3. How to rollback if needed
4. Estimated scope (files/lines)

### 4. Execute incrementally

For each batch:
1. Create a checkpoint: `git stash` or commit
2. Apply changes to a small batch (5-10 files max)
3. Run tests: `npx vitest run`
4. Run type check: `npx tsc --noEmit`
5. Commit if green: `git commit -m "refactor: migrate <batch> from <old> to <new>"`
6. If red: diagnose, fix, or rollback

### 5. Cleanup

After all batches:
- Remove old pattern if fully migrated
- Update documentation
- Remove deprecated imports/exports
- Run full test suite

### Common Migration Paths

| From | To | Strategy |
|------|----|----------|
| Class components | Function + hooks | Wrap, convert, verify |
| Redux | Zustand | Create store alongside, migrate consumers |
| CSS/SCSS | Tailwind | Component by component, visual regression |
| REST | tRPC/GraphQL | Dual-write period, switch consumers |
| Jest | Vitest | Config swap, fix API differences |
| CRA | Vite/Next.js | New entry point, move routes incrementally |
| PropTypes | TypeScript | Add types alongside, remove PropTypes |
| Moment.js | date-fns | Function by function replacement |
