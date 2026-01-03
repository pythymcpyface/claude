---
name: mcp-delegation
description: Delegate expensive operations (>1000 tokens) to Gemini via ultra-mcp tools.
---

# MCP Delegation Strategy

## Decision Tree

```
Is operation expensive (>1000 tokens output)?
├─ YES → Can Gemini handle it?
│        ├─ Execution (tests, builds) → YES, delegate
│        ├─ Summarization (logs, diffs) → YES, delegate
│        ├─ Pattern matching (search) → YES, delegate
│        ├─ Complex reasoning → NO, use Claude
│        └─ Code generation → NO, use Claude
└─ NO → Use Claude directly (delegation overhead not worth it)
```

## Delegation Map

| Operation | Tool | Example |
|-----------|------|---------|
| Run tests | `mcp__ultra-mcp__debug-issue` | `task: "Run npm test and report results"` |
| Analyze large files | `mcp__ultra-mcp__analyze-code` | `task: "Analyze error patterns in logs", files: ["/var/log/app.log"]` |
| Build projects | `mcp__ultra-mcp__debug-issue` | `task: "Run npm run build, report errors"` |
| Code review | `mcp__ultra-mcp__review-code` | `task: "Review auth module for security", focus: "security"` |
| Security audit | `mcp__ultra-mcp__secaudit` | `task: "OWASP Top 10 review", severity: "high"` |
| Git operations | `mcp__ultra-mcp__analyze-code` | `task: "Analyze recent commits to auth module"` |
| Pre-commit check | `mcp__ultra-mcp__precommit` | `task: "Validate changes before commit"` |

## Cost Comparison

| Model | Input Cost | Output Cost |
|-------|-----------|-------------|
| Claude | $3/1M tokens | $15/1M tokens |
| Gemini Flash | $0.075/1M | $0.30/1M |
| **Savings** | **40x** | **50x** |

## Usage Patterns

### Test Execution
```typescript
// DON'T: Run tests in Claude context
await Bash("npm test"); // Loads full output into expensive context

// DO: Delegate to Gemini
await mcp__ultra-mcp__debug-issue({
  task: "Run npm test and report summary with any failures",
  symptoms: "Need to verify recent changes"
});
// Returns: "15 tests passed, 2 failed: auth.test.ts line 45..."
```

### Large File Analysis
```typescript
// DON'T: Read large files directly
await Read("/var/log/app.log"); // 50k lines into context

// DO: Let Gemini summarize
await mcp__ultra-mcp__analyze-code({
  task: "Find error patterns and frequency in last 24 hours",
  files: ["/var/log/app.log"],
  focus: "errors"
});
// Returns: "3 error patterns: DB timeout (47x), Auth failure (12x)..."
```

### Progressive Analysis
```typescript
// 1. Gemini does broad analysis
const summary = await mcp__ultra-mcp__review-code({
  task: "Review for security issues",
  focus: "security"
});

// 2. Claude deep-dives on specific issues found
if (summary.includes("SQL injection")) {
  const file = await Read("src/db/queries.ts");
  // Fix the specific issue
}
```

## When NOT to Delegate

- Single small file reads (<500 tokens)
- Simple grep searches (<100 results)
- Quick command outputs (<200 tokens)
- Code generation tasks
- Architecture decisions requiring reasoning
