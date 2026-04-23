---
description: Full frontend performance audit — bundle analysis, dependency weight, image optimization, load waterfall
allowed-tools: Read, Glob, Grep, Bash(npx:*), Bash(pnpm:*), Bash(npm:*), Bash(node:*), Bash(du:*), Bash(find:*), Bash(wc:*), Bash(sort:*)
argument-hint: [focus-area]
---

# Performance Audit

Audit performance: $ARGUMENTS

## Instructions

### 1. Bundle Analysis

```bash
# Build and measure output
pnpm build 2>&1 | tail -30

# Measure build output size
find dist/ .next/ build/ -name '*.js' -type f 2>/dev/null | \
  xargs du -sh 2>/dev/null | sort -rh | head -15

# Find the largest JS chunks
find dist/ .next/static/ build/static/ -name '*.js' -type f 2>/dev/null | \
  while read f; do echo "$(du -k \"$f\" | cut -f1)KB  $f"; done | \
  sort -rn | head -10
```

Flag any chunk > 200KB (gzipped) as a concern.

### 2. Dependency Weight

```bash
# Top 20 heaviest node_modules
du -sh node_modules/* 2>/dev/null | sort -rh | head -20

# Check for duplicate packages
npm ls --all 2>/dev/null | grep -E 'deduped|UNMET' | head -10

# Find packages that could be lighter
grep -E '"(moment|lodash|date-fns|axios)"' package.json
```

**Common replacements:**
| Heavy | Lighter Alternative | Savings |
|-------|--------------------|---------|
| moment.js (~300KB) | date-fns (~20KB tree-shaken) or dayjs (~2KB) | 95%+ |
| lodash (~70KB) | lodash-es (tree-shakeable) or native | 80%+ |
| axios (~14KB) | fetch (built-in) | 100% |
| classnames (~1KB) | clsx (~0.5KB) | 50% |

### 3. Tree-Shaking Analysis

```bash
# Find namespace imports that prevent tree-shaking
grep -rn "import \* as" src/ --include='*.ts' --include='*.tsx' | \
  grep -v 'React\|next' | head -10

# Find barrel file re-exports
find src/ -name 'index.ts' -exec grep -l 'export \*' {} \; | head -10

# Check for side-effect imports
grep -rn "^import '" src/ --include='*.ts' --include='*.tsx' | head -10
```

### 4. Code Splitting

```bash
# Check for dynamic imports (good)
grep -rn 'dynamic(\|lazy(' src/ --include='*.tsx' | wc -l

# Check total page/route count vs dynamic imports
find src/app src/pages -name 'page.tsx' -o -name '*.page.tsx' 2>/dev/null | wc -l

# Find heavy components that should be code-split
find src/components -name '*.tsx' -size +10k | while read f; do
  echo "$(wc -l < \"$f\") lines  $(du -k \"$f\" | cut -f1)KB  $f"
done | sort -rn | head -10
```

### 5. Image Optimization

```bash
# Find non-optimized image formats
find public/ src/ -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' 2>/dev/null | \
  while read f; do echo "$(du -k \"$f\" | cut -f1)KB  $f"; done | \
  sort -rn | head -10

# Find images without Next.js Image component
grep -rn '<img ' src/ --include='*.tsx' | grep -v 'next/image' | head -10

# Find images missing lazy loading
grep -rn '<img\|<Image' src/ --include='*.tsx' | \
  grep -v 'loading=\|priority\|lazy' | head -10

# Check for images > 500KB (should be compressed)
find public/ -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.webp' \) -size +500k 2>/dev/null
```

### 6. Font Loading

```bash
# Check font files and sizes
find public/ src/ -name '*.woff2' -o -name '*.woff' -o -name '*.ttf' 2>/dev/null | \
  while read f; do echo "$(du -k \"$f\" | cut -f1)KB  $f"; done | sort -rn

# Check for font-display usage
grep -rn 'font-display' src/ public/ --include='*.css' --include='*.scss' 2>/dev/null

# Check for font preloading
grep -rn 'preload.*font' src/ --include='*.tsx' --include='*.html' 2>/dev/null
```

### 7. Third-Party Scripts

```bash
# Find external script tags
grep -rn '<script.*src=\|<Script.*src=' src/ --include='*.tsx' --include='*.html' | head -10

# Check for async/defer/strategy
grep -rn '<script\|<Script' src/ --include='*.tsx' | \
  grep -v 'async\|defer\|strategy\|lazyOnload\|afterInteractive' | head -10
```

### 8. Produce Report

```
## Performance Audit Report

**Date**: [today]
**Build size**: XX KB (gzipped)

### Score Card
| Area | Status | Detail |
|------|--------|--------|
| Bundle size | GREEN/YELLOW/RED | Xkb total, largest chunk Ykb |
| Dependencies | GREEN/YELLOW/RED | X heavy deps, Y replaceable |
| Code splitting | GREEN/YELLOW/RED | X/Y routes use dynamic imports |
| Images | GREEN/YELLOW/RED | X unoptimized, Y missing lazy |
| Fonts | GREEN/YELLOW/RED | X fonts, preloaded: yes/no |
| Third-party | GREEN/YELLOW/RED | X scripts, Y blocking |

### Action Items (by estimated impact)
1. [HIGH] Replace moment.js with date-fns — saves ~280KB
2. [HIGH] Code-split /dashboard route — reduces initial bundle by ~150KB
3. [MEDIUM] Convert PNG images to WebP — saves ~60% file size
4. ...

### What's Looking Good
- ...
```
