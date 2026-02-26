---
name: storage-cleanup
description: macOS disk space recovery with analysis-first approach. Analyzes caches, Docker, build artifacts, and node_modules for safe cleanup. Use when disk is >75% full or user requests cleanup.
tools: Bash, Read, AskUserQuestion
---

# Storage Cleanup Skill

macOS disk space recovery with analysis-first approach. Use when disk is >75% full or user requests cleanup.

## Protected Directories (NEVER Clear)

| Directory | Reason |
|-----------|--------|
| `~/.claude-mem/claude-mem.db` | Cross-session memory database (117MB typical) |
| `~/.claude/plugins/cache/thedotmack/` | claude-mem plugin cache |
| `~/.claude/sessions/` | Active session state |
| `~/.claude/settings.json` | User configuration |
| `~/.claude/skills/` | Custom skills |
| `~/.claude/commands/` | Custom commands |
| Any path containing `claude-mem` | Cross-session memory system |

---

## Claude Code Storage Architecture

### Storage Systems Comparison

| System | Location | Typical Size | Purpose |
|--------|----------|--------------|---------|
| **Session caches** | `~/.claude/projects/*/` | 6-8GB | Full conversation transcripts (`.jsonl`) |
| **claude-mem** | `~/.claude-mem/claude-mem.db` | 100-150MB | Extracted, searchable observations |
| **Debug logs** | `~/.claude/debug/` | 500MB+ | Debug output from past sessions |
| **Shell snapshots** | `~/.claude/shell-snapshots/` | 25-30MB | Shell state for session resumption |
| **Todos** | `~/.claude/todos/` | 50-60MB | Persistent todo lists |
| **File history** | `~/.claude/file-history/` | 50MB | File version history |
| **Command history** | `~/.claude/history.jsonl` | 3-5MB | Prompt history |

### Session Caches vs claude-mem: Key Differences

| Use Case | Session Cache | claude-mem |
|----------|--------------|------------|
| Resume interrupted session | Required | No |
| Search past work | No (not indexed) | Yes (FTS + semantic) |
| Find modified files | Yes (in transcript) | Yes (extracted) |
| Recall decisions | Difficult (raw text) | Yes (structured) |
| Storage efficiency | ~6.7GB | ~117MB |

**Important:** claude-mem contains *extracted knowledge* from sessions, not raw transcripts. Deleting session caches does NOT lose learned patterns - they're preserved in claude-mem.

### Claude Code Analysis Commands

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

### Claude Code Safe Cleanup Options

| Clear? | Path | Typical Size | Risk | Regenerates |
|--------|------|--------------|------|-------------|
| [ ] | `~/.claude/debug/*` | 500MB+ | None | Yes, on next session |
| [ ] | `~/.claude/shell-snapshots/*` | 25-30MB | Low | Yes, on next session |
| [ ] | `~/.claude/todos/*` | 50-60MB | Low | Yes, on next session |
| [ ] | `~/.claude/projects/<inactive>/` | 1-5GB each | Low* | Yes, on next session in that project |
| [ ] | `~/.claude/file-history/*` | 50MB | Medium | No |

*Only delete inactive project caches. Active project caches needed for session resumption.

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

# Claude Code caches
du -sh ~/.claude/projects 2>/dev/null || echo "0B"
du -sh ~/.claude/debug 2>/dev/null || echo "0B"
du -sh ~/.claude/todos 2>/dev/null || echo "0B"
du -sh ~/.claude/shell-snapshots 2>/dev/null || echo "0B"
du -sh ~/.claude/file-history 2>/dev/null || echo "0B"

# Claude Code - claude-mem database (PROTECTED - for info only)
du -sh ~/.claude-mem 2>/dev/null || echo "0B"
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

#### Claude Code - Debug Logs
```bash
# Safe to clear - regenerates as needed
rm -rf ~/.claude/debug/*
```

#### Claude Code - Shell Snapshots
```bash
# Safe to clear - regenerates on next session
rm -rf ~/.claude/shell-snapshots/*
```

#### Claude Code - Todos
```bash
# Safe to clear - regenerates on next session
rm -rf ~/.claude/todos/*
```

#### Claude Code - Inactive Project Caches
```bash
# Only clear projects NOT currently being worked on
# claude-mem preserves the extracted knowledge
rm -rf ~/.claude/projects/-Users-<username>-path-to-inactive-project/
```

#### Claude Code - File History
```bash
# Only if user confirmed - this is NOT regenerated
rm -rf ~/.claude/file-history/*
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
| Claude Code total | `du -sh ~/.claude/*/` |
| Claude Code projects | `du -sh ~/.claude/projects/*/` |
| claude-mem | `sqlite3 ~/.claude-mem/claude-mem.db "SELECT COUNT(*) FROM observations;"` |

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
