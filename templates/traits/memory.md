## Cross-Session Memory (Knowledge Graph)

### Search Before Complex Tasks
Use `memory_search_nodes` to find prior work:
```python
memory_search_nodes(query="previous implementation of auth")
memory_search_nodes(query="decision about encryption approach")
```

### Store Decisions & Milestones
Use `memory_create_entities` to record important context:
```python
memory_create_entities(entities=[{
  "name": "project:auth-architecture",
  "entityType": "decision",
  "observations": [
    "chose JWT over sessions for stateless auth",
    "files modified: src/auth/, config/jwt.yaml"
  ]
}])
```

### Read Specific Entities
Use `memory_open_nodes` to retrieve stored context:
```python
memory_open_nodes(names=["project:auth-architecture"])
```

### Entity Naming Convention
- Pattern: `{project}:{topic}` (e.g., `slapenir:auth-architecture`)
- Types: `decision`, `milestone`, `blocker`, `architecture`, `convention`