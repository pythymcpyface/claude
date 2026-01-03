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
