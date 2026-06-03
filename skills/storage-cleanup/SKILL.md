---
name: storage-cleanup
description: macOS disk space recovery with analysis-first approach. Analyzes caches, Docker, build artifacts, and node_modules for safe cleanup. Use when disk is >75% full or user requests cleanup.
tools: Bash, Read, AskUserQuestion
---

# Storage Cleanup Skill

macOS disk space recovery with analysis-first approach. Use when disk is >75% full or user requests cleanup.

This SKILL.md is a router. Detailed commands live in `references/`:

| You need… | Read |
|---|---|
| Analysis commands (disk status, cache sizing, Docker, build artifacts) | `references/analysis.md` |
| Cleanup execution commands per category, verification, Colima notes | `references/cleanup.md` |

---

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
| `~/.colima/` | Colima VM (active running VMs) |
| `~/.bob/` | Bob CLI tool configuration |
| `~/Documents/` | User documents |
| `~/Library/Application Support/Code/User/` | VSCode user data/extensions |
| `~/Library/Application Support/OnVUE/` | OnVUE exam software |
| `~/Library/Application Support/IBM Bob/` | IBM Bob configuration |
| `~/.ollama/` | Ollama AI models |

---

## Claude Code Storage Architecture

| System | Location | Typical Size | Purpose |
|--------|----------|--------------|---------|
| **Session caches** | `~/.claude/projects/*/` | 6-8GB | Full conversation transcripts (`.jsonl`) |
| **claude-mem** | `~/.claude-mem/claude-mem.db` | 100-150MB | Extracted, searchable observations |
| **Debug logs** | `~/.claude/debug/` | 500MB+ | Debug output from past sessions |
| **Shell snapshots** | `~/.claude/shell-snapshots/` | 25-30MB | Shell state for session resumption |
| **Todos** | `~/.claude/todos/` | 50-60MB | Persistent todo lists |
| **File history** | `~/.claude/file-history/` | 50MB | File version history |
| **Command history** | `~/.claude/history.jsonl` | 3-5MB | Prompt history |

### Session Caches vs claude-mem

| Use Case | Session Cache | claude-mem |
|----------|--------------|------------|
| Resume interrupted session | Required | No |
| Search past work | No (not indexed) | Yes (FTS + semantic) |
| Find modified files | Yes (in transcript) | Yes (extracted) |
| Recall decisions | Difficult (raw text) | Yes (structured) |
| Storage efficiency | ~6.7GB | ~117MB |

**Important**: claude-mem contains *extracted knowledge* from sessions, not raw transcripts. Deleting session caches does NOT lose learned patterns — they're preserved in claude-mem.

### Claude Code Safe Cleanup

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

| Step | Goal | Reference |
|------|------|-----------|
| 1 | Disk status check (`df -h /System/Volumes/Data`) | `references/analysis.md` |
| 2 | Analyze storage usage (caches, Docker, build artifacts, Ollama, Claude Code) | `references/analysis.md` |
| 3 | Present analysis as table with checkboxes; total reclaimable | `references/analysis.md` |
| 4 | User selection via `AskUserQuestion` (multiSelect) | `references/cleanup.md` |
| 5 | Execute cleanup — only what user selected; show progress | `references/cleanup.md` |
| 6 | Verification — `df -h` before/after, calculate space recovered | `references/cleanup.md` |

> Use `/System/Volumes/Data` not `/` for disk usage (APFS snapshots hide true usage).

---

## Integration

- Complements `/memory-cleanup` (Claude Code session/memory state)
- For container-specific cleanup, see Colima section in `references/cleanup.md`
- Always verifies user confirmation before destructive operations
