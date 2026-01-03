#!/bin/bash
# Generate Project-Specific CLAUDE.md
# Called by SessionStart hook when entering a project directory
# Creates .claude/CLAUDE.md if it doesn't exist

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
PROJECT_CLAUDE="$CLAUDE_DIR/CLAUDE.md"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"

# Skip if already exists
if [ -f "$PROJECT_CLAUDE" ]; then
  exit 0
fi

# Skip if not a project directory (no package.json, Cargo.toml, etc.)
cd "$PROJECT_DIR" 2>/dev/null || exit 0

HAS_PROJECT=false
[ -f "package.json" ] && HAS_PROJECT=true
[ -f "Cargo.toml" ] && HAS_PROJECT=true
[ -f "go.mod" ] && HAS_PROJECT=true
[ -f "pyproject.toml" ] && HAS_PROJECT=true
[ -f "setup.py" ] && HAS_PROJECT=true
[ -f "requirements.txt" ] && HAS_PROJECT=true
[ -f "Makefile" ] && HAS_PROJECT=true
[ -d ".git" ] && HAS_PROJECT=true

if [ "$HAS_PROJECT" = false ]; then
  exit 0
fi

# Create .claude directory
mkdir -p "$CLAUDE_DIR"

# Detect project characteristics
STACK=""
FRAMEWORKS=""
TESTING=""
DATABASE=""
BUILD_TOOLS=""

# Node.js/TypeScript detection
if [ -f "package.json" ]; then
  STACK="Node.js"

  # Check for TypeScript
  if [ -f "tsconfig.json" ] || grep -q '"typescript"' package.json 2>/dev/null; then
    STACK="TypeScript"
  fi

  # Frameworks
  grep -q '"next"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS Next.js,"
  grep -q '"react"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS React,"
  grep -q '"vue"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS Vue,"
  grep -q '"express"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS Express,"
  grep -q '"fastify"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS Fastify,"
  grep -q '"nestjs"' package.json 2>/dev/null && FRAMEWORKS="$FRAMEWORKS NestJS,"

  # Testing
  grep -q '"jest"' package.json 2>/dev/null && TESTING="Jest"
  grep -q '"vitest"' package.json 2>/dev/null && TESTING="Vitest"
  grep -q '"playwright"' package.json 2>/dev/null && TESTING="$TESTING Playwright"
  grep -q '"cypress"' package.json 2>/dev/null && TESTING="$TESTING Cypress"

  # Database
  grep -q '"prisma"' package.json 2>/dev/null && DATABASE="Prisma"
  grep -q '"drizzle"' package.json 2>/dev/null && DATABASE="Drizzle"
  grep -q '"typeorm"' package.json 2>/dev/null && DATABASE="TypeORM"
  grep -q '"mongoose"' package.json 2>/dev/null && DATABASE="Mongoose"

  # Build tools
  [ -f "vite.config.ts" ] || [ -f "vite.config.js" ] && BUILD_TOOLS="Vite"
  [ -f "webpack.config.js" ] && BUILD_TOOLS="Webpack"
  [ -f "turbo.json" ] && BUILD_TOOLS="$BUILD_TOOLS Turborepo"
fi

# Rust detection
if [ -f "Cargo.toml" ]; then
  STACK="Rust"

  grep -q 'actix-web' Cargo.toml 2>/dev/null && FRAMEWORKS="Actix-web"
  grep -q 'axum' Cargo.toml 2>/dev/null && FRAMEWORKS="Axum"
  grep -q 'rocket' Cargo.toml 2>/dev/null && FRAMEWORKS="Rocket"
  grep -q 'tokio' Cargo.toml 2>/dev/null && FRAMEWORKS="$FRAMEWORKS Tokio,"

  grep -q 'sqlx' Cargo.toml 2>/dev/null && DATABASE="SQLx"
  grep -q 'diesel' Cargo.toml 2>/dev/null && DATABASE="Diesel"
  grep -q 'sea-orm' Cargo.toml 2>/dev/null && DATABASE="SeaORM"

  TESTING="cargo test"
fi

