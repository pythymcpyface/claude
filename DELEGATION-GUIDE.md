# Token-Efficient Delegation System

## Quick Start

### Automatic Triggering
The `/efficient-delegate` skill auto-triggers for implementation tasks:
- "implement user authentication"
- "add dark mode feature"
- "refactor the API layer"
- "fix validation bugs"

### Manual Invocation
```bash
/efficient-delegate
# Then describe your task
```

### Direct Haiku Delegation
For simple, well-defined tasks, spawn Haiku directly:
```
Use the haiku-executor agent to add a utility function...
```

## How It Works

```mermaid
User Request
    ↓
Sonnet analyzes & breaks down task
    ↓
Creates subtask list (TodoWrite)
    ↓
Delegates to Haiku executors (parallel)
    ↓
Haiku completes atomic subtasks
    ↓
Sonnet verifies & integrates
    ↓
Reports success to user
```

## Token Cost Comparison

### Traditional Approach (All Sonnet)
```
Feature implementation: ~50,000 tokens
Cost: 50k × $3/1M = $0.15
```

### Delegated Approach
```
Planning (Sonnet):     10,000 tokens × $3/1M   = $0.03
Execution (Haiku):     30,000 tokens × $0.25/1M = $0.0075
Verification (Sonnet): 10,000 tokens × $3/1M   = $0.03
Total: $0.0675

Savings: 55% cost reduction
```

## Best Practices

### Good Delegation Candidates
✅ CRUD operations with clear specs
✅ Repetitive file modifications
✅ Test writing for existing code
✅ Running builds/tests and reporting
✅ Code reformatting or linting fixes
✅ Adding types to untyped code

### Poor Delegation Candidates
❌ Architectural decisions
❌ Debugging complex issues
❌ Ambiguous requirements
❌ Novel algorithm implementation
❌ Cross-cutting refactors
❌ Integration of new libraries

## Configuration Files

- **Skill**: `~/.claude/skills/efficient-delegate.md`
- **Haiku Agent**: `~/.claude/agents/haiku-executor.md`

## Example Usage

### Example 1: Add Feature
```
User: "Add a user profile page with avatar upload"

Claude (Sonnet):
Breaking down task:
1. Create profile page component
2. Add avatar upload component
3. Create API endpoint for upload
4. Add image storage utility
5. Write tests

Delegating to Haiku:
- Tasks 1, 2, 4, 5 → haiku-executor
- Task 3 (API design) → keeping in Sonnet

[Spawns 2 Haiku agents in parallel]
[Handles task 3 in Sonnet]
[Verifies integration]
```

### Example 2: Bug Fixes
```
User: "Fix the 3 TypeScript errors in the auth module"

Claude (Sonnet):
Reading error output... 3 straightforward type mismatches

Delegating all to Haiku (simple fixes):
[Spawns single haiku-executor]
[Verifies with type check]
```

### Example 3: Complex Refactor
```
User: "Refactor the state management to use Zustand"

Claude (Sonnet):
This requires architectural decisions.
Not delegating - handling in Sonnet.

[Proceeds with Sonnet for entire task]
```

## Monitoring Efficiency

Track your token savings:

```bash
# View recent session costs in ~/.claude/logs
# Compare delegated vs non-delegated sessions
```

## Tips for Maximum Efficiency

1. **Be specific**: Clear requirements = better Haiku results
2. **Batch similar tasks**: Parallel Haiku agents for similar subtasks
3. **Trust the system**: Let Sonnet decide delegation strategy
4. **Provide context once**: Front-load context in the breakdown phase
5. **Verify assumptions**: Haiku will ask if requirements are unclear

## Troubleshooting

**Haiku gets stuck or confused**
→ Task too ambiguous; Sonnet will retry

**Over-delegation warnings**
→ Simple task broken down unnecessarily; just do it in Sonnet

**Integration issues**
→ Subtasks need better coordination; adjust breakdown strategy

## Advanced: Custom Subagents

Create domain-specific Haiku executors:

```yaml
# ~/.claude/agents/test-writer.md
---
name: test-writer
model: haiku
description: Write tests for existing code
tools: Read, Write, Bash(npm test)
---
```

Then delegate: "Use test-writer agent to add tests for the auth module"

## ROI Analysis

**Typical project (100 tasks over 1 month):**

| Approach | Tokens | Cost |
|----------|--------|------|
| All Sonnet | 5M | $15.00 |
| Smart Delegation | 2M Sonnet + 2M Haiku | $6.50 |
| **Monthly Savings** | | **$8.50** |

**Annual savings: ~$100** while maintaining code quality!

---

*Questions? Check `/help` or GitHub issues at anthropics/claude-code*
