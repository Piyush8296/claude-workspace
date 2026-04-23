---
description: Work on a ticket end-to-end — from reading requirements to creating a PR
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(pnpm:*), Bash(npx:*)
argument-hint: <TICKET-ID>
---

# Ticket Workflow

Work on ticket: $ARGUMENTS

## Instructions

### 1. Understand the ticket

If a ticket tracker MCP is available, fetch ticket details. Otherwise, ask the user to provide:
- Title and description
- Acceptance criteria
- Design links or screenshots
- Dependencies or blockers

Summarize:
- What needs to be done
- Acceptance criteria (as checklist)
- Scope boundaries (what's NOT included)

### 2. Explore the codebase

Before writing any code:
- Search for related existing components/utilities
- Understand current patterns in the area you'll modify
- Identify files that need changes
- Check for existing tests

### 3. Create a feature branch

```bash
git checkout main && git pull
git checkout -b feat/$ARGUMENTS-<brief-slug>
```

### 4. Plan the implementation

Before coding, outline:
- Files to create or modify
- Component hierarchy (if UI work)
- State management approach
- API integration points
- Test strategy

Ask for confirmation before proceeding.

### 5. Implement with TDD

For each unit of work:
1. Write a failing test that captures the requirement
2. Implement the minimal code to pass
3. Refactor for clarity and patterns
4. Commit with descriptive conventional commit message

### 6. Verify quality

```bash
npx tsc --noEmit            # Type check
npx eslint src/             # Lint
npx vitest run              # Unit tests
npx prettier --check src/   # Format
```

### 7. Create PR

```bash
git push -u origin HEAD
gh pr create --title "feat($ARGUMENTS): <description>" --body "<generated PR description>"
```

Link the PR to the ticket if possible.

### 8. Checklist before marking done

- [ ] All acceptance criteria met
- [ ] Tests written and passing
- [ ] No TypeScript errors
- [ ] No lint warnings
- [ ] Accessibility verified
- [ ] Responsive across breakpoints
- [ ] Loading, error, and empty states handled
- [ ] PR description complete
