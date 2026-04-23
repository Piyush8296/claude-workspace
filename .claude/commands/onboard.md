---
description: Explore and document an unfamiliar codebase
allowed-tools: Read, Glob, Grep, Bash(cat:*), Bash(find:*), Bash(wc:*), Bash(head:*), Bash(ls:*), Bash(git log*)
---

# Codebase Onboarding

Explore and map: $ARGUMENTS

## Instructions

### 1. High-level structure

```bash
# Directory tree (2 levels deep)
find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git | grep -v dist | grep -v .next | sort

# File counts by extension
find src/ -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15

# Package.json essentials
cat package.json | head -50
```

### 2. Technology stack

Identify from `package.json` and config files:
- Framework (React, Next.js, Remix, etc.)
- Language (TypeScript version, strict mode?)
- Styling (Tailwind, CSS Modules, styled-components)
- State management (Zustand, Redux, Jotai, Context)
- Data fetching (TanStack Query, SWR, tRPC)
- Testing (Vitest, Jest, Playwright, Cypress)
- Build tool (Vite, Turbopack, webpack)

### 3. Architecture patterns

Examine:
- Routing strategy (file-based, config-based)
- Component organization (feature-based, type-based)
- State management patterns
- API layer structure
- Error handling approach

### 4. Key entry points

Find and read:
- Main app entry (`src/app/layout.tsx`, `src/main.tsx`, `src/App.tsx`)
- Route definitions
- Global providers/wrappers
- Shared types/constants

### 5. Development workflow

Document:
- Available scripts (`package.json` scripts)
- Environment setup (`.env.example`, config files)
- Git workflow (branch naming, PR templates)
- CI/CD pipeline (`.github/workflows/`)

### 6. Produce onboarding doc

Generate a concise summary covering:
- Stack overview (one line per technology)
- Directory map with purpose of each top-level folder
- Key patterns to follow
- How to run locally
- How to run tests
- Where to find things (components, hooks, utils, types, tests)
- Known gotchas or quirks
