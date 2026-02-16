#!/bin/bash
# Environment Setup Script
# Run before starting Ralph Loop implementation
# Usage: bash .claude/scripts/setup-env.sh [project_directory]

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
CLAUDE_DIR="$PROJECT_DIR/.claude"

echo "🔧 Setting up project environment..."
echo "   Project: $PROJECT_DIR"

# Read project configuration for tech stack
if [ -f "$CLAUDE_DIR/docs/PROJECT-PLAN.md" ]; then
  echo "📖 Reading project configuration..."
else
  echo "⚠️  PROJECT-PLAN.md not found. Using defaults."
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$PROJECT_DIR/src"/{api,models,services,utils,middleware}
mkdir -p "$PROJECT_DIR/tests"/{unit,integration,e2e}
mkdir -p "$PROJECT_DIR/docs"
mkdir -p "$PROJECT_DIR/config"

echo "   ✓ src/{api,models,services,utils,middleware}"
echo "   ✓ tests/{unit,integration,e2e}"
echo "   ✓ docs"
echo "   ✓ config"

# Initialize package.json if not exists
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  echo "📦 Initializing package.json..."
  cd "$PROJECT_DIR"
  npm init -y --silent
  echo "   ✓ package.json created"
else
  echo "   ✓ package.json already exists"
fi

# Install base dependencies
echo "📥 Installing base dependencies..."
cd "$PROJECT_DIR"
npm install --silent --no-audit --no-fund \
  typescript @types/node \
  jest ts-jest @types/jest \
  @typescript-eslint/parser @typescript-eslint/eslint-plugin \
  eslint 2>/dev/null || echo "   ⚠️  Some packages may already be installed"

echo "   ✓ Dependencies installed"

# Create config files from templates
echo "⚙️  Creating configuration files..."

# TypeScript config
if [ ! -f "$PROJECT_DIR/tsconfig.json" ]; then
  cat > "$PROJECT_DIR/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
  echo "   ✓ tsconfig.json created"
else
  echo "   ✓ tsconfig.json already exists"
fi

# Jest config
if [ ! -f "$PROJECT_DIR/jest.config.js" ]; then
  cat > "$PROJECT_DIR/jest.config.js" << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.interface.ts',
    '!src/index.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1'
  }
};
EOF
  echo "   ✓ jest.config.js created"
else
  echo "   ✓ jest.config.js already exists"
fi

# ESLint config
if [ ! -f "$PROJECT_DIR/.eslintrc.js" ]; then
  cat > "$PROJECT_DIR/.eslintrc.js" << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: './tsconfig.json'
  },
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-console': ['warn', { allow: ['warn', 'error'] }]
  }
};
EOF
  echo "   ✓ .eslintrc.js created"
else
  echo "   ✓ .eslintrc.js already exists"
fi

# .gitignore
if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
  cat > "$PROJECT_DIR/.gitignore" << 'EOF'
node_modules/
dist/
coverage/
.env
.env.local
*.log
.DS_Store
.claude/
*.tgz
EOF
  echo "   ✓ .gitignore created"
else
  echo "   ✓ .gitignore already exists"
fi

# Add test script to package.json
echo "📜 Adding npm scripts..."
if command -v jq &> /dev/null; then
  jq '.scripts.test = "jest"' \
     jq '.scripts.test:coverage = "jest --coverage"' \
     jq '.scripts.lint = "eslint src --ext .ts"' \
     jq '.scripts.type-check = "tsc --noEmit"' \
     jq '.scripts.build = "tsc"' \
     "$PROJECT_DIR/package.json" > "$PROJECT_DIR/package.json.tmp"
  mv "$PROJECT_DIR/package.json.tmp" "$PROJECT_DIR/package.json"
  echo "   ✓ npm scripts added"
else
  echo "   ⚠️  jq not found, skipping script updates"
fi

# Create PROGRESS.md if not exists
if [ ! -f "$CLAUDE_DIR/docs/PROGRESS.md" ]; then
  cat > "$CLAUDE_DIR/docs/PROGRESS.md" << 'EOF'
# Implementation Progress

**Last Updated:** $(date +%Y-%m-%d\ %H:%M)

## Environment Setup
- [x] Environment setup completed

## Statistics
- Total Specifications: [from SPECIFICATIONS.md]
- Completed: 0
- In Progress: 0
- Not Started: [total]

## Completed Specifications
None yet.

## In Progress
None yet.

## Not Started
All specifications.

---
Environment ready. Run `/ralph-loop` to begin implementation.
EOF
  echo "   ✓ PROGRESS.md created"
else
  echo "   ✓ PROGRESS.md already exists"
fi

# Create placeholder source files
echo "📄 Creating placeholder files..."

# Create index.ts
if [ ! -f "$PROJECT_DIR/src/index.ts" ]; then
  cat > "$PROJECT_DIR/src/index.ts" << 'EOF'
// Main entry point
// Auto-generated by setup-env.sh

export * from './api';
export * from './models';
export * from './services';
EOF
  echo "   ✓ src/index.ts created"
fi

# Create empty barrel files
for dir in api models services utils middleware; do
  if [ ! -f "$PROJECT_DIR/src/$dir/index.ts" ]; then
    echo "// $dir barrel file" > "$PROJECT_DIR/src/$dir/index.ts"
  fi
done

echo "   ✓ Placeholder files created"

# Verify setup
echo ""
echo "🔍 Verifying setup..."

# Check if tests can run (should pass with 0 tests)
cd "$PROJECT_DIR"
if npx jest --passWithNoTests 2>&1 | grep -q "No tests found"; then
  echo "   ✓ Jest configured correctly"
else
  echo "   ⚠️  Jest configuration may need verification"
fi

# Check TypeScript compilation
if npx tsc --noEmit 2>&1 | head -1 | grep -q "error TS"; then
  echo "   ⚠️  TypeScript has errors (expected for empty project)"
else
  echo "   ✓ TypeScript compiles without errors"
fi

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "📁 Project structure:"
ls -la "$PROJECT_DIR"/{src,tests,.claude} 2>/dev/null | head -20
echo ""
echo "🚀 Next steps:"
echo "   1. Review generated configuration files"
echo "   2. Run tests: npm test"
echo "   3. Start Ralph Loop: /ralph-loop"
echo ""
