---
description: macOS disk space recovery with analysis-first approach. Analyzes caches, Docker, build artifacts, and node_modules for safe cleanup. Use when disk is >75% full or user requests cleanup.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Storage Cleanup Command

Run a comprehensive disk space analysis and cleanup for macOS.

## Purpose

Recover disk space through safe, analysis-first cleanup:
- Analyze caches (npm, yarn, pnpm, pip, Homebrew)
- Review Docker images, volumes, and build cache
- Identify build artifacts (.next, dist, build)
- Find large node_modules in inactive projects
- Clear Claude Code debug logs and snapshots
- Protect critical data (claude-mem database, settings)

## Workflow

### 1. Load the Storage Cleanup Skill

Read the skill definition to get the full cleanup checklist and protected directories:

```
Read: skills/storage-cleanup/SKILL.md
```

### 2. Check Disk Status

```bash
df -h /System/Volumes/Data
```

Note: Use `/System/Volumes/Data` not `/` (APFS snapshots hide true usage)

### 3. Run Analysis (All in Parallel)

**Package Manager Caches:**
```bash
du -sh ~/.npm/_cacache 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/Yarn 2>/dev/null || echo "0B"
du -sh ~/Library/pnpm 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/pip 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/Homebrew 2>/dev/null || echo "0B"
```

**Application Caches:**
```bash
du -sh ~/Library/Caches/ms-playwright 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/Google 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/com.microsoft.VSCode.ShipIt 2>/dev/null || echo "0B"
du -sh ~/Library/Caches/com.spotify.client 2>/dev/null || echo "0B"
```

**Docker:**
```bash
docker system df 2>/dev/null || echo "Docker not running"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null
```

**Ollama:**
```bash
ollama list 2>/dev/null
du -sh ~/.ollama/models 2>/dev/null || echo "0B"
```

**Build Artifacts:**
```bash
find ~/Documents -type d -name ".next" -exec du -sh {} \; 2>/dev/null | head -20
find ~/Documents -type d \( -name "dist" -o -name "build" \) -not -path "*/node_modules/*" -exec du -sh {} \; 2>/dev/null | head -20
find ~/Documents -type d -name "node_modules" -exec du -sh {} \; 2>/dev/null | head -20
```

**Claude Code:**
```bash
du -sh ~/.claude/projects 2>/dev/null || echo "0B"
du -sh ~/.claude/debug 2>/dev/null || echo "0B"
du -sh ~/.claude/todos 2>/dev/null || echo "0B"
du -sh ~/.claude/shell-snapshots 2>/dev/null || echo "0B"
du -sh ~/.claude/file-history 2>/dev/null || echo "0B"
du -sh ~/.claude-mem 2>/dev/null || echo "0B"
```

### 4. Present Results

Format as a table with checkboxes and risk levels:

| Clear? | Category | Path | Size | Risk |
|--------|----------|------|------|------|
| [ ] | npm cache | ~/.npm/_cacache | X GB | None |
| [ ] | Docker images | docker images | X GB | Low (re-pull) |
| ... | ... | ... | ... | ... |

**Total reclaimable: X GB**

### 5. User Selection

Use AskUserQuestion with multiSelect to let user choose what to clear.

### 6. Execute Cleanup

Only clear what the user selected. Show progress and verify each step.

### 7. Verification

```bash
df -h /System/Volumes/Data
echo ""
echo "Space recovered: [calculate from before/after]"
```

## Protected Directories (NEVER Clear)

| Directory | Reason |
|-----------|--------|
| `~/.claude-mem/claude-mem.db` | Cross-session memory database |
| `~/.claude/plugins/cache/thedotmack/` | claude-mem plugin cache |
| `~/.claude/sessions/` | Active session state |
| `~/.claude/settings.json` | User configuration |
| `~/.claude/skills/` | Custom skills |
| `~/.claude/commands/` | Custom commands |

## Usage

```
/storage-cleanup
```

## When to Use

- When disk is >75% full
- Before/after large installations
- Monthly maintenance
- When Docker is consuming excessive space
- After building large projects
