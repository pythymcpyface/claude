# Claude Global Configuration

Shared configuration for Claude Code, OpenCode, and Bob. Acts as the single source of truth for AI assistant behaviour, MCP server setup, skills, and automation scripts. Transfer between machines or team members by cloning this repo and running one setup script.

## New Machine Setup

```bash
git clone <this-repo> ~/.claude
cp ~/.claude/mcp/secrets.env.example ~/.claude/mcp/secrets.env
# Edit secrets.env and fill in real values (see comments inside)
bash ~/.claude/mcp/mcp-ensure.sh
```

That's it. The script configures all MCP servers for OpenCode, Claude Code, and Bob, and ensures the Memgraph container is running with the correct restart policy.

## MCP Servers

Four servers run across all three clients. Config is managed centrally in `mcp/`.

| Server | Purpose | Requires |
|--------|---------|---------|
| `memory` | Cross-session knowledge graph | — |
| `cgr-local` | Code structure queries via Memgraph (code-graph-rag) | Memgraph container |
| `kdb-local` | Local vector RAG over ingested documents | — |
| `kdb-remote` | Remote KDB vector store (IBM Cloud Redis + watsonx) | IBM Cloud credentials |

### Infrastructure

`cgr-local` requires a Memgraph container. `mcp-ensure.sh` creates it if missing and sets `restart=unless-stopped` so it survives reboots.

Manual start if needed:
```bash
docker run -d --name memgraph-codegraph --restart=unless-stopped -p 7689:7687 memgraph/memgraph
```

### Files

```
~/.claude/mcp/
├── mcp-ensure.sh        # Run this to apply config to all clients (idempotent)
├── servers.json         # Human-readable server definitions (no secrets)
├── secrets.env.example  # Template — commit this, not secrets.env
└── secrets.env          # Live secrets — gitignored, never commit
```

### Rotating credentials

Edit `~/.claude/mcp/secrets.env`, then re-run:
```bash
bash ~/.claude/mcp/mcp-ensure.sh
```

## Structure

```
~/.claude/
├── CLAUDE.md               # Main constitution — core rules & identity
├── opencode.json           # OpenCode config (MCP, providers, permissions)
├── settings.json           # Claude Code hooks
├── mcp/                    # MCP server definitions and setup (see above)
├── agents/                 # Sub-agent definitions
├── commands/               # Custom slash commands (/quality-check, etc.)
├── rules/                  # Path-scoped instruction files
├── scripts/                # Automation scripts
│   ├── session-init.sh     # Session start: stack detection, CLAUDE.md generation
│   ├── generate-project-claude.sh
│   └── detect-project.sh
├── skills/                 # Lazy-loaded specialised knowledge
└── templates/traits/       # Building blocks for project CLAUDE.md
```

## How It Works

### Session Initialisation

`session-init.sh` runs on session start (via `settings.json` hooks):
1. Detects stack from `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`
2. Generates `.claude/CLAUDE.md` for the project if missing
3. Copies autonomous development flow docs for new projects

### MCP Tool Priority

See `rules/mcp-tools.md` for the full decision tree. Short version:
- Code relationships → `cgr-local` first, then grep/glob
- Cross-session context → `memory` first
- Document search → `kdb-local` / `kdb-remote` first

### Dynamic Skill Loading

Skills in `skills/` are loaded on keyword detection or explicit request:
- "add postgres" / "database" → database skill
- "deploy to railway" → Railway deploy skill
- "production readiness" → production readiness review

## Commands

| Command | Purpose |
|---------|---------|
| `/quality-check` | Lint, type-check, test coverage gate |
| `/git-process` | Commit and PR workflow |
| `/production-readiness-review` | Full pre-deploy checklist |

## Extending

- **Add a skill**: create `skills/{name}/SKILL.md`
- **Add a command**: create `commands/{name}.md`
- **Add an MCP server**: add to `mcp/servers.json`, update `mcp/mcp-ensure.sh`, re-run it