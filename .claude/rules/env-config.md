---
globs:
  - .env
  - .env.*
  - "**/env.ts"
  - "**/env.mjs"
  - "**/config.ts"
---

# Environment Configuration Rules

## Validation with Zod

Always validate environment variables at build time using a typed schema:

```typescript
// env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().url(),
  NEXT_PUBLIC_API_URL: z.string().url(),
  NEXT_PUBLIC_SITE_URL: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  REDIS_URL: z.string().url().optional(),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

## Rules

- Never commit `.env` files with real values. Only `.env.example` with placeholder values.
- Prefix client-exposed vars with `NEXT_PUBLIC_` (Next.js) or `VITE_` (Vite).
- Never access `process.env` directly in application code; import from the validated `env` module.
- Keep `.env.example` in sync: every variable used in `env.ts` must have a placeholder entry.
- Use different `.env` files per environment: `.env.local`, `.env.development`, `.env.production`.
- Server-only secrets must never have `NEXT_PUBLIC_` / `VITE_` prefix.
- Add new env vars to CI/CD pipeline config at the same time as code changes.
- Document each variable's purpose with inline comments in `.env.example`.

## .env.example Template

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# Authentication
AUTH_SECRET=generate-a-32-char-random-string-here

# Public (exposed to browser)
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Optional services
# REDIS_URL=redis://localhost:6379
```

## Anti-Patterns

- Using `process.env.SOME_VAR!` (non-null assertion) instead of validated env module
- Mixing server and client env vars without clear naming convention
- Leaving stale env vars in `.env.example` that are no longer used
- Using fallback defaults for secrets (`process.env.SECRET || 'default'`)
- Logging environment variables, even in development
