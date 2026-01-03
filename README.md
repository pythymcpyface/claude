# **Claude Code Global Configuration 🧠**

A highly optimized, token-efficient global configuration for [Claude Code](https://github.com/anthropics/claude-code). This setup transforms Claude into a senior engineer that automatically adapts to your project's tech stack, delegates expensive tasks to cheaper models, and lazy-loads specialized skills only when needed.

## **🚀 Key Features**

* **Lazy Loading Skills**: Specialized knowledge (Database, E2E Testing, Algorithms) is only loaded into context when relevant keywords are detected in your project.  
* **Cost-Efficient Delegation**: Automatically intercepts expensive operations (running tests, reading large logs) and delegates them to Haiku or Gemini via MCP.  
* **Auto-Bootstrapping**: When you enter a directory, it detects the stack (Rust, Node, Python) and generates a project-specific CLAUDE.md constitution.  
* **Safety Rails**: Pre-configured hooks prevent forbidden directory access (node\_modules) and accidental secrets exposure.

## **📂 Structure**

\~/.claude/  
├── CLAUDE.md               \# The "Constitution" \- core rules & identity  
├── settings.json           \# Hooks connecting events to scripts  
├── agents/                 \# Sub-agent definitions (e.g., Haiku Executor)  
├── commands/               \# Custom slash commands (/quality-check)  
├── scripts/                \# Automation logic  
│   ├── detect-project.sh   \# Scans files to recommend skills  
│   ├── delegate-check.sh   \# Intercepts expensive commands  
│   └── generate-\*.sh       \# Creates per-project context  
└── skills/                 \# The Knowledge Base  
    ├── core/               \# Always-on skills (Security, Testing)  
    └── extended/           \# Lazy-loaded skills (DB, E2E, Algo)

## **🛠️ Installation**

1. **Backup existing config:**  
   mv \~/.claude \~/.claude.bak

2. Copy files:  
   Copy the contents of this repository to \~/.claude.  
3. Verify Permissions:  
   Ensure scripts are executable:  
   chmod \+x \~/.claude/scripts/\*.sh

4. Install MCP Tools (Optional but Recommended):  
   For delegation to work optimally, ensure you have the ultra-mcp or equivalent tools installed and configured in your MCP settings.

## **💡 How It Works**

### **1\. The "SessionStart" Hook**

When you start a session, settings.json triggers:

1. **generate-project-claude.sh**: Checks if a .claude/CLAUDE.md exists in the current folder. If not, it scans your package.json/Cargo.toml and generates one customized for your stack.  
2. **detect-project.sh**: Scans for specific libraries (e.g., prisma, playwright). If found, it injects a **Recommendation** into the chat context, prompting Claude to read the specific Extended Skill file.

### **2\. The Delegation Interceptor**

When Claude tries to run a command like npm test or git log:

1. The **PreToolUse** hook runs delegate-check.sh.  
2. If the command is flagged as "expensive" (high token output), the script interrupts and suggests delegating the task to a specialized MCP tool (like Gemini) or a sub-agent.

### **3\. Sub-Agents (Haiku)**

For repetitive tasks, you can invoke the Haiku Executor to save \~90% on costs:

"Use the haiku agent to refactor these 5 files."

The agents/haiku-executor.md definition ensures it uses the cheaper model with a stripped-down context window.

## **⚡ Usage Tips**

* **Compact often:** The system is designed for small contexts. Use /compact if you feel the session slowing down.  
* **Trigger Skills Manually:** If the auto-detection misses something, you can load skills manually:"Read skills/extended/database-integrity.md"  
* **Check Token Usage:** Look at your session logs to see how much the Delegation Strategy is saving you on npm test runs.

## **🧱 Extending**

* **Add a new Skill:** Create a markdown file in skills/extended/. Add a detection rule in scripts/detect-project.sh.  
* **Add a new Command:** Create a file in commands/ with description and allowed-tools frontmatter.

*Built for the [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) ecosystem.*