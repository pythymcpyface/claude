# Project CLAUDE.md - Minimal Template

This file is auto-generated when starting a new project. Edit to add project-specific details.

## Critical Constraints
- **NEVER include AI attribution** (no Co-Authored-By, no watermarks)
- **NEVER output real API keys** (use `<YOUR_KEY>` or env vars)
- **Warn before destructive actions** (`rm -rf`, `DROP TABLE`, force push)
- **Git commits must appear as senior human engineer work**

## MCP Tool Priority

Use these MCP tools BEFORE falling back to grep/read:

| Task | MCP Tool |
|------|----------|
| Code relationships (calls, deps) | `code-graph-rag_query_code_graph` |
| Cross-session context | `memory_search_nodes` |
| Document search | `knowledge_query_documents` |

**Note**: Run `code-graph-rag_index_repository` once per project to enable code graph queries.

## Token Optimization

- Target: <50k tokens per session
- Grep first, then read specific sections
- Skip: node_modules, dist, build, __pycache__
- Truncate long outputs: `git log --oneline | head -20`

## Memory System

Store decisions and milestones:
```python
memory_create_entities(entities=[{
  "name": "project:feature-decision",
  "entityType": "decision",
  "observations": ["chose approach X because Y", "files: src/auth/"]
}])
```

Search context:
```python
memory_search_nodes(query="previous implementation of feature")
```

## Available Commands
- `/quality-check` - Lint, types, tests, coverage
- `/git-process` - Safe commit with secret detection
- `/production-readiness-review` - Full production review

## Project Documentation
- `.claude/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md` - Development workflow

---

*Edit this file to add project-specific patterns, key files, or team conventions.*