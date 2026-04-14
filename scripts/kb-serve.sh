#!/bin/bash
# Launcher for graphify MCP server, serving this KB's graph.
# Usage: invoked by .mcp.json. Override graph path with KB_GRAPH_PATH env var.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GRAPH_PATH="${KB_GRAPH_PATH:-${CLAUDE_PROJECT_DIR:-$REPO_ROOT}/graphify-out/graph.json}"

PYTHON=""
for candidate in python3 python; do
  if command -v "$candidate" &>/dev/null; then
    if "$candidate" -c "import graphify.serve" 2>/dev/null; then
      PYTHON="$candidate"
      break
    fi
  fi
done

if [[ -z "$PYTHON" ]] && command -v graphify &>/dev/null; then
  PIPX_PYTHON=$(head -1 "$(command -v graphify)" | sed 's|^#!||')
  if [[ -x "$PIPX_PYTHON" ]] && "$PIPX_PYTHON" -c "import graphify.serve" 2>/dev/null; then
    PYTHON="$PIPX_PYTHON"
  fi
fi

if [[ -z "$PYTHON" ]]; then
  echo "ERROR: No Python with 'graphify.serve' importable." >&2
  echo "       Tried: python3, python, pipx venv via 'graphify' CLI." >&2
  echo "       The 'mcp' module may be missing — run: pipx inject graphifyy mcp" >&2
  echo "       See CLAUDE.md Setup section." >&2
  exit 1
fi

if [[ ! -f "$GRAPH_PATH" ]]; then
  echo "ERROR: Graph file not found: $GRAPH_PATH" >&2
  echo "       Run /graphify to build the knowledge graph first." >&2
  exit 1
fi

exec "$PYTHON" -m graphify.serve "$GRAPH_PATH"
