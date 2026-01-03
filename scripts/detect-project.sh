#!/bin/bash
# Project Detection Script for Lazy Skill Loading
# Called by SessionStart hook to detect project type and suggest relevant skills

PROJECT_DIR="${1:-.}"
SKILLS_TO_LOAD=()

cd "$PROJECT_DIR" 2>/dev/null || exit 0

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
  if grep -q "algorithm\|crypto\|benchmark" Cargo.toml 2>/dev/null; then
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

# Output recommendations
if [ ${#SKILLS_TO_LOAD[@]} -gt 0 ]; then
  echo "PROJECT_CONTEXT: Detected project patterns"
  echo "RECOMMENDED_SKILLS:"
  printf '%s\n' "${SKILLS_TO_LOAD[@]}" | sort -u
  echo "---"
  echo "Load with: Read ~/.claude/skills/extended/[skill-name].md"
fi
