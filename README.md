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
│   ├── settings.json                        # Permissions, hooks, env config
│   ├── agents/
│   │   ├── code-reviewer.md                 # Senior code reviewer (auto-invoked)
│   │   ├── performance-auditor.md           # Core Web Vitals & bundle analysis
│   │   ├── accessibility-auditor.md         # WCAG 2.1 AA compliance
│   │   └── refactor-planner.md              # Safe refactoring strategy
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
│   └── skills/
│       ├── react-patterns/SKILL.md          # Component architecture & patterns
│       ├── state-management/SKILL.md        # State strategies & data fetching
│       ├── testing-strategy/SKILL.md        # Testing methodology & factories
│       ├── css-architecture/SKILL.md        # Styling patterns & responsive design
│       ├── performance-optimization/SKILL.md # Web Vitals, lazy loading, memoization
│       ├── accessibility/SKILL.md           # WCAG, ARIA, keyboard nav
│       └── systematic-debugging/SKILL.md    # Root cause analysis methodology
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

### Skills (`.claude/skills/`)

Skills are deep knowledge bases that Claude loads when relevant. Each contains patterns, anti-patterns, code examples, and checklists. Claude auto-discovers them based on task context.

**Example**: When you ask Claude to build a form component, it automatically loads both `react-patterns` and `state-management` skills.

### Agents (`.claude/agents/`)

Specialized sub-agents that run in isolated contexts with focused toolsets. Claude delegates to them for domain-specific analysis.

**Example**: After writing code, the `code-reviewer` agent proactively reviews your changes against project standards.

### Commands (`.claude/commands/`)

Slash commands for repeatable workflows. Type `/command-name` in Claude Code to trigger them.

| Command | Usage | What it does |
|---------|-------|--------------|
| `/code-quality` | `/code-quality src/components/` | Runs lint, typecheck, and manual review |
| `/component-gen` | `/component-gen UserAvatar` | Scaffolds component + test + story |
| `/pr-review` | `/pr-review` | Reviews current branch changes |
| `/ticket` | `/ticket PROJ-123` | Full ticket-to-PR workflow |
| `/migrate` | `/migrate class-components hooks` | Guided migration with safety checks |
| `/onboard` | `/onboard` | Explores and documents the codebase |

### Rules (`.claude/rules/`)

Path-scoped rules that lazy-load only when Claude touches matching files. Zero overhead when not relevant.

### Hooks (in `settings.json`)

Deterministic shell commands that run at specific lifecycle points:

- **PreToolUse**: Blocks edits on `main` branch
- **PostToolUse**: Auto-formats with Prettier, runs TypeScript checks, executes related tests, installs deps on `package.json` changes

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

## License

MIT
