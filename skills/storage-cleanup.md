# Storage Cleanup Skill

macOS disk space recovery with analysis-first approach. Use when disk is >75% full or user requests cleanup.

## Protected Directories (NEVER Clear)

| Directory | Reason |
|-----------|--------|
| `~/.claude/plugins/cache/thedotmack/` | claude-mem persistent memory |
| `~/.claude/sessions/` | Session state |
| `~/.claude/settings.json` | User configuration |
| Any path containing `claude-mem` | Cross-session memory database |

---

## Workflow

### Step 1: Disk Status Check

```bash
df -h /System/Volumes/Data
```

Note: Use `/System/Volumes/Data` not `/` (APFS snapshots hide true usage)

---

### Step 2: Analyze Storage Usage

Run ALL analysis commands in parallel, then present results in a table:

```bash
# Docker
docker system df 2>/dev/null || echo "Docker not running"

# npm cache
du -sh ~/.npm/_cacache 2>/dev/null || echo "0B"

# Yarn cache
du -sh ~/Library/Caches/Yarn 2>/dev/null || echo "0B"

# pnpm cache
du -sh ~/Library/pnpm 2>/dev/null || echo "0B"

# Playwright browsers
du -sh ~/Library/Caches/ms-playwright 2>/dev/null || echo "0B"

# Google Chrome
du -sh ~/Library/Caches/Google 2>/dev/null || echo "0B"

# VSCode
du -sh ~/Library/Caches/com.microsoft.VSCode.ShipIt 2>/dev/null || echo "0B"

# Python
du -sh ~/Library/Caches/com.apple.python 2>/dev/null || echo "0B"

# Spotify
du -sh ~/Library/Caches/com.spotify.client 2>/dev/null || echo "0B"

# Ollama models
du -sh ~/.ollama/models 2>/dev/null || echo "0B"

# Claude CLI cache (EXCLUDE claude-mem)
du -sh ~/Library/Caches/claude-cli-nodejs 2>/dev/null || echo "0B"

# Homebrew cache
du -sh ~/Library/Caches/Homebrew 2>/dev/null || echo "0B"

# pip cache
du -sh ~/Library/Caches/pip 2>/dev/null || echo "0B"

# Gradle cache
du -sh ~/.gradle/caches 2>/dev/null || echo "0B"

# Maven cache
du -sh ~/.m2/repository 2>/dev/null || echo "0B"

# CocoaPods cache
du -sh ~/Library/Caches/CocoaPods 2>/dev/null || echo "0B"

# Xcode derived data
du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null || echo "0B"
```

### Build Artifacts Analysis

```bash
# Next.js .next folders
find ~/Documents -type d -name ".next" -exec du -sh {} \; 2>/dev/null

# dist/build folders
find ~/Documents -type d \( -name "dist" -o -name "build" \) -not -path "*/node_modules/*" -exec du -sh {} \; 2>/dev/null | head -20

# node_modules in projects (summarize)
find ~/Documents -type d -name "node_modules" -exec du -sh {} \; 2>/dev/null | head -20
```

### Docker Detailed Analysis

```bash
# List all images with sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null

# List all volumes with sizes
docker volume ls -q | while read vol; do
  size=$(docker run --rm -v "$vol:/data" alpine du -sh /data 2>/dev/null | cut -f1)
  echo "$vol: $size"
done 2>/dev/null

# Find truly unused volumes (not connected to any container)
docker volume ls -q | while read vol; do
  docker ps -a --filter volume="$vol" --format '{{.Names}}' 2>/dev/null | grep -q . || echo "$vol (unused)"
done
```

### Ollama Models Analysis

```bash
ollama list 2>/dev/null
```

---

### Step 3: Present Analysis Results

Format as a table with checkboxes:

| Clear? | Category | Path | Size | Risk |
|--------|----------|------|------|------|
| [ ] | Docker images | docker images | X GB | Low (re-pull) |
| [ ] | Docker volumes (unused) | docker volumes | X GB | Medium (data loss) |
| [ ] | npm cache | ~/.npm/_cacache | X GB | None |
| [ ] | Playwright browsers | ~/Library/Caches/ms-playwright | X GB | Low (re-download) |
| ... | ... | ... | ... | ... |

**Total reclaimable: X GB**

---

### Step 4: User Selection

Use AskUserQuestion with multiSelect to let user choose what to clear:

```
Question: "Which items would you like to clean?"
Options: (multiSelect: true)
- [ ] npm cache (X GB) - Safe, re-downloads on demand
- [ ] Playwright browsers (X GB) - Re-downloads on next test run
- [ ] Docker unused volumes (X GB) - Verify no important data
- [ ] Build artifacts (X GB) - Regenerate with npm run build
- [ ] etc.
```

---

### Step 5: Execute Cleanup

Only clear what user selected. Show progress and verify each step.

#### npm Cache
```bash
rm -rf ~/.npm/_cacache
```

#### Yarn Cache
```bash
yarn cache clean
```

#### pnpm Cache
```bash
pnpm store prune
```

#### Playwright Browsers
```bash
rm -rf ~/Library/Caches/ms-playwright
```

#### Docker - Images
```bash
# Remove dangling images
docker image prune -f

# Remove all unused images (user confirmed only)
docker image prune -a -f
```

#### Docker - Volumes
```bash
# Only remove user-confirmed unused volumes
docker volume rm <volume-name> ...
```

#### Docker - Full System Prune (CAUTION)
```bash
# Only if user explicitly confirmed
docker system prune -a --volumes -f
```

#### Ollama Models
```bash
ollama rm <model-name>
```

#### Build Artifacts
```bash
# Remove confirmed .next folders
rm -rf <path>/.next

# Remove confirmed dist/build folders
rm -rf <path>/dist <path>/build
```

#### node_modules (Inactive Projects)
```bash
# Only remove user-confirmed directories
rm -rf <project>/node_modules
```

---

### Step 6: Verification

After cleanup, verify recovery:

```bash
df -h /System/Volumes/Data
echo ""
echo "Space recovered: [calculate from before/after]"
```

---

## Analysis Commands Quick Reference

| Category | Command |
|----------|---------|
| Docker total | `docker system df` |
| Docker images | `docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}"` |
| Docker volumes | `docker volume ls -q` + size check |
| npm | `du -sh ~/.npm/_cacache` |
| Yarn | `du -sh ~/Library/Caches/Yarn` |
| Playwright | `du -sh ~/Library/Caches/ms-playwright` |
| Ollama | `ollama list` + `du -sh ~/.ollama/models` |
| Build artifacts | `find ~ -type d -name ".next" -exec du -sh {} \;` |

---

## Colima VM (if using Colima instead of Docker Desktop)

Check VM internal usage:
```bash
colima ssh -- df -h
```

Resize VM if needed:
```bash
colima stop
colima start --cpu 4 --memory 8 --disk 60
```
