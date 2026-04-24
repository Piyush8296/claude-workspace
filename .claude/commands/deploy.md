---
description: Pre-deployment verification checklist
---

# Deploy Readiness Check

Run a comprehensive pre-deployment verification before shipping to production.

## Steps

### 1. Environment Validation
- Verify all required environment variables are set for the target environment
- Check `.env.example` is in sync with actual `.env` usage across the codebase
- Confirm no secrets or API keys are hardcoded in source files
- Validate environment-specific configs (API URLs, feature flags, analytics IDs)

### 2. Build Verification
- Run `npm run build` (or equivalent) and confirm zero errors
- Check bundle size against budgets: main JS < 200KB gzipped, CSS < 50KB gzipped
- Verify no console.log or debugger statements in production code
- Confirm source maps are configured correctly (generated but not publicly served)
- Check for any TypeScript `@ts-ignore` or `any` type escapes added in this release

### 3. Test Suite
- Run full test suite: `npm test -- --coverage`
- Confirm coverage thresholds are met (statements > 80%, branches > 75%)
- Run E2E tests against staging: `npm run test:e2e`
- Verify no skipped tests (`.skip`) were left from debugging

### 4. Database & API
- List any pending database migrations and verify they are reversible
- Confirm API versioning: no breaking changes to existing endpoints
- Check that new API endpoints have rate limiting configured
- Verify webhook endpoints have retry/idempotency handling

### 5. Feature Flags
- List all feature flags modified in this release
- Confirm flags default to OFF for new features
- Document flag cleanup plan for flags older than 30 days
- Verify flag evaluation doesn't block critical render path

### 6. Performance Check
- Run Lighthouse CI and confirm scores: Performance > 90, Accessibility > 95
- Check Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1
- Verify no render-blocking resources added
- Confirm images are optimized (WebP/AVIF with fallbacks, proper sizing)

### 7. Security Scan
- Run `npm audit` and confirm no high/critical vulnerabilities
- Check CSP headers are configured for new external resources
- Verify authentication flows work end-to-end
- Confirm CORS policies are correct for the target environment

### 8. Rollback Plan
- Document the rollback procedure (revert commit SHA, feature flag kill switch)
- Confirm previous version's Docker image / build artifact is still available
- Identify monitoring alerts that would trigger a rollback
- Set rollback decision deadline (e.g., 30 minutes post-deploy)

### 9. Release Notes
- Generate changelog from commits since last release
- Document any required manual steps post-deploy (cache invalidation, DNS changes)
- Notify stakeholders of deployment window
- Update status page if applicable

## Output Format

Present results as a deployment readiness report:

```
## Deploy Readiness: [PASS/FAIL]

| Check              | Status | Notes                    |
|--------------------|--------|-------------------------|
| Environment        | ✅/❌   |                          |
| Build              | ✅/❌   |                          |
| Tests              | ✅/❌   | Coverage: XX%            |
| Database           | ✅/❌   | X migrations pending     |
| Feature Flags      | ✅/❌   | X flags modified         |
| Performance        | ✅/❌   | Lighthouse: XX           |
| Security           | ✅/❌   | X vulnerabilities        |
| Rollback Plan      | ✅/❌   |                          |

Blocking Issues: [list any]
Recommendation: [SHIP IT / HOLD]
```
