# Architecture Validation Template

Use this template to validate architectural decisions before implementation. This ensures the design aligns with codebase patterns, conventions, and long-term maintainability goals.

---

## How to Use This Template

1. **Complete during Phase 4.5: Architecture Validation** of the /feature-dev workflow
2. **Review after architecture design** but before TDD strategy
3. **Verify alignment** with existing codebase patterns
4. **Create ADR** (Architecture Decision Record) for significant decisions

---

## Design Pattern Verification

### Pattern Alignment

| Pattern | Status | Notes |
|---------|--------|-------|
| Singleton / Factory / Builder used appropriately | [ ] | |
| Repository pattern for data access | [ ] | |
| Service layer for business logic | [ ] | |
- Dependency injection used | [ ] | |
| Observer/Pub-Sub for events | [ ] | |

### Codebase Pattern Matching

| Check | Status | Notes |
|-------|--------|-------|
| Matches existing file organization | [ ] | |
| Uses existing naming conventions | [ ] | |
| Follows established module structure | [ ] | |
| Compatible with existing error handling | [ ] | |
| Uses shared utilities where applicable | [ ] | |

---

## Convention Alignment Checklist

### Naming Conventions

| Convention | Status | Notes |
|------------|--------|-------|
| Variables follow project style (camelCase/snake_case) | [ ] | |
| Classes follow project style (PascalCase/CapWords) | [ ] | |
| Constants follow project style (UPPER_SNAKE_CASE) | [ ] | |
- Files named according to convention | [ ] | |
| Test files follow naming pattern | [ ] | |

### File Structure

| Check | Status | Notes |
|-------|--------|-------|
| Files in correct directories | [ ] | |
| Index files used appropriately | [ ] | |
| No circular dependencies | [ ] | |
| Module boundaries respected | [ ] | |

### Code Organization

| Check | Status | Notes |
|-------|--------|-------|
| Single Responsibility Principle followed | [ ] | |
| Functions/classes focused on one thing | [ ] | |
| Related code grouped together | [ ] | |
| Public API clearly defined | [ ] | |

---

## SOLID Principles Verification

### Single Responsibility Principle
- [ ] Each class/function has one reason to change
- [ ] No "god" classes or functions
- [ ] Clear separation of concerns

### Open/Closed Principle
- [ ] Open for extension, closed for modification
- [ ] Uses interfaces/abstract classes
- [ ] Plugin/strategy pattern for variations

### Liskov Substitution Principle
- [ ] Subtypes can replace base types
- [ ] No violating contracts
- [ ] Proper inheritance hierarchies

### Interface Segregation Principle
- [ ] Interfaces are focused
- [ ] No fat interfaces
- [ ] Clients depend only on what they use

### Dependency Inversion Principle
- [ ] Depend on abstractions, not concretions
- [ ] High-level modules don't depend on low-level
- [ ] Inversion of control applied

---

## Architectural Characteristics

### Maintainability
| Check | Status | Notes |
|-------|--------|-------|
| Code is readable and self-documenting | [ ] | |
| Clear separation of layers | [ ] | |
- Easy to locate functionality | [ ] | |
| Minimal coupling between modules | [ ] | |

### Scalability
| Check | Status | Notes |
|-------|--------|-------|
| Stateless design where appropriate | [ ] | |
| Horizontal scaling considered | [ ] | |
| Database queries optimized | [ ] | |
| Caching strategy defined | [ ] | |

### Testability
| Check | Status | Notes |
|-------|--------|-------|
| Dependencies can be mocked | [ ] | |
| No hidden global state | [ ] | |
| Pure functions where possible | [ ] | |
| Clear test boundaries | [ ] | |

### Performance
| Check | Status | Notes |
|-------|--------|-------|
| Algorithm complexity appropriate | [ ] | |
| No N+1 queries | [ ] | |
- Lazy loading where appropriate | [ ] | |
| Resource usage considered | [ ] | |

---

## Integration Points

### External Dependencies
| Dependency | Purpose | Fallback | Version Pin |
|------------|---------|----------|-------------|
| | | | |

### Internal Dependencies
| Module | Purpose | Coupling Level |
|--------|---------|----------------|
| | | |

### API Boundaries
| Endpoint | Authentication | Rate Limit | Validation |
|----------|----------------|------------|------------|
| | | | |

---

## Error Handling Strategy

| Error Type | Handling Strategy | User Experience |
|------------|-------------------|-----------------|
| Validation | | |
| Authentication | | |
| Authorization | | |
| Not Found | | |
| Server Error | | |
| External Service | | |

---

## Data Model Validation

| Entity | Fields | Relationships | Indexes |
|--------|--------|---------------|---------|
| | | | |

### Data Integrity
- [ ] Foreign keys defined
- [ ] Constraints enforced
- [ ] Cascade rules defined
- [ ] Transactions used for multi-step operations

---

## Security Considerations (Architecture Level)

| Concern | Mitigation |
|---------|------------|
| Authorization at boundaries | |
| Input validation layer | |
| Secrets management | |
| Audit logging | |
- Rate limiting | |

---

## Technology Stack Alignment

| Technology | Version | Justification |
|------------|---------|---------------|
| | | |

### New Dependencies
| Package/Library | Purpose | Alternatives Considered |
|-----------------|---------|------------------------|
| | | |

---

## Architecture Decision Record (ADR)

### ADR-XXX: [Decision Title]

**Status**: Proposed / Accepted / Deprecated / Superseded

**Context**
[What is the situation that requires a decision?]

**Decision**
[What did we decide?]

**Consequences**
- **Positive**: [Benefits of this decision]
- **Negative**: [Drawbacks or trade-offs]

**Alternatives Considered**
1. [Alternative 1] - [Why not chosen]
2. [Alternative 2] - [Why not chosen]

**Related Decisions**
- [Link to related ADRs]

---

## Validation Summary

| Category | Pass/Fail | Notes |
|----------|-----------|-------|
| Design Patterns | [ ] | |
| Conventions | [ ] | |
- SOLID Principles | [ ] | |
| Architectural Characteristics | [ ] | |
| Integration Points | [ ] | |
| Error Handling | [ ] | |
| Data Model | [ ] | |
| Security | [ ] | |
| Technology Stack | [ ] | |

**Overall Assessment**: [ ] Pass / [ ] Fail / [ ] Pass with Conditions

**Conditions/Concerns**:


**Reviewer Approval**: [ ] Approved / [ ] Approved with Changes / [ ] Needs Revision

---

*End of ARCHITECTURE-VALIDATION template*
