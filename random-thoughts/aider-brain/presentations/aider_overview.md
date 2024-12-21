---
marp: true
theme: default
paginate: true
title: Aider Overview
description: A comprehensive guide to Aider and its features
style: |
  section {
    background: #2b2b2b;
    color: #ffffff;
    font-size: 1.3em;
    font-family: "Source Code Pro", "Fira Code", monospace;
    line-height: 1.6;
    text-shadow: 0 1px 1px rgba(0,0,0,0.2);
  }
  h1, h2 {
    color: #ffcfaf;
    font-weight: 700;
    letter-spacing: -0.01em;
    text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
  }
  h1 {
    font-size: 2.4em;
  }
  h2 {
    font-size: 2em;
  }
  a {
    color: #8faf9f;
    text-decoration: none;
    font-weight: bold;
  }
  a:hover {
    color: #a0cfaf;
    text-decoration: underline;
  }
  table {
    color: #ffffff;
    font-size: 1.1em;
    border-collapse: collapse;
    width: 100%;
  }
  th {
    background: #1a1a1a;
    color: #ffffff;
    padding: 12px;
    font-weight: bold;
  }
  td {
    background: #333333;
    border: 2px solid #4a4a4a;
    padding: 12px;
  }
  code {
    background: #1a1a1a;
    color: #ffffff;
    border: 1px solid #4a4a4a;
    border-radius: 4px;
    padding: 4px 8px;
    font-family: "Source Code Pro", "Fira Code", monospace;
    font-size: 0.95em;
    text-shadow: none;
    box-shadow: 0 1px 2px rgba(0,0,0,0.2);
  }
  section.lead {
    background: linear-gradient(135deg, #383838, #2f2f2f);
    color: #f0f0f0;
  }
  section.lead h1, section.lead h2 {
    color: #ffcfaf;
  }
  section.default {
    background: #404040;
  }
---

<!-- _class: lead -->
# Aider: Your AI Pair Programming Assistant

<!-- _class: lead -->
## What is Aider?
- An AI-powered coding assistant that integrates with your development workflow
- Uses GPT models to help write, edit, and understand code
- Seamlessly integrates with Git for version control
- Provides natural language interface for code modifications

---
<!-- _class: default -->
## Key Features

1. **Natural Language Code Editing**
   - Edit code using conversational commands
   - Supports multiple programming languages
   - Intelligent context understanding

2. **Git Integration**
   - Automatic commit management
   - Version control awareness
   - Safe code modifications

3. **Context-Aware**
   - Understands project structure
   - Maintains chat history
   - Remembers file contents

---

<!-- _class: lead -->
## Command Categories Overview

Aider provides various command categories for different operations:
- File Management
- Chat Control
- Code Operations
- Integration & Execution
- System & Settings

---

<!-- _class: default -->
## File Management Commands
Commands for managing files in your session:

| Command | Purpose |
|---------|----------|
| `/add` | Add files to edit |
| `/drop` | Remove files from session |
| `/ls` | List known files |
| `/read-only` | Add reference-only files |

---

<!-- _class: default -->
## Chat Control Commands

Commands for managing the chat interface:

| Command | Purpose |
|---------|----------|
| `/clear` | Clear chat history |
| `/chat-mode` | Switch chat mode |
| `/copy` | Copy assistant message |
| `/voice` | Voice input |

---

<!-- _class: default -->
## Code Operations

Commands for code manipulation:

| Command | Purpose |
|---------|----------|
| `/code` | Request code changes |
| `/architect` | Discuss design |
| `/ask` | Ask code questions |
| `/lint` | Fix code style |

---

<!-- _class: default -->
## Integration & Execution

Commands for running code and version control:

| Command | Purpose |
|---------|----------|
| `/run` | Execute code |
| `/git` | Run git commands |
| `/undo` | Undo changes |
| `/commit` | Commit changes |

---

<!-- _class: default -->
## System & Settings

Commands for configuration:

| Command | Purpose |
|---------|----------|
| `/model` | Switch LLM model |
| `/settings` | View settings |
| `/tokens` | Check token usage |
| `/map` | View repo structure |

---
<!-- _class: default -->
## Best Practices

1. **Start Small**
   - Add only relevant files
   - Make focused changes
   - Review diffs frequently

2. **Use Version Control**
   - Regular commits
   - Review changes with `/diff`
   - Use `/undo` when needed

3. **Optimize Context**
   - Drop unused files
   - Clear chat when needed
   - Monitor token usage

---

<!-- _class: default -->
## Tips & Tricks

- Use up arrow ⬆️ to access command history
- CTRL+R for history search
- CTRL+C to safely interrupt
- Combine commands for efficient workflows
- Use `/help` when stuck

---

<!-- _class: lead -->
## Getting Help

- `/help` - General assistance
- `/report` - Report issues
- Documentation at [aider.chat](https://aider.chat)
- GitHub repository for updates and issues
