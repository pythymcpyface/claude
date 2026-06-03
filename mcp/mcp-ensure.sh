#!/usr/bin/env bash
# ~/.claude/mcp/mcp-ensure.sh
#
# Idempotent setup: configures all MCP servers for opencode, Claude Code, and Bob.
# Run once after a fresh clone or new machine setup:
#
#   bash ~/.claude/mcp/mcp-ensure.sh
#
# Safe to re-run — overwrites only the MCP server blocks, leaves everything else intact.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS="$SCRIPT_DIR/secrets.env"

# ── 1. Load secrets ──────────────────────────────────────────────────────────
if [[ ! -f "$SECRETS" ]]; then
  echo "ERROR: $SECRETS not found."
  echo "Copy $SCRIPT_DIR/secrets.env.example to $SCRIPT_DIR/secrets.env and fill in values."
  exit 1
fi
# shellcheck disable=SC1090
set -a; source "$SECRETS"; set +a

# Validate required secrets
for var in ICA_API_KEY ICA_ENDPOINT; do
  if [[ -z "${!var:-}" || "${!var}" == "<"* ]]; then
    echo "ERROR: $var is not set in secrets.env"
    exit 1
  fi
done

# ── 2. Resolve stable binary paths ───────────────────────────────────────────
CGR_BIN="$HOME/.local/share/uv/tools/code-graph-rag/bin/cgr"
MCP_MEMORY_BIN="$HOME/.local/share/fnm/node-versions/v24.14.0/installation/bin/mcp-server-memory"
MCP_LOCAL_RAG_BIN="$HOME/.local/share/fnm/node-versions/v24.14.0/installation/bin/mcp-local-rag"
KDB_REMOTE_DIR="$HOME/.local/share/kdb-remote"

for bin in "$CGR_BIN" "$MCP_MEMORY_BIN" "$MCP_LOCAL_RAG_BIN"; do
  if [[ ! -x "$bin" ]]; then
    echo "WARNING: binary not found or not executable: $bin"
  fi
done
if [[ ! -f "$KDB_REMOTE_DIR/start-mcp-server.sh" ]]; then
  echo "WARNING: kdb-remote start script not found at $KDB_REMOTE_DIR/start-mcp-server.sh"
fi

# ── 3. Apply to opencode (~/.claude/opencode.json) ───────────────────────────
OPENCODE_CONFIG="$HOME/.claude/opencode.json"
echo "→ Patching opencode: $OPENCODE_CONFIG"

python3 - "$OPENCODE_CONFIG" "$CGR_BIN" "$MCP_MEMORY_BIN" "$MCP_LOCAL_RAG_BIN" "$KDB_REMOTE_DIR" \
  "$ICA_API_KEY" "$ICA_ENDPOINT" \
  "${WATSONX_API_KEY:-}" "${WATSONX_PROJECT_ID:-}" "${WATSONX_URL:-}" \
  "${REDIS_HOST:-}" "${REDIS_PORT:-}" "${REDIS_PASSWORD:-}" "${REDIS_USERNAME:-}" \
  "${REDIS_TLS:-}" "${KDB_NODE_ENV:-production}" \
  <<'PYEOF'
import json, sys
cfg_path, cgr_bin, mem_bin, rag_bin, kdb_dir = sys.argv[1:6]
ica_key, ica_ep = sys.argv[6:8]
wx_key, wx_proj, wx_url = sys.argv[8:11]
redis_host, redis_port, redis_pw, redis_user, redis_tls, kdb_env = sys.argv[11:17]

with open(cfg_path) as f:
    cfg = json.load(f)

