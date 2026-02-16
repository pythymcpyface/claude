# Storage Cleanup Skill

macOS disk space recovery patterns. Use when disk is >75% full or user requests cleanup.

## Current Status Check
```bash
df -h /System/Volumes/Data
```
Note: Use `/System/Volumes/Data` not `/` (APFS snapshots hide true usage)

---

## Phase 1: Docker Cleanup (Highest Impact)

### Check Docker Usage
```bash
docker system df
```

### Find Unused Volumes
`docker volume prune -f` may report 0B even with unused volumes. To identify truly unused:

```bash
docker volume ls -q | while read vol; do
  docker ps -a --filter volume="$vol" --format '{{.Names}}' 2>/dev/null | grep -q . || echo "$vol"
done
```

### Remove Unused Volumes
```bash
# After identifying unused volumes above
docker volume rm <volume-name> ...
```

---

## Phase 2: Application Caches

| Cache | Command | Size |
|-------|---------|------|
| npm | `npm cache clean --force` or `rm -rf ~/.npm/_cacache` | ~3GB |
| Yarn | `yarn cache clean` | ~100MB |
| Playwright | `rm -rf ~/Library/Caches/ms-playwright` | ~1.3GB |
| Google | `rm -rf ~/Library/Caches/Google` | ~1GB |
| VSCode | `rm -rf ~/Library/Caches/com.microsoft.VSCode.ShipIt` | ~700MB |
| Python | `rm -rf ~/Library/Caches/com.apple.python` | ~200MB |
| Spotify | `rm -rf ~/Library/Caches/com.spotify.client` | ~150MB |

**Note**: `npm cache clean --force` can fail with ENOTEMPTY. Use direct `rm -rf ~/.npm/_cacache` as fallback.

---

## Phase 3: Ollama Models

```bash
ollama list
ollama rm <model-name>
```

---

## Phase 4: Development Cleanup

### Find Build Artifacts
```bash
find ~/Documents/nodeprojects -type d -name ".next"
find ~/Documents/nodeprojects -type d \( -name "dist" -o -name "build" \)
```

### Remove Build Artifacts
```bash
# Next.js
rm -rf <project>/.next
# Other builds
rm -rf <project>/dist <project>/build
```

**Warning**: Exclude `node_modules` directories when removing `build/` folders.

### Remove node_modules (Inactive Projects)
```bash
rm -rf <project>/node_modules
# Restore later with: npm install
```

---

## Phase 5: Verification

After each phase, verify recovery:
```bash
df -h /System/Volumes/Data
```

---

## Colima VM

Check VM internal usage:
```bash
colima ssh -- df -h
```
