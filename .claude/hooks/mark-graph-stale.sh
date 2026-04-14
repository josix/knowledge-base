#!/bin/bash
# PostToolUse hook: when a Markdown file in the KB is written or edited,
# mark the graphify graph as stale so the user knows to re-run /graphify.
# Reads tool input JSON from stdin (Claude Code hook protocol).
set -euo pipefail

input="$(cat)"

file_path="$(printf '%s' "$input" | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || true)"

case "$file_path" in
  *.md|*.markdown)
    repo_root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
    mkdir -p "$repo_root/graphify-out"
    touch "$repo_root/graphify-out/.needs_update"
    echo "[kb] graph stale — run /graphify --update to refresh" >&2
    ;;
esac

exit 0
