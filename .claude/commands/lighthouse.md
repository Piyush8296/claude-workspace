---
description: Run a Lighthouse audit, parse scores, and generate a prioritized fix list
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(npx lighthouse*), Bash(npx:*), Bash(pnpm:*), Bash(node:*), Bash(cat:*)
argument-hint: [url-or-path]
---

# Lighthouse Audit

Audit: $ARGUMENTS

## Instructions

### 1. Determine the target

- If a URL is provided, use it directly
- If no argument, use `http://localhost:3000`
- If a path is provided, assume it's a route on localhost

### 2. Run Lighthouse

```bash
# Run Lighthouse with JSON output
npx lighthouse "$TARGET_URL" \
  --output=json \
  --output-path=./.lighthouse-report.json \
  --chrome-flags="--headless --no-sandbox" \
  --quiet
```

If Lighthouse isn't available or fails, fall back to manual analysis:
- Read the HTML output of key pages
- Check for common performance/SEO/a11y patterns
- Run `npx tsc --noEmit` and `npx eslint` as proxies

### 3. Parse scores

Extract the four category scores:

```bash
cat .lighthouse-report.json | node -e "
  const r = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
  const c = r.categories;
  console.log('Performance:', Math.round(c.performance.score * 100));
  console.log('Accessibility:', Math.round(c.accessibility.score * 100));
  console.log('Best Practices:', Math.round(c['best-practices'].score * 100));
  console.log('SEO:', Math.round(c.seo.score * 100));
"
```

### 4. Extract failing audits

For each category with score < 90, list failing audits:

```bash
cat .lighthouse-report.json | node -e "
  const r = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
  Object.entries(r.audits)
    .filter(([,a]) => a.score !== null && a.score < 1)
    .sort((a,b) => (a[1].score||0) - (b[1].score||0))
    .slice(0, 20)
    .forEach(([id, a]) => {
      console.log(Math.round((a.score||0)*100) + '/100', id, '-', a.title);
    });
"
```

### 5. Generate fix plan

For each failing audit, prioritize by impact:

**CRITICAL (score < 50):**
- Identify the root cause in the codebase
- Provide a specific fix with file:line reference
- Reference the relevant skill (core-web-vitals, seo-fundamentals, accessibility)

**WARNING (score 50-89):**
- Describe the issue and suggest a fix
- Estimate effort (quick fix vs. architectural change)

**SUGGESTION (score 90-99):**
- Note for future improvement

### 6. Auto-fix quick wins

If the user approves, automatically fix:
- Missing meta descriptions
- Missing alt text on images
- Missing `width`/`height` on images
- `font-display: swap` on web fonts
- `loading="lazy"` on below-fold images

### 7. Report

```
## Lighthouse Audit Report

**URL**: [target]
**Date**: [today]

| Category | Score | Status |
|----------|-------|--------|
| Performance | XX | GREEN/YELLOW/RED |
| Accessibility | XX | GREEN/YELLOW/RED |
| Best Practices | XX | GREEN/YELLOW/RED |
| SEO | XX | GREEN/YELLOW/RED |

### Fixes (prioritized)
1. [CRITICAL] ...
2. [WARNING] ...
3. [SUGGESTION] ...

### Quick Wins Applied
- [file] — fix description
```

### 8. Cleanup

```bash
rm -f .lighthouse-report.json
```
