# Developer Constitution

## Overview
This configuration is auto-generated and optimized for the current project context.

## Project: .claude

### Stack
- **Language**: 

### Key Directories

## Critical Constraints
- **NEVER include AI attribution** (no Co-Authored-By, no watermarks, no robot emojis in git commits)
- NEVER output real API keys (use `<YOUR_KEY>` or environment variables)
- Warn before destructive actions (`rm -rf`, `DROP TABLE`, force push)
- Git commits must appear indistinguishable from senior human engineer work

## Token Optimization

### Context Budget
- Target: <50k tokens per session for optimal performance
- Use `/compact` when responses slow down
- Use `/clear` when switching projects

### Tool Result Truncation
Always limit output from expensive commands:
```bash
git log --oneline | head -20      # Not full history
npm test 2>&1 | tail -50          # Only recent output
find . -name "*.ts" | head -30    # Limit file lists
```

### Delegation Strategy
Delegate operations >1000 tokens to Gemini via ultra-mcp:

| Claude (expensive) | Gemini (cheap) |
|-------------------|----------------|
| Code generation | Test execution |
| Architecture decisions | Build processes |
| Complex reasoning | Large file analysis |
| User interaction | Git log/diff processing |

### Delegation Tools
- Tests/builds: `mcp__ultra-mcp__debug-issue`
- Large files/logs: `mcp__ultra-mcp__analyze-code`
- Code review: `mcp__ultra-mcp__review-code`
- Security audit: `mcp__ultra-mcp__secaudit`

## Cross-Session Memory (claude-mem)

### Before Complex Tasks
Search memory for prior work:
```
/mem-search "previous implementation of [feature]"
/mem-search "decision about [architecture choice]"
```

### Memory Commands
- `mem-search` - Search past sessions
- `get_recent_context` - Load recent work
- `timeline` - View session history

## Dynamic Context Loading

Extended skills load on keyword detection:
- Database (prisma, migration, schema) -> `skills/extended/database-integrity.md`
- Algorithms (consolidate, validation) -> `skills/extended/algorithm-validation.md`
- Error handling (retry, circuit breaker) -> `skills/extended/error-classification-recovery.md`
- E2E testing (playwright, cypress) -> `commands/extended/generate-e2e-tests.md`

## Available Commands
- `/quality-check` - Lint, types, tests, coverage validation
- `/git-process` - Safe commit workflow with secret detection
- `/migrate-schema` - Database schema migrations
- `/mem-search` - Search cross-session memory
- `/fast` - Fast execution with Haiku

### Files to Skip Reading
- `node_modules/`, `vendor/`, `target/`, `__pycache__/`
- `dist/`, `build/`, `.next/`, `out/`
- `*.lock`, `*.log`, `coverage/`
- Generated files (check .gitignore)

---

*Auto-generated. Edit to add project-specific patterns, key files, or team conventions.*
