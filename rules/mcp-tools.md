# MCP Tool Priority

Three MCP tool groups may be configured. Use them BEFORE falling back to grep/glob/read when applicable. If an MCP isn't available in this session, fall back silently.

## Decision Tree

```
Task received
  ├─ "How does X connect to Y?" / "Who calls this?" / "Show dependencies"
  │   → code-graph-rag FIRST, then grep/glob for specifics
  │
  ├─ "What did we decide about X?" / "Previous work on Y?" / Cross-session context
  │   → memory_search_nodes FIRST
  │
  ├─ "Find documentation about X" / "Search ingested docs for Y"
  │   → knowledge_query_documents FIRST
  │
  └─ "Show me file X" / "Find files matching Y" / "What's in directory Z?"
      → read/glob/grep (direct file access)
```

## code-graph-rag (Code Relationships)
- **When**: questions about function calls, class hierarchies, dependency chains, impact analysis.
- **First action per project**: `code-graph-rag_index_repository` if not yet indexed.
- **Query**: `code-graph-rag_query_code_graph` for natural-language code questions.
- **Snippet**: `code-graph-rag_get_code_snippet` to retrieve source by qualified name.
- **Edit**: `code-graph-rag_surgical_replace_code` for precise targeted edits.
- **Fallback**: only fall back to grep/glob if code-graph-rag returns no results.

## memory (Cross-Session State)
- **Session start**: `memory_search_nodes` with project/topic keywords.
- **After milestones**: `memory_create_entities` with decisions, trade-offs, files modified.
- **Entity naming**: `{project}:{topic}` (e.g., `slapenir:auth-architecture`).
- **Entity types**: `decision`, `milestone`, `blocker`, `architecture`, `convention`.
- **Read**: `memory_open_nodes` to retrieve specific entities.

## knowledge (Document Search)
- **Query**: `knowledge_query_documents` with specific terms + context.
- **Ingest**: `knowledge_ingest_file` for new docs, `knowledge_ingest_data` for web/text content.
- **Status**: `knowledge_list_files` to see what's indexed.

## Priority Rules
1. Code relationship questions: `code-graph-rag` > grep > read.
2. Cross-session questions: `memory` > re-reading files.
3. Document questions: `knowledge` > glob+read.
4. File content questions: read > code-graph-rag.
5. File search by name: glob (fastest, no MCP overhead).
6. Combine tools for complex tasks: `memory` + `code-graph-rag` together.
