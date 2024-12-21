---
marp: true
theme: default
paginate: true
title: The Aider Saga
description: A guide to wielding the Force of AI in your development journey
style: |
  section {
    background: #000000 url('https://raw.githubusercontent.com/yourusername/repo/main/stars-bg.png');
    color: #FFE81F;
    font-size: 1.3em;
    font-family: "Star Jedi", "Source Code Pro", monospace;
    line-height: 1.5;
  }
  h1, h2 {
    color: #FFE81F;
    font-weight: 700;
    letter-spacing: -0.01em;
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
  code {
    background: #1a1a1a;  /* Darker background */
    color: #00ff00;       /* Bright green text like old terminals */
    border: 1px solid #FFE81F; /* Star Wars yellow border */
    border-radius: 4px;
    padding: 3px 6px;
    font-family: "Source Code Pro", "Fira Code", monospace;
    font-size: 1.1em;     /* Slightly larger */
  }

  pre {
    background: #1a1a1a;
    padding: 15px;
    border: 2px solid #FFE81F;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(255,232,31,0.3);
  }
  section.lead {
    background: linear-gradient(135deg, #383838, #2f2f2f);
  }

---

<!-- _class: lead -->
# Aider in Practice
## Real-world Developer Workflows with AI

---

<!-- _class: default -->
## What Makes Aider Different?

- 🤝 Natural language code editing
- 🌳 Deep code understanding via RepoMap & CST
- 🔄 Git integration & version control
- 🧠 Context-aware assistance
- 🛠️ Works with any editor

---

<!-- _class: default -->
## Core Concepts

1. **RepoMap & Code Understanding**
   - Builds semantic map of codebase
   - Uses Concrete Syntax Tree (CST)
   - Enables precise code navigation
   - Better context for LLM prompts

2. **Git Integration**
   - Automatic commits
   - Change tracking
   - Safe experimentation

---

<!-- _class: default -->
## Real Developer Workflows

### Code Understanding
```bash
/architect explain this module
/how does this function work?
```

### Documentation
```bash
/architect generate sequence diagram
/document this class
```

### Testing
```bash
/add tests/
/write unit tests for this function
```

---

<!-- _class: default -->
## Demo: Code Understanding

1. Add relevant files:
```bash
/add src/main.py
```

2. Ask for architecture overview:
```bash
/architect show class diagram
```

3. Deep dive into specific components:
```bash
/ask explain the authentication flow
```

---

<!-- _class: default -->
## Demo: Documentation Generation

1. Generate diagrams:
```bash
/architect sequence diagram for login flow
```

2. Update docs:
```bash
/update README with new features
```

3. Create presentations:
```bash
/create marp slides for this module
```

---

<!-- _class: default -->
## IDE Integration

Use AI comments in any editor:
```python
# Add input validation here AI!
def process_data(input):
    pass

# How does this function handle errors? AI?
```

No plugins needed - works with:
- VS Code
- PyCharm
- Vim
- Any text editor!

---

<!-- _class: default -->
## Practical Applications

1. **Codebase Exploration**
   - Quick understanding of new projects
   - Architecture visualization
   - Finding relevant code sections

2. **Documentation**
   - Auto-generate diagrams
   - Keep docs in sync with code
   - Create presentations

3. **Testing**
   - Generate unit tests
   - Match existing test style
   - Cover edge cases

---

<!-- _class: default -->
## Best Practices

1. **File Management**
   - Add only relevant files
   - Use `/drop` to maintain focus
   - Leverage read-only mode

2. **Effective Prompts**
   - Be specific in requests
   - Use appropriate commands
   - Break down complex tasks

3. **Integration Patterns**
   - Git commit workflow
   - Documentation automation
   - Test generation pipeline

---

<!-- _class: default -->
## Common Pitfalls

❌ Adding too many files
✅ Focus on relevant modules

❌ Vague requests
✅ Specific, actionable prompts

❌ Trusting blindly
✅ Review and verify changes

❌ Ignoring context
✅ Provide necessary background

---

<!-- _class: lead -->
## The Human Role

- Focus on high-level design
- Review and verify AI suggestions
- Make architectural decisions
- Guide the development process
- Share knowledge effectively

---

<!-- _class: default -->
## Resources

- [Aider Documentation](https://aider.chat)
- [Installation Guide](https://aider.chat/docs/install.html)
- [Command Reference](https://aider.chat/docs/usage/commands.html)
- [Best Practices](https://aider.chat/docs/usage/tips.html)

Questions? Let's try some live demos! 🚀
