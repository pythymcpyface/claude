# code-quality-review — Detailed Checklists

Full checklist tables, search patterns, and per-category guidance for code-quality-review. SKILL.md routes here when running the review workflow.


### Phase 1: Stack Detection

Detect the project's technology stack and quality tools:

```bash
# Detect stack
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt pom.xml build.gradle 2>/dev/null || echo "Unknown stack"

# Detect linters
ls .eslintrc* .prettierrc* .pylintrc setup.cfg flake8 ruff.toml .golangci.yml checkstyle.xml 2>/dev/null

# Detect type checkers
grep -r "typescript\|mypy\|pyright\|golangci-lint" package.json requirements.txt go.mod pyproject.toml 2>/dev/null

# Detect test frameworks
grep -r "jest\|vitest\|pytest\|go test\|junit" package.json requirements.txt go.mod pom.xml 2>/dev/null

# Check for strict mode configurations
grep -r "strict\|strictNullChecks\|noImplicitAny\|strict=True" tsconfig.json pyproject.toml setup.cfg 2>/dev/null
```

### Phase 2: Code Quality Checklist

Run all checks and compile results:

#### 1. SOLID Principles Compliance

| Check | Pattern | Status |
|-------|---------|--------|
| Single Responsibility | Classes/functions have one reason to change | Required |
| Open/Closed | Open for extension, closed for modification | Required |
| Liskov Substitution | Subtypes substitutable for base types | Required |
| Interface Segregation | Small, focused interfaces | Required |
| Dependency Inversion | Depend on abstractions, not concretions | Required |
| Class size | Classes under 300 lines | Recommended |
| Method size | Methods under 30 lines | Recommended |
| Parameter count | Functions with max 4-5 parameters | Recommended |

**Search Patterns:**
```bash
# Find large classes (potential SRP violations)
find . -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -20

# Find long functions
grep -rE "function|def |func |void |public |private " --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -50

# Find deep nesting (potential complexity)
grep -rE "^\s{16,}" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -20

# Find god classes (too many methods)
grep -rE "(class|interface|struct).*\{" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -30

# Find hardcoded dependencies (DIP violation)
grep -rE "new [A-Z][a-zA-Z]+\(|import.*concrete|from.*concrete" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -20

# Find large interfaces (ISP violation)
grep -rE "interface.*\{" --include="*.ts" --include="*.go" --include="*.java" 2>/dev/null | head -20
```

#### 2. Linting Standards

| Check | Pattern | Status |
|-------|---------|--------|
| Linter configured | ESLint, Pylint, Golangci-lint, etc. | Required |
| Linter passes | No errors in linter output | Required |
| Formatting standard | Prettier, Black, gofmt, etc. | Required |
| Pre-commit hooks | Linting runs on commit | Recommended |
| CI lint check | Linting in CI pipeline | Required |
| Custom rules | Project-specific lint rules | Recommended |
| Deprecated patterns | No use of deprecated syntax | Required |

**Search Patterns:**
```bash
# Check for linter config
find . -name ".eslintrc*" -o -name ".pylintrc" -o -name ".golangci.yml" -o -name "checkstyle.xml" -o -name "ruff.toml" 2>/dev/null | head -10

# Check for formatter config
find . -name ".prettierrc*" -o -name ".editorconfig" -o -name "pyproject.toml" -o -name ".clang-format" 2>/dev/null | head -10

# Run linter (TypeScript)
npx eslint . --ext .ts,.tsx 2>&1 | head -50

# Run linter (Python)
python -m pylint **/*.py 2>&1 | head -50 || ruff check . 2>&1 | head -50

# Run linter (Go)
golangci-lint run 2>&1 | head -50

# Check for pre-commit hooks
ls -la .git/hooks/pre-commit .pre-commit-config.yaml 2>/dev/null

# Check CI config for lint steps
grep -r "lint\|eslint\|pylint\|golangci" .github/workflows/* .gitlab-ci.yml .circleci/config.yml 2>/dev/null | head -20
```

#### 3. Code Review Readiness

| Check | Pattern | Status |
|-------|---------|--------|
| Descriptive naming | Variables/functions clearly named | Required |
| Comments explain WHY | Comments explain intent, not what | Required |
| No commented code | Dead code removed, not commented | Required |
| Consistent style | Follows project style guide | Required |
| No magic numbers | Constants with descriptive names | Required |
| Error messages clear | Actionable error messages | Required |
| Documentation | Complex logic documented | Recommended |
| Self-documenting code | Code readable without comments | Required |

