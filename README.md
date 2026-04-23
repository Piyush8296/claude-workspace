# Claude Workspace — Frontend Engineering Configuration

A production-grade Claude Code workspace configuration built by senior frontend engineers, for frontend engineers. Drop this into any React/TypeScript project and immediately get expert-level AI pair programming with enforced standards, automated quality gates, and domain-specific knowledge.

## Architecture

<p align="center">
  <img src="assets/architecture.svg" alt="Claude Workspace Architecture — showing CLAUDE.md, settings.json, agents, commands, rules, skills, and hooks" width="720" />
</p>

## What's Inside

```
claude-workspace/
├── CLAUDE.md                                # Project memory — stack, conventions, critical rules
├── .claude/
│   ├── settings.json                        # Permissions, 10 hooks, env config
│   ├── agents/
│   │   ├── code-reviewer.md                 # Senior code reviewer (auto-invoked)
│   │   ├── performance-auditor.md           # Core Web Vitals & bundle analysis
│   │   ├── accessibility-auditor.md         # WCAG 2.1 AA compliance
│   │   ├── refactor-planner.md              # Safe refactoring strategy
│   │   ├── doc-generator.md                 # Auto-writes JSDoc & component docs
│   │   ├── architecture-reviewer.md         # Module boundaries & scalability
│   │   └── test-writer.md                   # Writes tests with factory patterns
│   ├── commands/
│   │   ├── code-quality.md                  # /code-quality <path>
│   │   ├── component-gen.md                 # /component-gen <ComponentName>
│   │   ├── pr-review.md                     # /pr-review [branch]
│   │   ├── ticket.md                        # /ticket <PROJ-123>
│   │   ├── migrate.md                       # /migrate <from> <to>
│   │   └── onboard.md                       # /onboard
│   ├── rules/
│   │   ├── typescript.md                    # TS/TSX file rules (lazy-loaded)
│   │   ├── styling.md                       # CSS/Tailwind rules (lazy-loaded)
│   │   ├── testing.md                       # Test file rules (lazy-loaded)
│   │   └── documentation.md                 # Markdown rules (lazy-loaded)
│   ├── skills/
│   │   ├── react-patterns/SKILL.md          # Component architecture & patterns
│   │   ├── state-management/SKILL.md        # State strategies & data fetching
│   │   ├── testing-strategy/SKILL.md        # Testing methodology & factories
│   │   ├── css-architecture/SKILL.md        # Styling patterns & responsive design
│   │   ├── performance-optimization/SKILL.md # Web Vitals, lazy loading, memoization
│   │   ├── accessibility/SKILL.md           # WCAG, ARIA, keyboard nav
│   │   ├── systematic-debugging/SKILL.md    # Root cause analysis methodology
│   │   ├── frontend-design/SKILL.md         # Bold aesthetics, typography, micro-interactions
│   │   └── design-intelligence/SKILL.md     # Claude Design + Google Stitch workflows
│   └── hooks/
│       └── scripts/
│           └── screenshot.sh                # UI screenshot capture for visual review
├── .mcp.json                                # MCP server configuration
└── .gitignore
```

## Quick Start

### 1. Clone into your project

```bash
# Option A: Copy the .claude/ folder and CLAUDE.md into an existing project
git clone https://github.com/Piyush8296/claude-workspace.git /tmp/claude-workspace
cp -r /tmp/claude-workspace/.claude /tmp/claude-workspace/CLAUDE.md /tmp/claude-workspace/.mcp.json your-project/

# Option B: Use as a template for new projects
git clone https://github.com/Piyush8296/claude-workspace.git my-project
cd my-project && rm -rf .git && git init
```

### 2. Customize CLAUDE.md

Update the Quick Facts section in `CLAUDE.md` to match your project's actual stack, directories, and commands.

### 3. Start Claude Code

```bash
cd your-project
claude
```

Claude will automatically load the configuration and have access to all skills, agents, commands, and rules.

## How It Works

### Skills (9 skills in `.claude/skills/`)

Skills are deep knowledge bases that Claude loads when relevant. Each contains patterns, anti-patterns, code examples, and checklists. Claude auto-discovers them based on task context.

| Skill | What It Covers |
|-------|----------------|
| `react-patterns` | Component architecture, composition, state handling order |
| `state-management` | TanStack Query, Zustand, URL state, decision framework |
| `testing-strategy` | TDD, factory pattern, mocking, coverage targets |
| `css-architecture` | Tailwind patterns, design tokens, responsive, z-index |
| `performance-optimization` | Core Web Vitals, code splitting, virtualization |
| `accessibility` | WCAG 2.1 AA, ARIA, keyboard nav, focus management |
| `systematic-debugging` | 4-phase root cause analysis, no fix without diagnosis |
| `frontend-design` | Bold aesthetics, typography, micro-interactions, skeleton loading |
| `design-intelligence` | Claude Design + Google Stitch workflows, design tokens, style selection |

