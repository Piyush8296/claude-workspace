---
name: accessibility
description: WCAG 2.1 AA accessibility patterns for React — semantic HTML, ARIA, keyboard navigation, screen readers, focus management. Use when building interactive components, forms, modals, or auditing accessibility.
---

# Accessibility (a11y)

## Principle: Semantic HTML First

Use the right element before reaching for ARIA:

```tsx
// BAD: div cosplaying as a button
<div onClick={handleClick} className="btn">
  Submit
</div>

// GOOD: actual button
<button onClick={handleClick} type="button">
  Submit
</button>
```

Semantic elements provide keyboard handling, focus management, and screen reader semantics for free.

## Interactive Element Patterns

### Buttons vs Links

```tsx
// Button: performs an action
<button type="button" onClick={handleSave}>
  Save Changes
</button>

// Link: navigates somewhere
<a href="/settings">Go to Settings</a>

// NEVER: link styled as button that performs action
// <a href="#" onClick={handleSave}>Save</a> // NO!
```

### Toggle Button

```tsx
function ToggleButton({ isPressed, onToggle, label }: ToggleButtonProps) {
  return (
    <button
      type="button"
      aria-pressed={isPressed}
      onClick={onToggle}
    >
      {label}
    </button>
  );
}
```

### Disclosure (Expand/Collapse)

```tsx
function Disclosure({ title, children }: DisclosureProps) {
  const [isOpen, setIsOpen] = useState(false);
  const contentId = useId();

  return (
    <div>
      <button
        type="button"
        aria-expanded={isOpen}
        aria-controls={contentId}
        onClick={() => setIsOpen(!isOpen)}
      >
        {title}
      </button>
      <div id={contentId} role="region" hidden={!isOpen}>
        {children}
      </div>
    </div>
  );
}
```

## Modal / Dialog

```tsx
function Modal({ isOpen, onClose, title, children }: ModalProps) {
  const titleId = useId();
  const previousFocus = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      previousFocus.current = document.activeElement as HTMLElement;
    } else {
      previousFocus.current?.focus(); // Restore focus on close
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
      onKeyDown={(e) => e.key === 'Escape' && onClose()}
    >
      <h2 id={titleId}>{title}</h2>
      {children}
      <button type="button" onClick={onClose} aria-label="Close dialog">
        ×
      </button>
    </div>
  );
}
```

**Modal requirements:**
- `role="dialog"` + `aria-modal="true"`
- `aria-labelledby` pointing to the title
- Focus trapped inside while open
- Escape key closes
- Focus returns to trigger on close

## Forms

```tsx
function LoginForm() {
  const emailId = useId();
  const passwordId = useId();
  const emailErrorId = useId();

  return (
    <form>
      <div>
        <label htmlFor={emailId}>Email address</label>
        <input
          id={emailId}
          type="email"
          autoComplete="email"
          aria-required="true"
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? emailErrorId : undefined}
        />
        {errors.email && (
          <p id={emailErrorId} role="alert">
            {errors.email}
          </p>
        )}
      </div>

      <div>
        <label htmlFor={passwordId}>Password</label>
        <input
          id={passwordId}
          type="password"
          autoComplete="current-password"
          aria-required="true"
        />
      </div>

      <button type="submit">Sign in</button>
    </form>
  );
}
```

**Form requirements:**
- Every input has a visible `<label>` linked via `htmlFor`/`id`
- `aria-required` on required fields
- `aria-invalid` + `aria-describedby` for error messages
- `autocomplete` attributes for autofill support
- Error messages linked and announced

## Live Regions

```tsx
// Toast notification
<div role="alert" aria-live="assertive">
  {errorMessage}
</div>

// Status update (non-urgent)
<div role="status" aria-live="polite">
  {`${results.length} results found`}
</div>

// Loading state
<div aria-busy={isLoading} aria-live="polite">
  {isLoading ? 'Loading...' : content}
</div>
```

| Urgency | Use | ARIA |
|---------|-----|------|
| Interrupting | Error alerts, urgent notifications | `role="alert"` or `aria-live="assertive"` |
| Background | Search results, saved confirmation | `role="status"` or `aria-live="polite"` |
| Loading | Async operations | `aria-busy="true"` + `aria-live="polite"` |

## Images

```tsx
// Informative image
<img src="/chart.png" alt="Revenue grew 23% quarter over quarter in Q4 2024" />

// Decorative image (no info conveyed)
<img src="/divider.svg" alt="" role="presentation" />

// Complex image (needs long description)
<figure>
  <img src="/architecture.png" alt="System architecture diagram" aria-describedby="arch-desc" />
  <figcaption id="arch-desc">
    The system consists of three microservices communicating via an event bus...
  </figcaption>
</figure>

// Icon button (no visible text)
<button type="button" aria-label="Close" onClick={onClose}>
  <XIcon aria-hidden="true" />
</button>
```

## Keyboard Navigation Patterns

| Widget | Keys | Behavior |
|--------|------|---------|
| Button | Enter, Space | Activate |
| Link | Enter | Navigate |
| Tabs | Arrow Left/Right | Switch tab |
| Menu | Arrow Up/Down | Navigate items |
| Dialog | Escape | Close, return focus |
| Dropdown | Escape | Close |
| Checkbox | Space | Toggle |

## Testing

```bash
# Automated (catches ~30% of issues)
npx axe <url>                    # axe-core CLI
npx eslint --rule '{"jsx-a11y/*": "error"}' src/

# Manual (catches the rest)
# 1. Tab through entire page — logical order? Focus visible?
# 2. Screen reader test — VoiceOver (Mac), NVDA (Windows)
# 3. Zoom to 200% — content reflows? Nothing hidden?
# 4. Keyboard-only — every action possible without mouse?
```

## Checklist

- [ ] Semantic HTML for all elements
- [ ] All interactive elements keyboard accessible
- [ ] Focus visible on all focusable elements
- [ ] Color contrast ≥ 4.5:1
- [ ] Images have alt text
- [ ] Forms have labels and error messages
- [ ] Modals trap focus and support Escape
- [ ] Dynamic content announced via live regions
- [ ] `prefers-reduced-motion` respected
- [ ] Page works at 200% zoom

## Integration with Other Skills

- **react-patterns**: Accessible component templates
- **css-architecture**: Focus styles, contrast, motion preferences
- **testing-strategy**: Accessible query priority in tests