**Search Patterns:**
```bash
# Find commented-out code
grep -rE "^\s*//.*[;{}]\s*$|^\s*#.*[;{}]\s*$|^\s*/\*.*\*/\s*$" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -20

# Find magic numbers
grep -rE "[^a-zA-Z_][0-9]{2,}[^0-9]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find unclear variable names
grep -rE "\b(x|y|z|temp|tmp|data|val|var|str|num|int)\s*[=:]" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find TODO/FIXME without issue reference
grep -rE "TODO|FIXME|HACK|XXX" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find missing documentation on public APIs
grep -rE "^(export )?(function|class|interface|def )" --include="*.ts" --include="*.py" --include="*.go" 2>/dev/null | head -30

# Find long parameter lists
grep -rE "function\s*\([^)]{50,}\)|def\s+\w+\([^)]{50,}\)" --include="*.ts" --include="*.py" 2>/dev/null | head -20
```

#### 4. Redundant Code Detection

| Check | Pattern | Status |
|-------|---------|--------|
| No duplicate code | DRY principle followed | Required |
| No unused imports | All imports used | Required |
| No unused variables | All variables used | Required |
| No dead code | Unreachable code removed | Required |
| No redundant conditions | Simplified conditionals | Required |
| No copy-paste patterns | Abstractions for repeated code | Required |
| Minimal code | Simplest solution that works | Recommended |

**Search Patterns:**
```bash
# Find duplicate code blocks (simple heuristic)
find . -name "*.ts" -o -name "*.py" -o -name "*.go" 2>/dev/null | xargs -I {} sh -c 'echo "=== {} ===" && cat {}' 2>/dev/null | sort | uniq -d | head -20

# Find unused imports (TypeScript)
npx ts-prune 2>&1 | head -30 || npx unimported 2>&1 | head -30

# Find unused imports (Python)
python -m autoflake --remove-all-unused-imports --check . 2>&1 | head -30

# Find unused variables (Go)
go vet ./... 2>&1 | grep "declared but not used" | head -20

# Find dead code with static analysis
npx knip 2>&1 | head -50

# Find redundant conditions
grep -rE "if\s*\(\s*true\s*\)|if\s*\(\s*false\s*\)|if\s*\(\s*!\s*false\s*\)" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Find empty blocks
grep -rE "\{\s*\}|\:\s*pass\s*$" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20

# Find repeated code patterns (similar function names)
grep -rE "function|def |func " --include="*.ts" --include="*.py" --include="*.go" 2>/dev/null | grep -E "get|fetch|load|read|retrieve" | head -30
```

#### 5. Type Safety

| Check | Pattern | Status |
|-------|---------|--------|
| Strict mode enabled | TypeScript strict, mypy strict | Required |
| No any types | Explicit types, no `any`/`object` | Required |
| Null safety | Proper null/undefined handling | Required |
| Return types | Functions have explicit return types | Required |
| Type coverage | >90% type coverage | Required |
| Runtime validation | Input validation with types | Required |
| Generic constraints | Proper generic typing | Recommended |

**Search Patterns:**
```bash
# Check TypeScript strict mode
cat tsconfig.json 2>/dev/null | grep -E "strict|noImplicitAny|strictNullChecks"

# Find any types (TypeScript)
grep -rE ": any\b|as any\b|<any>" --include="*.ts" --include="*.tsx" 2>/dev/null | head -30

# Find missing type annotations (Python)
grep -rE "def\s+\w+\([^)]*\)\s*:" --include="*.py" 2>/dev/null | grep -v "->" | head -30

# Find type assertions (potential type safety issues)
grep -rE "as\s+[A-Z]|@ts-ignore|@ts-expect-error|# type: ignore" --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null | head -20

# Find null/undefined issues
grep -rE "!\.|\?\.\?|null\s*!|undefined\s*!" --include="*.ts" --include="*.tsx" 2>/dev/null | head -20

# Check mypy configuration
cat pyproject.toml setup.cfg mypy.ini 2>/dev/null | grep -E "strict|disallow|warn"

# Run type checker (TypeScript)
npx tsc --noEmit 2>&1 | head -50

# Run type checker (Python)
python -m mypy . --strict 2>&1 | head -50

# Find missing return types
grep -rE "function\s+\w+\s*\([^)]*\)\s*\{" --include="*.ts" 2>/dev/null | grep -v ": " | head -20
```

#### 6. Language-Specific Checks