cfg["mcp"] = {
    "memory": {
        "type": "local",
        "command": [mem_bin],
        "env": {"MEMORY_FILE_PATH": f"{__import__('os').environ['HOME']}/.local/share/mcp-memory/memory.jsonl"},
        "enabled": True,
        "timeout": 3600000
    },
    "cgr-local": {
        "type": "local",
        "command": [cgr_bin, "mcp-server"],
        "env": {
            "MEMGRAPH_HOST": "localhost",
            "MEMGRAPH_PORT": "7689",
            "ORCHESTRATOR_PROVIDER": "openai",
            "ORCHESTRATOR_MODEL": "claude-sonnet-4-6",
            "ORCHESTRATOR_ENDPOINT": ica_ep,
            "ORCHESTRATOR_API_KEY": ica_key,
            "CYPHER_PROVIDER": "openai",
            "CYPHER_MODEL": "claude-sonnet-4-6",
            "CYPHER_ENDPOINT": ica_ep,
            "CYPHER_API_KEY": ica_key
        },
        "enabled": True,
        "timeout": 600000
    },
    "kdb-local": {
        "type": "local",
        "command": [rag_bin],
        "env": {
            "DB_PATH": f"{__import__('os').environ['HOME']}/.local/share/mcp-knowledge",
            "MODEL_NAME": "Xenova/all-MiniLM-L6-v2",
            "CACHE_DIR": f"{__import__('os').environ['HOME']}/.cache/huggingface",
            "HF_HUB_OFFLINE": "0"
        },
        "enabled": True,
        "timeout": 3600000
    },
    "kdb-remote": {
        "type": "local",
        "command": [f"{kdb_dir}/start-mcp-server.sh"],
        "env": {"NODE_ENV": kdb_env or "production"},
        "enabled": True,
        "timeout": 3600000
    }
}

