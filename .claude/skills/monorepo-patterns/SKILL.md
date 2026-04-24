# Monorepo Patterns

Workspace architecture patterns for Turborepo, Nx, and pnpm workspaces. Scalable multi-package project structures with shared configs, optimized builds, and dependency management.

## Workspace Structure

```
monorepo/
├── apps/
│   ├── web/                 # Next.js app
│   ├── mobile/              # React Native app
│   └── docs/                # Documentation site
├── packages/
│   ├── ui/                  # Shared component library
│   ├── config/              # Shared configs (ESLint, TS, Tailwind)
│   ├── utils/               # Shared utilities
│   └── types/               # Shared TypeScript types
├── turbo.json               # Turborepo pipeline config
├── pnpm-workspace.yaml      # Workspace definition
└── package.json             # Root package.json
```

## Turborepo Pipeline Configuration

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
```

## Shared Package Pattern

```typescript
// packages/ui/package.json
{
  "name": "@workspace/ui",
  "version": "0.0.0",
  "private": true,
  "exports": {
    "./button": "./src/button.tsx",
    "./card": "./src/card.tsx",
    "./input": "./src/input.tsx",
    "./styles.css": "./src/styles.css"
  },
  "devDependencies": {
    "@workspace/config": "workspace:*",
    "typescript": "^5.0.0"
  }
}

// packages/ui/src/button.tsx
import { forwardRef, type ButtonHTMLAttributes } from 'react';
import { cn } from '@workspace/utils';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'inline-flex items-center justify-center rounded-md font-medium transition-colors',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
          'disabled:pointer-events-none disabled:opacity-50',
          variantStyles[variant],
          sizeStyles[size],
          className
        )}
        {...props}
      />
    );
  }
);
Button.displayName = 'Button';

const variantStyles = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700',
  secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
  ghost: 'hover:bg-gray-100 text-gray-700',
} as const;

const sizeStyles = {
  sm: 'h-8 px-3 text-sm',
  md: 'h-10 px-4 text-sm',
  lg: 'h-12 px-6 text-base',
} as const;
```

## Shared Config Pattern

```typescript
// packages/config/eslint/index.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'import'],
  rules: {
    'import/order': ['error', {
      groups: ['builtin', 'external', 'internal', 'parent', 'sibling'],
      'newlines-between': 'always',
      alphabetize: { order: 'asc' },
    }],
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/consistent-type-imports': 'error',
  },
};

// packages/config/tsconfig/react.json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["DOM", "DOM.Iterable", "ES2020"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

## Internal Package Consumption

```typescript
// apps/web/package.json — consuming shared packages
{
  "name": "@workspace/web",
  "dependencies": {
    "@workspace/ui": "workspace:*",
    "@workspace/utils": "workspace:*",
    "@workspace/types": "workspace:*"
  }
}

// apps/web/next.config.js — transpile internal packages
const nextConfig = {
  transpilePackages: ['@workspace/ui', '@workspace/utils'],
};
module.exports = nextConfig;

// apps/web/src/app/page.tsx
import { Button } from '@workspace/ui/button';
import { formatDate } from '@workspace/utils';
import type { User } from '@workspace/types';
```

## Dependency Management

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

```jsonc
// Root package.json scripts
{
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "test": "turbo test",
    "typecheck": "turbo typecheck",
    "clean": "turbo clean && rm -rf node_modules",
    "format": "prettier --write \"**/*.{ts,tsx,md}\""
  }
}
```

## Versioning and Changesets

```typescript
// .changeset/config.json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [["@workspace/ui", "@workspace/utils"]],
  "access": "restricted",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": ["@workspace/web", "@workspace/docs"]
}
```

## Checklist

- [ ] Workspace packages use `workspace:*` protocol for internal deps
- [ ] Turborepo pipeline has correct `dependsOn` graph
- [ ] Build outputs are specified for caching
- [ ] Shared configs are consumed via package references, not copy-paste
- [ ] `transpilePackages` configured in Next.js for internal packages
- [ ] TypeScript project references or paths configured
- [ ] CI runs `turbo build --filter=...[origin/main]` for affected-only builds
- [ ] Changesets configured for versioning public packages
- [ ] Root `.gitignore` covers all app/package build outputs
- [ ] `dev` tasks marked as `persistent: true` and `cache: false`

## Anti-Patterns

- Duplicating configs across apps instead of sharing from `packages/config`
- Using `*` or `latest` instead of `workspace:*` for internal dependencies
- Missing `dependsOn: ["^build"]` causing stale package builds
- Putting app-specific code in shared packages
- Circular dependencies between workspace packages
- Not setting `outputs` in turbo.json — breaks remote caching
- Hardcoding absolute paths instead of using workspace aliases
