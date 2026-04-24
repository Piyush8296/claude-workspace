---
name: auth-patterns
description: Authentication and authorization patterns for React and Next.js — NextAuth/Auth.js setup, middleware route protection, token refresh, session management, protected components, OAuth providers, role-based UI. Use when implementing login, protecting routes, or managing user sessions.
---

# Auth Patterns

## Architecture Decision

| Approach | Best For | Session Storage |
|----------|----------|----------------|
| **NextAuth / Auth.js** | Next.js apps, OAuth providers | Server-side (JWT or database) |
| **Custom JWT** | React SPAs, custom backends | httpOnly cookie (server-set) |
| **Session cookie** | Traditional server-rendered | httpOnly cookie |

**Rule:** Never store auth tokens in `localStorage` or `sessionStorage`. Always use `httpOnly` cookies.

## Next.js Middleware Protection

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { getToken } from 'next-auth/jwt';

const PUBLIC_ROUTES = ['/', '/login', '/register', '/forgot-password'];
const AUTH_ROUTES = ['/login', '/register'];  // Redirect away if already logged in

export async function middleware(req: NextRequest) {
  const token = await getToken({ req });
  const { pathname } = req.nextUrl;

  // Already authenticated → redirect away from auth pages
  if (token && AUTH_ROUTES.some((r) => pathname.startsWith(r))) {
    return NextResponse.redirect(new URL('/dashboard', req.url));
  }

  // Not authenticated → redirect to login (except public routes)
  if (!token && !PUBLIC_ROUTES.some((r) => pathname === r || pathname.startsWith('/api/auth'))) {
    const loginUrl = new URL('/login', req.url);
    loginUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|public/).*)'],
};
```

## NextAuth Setup

```typescript
// lib/auth.ts
import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';
import Credentials from 'next-auth/providers/credentials';
import { env } from '@/lib/env';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Google({
      clientId: env.GOOGLE_CLIENT_ID,
      clientSecret: env.GOOGLE_CLIENT_SECRET,
    }),
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      authorize: async (credentials) => {
        const user = await verifyCredentials(credentials);
        if (!user) return null;
        return { id: user.id, email: user.email, name: user.name, role: user.role };
      },
    }),
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) {
        token.id = user.id;
        token.role = user.role;
      }
      return token;
    },
    session({ session, token }) {
      session.user.id = token.id as string;
      session.user.role = token.role as string;
      return session;
    },
  },
  pages: {
    signIn: '/login',
    error: '/login',
  },
});
```

## Session Hook

```typescript
// hooks/useAuth.ts
import { useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';

export function useAuth({ required = false } = {}) {
  const { data: session, status } = useSession({ required });
  const router = useRouter();

  return {
    user: session?.user ?? null,
    isAuthenticated: !!session?.user,
    isLoading: status === 'loading',
    role: session?.user?.role ?? 'guest',
    signOut: () => {
      signOut({ callbackUrl: '/login' });
    },
  };
}
```

## Protected Components

```tsx
// components/ProtectedRoute.tsx
'use client';

import { useAuth } from '@/hooks/useAuth';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: string;
  fallback?: React.ReactNode;
}

export function ProtectedRoute({ children, requiredRole, fallback }: ProtectedRouteProps) {
  const { isAuthenticated, isLoading, role } = useAuth({ required: true });

  if (isLoading) return fallback ?? <LoadingSkeleton />;
  if (!isAuthenticated) return null;  // Middleware handles redirect
  if (requiredRole && role !== requiredRole) return <ForbiddenState />;

  return <>{children}</>;
}

// Role-based UI rendering
export function RoleGate({ allowed, children }: { allowed: string[]; children: React.ReactNode }) {
  const { role } = useAuth();
  if (!allowed.includes(role)) return null;
  return <>{children}</>;
}
```

```tsx
// Usage
<ProtectedRoute requiredRole="admin">
  <AdminDashboard />
</ProtectedRoute>

<RoleGate allowed={['admin', 'editor']}>
  <EditButton />
</RoleGate>
```

## React SPA (Custom JWT)

For plain React without Next.js:

```typescript
// lib/auth.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  checkSession: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,

  login: async (email, password) => {
    // Server sets httpOnly cookie, returns user object
    const user = await fetchClient<User>('/api/auth/login', {
      method: 'POST',
      body: { email, password },
    });
    set({ user, isAuthenticated: true });
  },

  logout: async () => {
    await fetchClient('/api/auth/logout', { method: 'POST' });
    set({ user: null, isAuthenticated: false });
  },

  checkSession: async () => {
    try {
      const user = await fetchClient<User>('/api/auth/me');
      set({ user, isAuthenticated: true });
    } catch {
      set({ user: null, isAuthenticated: false });
    }
  },
}));
```

## Security Rules

- Tokens in `httpOnly`, `Secure`, `SameSite=Strict` cookies only
- Short-lived access tokens (15 min) + long-lived refresh (7 days)
- Validate auth server-side on every request, not just client-side
- Logout must invalidate server session, not just clear client state
- Rate-limit login attempts (5/min per IP)
- Hash passwords with bcrypt/argon2, never SHA/MD5
- CSRF tokens on state-changing requests if using cookies

## Integration with Other Skills

- **api-layer**: Auth interceptor for token injection
- **error-handling**: AuthError class, redirect on 401
- **security-audit**: Token storage, CSRF, rate limiting
- **state-management**: Auth state in Zustand store
