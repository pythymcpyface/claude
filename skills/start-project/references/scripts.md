# Start Project — Helper Script Templates

Three bash scripts generated in `.claude/scripts/` during Phase 5. **Generate only — do not execute.**

---

## quality-gate.sh

```bash
#!/bin/bash
# Quality Gate Verification
# Run before each commit

echo "🔍 Running Quality Gates..."

# 1. Tests
npm test --silent 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Tests failing"
  exit 1
fi

# 2. TypeScript (if applicable)
if [ -f "tsconfig.json" ]; then
  npx tsc --noEmit 2>&1 | head -10
  if [ $? -ne 0 ]; then
    echo "❌ TypeScript errors"
    exit 1
  fi
fi

# 3. Lint
npm run lint 2>&1 | tail -5
if [ $? -ne 0 ]; then
  echo "❌ Lint errors"
  exit 1
fi

# 4. Coverage
npm run test:coverage 2>&1 | grep -E "Lines|Statements|Branches|Functions"

echo "✅ All quality gates passed"
exit 0
```

---

## validate-planning.sh

```bash
#!/bin/bash
# Planning Document Validation

BASE_DIR=".claude/docs"
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-zA-Z0-9]/-/g' || echo "main")
DOCS_DIR="$BASE_DIR/$BRANCH"
ERRORS=0

echo "🔍 Validating planning documents in $DOCS_DIR..."

# Spec-workflow outputs (Phase 0)
for doc in USER-JOURNEYS.md REQUIREMENTS.md TDD-STRATEGY.md \
           TRACEABILITY-MATRIX.md VERIFICATION-REPORT.md; do
  if [ ! -f "$DOCS_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

# Project documentation (Phases 1-5)
for doc in PROJECT-PLAN.md SPECIFICATIONS.md RISKS-AND-MITIGATIONS.md \
           IMPLEMENTATION-ROADMAP.md TDD-MASTER-DOCUMENT.md GIT-STRATEGY.md \
           TEST-FIXTURES.md INTEGRATION-TESTS.md DEPENDENCY-GRAPH.md \
           PARALLEL-GROUPS.md CRITICAL-PATH.md; do
  if [ ! -f "$DOCS_DIR/$doc" ]; then
    echo "❌ Missing: $doc"
    ERRORS=$((ERRORS + 1))
  fi
done

# Root documentation
if [ ! -f "$BASE_DIR/../CLAUDE.md" ]; then
  echo "❌ Missing: CLAUDE.md"
  ERRORS=$((ERRORS + 1))
fi

# Feature files
if [ ! -d "$DOCS_DIR/features" ]; then
  echo "❌ Missing: features/ directory"
  ERRORS=$((ERRORS + 1))
else
  FEATURE_COUNT=$(ls -1 "$DOCS_DIR/features/"*.feature 2>/dev/null | wc -l)
  if [ $FEATURE_COUNT -eq 0 ]; then
    echo "⚠️  Warning: No feature files found"
  else
    echo "✅ Found $FEATURE_COUNT feature files"
  fi
fi

if [ $ERRORS -eq 0 ]; then
  echo "✅ All planning documents validated"
  exit 0
else
  echo "❌ Found $ERRORS missing documents"
  exit 1
fi
```

---

## setup-env.sh

```bash
#!/bin/bash
# Environment Setup Script
# Run this manually after documentation is approved

set -e

echo "🚀 Setting up development environment..."

# Detect project type
if [ -f "package.json" ]; then
  echo "📦 Node.js project detected"

  # Install dependencies
  if command -v pnpm &> /dev/null; then
    echo "   Using pnpm..."
    pnpm install
  elif command -v yarn &> /dev/null; then
    echo "   Using yarn..."
    yarn install
  else
    echo "   Using npm..."
    npm install
  fi

  # Run initial build
  if grep -q '"build"' package.json; then
    echo "   Running initial build..."
    npm run build
  fi

  # Run tests to verify setup
  echo "   Running tests..."
  npm test

elif [ -f "Cargo.toml" ]; then
  echo "🦀 Rust project detected"
  cargo build
  cargo test

elif [ -f "go.mod" ]; then
  echo "🐹 Go project detected"
  go mod download
  go build ./...
  go test ./...

elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  echo "🐍 Python project detected"

  # Create virtual environment
  python3 -m venv venv
  source venv/bin/activate

  # Install dependencies
  if [ -f "pyproject.toml" ]; then
    pip install -e .
  elif [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
  fi

  # Run tests
  pytest

else
  echo "⚠️  Unknown project type"
  echo "   Please set up your environment manually"
  exit 1
fi

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "Next steps:"
echo "   1. Review documentation in .claude/docs/"
echo "   2. Begin implementation following the roadmap"
echo "   3. Run quality gates before each commit: bash .claude/scripts/quality-gate.sh"
```
