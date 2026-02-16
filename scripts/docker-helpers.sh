#!/bin/bash
# Docker Development Helpers
# Reusable functions for container management and orchestration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# COLIMA MANAGEMENT
# =============================================================================

# Check if Colima is running and healthy
# Returns: 0 if running, 1 if not
check_colima() {
    if colima status &>/dev/null; then
        log_ok "Colima is running"
        return 0
    else
        log_info "Colima is not running"
        return 1
    fi
}

# Start Colima with sensible defaults
start_colima() {
    log_info "Starting Colima..."

    # Use default resources if not configured
    local cpu="${COLIMA_CPU:-4}"
    local memory="${COLIMA_MEMORY:-8}"
    local disk="${COLIMA_DISK:-60}"

    if colima start --cpu "$cpu" --memory "$memory" --disk "$disk" 2>&1; then
        log_ok "Colima started successfully"
        return 0
    else
        log_error "Failed to start Colima"
        return 1
    fi
}

# Restart Colima (useful when stale/unhealthy)
restart_colima() {
    log_warn "Restarting Colima..."
    colima restart 2>&1
    local status=$?
    if [[ $status -eq 0 ]]; then
        log_ok "Colima restarted successfully"
    else
        log_error "Failed to restart Colima"
    fi
    return $status
}

# Full reset of Colima (destructive)
reset_colima() {
    log_warn "Performing full Colima reset (destructive)..."
    colima delete -f 2>/dev/null || true
    start_colima
}

# Check Docker daemon responsiveness
check_docker_daemon() {
    if docker info &>/dev/null; then
        log_ok "Docker daemon is responsive"
        return 0
    else
        log_error "Docker daemon not responsive"
        return 1
    fi
}

# Ensure Docker runtime is ready
ensure_docker_ready() {
    if ! check_colima; then
        start_colima || return 1
    fi

    if ! check_docker_daemon; then
        log_warn "Docker daemon not ready, restarting Colima..."
        restart_colima || return 1
        check_docker_daemon || return 1
    fi

    return 0
}

# =============================================================================
# PROJECT DETECTION
# =============================================================================

# Detect docker-compose file in current directory
# Returns: path to compose file or empty string
detect_compose_file() {
    local compose_files=(
        "docker-compose.yml"
        "docker-compose.yaml"
        "compose.yaml"
        "compose.yml"
    )

    for file in "${compose_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "$file"
            return 0
        fi
    done

    return 1
}

