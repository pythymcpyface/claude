---
description: Run comprehensive code quality validation (linting, types, tests, coverage, comments)
allowed-tools: Bash(npm:*), Bash(cargo:*), Bash(python:*), Bash(go:*), Bash(pytest:*), Bash(jest:*), Bash(tsc:*), Bash(mypy:*), Bash(pylint:*), Bash(ruff:*), Bash(golangci-lint:*), Bash(clippy:*), Bash(rustfmt:*), Bash(prettier:*), Bash(eslint:*), Bash(find:*), Bash(grep:*), Bash(cat:*), Read, Grep, Glob
---

# Quality Check Command

Run linting, type checking, tests with coverage (>80% threshold), and comment quality validation.

## Workflow

### 1. Detect Stack

| Indicator | Stack |
|-----------|-------|
| `package.json` | Node.js/TypeScript |
| `Cargo.toml` | Rust |
| `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |

### 2. Run Linters

| Stack | Command |
|-------|---------|
| Node.js | `npm run lint` / `npx prettier --check .` |
| Rust | `cargo clippy -- -D warnings` / `cargo fmt --check` |
| Python | `ruff check .` / `black --check .` |
| Go | `golangci-lint run` / `gofmt -l .` |

### 3. Type Checking

| Stack | Command |
|-------|---------|
| TypeScript | `npx tsc --noEmit` |
| Rust | `cargo check` |
| Python | `mypy . --strict` |
| Go | `go vet ./...` |

### 4. Tests + Coverage (80% threshold)

| Stack | Command |
|-------|---------|
| Node.js | `npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'` |
| Rust | `cargo tarpaulin --fail-under 80` |
| Python | `pytest --cov=. --cov-fail-under=80` |
| Go | `go test -cover ./...` |

### 5. Comment Quality

Flag "what" comments that should explain "why":

```bash
grep -rn -E "^[[:space:]]*(//|#)[[:space:]]*(Create|Get|Set|Return|Initialize)" .
```

**Bad:** `// Create a user` (code shows this)
**Good:** `// Cache to avoid expensive recalculation on render`

### 6. Report

```
═══════════════════════════════════════════════
              QUALITY CHECK REPORT
═══════════════════════════════════════════════
🧹 LINTING:        [PASS/FAIL]
🔍 TYPE CHECKING:  [PASS/FAIL]
🧪 TESTS:          [X/Y passed] Coverage: [%]
💬 COMMENTS:       [count] "what" comments found

✅ OVERALL: [PASS/FAIL]
═══════════════════════════════════════════════
```

## When to Use

✅ Before commit, before PR, after refactoring
❌ During active development, on WIP code

## Constitution Alignment

Enforces Quality Gates from CLAUDE.md:
- Lint-free code
- Strict typing (no `any`)
- >80% coverage on business logic
- Comments explain WHY, not WHAT