**TypeScript/JavaScript:**
| Check | Pattern | Status |
|-------|---------|--------|
| strictNullChecks | Enabled in tsconfig | Required |
| noImplicitAny | Enabled in tsconfig | Required |
| noUnusedLocals | No unused variables | Required |
| noUnusedParameters | No unused parameters | Required |
| exactOptionalPropertyTypes | Strict optional properties | Recommended |
| noImplicitReturns | All code paths return | Required |

**Python:**
| Check | Pattern | Status |
|-------|---------|--------|
| Type hints | All functions have type hints | Required |
| mypy strict | Strict mypy configuration | Required |
| pyright strict | Pyright strict mode | Recommended |
| No bare except | Specific exception types | Required |
| f-strings | Modern string formatting | Recommended |

**Go:**
| Check | Pattern | Status |
|-------|---------|--------|
| go vet | Passes go vet | Required |
| errcheck | Errors are checked | Required |
| gofmt | Code is formatted | Required |
| goimports | Imports are organized | Required |
| staticcheck | Passes staticcheck | Recommended |

**Java:**
| Check | Pattern | Status |
|-------|---------|--------|
| NullAway | Null safety checker | Recommended |
| Error Prone | Static analysis | Recommended |
| Checkstyle | Style compliance | Required |
| SpotBugs | Bug pattern detection | Recommended |

**Search Patterns:**
```bash
# TypeScript config check
cat tsconfig.json 2>/dev/null | jq '.compilerOptions | {strict, noImplicitAny, strictNullChecks, noUnusedLocals}'

# Python type hint coverage
grep -rE "def\s+\w+\s*\(" --include="*.py" 2>/dev/null | wc -l
grep -rE "def\s+\w+\s*\([^)]*\)\s*->" --include="*.py" 2>/dev/null | wc -l

# Go vet
go vet ./... 2>&1 | head -30

# Java Checkstyle
cat checkstyle.xml 2>/dev/null | head -50
```

---

### Phase 3: Gap Analysis

For each failed check, provide:

1. **What's missing**: Specific code quality gap
2. **Why it matters**: Impact on maintainability and reliability
3. **How to fix**: Concrete implementation guidance with code examples
4. **Priority**: Critical / High / Medium / Low

---

### Phase 4: Output Report

Generate a comprehensive report:

