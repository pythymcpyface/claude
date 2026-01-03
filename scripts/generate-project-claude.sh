#!/bin/bash
# Generate Project-Specific CLAUDE.md
# Called by SessionStart hook when entering a project directory
# Creates .claude/CLAUDE.md if it doesn't exist

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
PROJECT_CLAUDE="$CLAUDE_DIR/CLAUDE.md"
TRAITS_DIR="$HOME/.claude/templates/traits"

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

# ==========================================
# GENERATE CLAUDE.md from TRAITS
# ==========================================

# 1. Header
if [ -f "$TRAITS_DIR/common-header.md" ]; then
  cat "$TRAITS_DIR/common-header.md" > "$PROJECT_CLAUDE"
else
  echo "# Project Configuration" > "$PROJECT_CLAUDE"
fi

# 2. Project Specifics (Dynamic)
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

echo "" >> "$PROJECT_CLAUDE"

# 3. Critical Constraints
if [ -f "$TRAITS_DIR/critical-constraints.md" ]; then
  cat "$TRAITS_DIR/critical-constraints.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

# 4. Stack Specific Guidelines
if [ "$STACK" = "TypeScript" ] || [ "$STACK" = "Node.js" ]; then
  if [ -f "$TRAITS_DIR/stack-node.md" ]; then
    cat "$TRAITS_DIR/stack-node.md" >> "$PROJECT_CLAUDE"
    echo "" >> "$PROJECT_CLAUDE"
  fi
elif [ "$STACK" = "Rust" ]; then
  if [ -f "$TRAITS_DIR/stack-rust.md" ]; then
    cat "$TRAITS_DIR/stack-rust.md" >> "$PROJECT_CLAUDE"
    echo "" >> "$PROJECT_CLAUDE"
  fi
elif [ "$STACK" = "Go" ]; then
  if [ -f "$TRAITS_DIR/stack-go.md" ]; then
    cat "$TRAITS_DIR/stack-go.md" >> "$PROJECT_CLAUDE"
    echo "" >> "$PROJECT_CLAUDE"
  fi
elif [ "$STACK" = "Python" ]; then
  if [ -f "$TRAITS_DIR/stack-python.md" ]; then
    cat "$TRAITS_DIR/stack-python.md" >> "$PROJECT_CLAUDE"
    echo "" >> "$PROJECT_CLAUDE"
  fi
fi

# 5. Token Optimization & Delegation
if [ -f "$TRAITS_DIR/token-optimization.md" ]; then
  cat "$TRAITS_DIR/token-optimization.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

if [ -f "$TRAITS_DIR/delegation.md" ]; then
  cat "$TRAITS_DIR/delegation.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

# 6. Memory
if [ -f "$TRAITS_DIR/memory.md" ]; then
  cat "$TRAITS_DIR/memory.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

# 7. Dynamic Context
if [ -f "$TRAITS_DIR/dynamic-context.md" ]; then
  cat "$TRAITS_DIR/dynamic-context.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

# 8. Available Commands
if [ -f "$TRAITS_DIR/available-commands.md" ]; then
  cat "$TRAITS_DIR/available-commands.md" >> "$PROJECT_CLAUDE"
  echo "" >> "$PROJECT_CLAUDE"
fi

# 9. Files to Skip (Dynamic based on stack)
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