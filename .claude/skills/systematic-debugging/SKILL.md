---
name: systematic-debugging
description: Four-phase debugging methodology with root cause analysis. Use when investigating bugs, fixing test failures, diagnosing unexpected behavior, or troubleshooting production issues. Emphasizes NO FIXES WITHOUT ROOT CAUSE FIRST.
---

# Systematic Debugging

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Never apply symptom-focused patches that mask underlying problems. Understand WHY something fails before writing a single line of fix code.

## The Four-Phase Framework

### Phase 1: Reproduce & Gather Evidence

Before touching any code:

1. **Read the full error** — every word matters, including the stack trace
2. **Reproduce consistently** — define exact steps. If you can't reproduce, you can't verify a fix
3. **Check recent changes** — `git log --oneline -10`, what changed before this broke?
4. **Gather diagnostics** — console output, network tab, React DevTools, state snapshots
5. **Define expected vs actual** — write it down explicitly

```bash
# Find the breaking change
git log --oneline -20
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>
```

### Phase 2: Trace to Root Cause

Follow the data, not your assumptions:

```
1. Where does the error appear? (symptom location)
2. What value is wrong at that point?
3. Where does that value come from? (trace upstream)
4. Is the value wrong at the source, or corrupted in transit?
5. What assumption was violated?
```

**Key insight:** The bug is rarely where the error appears. Trace upstream until you find where correct data becomes incorrect.

### Phase 3: Hypothesize & Test

Scientific method, not shotgun debugging:

1. **One clear hypothesis** — "The error occurs because X causes Y"
2. **Predict the outcome** — "If my hypothesis is correct, then Z should happen when I..."
3. **Change ONE variable** — isolate the test
4. **Observe result** — did it match prediction?
5. **Iterate or proceed** — revise hypothesis if wrong, implement if right

### Phase 4: Fix & Verify

1. **Write a failing test** that captures the exact bug
2. **Implement the fix** — address root cause, not symptoms
3. **Verify the test passes**
4. **Run full test suite** — no regressions
5. **Verify in browser** — test the actual user flow

## Common Frontend Bug Categories

### Rendering Bugs

```
Symptom: Component shows wrong data or doesn't update
Common causes:
- Stale closure (useCallback/useEffect missing dependency)
- Key prop wrong (React reuses component instance)
- State mutation instead of immutable update
- useEffect dependency array incorrect

Diagnosis:
- React DevTools: check props and state values
- Add console.log at render time: is data correct?
- Check useEffect deps with ESLint exhaustive-deps rule
```

### Async/Race Condition Bugs

```
Symptom: Sometimes works, sometimes doesn't. Flaky tests.
Common causes:
- Response arrives after component unmounts
- Multiple rapid requests, last response isn't the latest
- State update after navigation

Diagnosis:
- Add timestamps to requests and responses
- Check for AbortController / cleanup functions
- Use React Query (handles cancellation automatically)
```

### Layout/Styling Bugs

```
Symptom: Element in wrong position, wrong size, or invisible
Common causes:
- CSS specificity conflict
- Missing overflow handling
- Flexbox/Grid misconfiguration
- z-index stacking context
- Missing responsive breakpoint

Diagnosis:
- Browser DevTools: Inspect computed styles
- Check for conflicting Tailwind classes (use tailwind-merge)
- Test at all breakpoints
```

### Hydration Mismatches (SSR)

```
Symptom: "Text content did not match" or "Hydration failed"
Common causes:
- Server renders different content than client
- Using browser APIs during render (window, localStorage)
- Dates/times formatted differently on server vs client
- Random values or Math.random() in render

Diagnosis:
- Check if component accesses window/document during render
- Wrap browser-only code in useEffect or dynamic import
- Use suppressHydrationWarning only for timestamps
```

## Red Flags — Stop Immediately

- **3+ failed fix attempts** → Re-evaluate the hypothesis. You're likely fixing symptoms.
- **"This should work"** → If you can't explain WHY it works, you don't understand the bug.
- **"Quick fix for now"** → There is no "for now." Fix the root cause or document the technical debt.
- **"Works on my machine"** → Environment difference IS the bug. Find it.

## Debugging Tools

```bash
# React DevTools
# - Components tab: inspect props/state/hooks
# - Profiler tab: identify unnecessary re-renders

# Browser DevTools
# - Console: errors, warnings, custom logs
# - Network: API calls, timing, response data
# - Performance: long tasks, layout thrashing
# - Application: localStorage, cookies, cache

# Code-level
console.trace('call stack');           # Print call stack
console.table(arrayOfObjects);         # Tabular data
JSON.stringify(obj, null, 2);          # Pretty-print deep objects
debugger;                              # Breakpoint in code
```

## Debugging Checklist

Before claiming a bug is fixed:

- [ ] Root cause identified and documented
- [ ] Hypothesis formed and tested
- [ ] Fix addresses root cause, not symptoms
- [ ] Failing test written that reproduces the bug
- [ ] Test passes with fix applied
- [ ] Full test suite passes (no regressions)
- [ ] Manually verified in browser
- [ ] Fix is minimal and focused

## Integration with Other Skills

- **testing-strategy**: Write reproducing test before fixing
- **react-patterns**: Common React-specific bug patterns
- **state-management**: State-related debugging techniques
