#!/bin/bash
# UI Screenshot Hook
# Captures a screenshot of the running app after UI file edits.
# Wire into PostToolUse with matcher: components/.*\.tsx
#
# Usage: Add to settings.json PostToolUse array:
# {
#   "matcher": "Edit|Write",
#   "hooks": [{
#     "type": "command",
#     "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" =~ (components|pages|app)/.*\\.(tsx|jsx|css)$ ]]; then bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/scripts/screenshot.sh\"; fi",
#     "timeout": 10
#   }]
# }

SCREENSHOT_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/screenshots"
mkdir -p "$SCREENSHOT_DIR"

# macOS screenshot (silent, no shadow)
if command -v screencapture &> /dev/null; then
  screencapture -x -T 1 "$SCREENSHOT_DIR/ui-$(date +%s).png"
  echo '{"feedback": "Screenshot captured. Ask Claude to review the latest screenshot.", "suppressOutput": true}'
# Linux (requires scrot or gnome-screenshot)
elif command -v scrot &> /dev/null; then
  scrot -d 1 "$SCREENSHOT_DIR/ui-$(date +%s).png"
  echo '{"feedback": "Screenshot captured.", "suppressOutput": true}'
else
  echo '{"feedback": "Screenshot tool not found. Install screencapture (macOS) or scrot (Linux)."}' >&2
fi
