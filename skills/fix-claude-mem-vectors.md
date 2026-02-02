# Fix Claude-Mem Vector Search

## Problem
Claude-mem vector search returns error:
```
Vector search failed - semantic search unavailable.
To enable semantic search:
1. Install uv
2. Restart the worker
```

## Root Cause
Claude-mem uses ChromaDB via the `chroma-mcp` Python package for vector embeddings. The worker spawns this as a subprocess using `uvx` (from `uv`). Three things must be configured:

1. **uv must be installed** (provides `uvx` command)
2. **CLAUDE_MEM_PYTHON_VERSION** must be set in settings
3. **chroma-mcp must be downloaded** (happens on first run via uvx)

## Quick Fix

### Step 1: Verify uv is installed
```bash
which uv && uv --version
```

If not installed:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Step 2: Create/update settings file
```bash
cat > ~/.claude-mem/settings.json << 'EOF'
{
  "CLAUDE_MEM_PYTHON_VERSION": "3.11",
  "CLAUDE_MEM_WORKER_PORT": 37777
}
EOF
```

### Step 3: Pre-install chroma-mcp (optional but speeds up first run)
```bash
uvx --python 3.11 chroma-mcp --help
```

### Step 4: Restart the worker
```bash
cd ~/.claude/plugins/marketplaces/thedotmack/
npm run worker:stop
npm run worker:start
```

### Step 5: Verify
```bash
# Check health
curl -s http://127.0.0.1:37777/health
# Expected: {"status":"ok",...}

# Check logs for Chroma connection
cat ~/.claude-mem/logs/worker-$(date +%Y-%m-%d).log | grep -i chroma
```

## One-Liner Fix
```bash
echo '{"CLAUDE_MEM_PYTHON_VERSION":"3.11","CLAUDE_MEM_WORKER_PORT":37777}' > ~/.claude-mem/settings.json && \
uvx --python 3.11 chroma-mcp --help 2>/dev/null && \
cd ~/.claude/plugins/marketplaces/thedotmack/ && \
npm run worker:stop && sleep 2 && npm run worker:start && \
sleep 5 && curl -s http://127.0.0.1:37777/health
```

## How It Works

The claude-mem worker (`worker-service.cjs`) contains a `ChromaSync` class that:

1. Spawns chroma-mcp via: `uvx --python <version> chroma-mcp --client-type persistent --data-dir ~/.claude-mem/vector-db`
2. Uses MCP (Model Context Protocol) to communicate with the Chroma subprocess
3. Syncs observations, summaries, and prompts to ChromaDB for vector search
4. Falls back gracefully if Chroma connection fails (SQLite search still works)

## Settings Reference

| Setting | Default | Description |
|---------|---------|-------------|
| CLAUDE_MEM_PYTHON_VERSION | none (required) | Python version for uvx |
| CLAUDE_MEM_WORKER_PORT | 37777 | HTTP port for worker |
| CLAUDE_MEM_MODEL | claude-sonnet-4-5 | LLM model for summaries |
| CLAUDE_MEM_CONTEXT_OBSERVATIONS | 50 | Max observations in context |

## Troubleshooting

### Worker starts but vector search still fails
Check logs for Chroma errors:
```bash
grep -i "error\|failed\|chroma" ~/.claude-mem/logs/worker-$(date +%Y-%m-%d).log
```

### Orphaned chroma-mcp processes
The worker cleans these up on restart, but you can manually kill them:
```bash
pkill -f chroma-mcp
```

### Port conflict
Check what's using the port:
```bash
lsof -i :37777
```

### Full diagnostic
```bash
cd ~/.claude/plugins/marketplaces/thedotmack/
npm run bug-report
```

## File Locations

| Item | Path |
|------|------|
| Settings | ~/.claude-mem/settings.json |
| Database | ~/.claude-mem/claude-mem.db |
| Vector DB | ~/.claude-mem/vector-db/ |
| Worker PID | ~/.claude-mem/worker.pid |
| Logs | ~/.claude-mem/logs/ |
| Plugin | ~/.claude/plugins/marketplaces/thedotmack/ |