# Go detection
if [ -f "go.mod" ]; then
  STACK="Go"

  grep -q 'gin-gonic' go.mod 2>/dev/null && FRAMEWORKS="Gin"
  grep -q 'echo' go.mod 2>/dev/null && FRAMEWORKS="Echo"
  grep -q 'fiber' go.mod 2>/dev/null && FRAMEWORKS="Fiber"

  grep -q 'gorm' go.mod 2>/dev/null && DATABASE="GORM"
  grep -q 'sqlx' go.mod 2>/dev/null && DATABASE="sqlx"

  TESTING="go test"
fi

# Python detection
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  STACK="Python"

  grep -qE 'fastapi|FastAPI' requirements.txt pyproject.toml 2>/dev/null && FRAMEWORKS="FastAPI"
  grep -qE 'django|Django' requirements.txt pyproject.toml 2>/dev/null && FRAMEWORKS="Django"
  grep -qE 'flask|Flask' requirements.txt pyproject.toml 2>/dev/null && FRAMEWORKS="Flask"

  grep -qE 'sqlalchemy|SQLAlchemy' requirements.txt pyproject.toml 2>/dev/null && DATABASE="SQLAlchemy"
  grep -qE 'prisma' requirements.txt pyproject.toml 2>/dev/null && DATABASE="Prisma"

  TESTING="pytest"
fi

# Clean up framework list
FRAMEWORKS=$(echo "$FRAMEWORKS" | sed 's/,$//' | sed 's/^,//' | xargs)

# Get project name
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Detect source directories
SRC_DIRS=""
[ -d "src" ] && SRC_DIRS="src/"
[ -d "lib" ] && SRC_DIRS="$SRC_DIRS lib/"
[ -d "app" ] && SRC_DIRS="$SRC_DIRS app/"
[ -d "pages" ] && SRC_DIRS="$SRC_DIRS pages/"
[ -d "components" ] && SRC_DIRS="$SRC_DIRS components/"

