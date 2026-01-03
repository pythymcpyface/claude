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
