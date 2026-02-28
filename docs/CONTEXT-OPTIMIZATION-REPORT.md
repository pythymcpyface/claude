# Claude Code Context Optimization Report

**Generated:** 2026-02-28
**Goal:** Reduce initial context to maximize available context window

---

## Current Context Footprint Analysis

### File Sizes

| Component | Files | Total Size | Est. Tokens |
|-----------|-------|------------|-------------|
| CLAUDE.md (main) | 1 | 6.8KB | ~1,700 |
| CLAUDE.md (.claude/) | 1 | 2.8KB | ~700 |
| Skills | 43 | 1,046KB | ~260,000 |
| Commands | 42 | 291KB | ~73,000 |
| Agents | 8 | 21KB | ~5,000 |
| Hooks | 7 scripts | - | runtime |

### Active Components

| Component | Status | Context Impact |
|-----------|--------|----------------|
| MCP Server (claude-mem) | 1 active | ~500-2000 tokens |
| Plugins enabled | 3 | Variable |
| Hooks per session | 7 | ~100-500 tokens |
| SessionStart hooks | 3 scripts | Adds to startup time |

---

## Recommendations

### 1. Environment Variables (HIGH IMPACT)

Add to `~/.claude/settings.json` under `"env"`:

```json
{
  "env": {
    "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_TELEMETRY": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "CLAUDE_CODE_DISABLE_TERMINAL_TITLE": "1",
    "MAX_THINKING_TOKENS": "0"
  }
}
```

**Estimated savings:** 500-2000 tokens per session

### 2. Consolidate Production Review Skills (HIGH IMPACT)

Current: 21 production review skills (~15,000 lines, ~375K chars)

**Problem:** Each skill file is 700-1100 lines. They're only used when explicitly invoked via `/production-readiness-review`.

**Solution:** Move to on-demand loading:
1. Create `skills/production-readiness/` with a single index SKILL.md
2. Move detailed skills to `skills/production-readiness/reviews/` subdirectory
3. Only load when the command is invoked

**Estimated savings:** 10,000-15,000 tokens (only load when needed)

### 3. Reduce Hooks (MEDIUM IMPACT)

Current SessionStart hooks run 3 scripts on every session:
- `generate-project-claude.sh` - Generates per-project CLAUDE.md
- `detect-project.sh` - Detects project type and loads skills
- `track-usage.sh --init` - Initializes usage tracking

**Recommendation:** Combine into a single script or make conditional:

```json
"SessionStart": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/scripts/session-init.sh \"$PWD\""
      }
    ]
  }
]
```

**Estimated savings:** 200-500 tokens, faster startup

### 4. Disable Unused Plugins (MEDIUM IMPACT)

Currently enabled:
- `claude-mem@thedotmack` - KEEP (memory is valuable)
- `everything-claude-code@everything-claude-code` - REVIEW
- `rust-analyzer-lsp@claude-plugins-official` - KEEP if doing Rust

**Check what everything-claude-code provides:**
```bash
ls ~/.claude/plugins/marketplaces/everything-claude-code/skills/
```

If you don't use the skills from this plugin, disable it:
```json
"everything-claude-code@everything-claude-code": false
```

**Estimated savings:** 1,000-5,000 tokens

### 5. Consolidate CLAUDE.md (MEDIUM IMPACT)

Current structure loads dynamic skills based on keywords:
```
Extended skills load on keyword detection:
- Database (prisma, migration, schema) -> skills/extended/database-integrity.md
- Algorithms (consolidate, validation) -> skills/extended/algorithm-validation.md
- Error handling (retry, circuit breaker) -> skills/extended/error-classification-recovery.md
- E2E testing (playwright, cypress) -> commands/extended/generate-e2e-tests.md
```

**This is good!** Keep this pattern. But review if all entries are needed.

### 6. Command Consolidation (LOW-MEDIUM IMPACT)

42 command files totaling 291KB. Many are production review commands that duplicate skill functionality.

**Recommendation:** Remove command wrappers that just invoke skills:
- `/code-quality-review` -> invokes `skills/code-quality-review/SKILL.md`
- `/security-review` -> invokes `skills/security-review/SKILL.md`
- etc.

Keep only commands that add unique value beyond skills.

### 7. Use Subagents for Heavy Operations (HIGH IMPACT)

From research: Using `context: "fork"` for subagents isolates their context:

```markdown
---
tools: Read, Grep, Glob, Bash
context: fork
---
```

This prevents subagent context from polluting main context.

### 8. MCP Server Optimization (MEDIUM IMPACT)

Current: 1 MCP server (claude-mem)

**Best practices from research:**
- Each MCP tool definition costs ~150-500 tokens
- claude-mem has 5 tools: ~750-2500 tokens

**If you don't use cross-session memory frequently:**
```json
"claude-mem@thedotmack": false
```

---

## Implementation Checklist

### Immediate (Do Now)

- [ ] Add environment variables to `settings.json`
- [ ] Disable `everything-claude-code` plugin if not actively used
- [ ] Combine SessionStart hooks into single script

### Short-term (This Week)

- [ ] Move production review skills to subdirectory for lazy loading
- [ ] Remove command wrappers that duplicate skills
- [ ] Audit and remove unused extended skills

### Long-term (Consider)

- [ ] Create a minimal "core" CLAUDE.md for new projects
- [ ] Implement progressive skill disclosure pattern
- [ ] Add context budget monitoring hook

---

## Expected Savings Summary

| Optimization | Token Savings |
|--------------|---------------|
| Environment variables | 500-2,000 |
| Disable unused plugins | 1,000-5,000 |
| Lazy-load review skills | 10,000-15,000 |
| Consolidate hooks | 200-500 |
| Remove duplicate commands | 2,000-5,000 |
| **Total Potential** | **13,700-27,500 tokens** |

---

## Context Window Math

| Model | Context Window | After Optimization |
|-------|---------------|-------------------|
| Claude Opus 4.5 | 200K tokens | ~185K available |
| Claude Sonnet 4 | 200K tokens | ~185K available |
| Haiku | 200K tokens | ~185K available |

**Key insight from research:** Performance degrades at 20-40% context usage, not 100%. By reducing initial context, you push back this degradation point.

---

## Sources

- [Claude Code Context Optimization (Juejin)](https://juejin.cn/post/7611375381651849259)
- [MCP Token Overhead Analysis](https://www.linkedin.com/pulse/cli-offloaded-mcp-context-engineering-hack-anthropic-guy-vago--vix1f)
- [Claude Code Best Practices (CSDN)](https://blog.csdn.net/2501_93058131/article/details/150604489)
- [Production Readiness Review Skills](https://github.com/anthropics/claude-code)
- [Token Savings with Code Execution](https://m.blog.csdn.net/Code1994/article/details/155265421)