with open(cfg_path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  done")
PYEOF

# ── 4. Apply to Claude Code (~/.claude.json mcpServers) ──────────────────────
CLAUDE_CONFIG="$HOME/.claude.json"
echo "→ Patching Claude Code: $CLAUDE_CONFIG"

python3 - "$CLAUDE_CONFIG" "$CGR_BIN" "$MCP_MEMORY_BIN" "$MCP_LOCAL_RAG_BIN" "$KDB_REMOTE_DIR" \
  "$ICA_API_KEY" "$ICA_ENDPOINT" \
  "${WATSONX_API_KEY:-}" "${WATSONX_PROJECT_ID:-}" "${WATSONX_URL:-}" \
  "${REDIS_HOST:-}" "${REDIS_PORT:-}" "${REDIS_PASSWORD:-}" "${REDIS_USERNAME:-}" \
  "${REDIS_TLS:-}" "${KDB_NODE_ENV:-production}" \
  <<'PYEOF'
import json, sys, os
cfg_path, cgr_bin, mem_bin, rag_bin, kdb_dir = sys.argv[1:6]
ica_key, ica_ep = sys.argv[6:8]
wx_key, wx_proj, wx_url = sys.argv[8:11]
redis_host, redis_port, redis_pw, redis_user, redis_tls, kdb_env = sys.argv[11:17]
home = os.environ["HOME"]

with open(cfg_path) as f:
    cfg = json.load(f)

cfg["mcpServers"] = {
    "memory": {
        "command": mem_bin,
        "args": [],
        "env": {"MEMORY_FILE_PATH": f"{home}/.local/share/mcp-memory/memory.jsonl"}
    },
    "cgr-local": {
        "command": cgr_bin,
        "args": ["mcp-server"],
        "env": {
            "MEMGRAPH_HOST": "localhost",
            "MEMGRAPH_PORT": "7689",
            "ORCHESTRATOR_PROVIDER": "openai",
            "ORCHESTRATOR_MODEL": "claude-sonnet-4-6",
            "ORCHESTRATOR_ENDPOINT": ica_ep,
            "ORCHESTRATOR_API_KEY": ica_key,
            "CYPHER_PROVIDER": "openai",
            "CYPHER_MODEL": "claude-sonnet-4-6",
            "CYPHER_ENDPOINT": ica_ep,
            "CYPHER_API_KEY": ica_key
        }
    },
    "kdb-local": {
        "command": rag_bin,
        "args": [],
        "env": {
            "DB_PATH": f"{home}/.local/share/mcp-knowledge",
            "MODEL_NAME": "Xenova/all-MiniLM-L6-v2",
            "CACHE_DIR": f"{home}/.cache/huggingface",
            "HF_HUB_OFFLINE": "0"
        }
    },
    "kdb-remote": {
        "command": f"{kdb_dir}/start-mcp-server.sh",
        "args": [],
        "env": {"NODE_ENV": kdb_env or "production"}
    }
}

with open(cfg_path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  done")
PYEOF

# ── 5. Apply to Bob (~/.bob/settings/mcp_settings.json) ──────────────────────
BOB_CONFIG="$HOME/.bob/settings/mcp_settings.json"
echo "→ Patching Bob: $BOB_CONFIG"

python3 - "$BOB_CONFIG" "$CGR_BIN" "$MCP_MEMORY_BIN" "$MCP_LOCAL_RAG_BIN" "$KDB_REMOTE_DIR" \
  "$ICA_API_KEY" "$ICA_ENDPOINT" \
  "${WATSONX_API_KEY:-}" "${WATSONX_PROJECT_ID:-}" "${WATSONX_URL:-}" \
  "${REDIS_HOST:-}" "${REDIS_PORT:-}" "${REDIS_PASSWORD:-}" "${REDIS_USERNAME:-}" \
  "${REDIS_TLS:-}" "${KDB_NODE_ENV:-production}" \
  <<'PYEOF'
import json, sys, os
cfg_path, cgr_bin, mem_bin, rag_bin, kdb_dir = sys.argv[1:6]
ica_key, ica_ep = sys.argv[6:8]
wx_key, wx_proj, wx_url = sys.argv[8:11]
redis_host, redis_port, redis_pw, redis_user, redis_tls, kdb_env = sys.argv[11:17]
home = os.environ["HOME"]

with open(cfg_path) as f:
    cfg = json.load(f)

# Bob uses same mcpServers schema as Claude Code
cfg["mcpServers"] = {
    "memory": {
        "command": mem_bin,
        "args": [],
        "env": {"MEMORY_FILE_PATH": f"{home}/.local/share/mcp-memory/memory.jsonl"}
    },
    "cgr-local": {
        "command": cgr_bin,
        "args": ["mcp-server"],
        "env": {
            "MEMGRAPH_HOST": "localhost",
            "MEMGRAPH_PORT": "7689",
            "ORCHESTRATOR_PROVIDER": "openai",
            "ORCHESTRATOR_MODEL": "claude-sonnet-4-6",
            "ORCHESTRATOR_ENDPOINT": ica_ep,
            "ORCHESTRATOR_API_KEY": ica_key,
            "CYPHER_PROVIDER": "openai",
            "CYPHER_MODEL": "claude-sonnet-4-6",
            "CYPHER_ENDPOINT": ica_ep,
            "CYPHER_API_KEY": ica_key
        }
    },
    "kdb-local": {
        "command": rag_bin,
        "args": [],
        "env": {
            "DB_PATH": f"{home}/.local/share/mcp-knowledge",
            "MODEL_NAME": "Xenova/all-MiniLM-L6-v2",
            "CACHE_DIR": f"{home}/.cache/huggingface",
            "HF_HUB_OFFLINE": "0"
        }
    },
    "kdb-remote": {
        "command": f"{kdb_dir}/start-mcp-server.sh",
        "args": [],
        "env": {"NODE_ENV": kdb_env or "production"}
    }
}

with open(cfg_path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  done")
PYEOF

# ── 6. Ensure Memgraph container has restart policy ──────────────────────────
echo "→ Ensuring Memgraph container restart policy..."
if docker inspect memgraph-codegraph &>/dev/null; then
  POLICY=$(docker inspect memgraph-codegraph --format '{{.HostConfig.RestartPolicy.Name}}')
  if [[ "$POLICY" != "unless-stopped" ]]; then
    docker update --restart=unless-stopped memgraph-codegraph
    echo "  restart policy set to unless-stopped"
  else
    echo "  already unless-stopped"
  fi

  # Start it if not running
  RUNNING=$(docker inspect memgraph-codegraph --format '{{.State.Running}}')
  if [[ "$RUNNING" != "true" ]]; then
    docker start memgraph-codegraph
    echo "  container started"
  else
    echo "  container already running"
  fi
else
  echo "  container not found — creating..."
  docker run -d \
    --name memgraph-codegraph \
    --restart=unless-stopped \
    -p 7689:7687 \
    memgraph/memgraph
  echo "  container created and started"
fi

echo ""
echo "✓ All MCP servers configured for opencode, Claude Code, and Bob."
echo "  Restart each client to pick up the changes."
