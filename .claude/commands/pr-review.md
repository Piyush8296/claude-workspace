---
description: Review current branch changes and prepare for PR
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(npx:*), Bash(gh:*)
---

# PR Review

Review current branch: $ARGUMENTS

## Instructions

### 1. Gather context

```bash
# Current branch
git branch --show-current

# Commits ahead of main
git log main..HEAD --oneline

# Changed files
git diff main --name-only

# Full diff
git diff main --stat
```

### 2. Run automated checks

```bash
# Lint all changed files
git diff main --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx)$' | xargs npx eslint --no-error-on-unmatched-pattern 2>/dev/null

# Type check
npx tsc --noEmit

# Run tests related to changed files
git diff main --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx)$' | xargs npx vitest related --run 2>/dev/null
```

### 3. Review changes

For each changed file, check:

- Does this change do what the commit messages claim?
- Are there any leftover `console.log`, `TODO`, or `debugger` statements?
- Is error handling complete?
- Are there new components missing tests?
- Are accessibility requirements met?
- Any performance concerns (bundle size, re-renders)?

### 4. Generate PR description

Produce a PR description in this format:

```markdown
## What
[One-line summary of the change]

## Why
[Context: ticket link, user problem, technical motivation]

## How
[Implementation approach, key decisions made]

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Accessibility verified
- [ ] Edge cases covered

## Screenshots
[If UI changes, note that screenshots should be added]
```

### 5. Verdict

End with one of:
- **READY** — Good to create PR
- **NEEDS WORK** — List specific items to address first
- **CONCERN** — Architectural or scope concern to discuss
