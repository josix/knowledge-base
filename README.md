# knowledge-base
Cogito, ergo sum

## Overview
This repository serves as my personal digital garden — a collection of interconnected notes, learnings, and insights gathered throughout my professional journey. It follows a Zettelkasten-style note-taking approach, where knowledge is organized in an organic, networked structure rather than a rigid hierarchy.

The vault is also indexed as a [graphify](https://github.com/) knowledge graph and exposed to Claude Code as an MCP server, so the notes can be queried by any Claude Code session (in this repo or others) with source-cited retrieval.

Topics covered:
- Software Engineering
- Data Science
- Management & Leadership
- Productivity
- Health & Wellness
- Design
- And more...

## Structure
- `/Permanent/` — long-form, well-developed notes
- `/software-engineer/` — technical notes on software development
- `/data-science/` — data science, machine learning, and analytics
- `/management/` — leadership and management insights
- `/productivity/` — personal effectiveness techniques
- `/health/` — health and wellness
- `/design/` — design principles and practices
- `/random-thoughts/` — daily thoughts and quick captures
- `/Readwise/` — imported highlights and articles from Readwise
- `/meetup/`, `/LaTex/`, `/content/`, `/assets/` — supporting material
- `/graphify-out/` — generated knowledge graph (`graph.json`), rebuilt by `/graphify`

## Claude Code + MCP setup

### One-time
The graphify pipx venv needs the `mcp` module:

```bash
pipx inject graphifyy mcp
```

Then (re)build the graph:

```bash
/graphify .
```

### Usage in this repo
Starting Claude Code from this directory auto-loads `.mcp.json`, giving any agent in the session access to the `graphify` MCP server (`query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`, `graph_stats`, `shortest_path`).

- `/kb <question>` — retrieves relevant notes with citations via the `kb-retriever` subagent.
- `/graphify` — rebuilds the graph; `/graphify --update` re-extracts only changed files.
- Editing a `.md` file marks the graph stale (`graphify-out/.needs_update`) and prints a one-line hint.

### Using this KB from another project
Add a `graphify` MCP entry to that project's `.mcp.json`:

```json
{
  "mcpServers": {
    "kb": {
      "type": "stdio",
      "command": "/path/to/knowledge-base/scripts/kb-serve.sh",
      "env": {
        "KB_GRAPH_PATH": "/path/to/knowledge-base/graphify-out/graph.json"
      }
    }
  }
}
```

`KB_GRAPH_PATH` makes the launcher serve this KB's graph regardless of where the caller session started. In agent-flow orchestrations, Riko / Senku / Lawliet already have `mcp__graphify__*` in their allowed tools and will pick it up automatically.

### Key files
- `.mcp.json` — declares the graphify MCP server for this repo
- `scripts/kb-serve.sh` — portable launcher (honors `KB_GRAPH_PATH`)
- `.claude/commands/kb.md` — `/kb` slash command
- `.claude/agents/kb-retriever.md` — retrieval subagent with citation formatting
- `.claude/hooks/hooks.json` + `mark-graph-stale.sh` — post-edit stale marker
- `graphify-out/graph.json` — the knowledge graph

## How to browse manually
- Notes are plain Markdown — open any folder that matches your interest.
- Links between notes form a network; follow them to explore related ideas.
- `Recent Notes.md` is a running index of the latest entries.