### Agents (7 agents in `.claude/agents/`)

Specialized sub-agents that run in isolated contexts with focused toolsets.

| Agent | Model | Trigger |
|-------|-------|---------|
| `code-reviewer` | Sonnet | Proactively after any code change |
| `performance-auditor` | Sonnet | Performance complaints or pre-launch |
| `accessibility-auditor` | Sonnet | UI work or a11y issues reported |
| `refactor-planner` | Sonnet | Before restructuring or migration |
| `doc-generator` | Haiku | Proactively after code changes (background) |
| `architecture-reviewer` | Sonnet | Adding modules or restructuring (background) |
| `test-writer` | Sonnet | After features or bug fixes (background) |

### Commands (6 slash commands in `.claude/commands/`)

| Command | Usage | What it does |
|---------|-------|--------------|
| `/code-quality` | `/code-quality src/components/` | Runs lint, typecheck, and manual review |
| `/component-gen` | `/component-gen UserAvatar` | Scaffolds component + test + barrel export |
| `/pr-review` | `/pr-review` | Reviews current branch changes |
| `/ticket` | `/ticket PROJ-123` | Full ticket-to-PR workflow |
| `/migrate` | `/migrate class-components hooks` | Guided migration with safety checks |
| `/onboard` | `/onboard` | Explores and documents the codebase |

### Rules (4 path-scoped rules in `.claude/rules/`)

Lazy-load only when Claude touches matching files. Zero overhead when not relevant.

| Rule | Triggers On |
|------|-------------|
| `typescript.md` | `**/*.ts`, `**/*.tsx` |
| `styling.md` | `**/*.css`, `**/*.scss`, `tailwind.config.*` |
| `testing.md` | `**/*.test.*`, `**/*.spec.*` |
| `documentation.md` | `**/*.md`, `**/*.mdx` |

### Hooks (10 hooks in `settings.json`)

Deterministic shell commands that run at specific lifecycle points:

| Hook | Event | What It Does |
|------|-------|--------------|
| Branch guard | PreToolUse | Blocks edits on `main` branch |
| File protection | PreToolUse | Blocks edits to `.env`, production configs, secrets |
| Prettier format | PostToolUse | Auto-formats JS/TS/JSX/TSX on save |
| TypeScript check | PostToolUse | Runs `tsc --noEmit` on TS file changes |
| Test runner | PostToolUse | Runs related tests on test file changes |
| Dep installer | PostToolUse | Auto-installs on `package.json` changes |
| Auto-commit | PostToolUse | Stages + commits every successful edit |
| UI screenshot | PostToolUse | Captures running app on UI file changes |
| Finish notification | Stop | macOS notification when Claude finishes |
| Vercel preview | Stop | Deploys preview after clean build |

## External Design Tools

The `design-intelligence` skill integrates with two AI design platforms:

- **[Claude Design](https://support.claude.com/en/articles/14604416-get-started-with-claude-design)** — Anthropic's visual prototyping tool. Creates designs from conversation, enforces your design system, exports to React.
- **[Google Stitch](https://stitch.withgoogle.com/)** — Free AI UI design tool. Generates up to 5 interconnected screens from natural language, exports to Tailwind, Vue, Angular, Flutter, SwiftUI.

## Extending for Backend / Full-Stack

This workspace is frontend-focused by default but designed for extension:

1. Add new skills in `.claude/skills/<domain>/SKILL.md`
2. Add new agents in `.claude/agents/<specialist>.md`
3. Add path-scoped rules in `.claude/rules/<domain>.md`
4. Update `CLAUDE.md` Quick Facts and Key Directories

## Philosophy

- **Opinionated defaults, easy overrides** — sensible standards out of the box, customize per project
- **Progressive disclosure** — Claude loads only what's relevant to the current task
- **Deterministic quality gates** — hooks guarantee formatting and type-checking regardless of model behavior
- **Senior-level patterns** — every skill encodes patterns from 15+ years of production frontend experience
- **Composable architecture** — skills reference each other, agents delegate, commands orchestrate

## References

- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Claude Code Showcase](https://github.com/ChrisWiles/claude-code-showcase)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [LeadGenMan Resources](https://resources.leadgenman.com/)
- [Claude Design](https://support.claude.com/en/articles/14604416-get-started-with-claude-design)
- [Google Stitch](https://stitch.withgoogle.com/)

## License

MIT