```
═══════════════════════════════════════════════════════════════
         CODE QUALITY PRODUCTION READINESS REPORT
═══════════════════════════════════════════════════════════════
Project: [name]
Stack: [detected stack]
Type Safety: [strict/loose/none]
Date: [timestamp]

OVERALL SCORE: [X/100] [PASS/NEEDS WORK/BLOCK]

───────────────────────────────────────────────────────────────
                    CHECKLIST RESULTS
───────────────────────────────────────────────────────────────

SOLID PRINCIPLES (30% weight)
  [FAIL] Single Responsibility - UserService has 15 methods
  [PASS] Open/Closed - Uses interfaces for extension
  [WARN] Liskov Substitution - Potential subtype issue in PaymentProcessor
  [PASS] Interface Segregation
  [WARN] Dependency Inversion - Direct instantiation in OrderService
  [WARN] Large class detected - UserService.ts (450 lines)

LINTING STANDARDS (20% weight)
  [PASS] ESLint configured
  [FAIL] 12 linting errors found
  [PASS] Prettier configured
  [PASS] Pre-commit hooks active
  [PASS] CI lint check present

CODE REVIEW READINESS (25% weight)
  [PASS] Descriptive naming conventions
  [FAIL] 8 instances of commented-out code
  [FAIL] Magic numbers without constants (5 found)
  [PASS] No TODO without issue references
  [WARN] Missing documentation on public APIs (3 functions)

REDUNDANT CODE (10% weight)
  [FAIL] Duplicate code block in handlers (35 lines)
  [FAIL] 4 unused imports detected
  [PASS] No unused variables
  [PASS] No dead code paths

TYPE SAFETY (15% weight)
  [FAIL] TypeScript strict mode not fully enabled
  [FAIL] 15 uses of 'any' type
  [WARN] 3 @ts-ignore comments
  [PASS] Null safety checks present
  [FAIL] 5 functions missing return types

───────────────────────────────────────────────────────────────
                    GAP ANALYSIS
───────────────────────────────────────────────────────────────

[CRITICAL] Single Responsibility Violation in UserService
  Impact: Difficult to test, maintain, and understand
  Fix: Split into UserAuthentication, UserProfile, UserPermissions
  File: src/services/UserService.ts

  // BEFORE (violates SRP):
  class UserService {
    login() {}
    logout() {}
    updateProfile() {}
    changePassword() {}
    assignRole() {}
    revokeAccess() {}
    // ... 10 more methods
  }

  // AFTER (follows SRP):
  class AuthenticationService {
    login() {}
    logout() {}
    changePassword() {}
  }

  class UserProfileService {
    updateProfile() {}
    getProfile() {}
  }

  class UserAuthorizationService {
    assignRole() {}
    revokeAccess() {}
  }

[HIGH] 12 Linting Errors
  Impact: Inconsistent code style, potential bugs
  Fix: Run `npx eslint --fix` and address remaining errors
  Action: npm run lint:fix && npm run lint

[HIGH] TypeScript Strict Mode Disabled
  Impact: Type errors slip through to runtime
  Fix: Enable all strict options in tsconfig.json
  File: tsconfig.json

  {
    "compilerOptions": {
      "strict": true,
      "noImplicitAny": true,
      "strictNullChecks": true,
      "noUnusedLocals": true,
      "noUnusedParameters": true,
      "noImplicitReturns": true
    }
  }

[HIGH] 15 Uses of 'any' Type
  Impact: Loss of type safety, potential runtime errors
  Fix: Replace with proper types or 'unknown' with type guards
  File: src/utils/parser.ts (5), src/api/handlers.ts (6), src/services/data.ts (4)

  // BEFORE (unsafe):
  function parseData(input: any): any {
    return JSON.parse(input);
  }

  // AFTER (type-safe):
  interface UserData {
    id: string;
    name: string;
    email: string;
  }

  function parseData(input: string): UserData {
    const data = JSON.parse(input);
    if (!isValidUserData(data)) {
      throw new Error('Invalid user data');
    }
    return data;
  }

  function isValidUserData(data: unknown): data is UserData {
    return typeof data === 'object'
      && typeof data.id === 'string'
      && typeof data.name === 'string'
      && typeof data.email === 'string';
  }

[MEDIUM] Duplicate Code Block in Handlers
  Impact: Maintenance burden, bug propagation
  Fix: Extract to shared utility function
  Files: src/handlers/user.ts, src/handlers/admin.ts

  // BEFORE (duplicate):
  // user.ts
  const validateInput = (data) => { /* 35 lines */ };
  // admin.ts
  const validateInput = (data) => { /* 35 lines */ };

  // AFTER (DRY):
  // utils/validation.ts
  export const validateInput = (data: unknown): ValidationResult => {
    // Shared implementation
  };

[MEDIUM] Commented-Out Code
  Impact: Code smell, confusion about intent
  Fix: Remove or document why it's preserved
  Files: src/legacy/adapter.ts (5), src/utils/formatter.ts (3)

  # Remove all commented code - git preserves history
  git rm src/legacy/adapter.ts

[MEDIUM] Magic Numbers Without Constants
  Impact: Unclear meaning, difficult to change
  Fix: Extract to named constants
  File: src/utils/calculator.ts

  // BEFORE (magic numbers):
  const result = value * 1.0825 + 5.99;

  // AFTER (named constants):
  const TAX_RATE = 1.0825;
  const SHIPPING_FEE = 5.99;
  const result = value * TAX_RATE + SHIPPING_FEE;

[LOW] Missing Return Type Annotations
  Impact: Reduced type inference clarity
  Fix: Add explicit return types to public functions
  File: src/api/controllers.ts

  // BEFORE:
  export function getUser(id: string) {
    return db.users.find(id);
  }

  // AFTER:
  export function getUser(id: string): Promise<User | null> {
    return db.users.find(id);
  }

───────────────────────────────────────────────────────────────
                  RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Before Production Release:
1. [CRITICAL] Refactor UserService to follow SRP
2. [HIGH] Enable TypeScript strict mode and fix all errors
3. [HIGH] Replace all 'any' types with proper types
4. [HIGH] Fix all linting errors
5. [MEDIUM] Extract duplicate code to shared utilities
6. [MEDIUM] Remove commented-out code
7. [MEDIUM] Replace magic numbers with constants

After Production:
1. Add explicit return types to all public functions
2. Add inline documentation for complex algorithms
3. Set up automated code complexity tracking
4. Configure SonarQube or similar quality gate
5. Add code coverage threshold (>80%)

═══════════════════════════════════════════════════════════════
```

---

