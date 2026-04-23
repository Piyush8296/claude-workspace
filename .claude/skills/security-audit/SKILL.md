---
name: security-audit
description: Frontend security audit covering XSS, injection, CSRF, secrets scanning, CSP headers, dependency vulnerabilities, and authentication patterns. Use when reviewing security, before launch, or when handling user input.
---

# Frontend Security Audit

## Threat Model for Frontend Apps

| Threat | Vector | Impact |
|--------|--------|--------|
| **XSS** | User input rendered as HTML/JS | Session hijack, data theft, defacement |
| **Injection** | Dynamic URLs, eval(), innerHTML | Code execution, redirects |
| **CSRF** | Forged requests from other sites | Unauthorized actions |
| **Secrets Exposure** | API keys in client bundle | Account compromise, billing abuse |
| **Dependency Vulns** | Outdated packages with CVEs | Supply chain attacks |
| **Clickjacking** | Iframe embedding | UI redress attacks |
| **Open Redirects** | Unvalidated redirect URLs | Phishing, credential theft |

## Audit Checklist

### 1. XSS Prevention

```bash
# Find dangerouslySetInnerHTML usage
grep -rn 'dangerouslySetInnerHTML' src/ --include='*.tsx' --include='*.jsx'

# Find direct DOM manipulation
grep -rn 'innerHTML\|outerHTML\|document\.write' src/ --include='*.ts' --include='*.tsx'

# Find eval and dynamic code execution
grep -rn 'eval(\|new Function(\|setTimeout.*string' src/ --include='*.ts' --include='*.tsx'
```

**Rules:**
- Never use `dangerouslySetInnerHTML` without DOMPurify sanitization
- Never use `eval()`, `new Function()`, or string-based `setTimeout`
- Always escape user input before rendering
- Use React's built-in escaping (JSX expressions auto-escape)

```typescript
// BAD: direct HTML injection
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// GOOD: sanitized
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />

// BEST: avoid entirely, use structured data
<div>{userInput}</div>  // React auto-escapes
```

### 2. Secrets & API Keys

```bash
# Scan for hardcoded secrets
grep -rn 'sk_live\|pk_live\|AKIA\|ghp_\|password\s*=\|secret\s*=' src/ --include='*.ts' --include='*.tsx' --include='*.js'

# Check for secrets in client-accessible env vars
grep -rn 'NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*KEY\|VITE_.*SECRET' .env* 2>/dev/null

# Check if .env is gitignored
grep -q '.env' .gitignore || echo "WARNING: .env not in .gitignore"
```

**Rules:**
- Never expose secret keys via `NEXT_PUBLIC_` or `VITE_` prefixed env vars
- API keys that must be client-side should be restricted by domain/IP in the provider dashboard
- Use backend API routes as proxies for sensitive API calls
- Rotate any key that was ever committed to git history

### 3. Authentication & Authorization

```typescript
// Token storage: NEVER localStorage for auth tokens
// BAD
localStorage.setItem('token', jwt);

// GOOD: httpOnly cookie (set by server)
// The token never touches JavaScript

// If you MUST use client storage:
// Use short-lived tokens + refresh via httpOnly cookie
```

**Rules:**
- Auth tokens in `httpOnly`, `Secure`, `SameSite=Strict` cookies
- Never store tokens in `localStorage` or `sessionStorage`
- Implement token refresh with short expiry (15 min access, 7 day refresh)
- Validate authorization on every API route, not just the frontend
- Logout must invalidate server-side session, not just clear client state

### 4. Dependency Security

```bash
# Audit for known vulnerabilities
npm audit 2>/dev/null || pnpm audit 2>/dev/null

# Check for outdated packages
npm outdated 2>/dev/null | head -20

# Find packages with no maintenance
npx is-website-vulnerable 2>/dev/null
```

**Rules:**
- Run `npm audit` in CI — fail on critical/high
- Pin exact versions in `package.json` (no `^` for security-critical deps)
- Review dependency changelogs before major upgrades
- Prefer packages with >1000 weekly downloads and recent maintenance

### 5. Content Security Policy (CSP)

```typescript
// next.config.js — example CSP header
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline'",  // Tighten in production
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: https:",
      "font-src 'self'",
      "connect-src 'self' https://api.yourapp.com",
      "frame-ancestors 'none'",             // Prevent clickjacking
    ].join('; '),
  },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
];
```

### 6. Input Validation

```typescript
import { z } from 'zod';

// Validate ALL user input at the boundary
const loginSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(8).max(128),
});

// In your form handler
const result = loginSchema.safeParse(formData);
if (!result.success) {
  // Show validation errors, don't send to API
  return;
}
// Only send validated data
await api.login(result.data);
```

**Rules:**
- Validate on client (UX) AND server (security)
- Use Zod or similar schema validation — never hand-written regex for security
- Limit string lengths to prevent DoS
- Sanitize file uploads: check MIME type, extension, and size

### 7. URL & Redirect Safety

```typescript
// BAD: open redirect
const redirectUrl = searchParams.get('redirect');
window.location.href = redirectUrl;  // Attacker: ?redirect=https://evil.com

// GOOD: allowlist validation
const ALLOWED_ORIGINS = ['https://yourapp.com', 'https://staging.yourapp.com'];
const redirectUrl = searchParams.get('redirect') ?? '/';
const isAllowed = ALLOWED_ORIGINS.some(origin => redirectUrl.startsWith(origin))
  || redirectUrl.startsWith('/');

if (isAllowed) {
  router.push(redirectUrl);
} else {
  router.push('/');
}
```

## Report Format

```
## Security Audit Summary

**Risk Level**: CRITICAL / HIGH / MEDIUM / LOW
**Score**: X/10

### Critical (act now)
- [file:line] Issue — Impact — Fix

### High (fix before launch)
- [file:line] Issue — Impact — Fix

### Medium (address soon)
- [file:line] Issue — Impact — Fix

### Passed Checks
- [check name] — confirmed safe
```

## Integration with Other Skills

- **react-patterns**: Secure component patterns
- **state-management**: Secure token/auth state handling
- **testing-strategy**: Security-focused test cases
- **systematic-debugging**: Investigating security incidents
