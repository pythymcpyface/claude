---
name: memory-cleanup
description: macOS memory and CPU cleanup. Analyzes processes consuming high memory or CPU, identifies safe targets for cleanup, and terminates resource-intensive tasks. Use when system is slow or memory is exhausted.
tools: Bash, AskUserQuestion
---

# Memory & CPU Cleanup Skill

macOS memory and CPU resource cleanup. Use when system is slow, memory is exhausted, or user requests cleanup.

## Protected Processes (NEVER Terminate)

| Process | Reason |
|---------|--------|
| `kernel_task` | macOS kernel - essential |
| `launchd` | macOS init - essential |
| `WindowServer` | Display server - essential |
| `loginwindow` | Login UI - essential |
| `Finder` | File explorer - essential |
| `SystemUIServer` | Menu bar - essential |
| `claude` | This CLI - essential |
| `code` / `Code` | Editor - essential |
| `iTerm2` / `Terminal` | Terminal - essential |
| `ssh-agent` | SSH authentication |
| `Dist_NOTIFIED.*` | Claude Code processes |

---

## Workflow

### Step 1: System Resource Check

```bash
# Memory pressure
vm_stat | head -10

# Top memory consumers
ps aux | head -1
ps aux | sort -rn -k4 | head -15

# Top CPU consumers
ps aux | sort -rn -k3 | head -15
```

---

### Step 2: Deep Process Analysis

Run ALL analysis in parallel:

```bash
# Processes by memory (sorted by RSS)
ps aux -m | sort -k4 -rn | head -20

# Processes by CPU (sorted by %CPU)
ps aux -M | sort -k3 -rn | head -20

# Apps using most memory (formatted)
ps -eo pmem,rss,comm | sort -k1 -rn | head -15

# Browser processes (often high memory)
ps aux | grep -iE "chrome|firefox|safari|arc|edge|brave" | grep -v grep | sort -k4 -rn

# Electron apps (often high memory)
ps aux | grep -iE "electron|slack|discord|zoom|teams|notion|figma" | grep -v grep | sort -k4 -rn

# Development tools
ps aux | grep -iE "node|npm|yarn|python|docker|code|xcode|intellij" | grep -v grep | sort -k4 -rn

# Background services
ps aux | grep -iE "backupd|cloudd|mdworker|spotlight|assistant" | grep -v grep | sort -k4 -rn
```

### Memory Context

```bash
# System memory overview
sysctl hw.memsize
vm_stat

# Compressed memory
vm_stat | grep -i compress

# Pageins/pageouts
vm_stat | grep -i page
```

### CPU Context

```bash
# CPU info
sysctl hw.ncpu
top -l1 | grep -i cpu

# CPU temperature (if available)
istats cpu_temp 2>/dev/null || echo "No istats"
```

---

### Step 3: Present Analysis Results

Format as a table with checkboxes:

| Terminate? | Process | PID | Memory | CPU | Type | Risk |
|------------|---------|-----|--------|-----|------|------|
| [ ] | Chrome | 1234 | 2.1GB | 15% | Browser | Low (save tabs) |
| [ ] | Slack | 5678 | 800MB | 8% | Electron | Low (re-open) |
| ... | ... | ... | ... | ... | ... | ... |

**Total memory freed: X GB**

---

### Step 4: User Selection

Use AskUserQuestion with multiSelect to let user choose what to terminate:

```
Question: "Which processes would you like to terminate?"
Options: (multiSelect: true)
- [ ] Chrome (2.1GB) - Save tabs first
- [ ] Slack (800MB) - Re-open app
- [ ] Docker (1.2GB) - Restart containers
- [ ] node (500MB) - Restart dev server
- [ ] etc.
```

---

### Step 5: Execute Cleanup

Before terminating, warn about data loss risk.

#### Graceful Terminate (Preferred)
```bash
# Send SIGTERM for graceful shutdown
kill -15 <PID>
```

#### Force Terminate (If Needed)
```bash
# Only if graceful fails
kill -9 <PID>
```

#### By Process Name (Multiple)
```bash
# Find PIDs and terminate
pkill -f "ProcessName"

# Force if needed
pkill -9 -f "ProcessName"
```

#### Browser Cleanup (Special)
```bash
# Chrome - warn user to save tabs
# Check for hanging Chrome processes
ps aux | grep "Chrome" | grep -v grep

# Safari - rarely needs manual termination
```

#### Docker Cleanup (Special)
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove stopped containers
docker container prune -f

# Clear unused images
docker image prune -af
```

#### Development Tools Cleanup
```bash
# Kill node processes (careful - may stop dev servers)
pkill -f "node"

# Kill Python processes
pkill -f "python"

# Kill npm/yarn
pkill -f "npm"
pkill -f "yarn"

# Kill Docker
docker stop $(docker ps -q)
```

---

### Step 6: Verification

After cleanup, verify recovery:

```bash
# Memory pressure
vm_stat

# Top consumers now
ps aux | sort -k4 -rn | head -10

echo ""
echo "Memory freed: [calculate from before/after]"
```

---

## Analysis Commands Quick Reference

| Category | Command |
|----------|---------|
| Memory pressure | `vm_stat` |
| Top memory | `ps aux | sort -k4 -rn | head -15` |
| Top CPU | `ps aux | sort -k3 -rn | head -15` |
| Browsers | `ps aux \| grep -iE "chrome\|fireware\|safari"` |
| Electron | `ps aux \| grep -iE "electron\|slack\|discord"` |
| Dev tools | `ps aux \| grep -iE "node\|python\|docker"` |
| By port | `lsof -i :<port>` |

---

## Safe Termination Guidelines

| Process Type | Action | Risk |
|--------------|--------|------|
| Browsers | Warn to save tabs | Low |
| Slack/Discord | Save pinned messages | Low |
| Terminal apps | Check for running jobs | Medium |
| Node/npm | Save work, restart | Medium |
| Docker | Containers stop | Medium |
| Xcode | Save project first | Medium |
| Virtual machines | Stop gracefully | High |

---

## Emergency Cleanup

If system is unresponsive:

```bash
# Force quit all user apps (except essential)
killall -9 -c "Chrome" "Slack" "Discord" "Zoom" "Teams" 2>/dev/null

# Clear font cache
atsutil databases remove

# Clear disk cache (if needed)
sudo purge
```