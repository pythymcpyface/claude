#!/bin/bash
# Project Detection Script for Lazy Skill Loading
# Called by SessionStart hook to detect project type and suggest relevant skills

PROJECT_DIR="${1:-.}"
CACHE_DIR="$PROJECT_DIR/.claude"
CACHE_FILE="$CACHE_DIR/.cache_hash"
SKILLS_TO_LOAD=()

cd "$PROJECT_DIR" 2>/dev/null || exit 0

# 1. Check if this is a project at all
if [ ! -f "package.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ] && [ ! -f "pyproject.toml" ] && [ ! -f "requirements.txt" ]; then
  exit 0
fi

# 2. Calculate Hash
calculate_hash() {
  local hash_input=""
  
  # Hash content of key files
  for f in package.json Cargo.toml go.mod pyproject.toml requirements.txt; do
    if [ -f "$f" ]; then
      hash_input+="$(cat "$f")"
    fi
  done
  
  # Hash existence of config files
  for f in prisma/schema.prisma drizzle.config.ts knexfile.js playwright.config.ts playwright.config.js cypress.config.ts cypress.config.js; do
    if [ -f "$f" ]; then
      hash_input+":$f"
    fi
  done

  # Hash existence of directories
  if [ -d "cypress" ]; then hash_input+":cypress_dir"; fi
  
  # Use md5 (macOS) or md5sum (Linux)
  if command -v md5 >/dev/null 2>&1; then
    echo "$hash_input" | md5
  elif command -v md5sum >/dev/null 2>&1;
    echo "$hash_input" | md5sum | awk '{print $1}'
  else
    echo "$hash_input" | cksum | awk '{print $1}'
  fi
}

CURRENT_HASH=$(calculate_hash)

# 3. Check Cache
if [ -f "$CACHE_FILE" ]; then
  CACHED_HASH=$(cat "$CACHE_FILE")
  if [ "$CURRENT_HASH" = "$CACHED_HASH" ]; then
    # No changes, exit silently
    exit 0
  fi
fi

# 4. Run Detection (Only if cache miss or changed)

# Database/ORM Detection
if [ -f "prisma/schema.prisma" ] || [ -f "drizzle.config.ts" ] || [ -f "knexfile.js" ]; then
  SKILLS_TO_LOAD+=("database-integrity")
fi

if grep -q "typeorm\|sequelize\|mongoose" package.json 2>/dev/null; then
  SKILLS_TO_LOAD+=("database-integrity")
fi

if [ -f "Cargo.toml" ] && grep -q "sqlx\|diesel\|sea-orm" Cargo.toml 2>/dev/null; then
  SKILLS_TO_LOAD+=("database-integrity")
fi

# E2E Testing Detection
if [ -f "playwright.config.ts" ] || [ -f "playwright.config.js" ]; then
  SKILLS_TO_LOAD+=("generate-e2e-tests")
fi

if [ -f "cypress.config.ts" ] || [ -f "cypress.config.js" ] || [ -d "cypress" ]; then
  SKILLS_TO_LOAD+=("generate-e2e-tests")
fi

# Algorithm-heavy Detection (Rust/Go/performance-critical)
if [ -f "Cargo.toml" ]; then
  if grep -q "algorithm\|crypto\|benchmark" Cargo.toml 2>/dev/null;
    SKILLS_TO_LOAD+=("algorithm-validation")
  fi
fi

# Error Handling Systems Detection
if grep -q "circuit.breaker\|retry\|backoff\|resilience" package.json 2>/dev/null; then
  SKILLS_TO_LOAD+=("error-classification-recovery")
fi

# Adaptive/Performance Systems
if grep -q "rate.limit\|throttle\|cache\|redis" package.json 2>/dev/null; then
  SKILLS_TO_LOAD+=("adaptive-optimization")
fi

# 5. Output recommendations and update cache
if [ ${#SKILLS_TO_LOAD[@]} -gt 0 ]; then
  echo "PROJECT_CONTEXT: Detected project patterns"
  echo "RECOMMENDED_SKILLS:"
  printf '%s\n' "${SKILLS_TO_LOAD[@]}" | sort -u
  echo "---"
  echo "Load with: Read ~/.claude/skills/extended/[skill-name].md"
fi

# Ensure .claude directory exists in the project before writing cache
mkdir -p "$CACHE_DIR"
echo "$CURRENT_HASH" > "$CACHE_FILE"