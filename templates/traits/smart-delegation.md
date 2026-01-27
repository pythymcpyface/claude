---
name: smart-delegation
description: Quota-aware delegation. Checks remaining quota and selects Sonnet or Haiku.
---

### Smart Delegation Strategy

Delegation model is selected based on remaining Z.AI quota:

| Remaining Quota | Delegate Model | Rationale |
|----------------|----------------|-----------|
| >50% (>300 prompts) | Sonnet | Balanced quality, plenty of quota |
| 20-50% (120-300 prompts) | Haiku | Conservative, preserve quota |
| <20% (<120 prompts) | Haiku only | Emergency mode, minimal usage |

### Check Current Quota

Before delegating, run:
```bash
bash ~/.claude/scripts/track-usage.sh --check
```

Response format: `USAGE: 45%|sonnet` or `USAGE: 15%|haiku`

### Delegation Rules

**When quota >50%:**
- Delegate to `sonnet-executor` for moderate tasks
- Delegate to `haiku-executor` for simple, well-defined tasks
- Quality matters more than conservation

**When quota 20-50%:**
- Prefer `haiku-executor` for most delegation
- Reserve `sonnet-executor` for complex tasks only
- Be selective about what to delegate

**When quota <20%:**
- Use `haiku-executor` only for critical tasks
- Consider doing more work directly (less delegation overhead)
- Emergency mode - preserve quota

### Recording Usage

After using Opus for a task, record the call:
```bash
bash ~/.claude/scripts/track-usage.sh --record opus
```

This helps track actual usage against quota.

### Available Delegates

| Agent | Model | Best For |
|-------|-------|----------|
| `sonnet-executor` | Sonnet | Features, debugging, refactoring |
| `haiku-executor` | Haiku | Simple tasks, test runs, builds |
