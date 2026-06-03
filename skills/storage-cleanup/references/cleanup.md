# Storage Cleanup — Execution Commands

Used in Steps 4-6 of the storage-cleanup workflow: user selection, executing the cleanup commands per category, verification, and Colima notes.

Only clear what the user explicitly selected. Show progress and verify each step.

---

## Step 4: User Selection

Use `AskUserQuestion` with `multiSelect: true`:

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

## Step 5: Execute Cleanup

### Package manager caches

```bash
# npm
rm -rf ~/.npm/_cacache

# Yarn
yarn cache clean

# pnpm
pnpm store prune

# Gradle
rm -rf ~/.gradle/caches

# uv
rm -rf ~/.cache/uv

# Trivy
rm -rf ~/.cache/trivy

# Puppeteer
rm -rf ~/.cache/puppeteer

# Rustup
rm -rf ~/.rustup
```

### Browser/test tools

```bash
# Playwright
rm -rf ~/Library/Caches/ms-playwright
```

### Docker

```bash
# Remove dangling images
docker image prune -f

# Remove all unused images (user confirmed only)
docker image prune -a -f

# Only remove user-confirmed unused volumes
docker volume rm <volume-name> ...

# Full system prune (CAUTION — only if user explicitly confirmed)
docker system prune -a --volumes -f
```

### Ollama models

```bash
ollama rm <model-name>
```

### Build artifacts

```bash
# Remove confirmed .next folders
rm -rf <path>/.next

# Remove confirmed dist/build folders
rm -rf <path>/dist <path>/build

# node_modules in inactive projects
rm -rf <project>/node_modules
```

### Claude Code caches

```bash
# Debug logs - safe, regenerates
rm -rf ~/.claude/debug/*

# Shell snapshots - safe, regenerates on next session
rm -rf ~/.claude/shell-snapshots/*

# Todos - safe, regenerates on next session
rm -rf ~/.claude/todos/*

# Inactive project caches - claude-mem preserves the extracted knowledge
rm -rf ~/.claude/projects/-Users-<username>-path-to-inactive-project/

# File history - NOT regenerated; only if user confirmed
rm -rf ~/.claude/file-history/*
```

### Application caches

```bash
# Slack
rm -rf ~/Library/Application\ Support/Slack/*

# Brave
rm -rf ~/Library/Application\ Support/BraveSoftware/Brave-Global-Default/Cache/*
rm -rf ~/Library/Application\ Support/BraveSoftware/Brave-Global-Default/CodeCache/*
```

---

## Step 6: Verification

After cleanup, verify recovery:

```bash
df -h /System/Volumes/Data
echo ""
echo "Space recovered: [calculate from before/after]"
```

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
