# Claude Code Global Configuration

A highly optimized, token-efficient global configuration for Claude Code. This setup transforms Claude into a senior engineer that automatically adapts to your project's tech stack and lazy-loads specialized skills only when needed.

## Key Features

- **Auto-Bootstrapping**: When entering a directory, detects the stack (Rust, Node, Python) and generates a project-specific CLAUDE.md
- **Lazy Loading Skills**: Specialized knowledge (Database, E2E Testing, Railway) is loaded only when relevant keywords are detected
- **MCP Tool Priority**: Uses knowledge graph and memory MCP tools before falling back to grep/read
- **Safety Rails**: Pre-configured hooks prevent forbidden directory access

## Structure

```
~/.claude/
├── CLAUDE.md               # Main constitution - core rules & identity
├── settings.json           # Hooks connecting events to scripts
├── agents/                 # Sub-agent definitions
├── commands/               # Custom slash commands (/quality-check, etc.)
├── scripts/                # Automation logic
│   ├── session-init.sh     # Session initialization (stack detection, CLAUDE.md generation)
│   ├── generate-project-claude.sh  # Creates project-specific CLAUDE.md
│   └── detect-project.sh  # Scans for libraries to recommend skills
├── skills/                 # Lazy-loaded specialized knowledge
│   ├── core/               # Core engineering patterns
│   ├── extended/          # Lazy-loaded (database, algorithms, error handling)
│   └── railway-*/         # Railway platform skills (deploy, database, etc.)
└── templates/traits/       # Building blocks for project CLAUDE.md
```

## How It Works

### Session Initialization

When you start a session, `session-init.sh` triggers:
1. **Stack Detection**: Scans for package.json, Cargo.toml, go.mod, pyproject.toml
2. **Project CLAUDE.md Generation**: Creates `.claude/CLAUDE.md` if missing, built from templates
3. **Autonomous Development Flow**: Copies docs for new projects

### MCP Tools

| Tool | Purpose |
|------|---------|
| `code-graph-rag` | Code relationships, function calls, dependency analysis |
| `memory` | Cross-session state, decisions, milestones |
| `knowledge` | Document search, ingested documentation |

### Dynamic Context Loading

Skills load on keyword detection:
- "add postgres" or "database" → Railway database skill
- "deploy to railway" → Railway deploy skill
- "production" or "readiness" → Production readiness review

## Usage Tips

- **Edit project CLAUDE.md**: Each project gets its own `.claude/CLAUDE.md` - edit to add project patterns
- **Trigger skills manually**: "Read `.claude/skills/railway-database/SKILL.md`"
- **Use commands**: `/quality-check`, `/git-process`, `/production-readiness-review`

## Extending

- **Add a skill**: Create `.claude/skills/extended/{skill-name}/SKILL.md`
- **Add a command**: Create `.claude/commands/{command-name}.md`