#!/bin/bash
# Claude Workspace Installer
# Copies .claude/ config, CLAUDE.md, and .mcp.json into your project.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Piyush8296/claude-workspace/main/install.sh | bash
#   OR
#   bash install.sh /path/to/your/project

set -euo pipefail

REPO_URL="https://github.com/Piyush8296/claude-workspace.git"
TMP_DIR=$(mktemp -d)
TARGET_DIR="${1:-.}"

echo "Claude Workspace Installer"
echo "========================="
echo ""

# Validate target
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Check for existing config
if [ -d "$TARGET_DIR/.claude" ]; then
  echo "Warning: .claude/ already exists in $TARGET_DIR"
  read -p "Overwrite? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

echo "Cloning workspace config..."
git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR"

echo "Copying files..."
cp -r "$TMP_DIR/.claude" "$TARGET_DIR/"
cp "$TMP_DIR/CLAUDE.md" "$TARGET_DIR/"
cp "$TMP_DIR/.mcp.json" "$TARGET_DIR/"

# Make hook scripts executable
find "$TARGET_DIR/.claude/hooks" -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true

# Don't overwrite existing .gitignore, just append Claude-specific entries
if [ -f "$TARGET_DIR/.gitignore" ]; then
  if ! grep -q '.claude/settings.local.json' "$TARGET_DIR/.gitignore" 2>/dev/null; then
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Claude Code local settings" >> "$TARGET_DIR/.gitignore"
    echo ".claude/settings.local.json" >> "$TARGET_DIR/.gitignore"
    echo ".claude/agent-memory/" >> "$TARGET_DIR/.gitignore"
    echo ".claude/todos.json" >> "$TARGET_DIR/.gitignore"
    echo ".claude/screenshots/" >> "$TARGET_DIR/.gitignore"
  fi
fi

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "Done! Installed to $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md to match your project stack"
echo "  2. Run 'claude' to start coding"
echo ""
echo "Files installed:"
echo "  .claude/settings.json       — Permissions, hooks, env"
echo "  .claude/agents/             — 8 specialized agents"
echo "  .claude/commands/           — 9 slash commands"
echo "  .claude/rules/              — 4 path-scoped rules"
echo "  .claude/skills/             — 10 domain skills"
echo "  .claude/hooks/scripts/      — Hook scripts"
echo "  CLAUDE.md                   — Project memory"
echo "  .mcp.json                   — MCP server config"
