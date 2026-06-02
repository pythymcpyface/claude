# Claude Scripts

Utility scripts for project detection, quality gates, and automation.

## Quality Gates

### `quality-gate.sh`
**Purpose**: Pre-commit validation (lint, types, tests, coverage)

**Usage**:
```bash
bash .claude/scripts/quality-gate.sh
```

**Dependencies**: npm, tsc (TypeScript), eslint, jest (auto-detected)

**Checks**:
- Test suite execution
- TypeScript compilation
- ESLint validation
- Test coverage thresholds
- Performance patterns (N+1 queries, caching, indexes)

**Exit Codes**:
- `0` - All gates passed
- `1` - One or more gates failed

---

### `tdd-gate.sh`
**Purpose**: TDD compliance verification - ensures tests exist before implementation

**Usage**:
```bash
# Check specific file
bash .claude/scripts/tdd-gate.sh src/auth/login.ts

# Check all implementation files
bash .claude/scripts/tdd-gate.sh
```

**Dependencies**: grep, find (built-in)

**Checks**:
- Test file existence for each implementation file
- Test quality (assertions, descriptions, edge cases)
- Acceptance criteria coverage (from TDD-STRATEGY.md)
- Mutation testing readiness

**Exit Codes**:
- `0` - TDD compliance verified
- `1` - Missing tests or quality issues

---

### `security-gate.sh`
**Purpose**: Security vulnerability scanning

**Usage**:
```bash
bash .claude/scripts/security-gate.sh
```

**Dependencies**: npm audit, cargo audit, pip-audit (auto-detected)

**Checks**:
- Known vulnerabilities in dependencies
- Hardcoded secrets detection
- Insecure patterns (SQL injection, XSS)

---

### `integration-gate.sh`
**Purpose**: Integration test validation

**Usage**:
```bash
bash .claude/scripts/integration-gate.sh
```

**Dependencies**: Project-specific test runner

**Checks**:
- Integration test execution
- Database connection tests
- API endpoint tests

---

## Setup & Initialization

### `session-init.sh`
**Purpose**: Auto-run on session start to detect project context

**Usage**: Automatically called by Claude on session start

**Actions**:
- Detects project stack (Node.js, Rust, Go, Python)
- Copies autonomous development flow docs
- Generates project-specific `.claude/CLAUDE.md` if missing

---

### `setup-env.sh`
**Purpose**: Project environment setup before implementation

**Usage**:
```bash
bash .claude/scripts/setup-env.sh [project_directory]
```

**Actions**:
- Creates `.claude/` directory structure
- Initializes documentation templates
- Sets up git hooks
- Configures environment variables

---

### `setup-auth.sh`
**Purpose**: Authentication configuration for external services

**Usage**:
```bash
bash .claude/scripts/setup-auth.sh
```

**Actions**:
- Configures API keys
- Sets up OAuth credentials
- Validates authentication tokens

---

## Utilities

### `detect-project.sh`
**Purpose**: Stack detection and skill recommendation

**Usage**:
```bash
bash .claude/scripts/detect-project.sh [project_directory]
```

**Detection**:
- Database/ORM (Prisma, Drizzle, TypeORM, SQLx, Diesel)
- E2E Testing (Playwright, Cypress)
- Algorithm-heavy projects (Rust, Go)
- Error handling systems (circuit breakers, retry)
- Performance systems (rate limiting, caching)

**Output**: Recommended skills to load based on detected patterns

**Caching**: Uses `.claude/.cache_hash` to avoid redundant detection

---

### `context-summary.sh`
**Purpose**: Generate context summaries for large codebases

**Usage**:
```bash
bash .claude/scripts/context-summary.sh
```

**Output**: Markdown summary of project structure, key files, and patterns

---

### `delegate-check.sh`
**Purpose**: Validate delegation configuration

**Usage**:
```bash
bash .claude/scripts/delegate-check.sh
```

**Checks**:
- Agent definitions are valid
- Tool permissions are correct
- Model configurations are set

---

### `docker-helpers.sh`
**Purpose**: Docker utilities for containerized development

**Usage**:
```bash
source .claude/scripts/docker-helpers.sh

# Available functions:
docker_build_and_push <image_name> <tag>
docker_cleanup_dangling
docker_logs_follow <container_name>
```

---

### `generate-project-claude.sh`
**Purpose**: Generate project-specific CLAUDE.md from templates

**Usage**:
```bash
bash .claude/scripts/generate-project-claude.sh
```

**Templates**: Uses `.claude/templates/traits/` to build custom constitution

---

### `local-llm-usage.sh`
**Purpose**: Track local LLM usage and costs

**Usage**:
```bash
bash .claude/scripts/local-llm-usage.sh
```

**Output**: JSON file with token counts and estimated costs

---

### `track-usage.sh`
**Purpose**: Track API usage across sessions

**Usage**:
```bash
bash .claude/scripts/track-usage.sh
```

**Output**: Updates `.claude/usage.json` with cumulative usage

---

### `validate-bash.sh`
**Purpose**: Bash script validation and linting

**Usage**:
```bash
bash .claude/scripts/validate-bash.sh <script_path>
```

**Checks**:
- Syntax errors
- Shellcheck warnings
- Best practices compliance

---

## Troubleshooting

### Quality Gate Failures

**Problem**: Tests failing
```bash
npm test 2>&1 | tail -50  # See last 50 lines of test output
```

**Problem**: TypeScript errors
```bash
npx tsc --noEmit  # See all type errors
```

**Problem**: ESLint errors
```bash
npx eslint src --ext .ts  # See all lint errors
```

---

### TDD Gate Failures

**Problem**: Missing test file
```
Expected test for: src/auth/login.ts
Missing test file: tests/auth/login.test.ts
```

**Solution**: Create test file first (RED), then implement (GREEN)

---

### Detection Cache Issues

**Problem**: Skills not loading after adding new dependencies

**Solution**: Clear cache and re-run detection
```bash
rm .claude/.cache_hash
bash .claude/scripts/detect-project.sh
```

---

## Environment Variables

Some scripts use environment variables for configuration:

| Variable | Purpose | Default |
|----------|---------|---------|
| `CLAUDE_DIR` | Claude configuration directory | `.claude` |
| `SKIP_QUALITY_GATE` | Skip quality gate checks | `false` |
| `SKIP_TDD_GATE` | Skip TDD gate checks | `false` |
| `COVERAGE_THRESHOLD` | Minimum test coverage | `80` |

---

## Integration with Commands

Most scripts are called automatically by commands:

| Command | Scripts Called |
|---------|----------------|
| `/quality-check` | `quality-gate.sh` |
| `/start-project` | `setup-env.sh`, `detect-project.sh` |
| `/feature-dev` | `tdd-gate.sh`, `quality-gate.sh` |
| `/bug-fix` | `tdd-gate.sh`, `quality-gate.sh` |
| `/git-process` | `security-gate.sh`, `quality-gate.sh` |

---

## Contributing

When adding new scripts:

1. Add shebang: `#!/bin/bash`
2. Add description comment
3. Use `set -euo pipefail` for safety
4. Handle missing dependencies gracefully
5. Provide clear error messages
6. Update this README

---

## See Also

- `.claude/commands/` - Command definitions that use these scripts
- `.claude/skills/` - Skills that reference these scripts
- `.claude/docs/` - Generated documentation
