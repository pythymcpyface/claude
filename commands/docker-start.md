# /docker-start - Container Development Environment Startup

## Purpose
Start application in Docker with automatic Colima management, port conflict
resolution, log monitoring, and documentation updates.

## Triggers
- User runs `/docker-start`
- User asks to "start docker", "run containers", "bring up the app"
- User wants to start development environment

## Workflow

### Phase 1: Docker Runtime Health

Check Colima status and ensure Docker daemon is accessible:

```bash
# Check if Colima is running
if ! colima status &>/dev/null; then
  echo "Colima not running. Starting..."
  colima start
fi

# Verify Docker daemon is responsive
if ! docker info &>/dev/null; then
  echo "Docker daemon not responsive. Restarting Colima..."
  colima restart
fi
```

If Colima fails to start:
1. Check system resources (`colima status`)
2. Suggest `colima delete && colima start` for fresh start
3. Ask user for guidance

### Phase 2: Project Analysis

Detect container configuration in current directory:

1. **Docker Compose files** (priority order):
   - `docker-compose.yml`
   - `docker-compose.yaml`
   - `compose.yaml`
   - `compose.yml`

2. **Makefile targets**:
   - Parse `make help` or check for `run`, `dev`, `up`, `start` targets

3. **Single Dockerfile**:
   - `Dockerfile` or `Dockerfile.*`

```bash
# Detection logic
COMPOSE_FILE=""
if [[ -f docker-compose.yml ]]; then
  COMPOSE_FILE="docker-compose.yml"
elif [[ -f docker-compose.yaml ]]; then
  COMPOSE_FILE="docker-compose.yaml"
elif [[ -f compose.yaml ]]; then
  COMPOSE_FILE="compose.yaml"
elif [[ -f compose.yml ]]; then
  COMPOSE_FILE="compose.yml"
fi

# Parse exposed ports from compose file
PORTS=$(grep -E "^\s*-\s*[0-9]+:" "$COMPOSE_FILE" 2>/dev/null | grep -oE "[0-9]+:" | tr -d ':' | sort -u)
```

### Phase 3: Port Conflict Detection

For each detected port, check for conflicts:

```bash
for port in $PORTS; do
  # Check if port is in use
  if lsof -i :$port &>/dev/null; then
    # Find what's using it
    CONFLICT=$(lsof -t -i :$port)
    CONTAINER=$(docker ps --format '{{.ID}} {{.Names}} {{.Ports}}' | grep ":$port->" | head -1)

    echo "Port $port is in use:"
    [[ -n "$CONTAINER" ]] && echo "  Container: $CONTAINER"
    [[ -n "$CONFLICT" ]] && echo "  Process PID: $CONFLICT"

    CONFLICTS["$port"]="$CONTAINER|$CONFLICT"
  fi
done
```

### Phase 4: Conflict Resolution (User Prompt)

If conflicts detected, prompt user:

```
Port conflicts detected:
  - Port 3000: Used by container "api-server"
  - Port 5432: Used by container "postgres-dev"

Options:
1. Stop conflicting containers
2. Change application ports
3. Cancel and handle manually

[Ask user to choose]
```

Resolution actions:
- **Stop containers**: `docker stop <container_name>`
- **Change ports**: Modify compose env vars or use `-p` override

### Phase 5: Container Startup

Execute appropriate startup command:

```bash
# Priority 1: Docker Compose
if [[ -n "$COMPOSE_FILE" ]]; then
  docker compose -f "$COMPOSE_FILE" up -d

# Priority 2: Makefile
elif [[ -f Makefile ]] && grep -qE "^(run|dev|up|start):" Makefile; then
  if grep -q "^run:" Makefile; then
    make run
  elif grep -q "^dev:" Makefile; then
    make dev
  elif grep -q "^up:" Makefile; then
    make up
  fi

# Priority 3: Single Dockerfile
elif [[ -f Dockerfile ]]; then
  IMAGE_NAME=$(basename "$PWD")
  docker build -t "$IMAGE_NAME" .
  docker run -d --name "$IMAGE_NAME" "$IMAGE_NAME"
fi
```

### Phase 6: Health Monitoring

Monitor startup logs for errors:

```bash
# Watch logs with timeout (30s default)
TIMEOUT=30
START_TIME=$(date +%s)

docker compose logs -f --tail=50 2>&1 | while read -r line; do
  # Check for error patterns
  if echo "$line" | grep -qiE "error|failed|refused|denied"; then
    ERRORS+=("$line")
  fi

  # Check for success indicators
  if echo "$line" | grep -qiE "listening|ready|started|connected"; then
    echo "Startup indicator: $line"
  fi

  # Timeout check
  NOW=$(date +%s)
  if (( NOW - START_TIME > TIMEOUT )); then
    echo "Monitoring timeout reached (${TIMEOUT}s)"
    break
  fi
done
```

Common error patterns and suggestions:
| Error Pattern | Likely Cause | Resolution |
|--------------|--------------|------------|
| `address already in use` | Port conflict | Stop conflicting container |
| `connection refused` | Dependency not ready | Wait or check health |
| `authentication failed` | Bad credentials | Check .env file |
| `no such host` | Network issue | Check DNS/VLAN |
| `out of memory` | Resource limit | Increase Colima resources |

### Phase 7: Documentation Update

Update project documentation with startup state:

```markdown
## Container Status (Updated: YYYY-MM-DD HH:MM)

Running containers:
- web-api: http://localhost:3000
- postgres: localhost:5432

Startup command: `docker compose up -d`
Issues resolved: Stopped conflicting container "old-api"
```

Target files (in order of preference):
1. `PROGRESS.md`
2. `README.md`
3. `.claude/docs/RUNNING.md`

### Phase 8: User Notification

Report final status:

```
Docker environment started successfully.

Containers running:
  - web-api    → http://localhost:3000
  - postgres   → localhost:5432
  - redis      → localhost:6379

Health: All services responding
Logs: Use `docker compose logs -f` to follow

Warnings:
  - None
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Colima won't start | Suggest `colima delete && colima start` |
| No Docker config found | List available options, ask user |
| Port conflict unresolved | Abort with manual instructions |
| Container exits immediately | Show logs, suggest `docker compose logs` |
| Health check fails | Show errors, offer retry |

## Flags (Optional)

| Flag | Purpose |
|------|---------|
| `--no-monitor` | Skip log monitoring phase |
| `--timeout N` | Set monitoring timeout to N seconds |
| `--rebuild` | Force rebuild of images |
| `--detach` | Run in background (default) |

## Integration

This command integrates with:
- `/quality-check` - Run after startup for validation
- `skills/storage-cleanup.md` - For disk space management
- Existing `scripts/docker-helpers.sh` - Shared functions