# Detect config files
CONFIG_FILES=""
[ -f "tsconfig.json" ] && CONFIG_FILES="$CONFIG_FILES tsconfig.json"
[ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] && CONFIG_FILES="$CONFIG_FILES eslint config"
[ -f "prettier.config.js" ] || [ -f ".prettierrc" ] && CONFIG_FILES="$CONFIG_FILES prettier config"
[ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && CONFIG_FILES="$CONFIG_FILES jest config"
[ -f "vitest.config.ts" ] && CONFIG_FILES="$CONFIG_FILES vitest config"

# Generate the project-specific CLAUDE.md
cat > "$PROJECT_CLAUDE" << 'HEADER'
# Project Configuration

This file extends ~/.claude/CLAUDE.md with project-specific context.
Auto-generated based on detected project structure.

---

HEADER

cat >> "$PROJECT_CLAUDE" << EOF
## Project: $PROJECT_NAME

### Stack
- **Language**: $STACK
EOF

[ -n "$FRAMEWORKS" ] && echo "- **Frameworks**: $FRAMEWORKS" >> "$PROJECT_CLAUDE"
[ -n "$DATABASE" ] && echo "- **Database/ORM**: $DATABASE" >> "$PROJECT_CLAUDE"
[ -n "$TESTING" ] && echo "- **Testing**: $TESTING" >> "$PROJECT_CLAUDE"
[ -n "$BUILD_TOOLS" ] && echo "- **Build Tools**: $BUILD_TOOLS" >> "$PROJECT_CLAUDE"

cat >> "$PROJECT_CLAUDE" << EOF

### Key Directories
EOF

[ -n "$SRC_DIRS" ] && echo "- Source: $SRC_DIRS" >> "$PROJECT_CLAUDE"
[ -d "tests" ] || [ -d "test" ] || [ -d "__tests__" ] && echo "- Tests: tests/ or __tests__/" >> "$PROJECT_CLAUDE"
[ -d "docs" ] && echo "- Documentation: docs/" >> "$PROJECT_CLAUDE"

# Add stack-specific guidance
cat >> "$PROJECT_CLAUDE" << 'EOF'

---

## Stack-Specific Guidelines

EOF

# TypeScript/Node.js specific
if [ "$STACK" = "TypeScript" ] || [ "$STACK" = "Node.js" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
### TypeScript/Node.js
- Use strict TypeScript (`strict: true` in tsconfig)
- Prefer `interface` over `type` for object shapes
- Use `unknown` over `any`, narrow with type guards
- Async/await over raw Promises
- Use named exports for better tree-shaking

### Commands
```bash
npm run dev          # Development server
npm run build        # Production build
npm test             # Run tests
npm run lint         # Lint code
npx tsc --noEmit     # Type check
```

EOF
fi

# React/Next.js specific
if echo "$FRAMEWORKS" | grep -qE 'React|Next'; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
### React Patterns
- Functional components with hooks
- Keep components small and focused
- Extract custom hooks for reusable logic
- Use React.memo() only when profiling shows need
- Prefer composition over prop drilling

EOF
fi

# Rust specific
if [ "$STACK" = "Rust" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
### Rust
- Follow Rust API guidelines
- Use `Result` for recoverable errors, `panic!` only for bugs
- Prefer `&str` over `String` in function parameters
- Use `clippy` warnings as errors
- Document public APIs with `///` comments

### Commands
```bash
cargo run            # Run project
cargo build --release # Production build
cargo test           # Run tests
cargo clippy         # Lint
cargo fmt            # Format
```

EOF
fi

# Go specific
if [ "$STACK" = "Go" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
### Go
- Follow Effective Go guidelines
- Use `error` return values, not panics
- Keep interfaces small (1-3 methods)
- Use `context.Context` for cancellation
- Table-driven tests

### Commands
```bash
go run .             # Run project
go build             # Build
go test ./...        # Run tests
go vet ./...         # Static analysis
golangci-lint run    # Lint
```

EOF
fi

# Python specific
if [ "$STACK" = "Python" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
### Python
- Use type hints (PEP 484)
- Follow PEP 8 style guide
- Use dataclasses or Pydantic for data structures
- Prefer `pathlib` over `os.path`
- Use context managers for resources

### Commands
```bash
python -m pytest     # Run tests
ruff check .         # Lint
mypy .               # Type check
black .              # Format
```

EOF
fi

# Database-specific guidance
if [ -n "$DATABASE" ]; then
cat >> "$PROJECT_CLAUDE" << EOF
### Database ($DATABASE)
- Use migrations for schema changes
- Parameterized queries only (no string concatenation)
- Index foreign keys and frequently queried columns
- Consider loading extended skill: \`skills/extended/database-integrity.md\`

EOF
fi

# Add token optimization reminder
cat >> "$PROJECT_CLAUDE" << 'EOF'
---

## Token Optimization (Project-Specific)

### Delegate These Operations
EOF

if [ "$STACK" = "TypeScript" ] || [ "$STACK" = "Node.js" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
- `npm test` -> `mcp__ultra-mcp__debug-issue`
- `npm run build` -> `mcp__ultra-mcp__debug-issue`
- Large bundle analysis -> `mcp__ultra-mcp__analyze-code`
EOF
fi

if [ "$STACK" = "Rust" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
- `cargo test` -> `mcp__ultra-mcp__debug-issue`
- `cargo build` -> `mcp__ultra-mcp__debug-issue`
- `cargo clippy` output -> `mcp__ultra-mcp__analyze-code`
EOF
fi

if [ "$STACK" = "Go" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
- `go test ./...` -> `mcp__ultra-mcp__debug-issue`
- `go build` -> `mcp__ultra-mcp__debug-issue`
EOF
fi

if [ "$STACK" = "Python" ]; then
cat >> "$PROJECT_CLAUDE" << 'EOF'
- `pytest` -> `mcp__ultra-mcp__debug-issue`
- Large log analysis -> `mcp__ultra-mcp__analyze-code`
EOF
fi

cat >> "$PROJECT_CLAUDE" << 'EOF'

### Files to Skip Reading
- `node_modules/`, `vendor/`, `target/`, `__pycache__/`
- `dist/`, `build/`, `.next/`, `out/`
- `*.lock`, `*.log`, `coverage/`
- Generated files (check .gitignore)

---

*Auto-generated. Edit to add project-specific patterns, key files, or team conventions.*
EOF

echo "PROJECT_CLAUDE_GENERATED: $PROJECT_CLAUDE"
