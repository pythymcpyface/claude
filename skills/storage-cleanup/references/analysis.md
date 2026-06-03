# Storage Cleanup — Analysis Commands

Used in Steps 1-3 of the storage-cleanup workflow: disk status, sizing every cache/cache-like location, presenting the result table.

---

## Step 1: Disk Status Check

```bash
df -h /System/Volumes/Data
```

> Use `/System/Volumes/Data`, not `/`, on macOS — APFS snapshots hide true usage from `/`.

---

## Step 2: Analyze Storage Usage

Run all analysis commands in parallel, then present results in a table.

### Caches and tools

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

# VSCode ShipIt
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

# uv cache
du -sh ~/.cache/uv 2>/dev/null || echo "0B"

# Trivy vulnerability scanner cache
du -sh ~/.cache/trivy 2>/dev/null || echo "0B"

# Puppeteer cache
du -sh ~/.cache/puppeteer 2>/dev/null || echo "0B"

# Rustup toolchains
du -sh ~/.rustup 2>/dev/null || echo "0B"

# Maven cache
du -sh ~/.m2/repository 2>/dev/null || echo "0B"

# Slack cache
du -sh ~/Library/Application\ Support/Slack 2>/dev/null || echo "0B"

# Brave cache
du -sh ~/Library/Application\ Support/BraveSoftware 2>/dev/null || echo "0B"

# CocoaPods cache
du -sh ~/Library/Caches/CocoaPods 2>/dev/null || echo "0B"

# Xcode derived data
du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null || echo "0B"

# Claude Code caches
du -sh ~/.claude/projects 2>/dev/null || echo "0B"
du -sh ~/.claude/debug 2>/dev/null || echo "0B"
du -sh ~/.claude/todos 2>/dev/null || echo "0B"
du -sh ~/.claude/shell-snapshots 2>/dev/null || echo "0B"
du -sh ~/.claude/file-history 2>/dev/null || echo "0B"

# Claude Code - claude-mem database (PROTECTED - for info only)
du -sh ~/.claude-mem 2>/dev/null || echo "0B"
```

### Build artifacts

```bash
# Next.js .next folders
find ~/Documents -type d -name ".next" -exec du -sh {} \; 2>/dev/null

# dist/build folders
find ~/Documents -type d \( -name "dist" -o -name "build" \) -not -path "*/node_modules/*" -exec du -sh {} \; 2>/dev/null | head -20

# node_modules in projects (summarize)
find ~/Documents -type d -name "node_modules" -exec du -sh {} \; 2>/dev/null | head -20
```

### Docker detail

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

### Ollama

```bash
ollama list 2>/dev/null
```

### Claude Code internal analysis

```bash
# Claude Code root directory breakdown
du -sh ~/.claude/*/ 2>/dev/null | sort -rh | head -20

# Project session caches (often the largest)
du -sh ~/.claude/projects/*/ 2>/dev/null | sort -rh | head -20

# Count debug files (can be thousands)
ls ~/.claude/debug/ | wc -l

# Count shell snapshots
ls ~/.claude/shell-snapshots/ | wc -l

# Count todos
ls ~/.claude/todos/ | wc -l

# Check claude-mem database size and record count
ls -lh ~/.claude-mem/claude-mem.db
sqlite3 ~/.claude-mem/claude-mem.db "SELECT COUNT(*) as observations FROM observations;"
```

---

## Step 3: Present Analysis Results

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

## Quick Reference

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
| Claude Code total | `du -sh ~/.claude/*/` |
| Claude Code projects | `du -sh ~/.claude/projects/*/` |
| claude-mem | `sqlite3 ~/.claude-mem/claude-mem.db "SELECT COUNT(*) FROM observations;"` |
