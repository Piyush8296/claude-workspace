---
paths:
  - "**/*.md"
  - "**/*.mdx"
---

# Documentation Rules

## Standards

- One topic per file — keep focused and scannable.
- Heading hierarchy is sequential: `#` → `##` → `###`. Never skip levels.
- Code examples are runnable — no pseudocode in docs meant for implementation.
- Use relative links between docs: `../guides/auth.md`, not absolute GitHub URLs.

## Structure

- `README.md` at project root — setup, architecture overview, contributing guide.
- `docs/` directory for extended docs — architecture decisions, API reference, deployment.
- Co-locate component docs with components when using Storybook/MDX.

## API Documentation

- Every exported function/component has a JSDoc comment with `@param`, `@returns`, `@example`.
- Props interfaces include JSDoc on each property.
- Complex hooks document their return value shape.

## Changelog

- Follow Keep a Changelog format.
- Entries grouped: Added, Changed, Deprecated, Removed, Fixed, Security.
- Every user-facing change has an entry.

## Writing Style

- Present tense, active voice: "Returns the user" not "Will return the user".
- Imperative for instructions: "Run the test suite" not "You should run the test suite".
- Avoid jargon without context — define acronyms on first use.
- Be concise. If a sentence doesn't add information, remove it.