# Check if Makefile exists and has relevant targets
# Returns: available targets (space-separated)
detect_makefile_targets() {
    if [[ ! -f Makefile ]]; then
        return 1
    fi

    local targets=()
    local desired_targets=("run" "dev" "up" "start" "serve" "docker")

    # Parse Makefile for targets
    for target in "${desired_targets[@]}"; do
        if grep -qE "^${target}:" Makefile; then
            targets+=("$target")
        fi
    done

    if [[ ${#targets[@]} -gt 0 ]]; then
        echo "${targets[*]}"
        return 0
    fi

    return 1
}

# Detect Dockerfile
detect_dockerfile() {
    if [[ -f Dockerfile ]]; then
        echo "Dockerfile"
        return 0
    fi

    # Check for Dockerfile.* variants
    local dockerfiles=(Dockerfile.*)
    if [[ ${#dockerfiles[@]} -gt 0 && -f "${dockerfiles[0]}" ]]; then
        echo "${dockerfiles[0]}"
        return 0
    fi

    return 1
}

# Determine project type
detect_project_type() {
    if detect_compose_file &>/dev/null; then
        echo "compose"
    elif detect_makefile_targets &>/dev/null; then
        echo "makefile"
    elif detect_dockerfile &>/dev/null; then
        echo "dockerfile"
    else
        echo "unknown"
    fi
}

# =============================================================================
# PORT MANAGEMENT
# =============================================================================

# Parse exposed ports from compose file
# Arguments: compose_file
# Returns: space-separated list of ports
parse_compose_ports() {
    local compose_file="${1:-$(detect_compose_file)}"
    [[ -z "$compose_file" ]] && return 1

    # Extract port mappings (handles "8080:80" format)
    grep -oE '\-[[:space:]]*["'"'"']?[0-9]+:' "$compose_file" 2>/dev/null | \
        grep -oE '[0-9]+' | sort -u | tr '\n' ' '

    # Also check for PORT environment variables
    grep -oE 'PORT[=:][[:space:]]*[0-9]+' "$compose_file" 2>/dev/null | \
        grep -oE '[0-9]+' | sort -u | tr '\n' ' '
}

# Parse exposed ports from Dockerfile
parse_dockerfile_ports() {
    local dockerfile="${1:-Dockerfile}"
    [[ ! -f "$dockerfile" ]] && return 1

    grep -iE '^EXPOSE' "$dockerfile" 2>/dev/null | \
        grep -oE '[0-9]+' | sort -u | tr '\n' ' '
}

# Check if a port is in use
# Arguments: port_number
# Returns: 0 if in use, 1 if available
is_port_in_use() {
    local port="$1"
    lsof -i ":$port" &>/dev/null
}

# Get process/container using a port
# Arguments: port_number
# Returns: description of what's using the port
get_port_user() {
    local port="$1"
    local result=""

    # Check for Docker container
    local container=$(docker ps --format '{{.Names}} ({{.ID}})' --filter "publish=$port" 2>/dev/null | head -1)
    if [[ -n "$container" ]]; then
        result="Container: $container"
    fi

    # Check for process
    local pid=$(lsof -t -i ":$port" 2>/dev/null | head -1)
    if [[ -n "$pid" ]]; then
        local process=$(ps -p "$pid" -o comm= 2>/dev/null)
        result="$result Process: $process (PID: $pid)"
    fi

    echo "$result"
}

# Detect all port conflicts for given ports
# Arguments: space-separated list of ports
# Returns: conflicts in format "port:user"
detect_port_conflicts() {
    local ports="$1"
    local conflicts=()

    for port in $ports; do
        if is_port_in_use "$port"; then
            local user=$(get_port_user "$port")
            conflicts+=("$port:$user")
        fi
    done

    printf '%s\n' "${conflicts[@]}"
}

# =============================================================================
# CONTAINER MANAGEMENT
# =============================================================================

# Start containers using docker compose
start_compose() {
    local compose_file="${1:-$(detect_compose_file)}"
    local rebuild="${2:-false}"

    if [[ -z "$compose_file" ]]; then
        log_error "No compose file found"
        return 1
    fi

    log_info "Starting containers with $compose_file..."

    local cmd="docker compose -f $compose_file up -d"
    [[ "$rebuild" == "true" ]] && cmd="docker compose -f $compose_file up -d --build"

    if eval "$cmd" 2>&1; then
        log_ok "Containers started"
        return 0
    else
        log_error "Failed to start containers"
        return 1
    fi
}

# Start using Makefile target
start_makefile() {
    local target="${1:-}"

    if [[ -z "$target" ]]; then
        local targets=$(detect_makefile_targets)
        target=$(echo "$targets" | awk '{print $1}')
    fi

    if [[ -z "$target" ]]; then
        log_error "No suitable Makefile target found"
        return 1
    fi

    log_info "Starting with make $target..."
    make "$target"
}

# Build and run single Dockerfile
start_dockerfile() {
    local dockerfile="${1:-Dockerfile}"
    local image_name="${2:-$(basename "$PWD")}"

    log_info "Building image from $dockerfile..."
    if ! docker build -t "$image_name" -f "$dockerfile" .; then
        log_error "Failed to build image"
        return 1
    fi

    log_info "Running container..."
    docker run -d --name "$image_name" "$image_name"
}

# Stop a container by name or ID
stop_container() {
    local container="$1"

    if docker stop "$container" &>/dev/null; then
        log_ok "Stopped container: $container"
        return 0
    else
        log_error "Failed to stop container: $container"
        return 1
    fi
}

# Stop all containers using specific ports
stop_containers_on_ports() {
    local ports="$1"

    for port in $ports; do
        local container=$(docker ps --format '{{.Names}}' --filter "publish=$port" 2>/dev/null)
        if [[ -n "$container" ]]; then
            stop_container "$container"
        fi
    done
}

# =============================================================================
# LOG MONITORING
# =============================================================================

# Monitor container logs for errors
# Arguments: [timeout_seconds] [compose_file]
monitor_logs() {
    local timeout="${1:-30}"
    local compose_file="${2:-$(detect_compose_file)}"
    local errors=()
    local success_indicators=()

    log_info "Monitoring logs for ${timeout}s..."

    local start_time=$(date +%s)

    docker compose -f "$compose_file" logs -f --tail=50 2>&1 | while IFS= read -r line; do
        local now=$(date +%s)
        if (( now - start_time > timeout )); then
            log_info "Monitoring timeout reached (${timeout}s)"
            break
        fi

        # Check for errors
        if echo "$line" | grep -qiE "error|failed|fatal|exception|refused|denied"; then
            log_error "$line"
        fi

        # Check for success
        if echo "$line" | grep -qiE "listening|ready|started|connected|server running"; then
            log_ok "$line"
        fi
    done
}

# Get recent container logs
# Arguments: [lines] [compose_file]
get_recent_logs() {
    local lines="${1:-50}"
    local compose_file="${2:-$(detect_compose_file)}"

    docker compose -f "$compose_file" logs --tail="$lines" 2>&1
}

# =============================================================================
# STATUS REPORTING
# =============================================================================

# Get status of running containers
get_container_status() {
    local compose_file="${1:-$(detect_compose_file)}"

    if [[ -n "$compose_file" ]]; then
        docker compose -f "$compose_file" ps 2>&1
    else
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1
    fi
}

# Generate status report
generate_status_report() {
    local compose_file=$(detect_compose_file)
    local project_type=$(detect_project_type)

    echo "=== Docker Environment Status ==="
    echo ""
    echo "Project type: $project_type"
    [[ -n "$compose_file" ]] && echo "Compose file: $compose_file"
    echo ""

    echo "Colima status:"
    colima status 2>&1 || echo "  Not running"
    echo ""

    echo "Running containers:"
    get_container_status "$compose_file"
    echo ""

    echo "Exposed ports:"
    case "$project_type" in
        compose)
            parse_compose_ports "$compose_file"
            ;;
        dockerfile)
            parse_dockerfile_ports
            ;;
    esac
    echo ""
}

# =============================================================================
# DOCUMENTATION HELPERS
# =============================================================================

# Generate markdown status block for documentation
generate_docs_block() {
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    local compose_file=$(detect_compose_file)
    local containers=$(docker compose ps --format '{{.Name}}: {{.Ports}}' 2>/dev/null)

    cat <<EOF
## Container Status (Updated: $timestamp)

Running containers:
\`\`\`
$containers
\`\`\`

Startup command: \`docker compose up -d\`
EOF
}

# =============================================================================
# MAIN ENTRY POINT (for testing)
# =============================================================================

main() {
    case "${1:-status}" in
        status)
            generate_status_report
            ;;
        start)
            ensure_docker_ready || exit 1
            case $(detect_project_type) in
                compose) start_compose ;;
                makefile) start_makefile ;;
                dockerfile) start_dockerfile ;;
                *) log_error "No Docker configuration found" ;;
            esac
            ;;
        stop)
            local compose_file=$(detect_compose_file)
            [[ -n "$compose_file" ]] && docker compose -f "$compose_file" down
            ;;
        logs)
            monitor_logs "${2:-30}"
            ;;
        conflicts)
            local ports=$(parse_compose_ports)
            detect_port_conflicts "$ports"
            ;;
        *)
            echo "Usage: $0 {status|start|stop|logs|conflicts}"
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
