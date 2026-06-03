# Start Project — Phases

Detailed per-phase actions, stop-points, and validation steps for the `start-project` skill.

---

## Phase 0: MANDATORY Specification Workflow

**CRITICAL**: This phase is **ALWAYS EXECUTED** — no skipping, no conditionals.

### 0.1 Setup Documentation Directory

```bash
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-zA-Z0-9]/-/g' || echo "main")
DOCS_DIR=".claude/docs/$BRANCH"
mkdir -p "$DOCS_DIR"
mkdir -p "$DOCS_DIR/features"
```

### 0.2 Execute Complete 4-Phase Specification Workflow

Invoke `/spec-workflow` (or the spec-workflow skill). Run **ALL 4** phases:

#### Phase 0.1: User Journey Analysis

Map EVERY possible path through the feature with exhaustive detail.

1. **Role Discovery** — primary users, secondary users, system actors, API consumers.
2. **Goal Extraction** — for each role: goals, success/failure criteria.
3. **Entry Point Mapping** — UI routes, API endpoints, events/webhooks, CLI commands.
4. **Path Enumeration** — happy path, all decision branches, all error states with recovery, all loop-back paths.
5. **Edge Case Discovery** — empty/null/undefined inputs, max boundaries, concurrent ops, state conflicts, permission violations.
6. **Mermaid diagrams** — flowcharts for paths, sequence diagrams for interactions, state diagrams for transitions.

**Output**: `$DOCS_DIR/USER-JOURNEYS.md`

#### Phase 0.2: Requirements Extraction (EARS)

Convert journeys to atomic EARS-formatted requirements.

**EARS patterns**:
- Ubiquitous: The [system] shall [response]
- Event-Driven: When [trigger], the [system] shall [response]
- State-Driven: While [state], the [system] shall [response]
- Optional: Where [feature], the [system] shall [response]
- Unwanted: The [system] shall not [behavior]

**Actions**:
1. Convert journey steps to requirements using EARS patterns.
2. Atomic decomposition loop (3–5 iterations): can this be implemented in a single function? Split until "ridiculously small".
3. Build dependency graph.
4. Assign priorities (Must / Should / Nice).
5. Assign test IDs (TEST-XXX-YYY).

**Output**: `$DOCS_DIR/REQUIREMENTS.md`

#### Phase 0.3: TDD Strategy Generation (Gherkin)

Create executable Gherkin specifications.

1. Group requirements by feature area.
2. Create feature files for each group.
3. Generate scenarios: happy path (one per acceptance criterion), sad path (errors), edge cases (boundaries), security (credential protection).
4. Create scenario outlines for data-driven tests.
5. Map step definitions to reusable code.
6. Define test fixtures and mocks.

**Outputs**:
- `$DOCS_DIR/TDD-STRATEGY.md`
- `$DOCS_DIR/features/*.feature`

#### Phase 0.4: Traceability Verification

Ensure bidirectional traceability with no orphans.

1. Build traceability graph: Journey → Requirement → Test.
2. Forward trace: every journey has requirements, every requirement has tests.
3. Backward trace: every test maps to requirement, every requirement to journey.
4. Calculate coverage by layer, priority, and type.
5. Generate verification report with gaps and recommendations.

**Outputs**:
- `$DOCS_DIR/TRACEABILITY-MATRIX.md`
- `$DOCS_DIR/VERIFICATION-REPORT.md`

### 0.3 Stop point: present spec summary

```markdown
## Specification Workflow Complete (Phase 0)

### Documents Generated:
- ✅ USER-JOURNEYS.md ([N] journeys, [N] steps)
- ✅ REQUIREMENTS.md ([N] atomic requirements)
- ✅ TDD-STRATEGY.md ([N] test scenarios)
- ✅ features/*.feature ([N] feature files)
- ✅ TRACEABILITY-MATRIX.md
- ✅ VERIFICATION-REPORT.md

### Statistics:
- Roles: [N]
- Journeys: [N]
- Requirements: [N] (Must: [N], Should: [N])
- Test Scenarios: [N]
- Coverage: [N]%

### Verification Status: [PASS/BLOCKED]
```

## ⛔ STOP — User Approve Specs Before Continuing

Wait for explicit user confirmation ("continue" / "approve") before Phase 1.

---

## Phase 1: Read Specification Outputs

### 1.1 Read all spec-workflow outputs

```text
Read $DOCS_DIR/USER-JOURNEYS.md
Read $DOCS_DIR/REQUIREMENTS.md
Read $DOCS_DIR/TDD-STRATEGY.md
Read $DOCS_DIR/TRACEABILITY-MATRIX.md
Read $DOCS_DIR/VERIFICATION-REPORT.md
Read every $DOCS_DIR/features/*.feature
```

### 1.2 Extract key information

- **USER-JOURNEYS.md** → roles, goals, entry points, all paths
- **REQUIREMENTS.md** → EARS atomic requirements with dependencies
- **TDD-STRATEGY.md** → Gherkin scenarios, test IDs, fixtures
- **TRACEABILITY-MATRIX.md** → coverage verification, gaps
- **features/*.feature** → executable Gherkin specifications

---

## Phase 2: Generate Core Documentation

### 2.1 Create directory structure

```bash
mkdir -p .claude/docs .claude/scripts
```

### 2.2 Generate `.claude/CLAUDE.md`

Use the template in `references/templates.md` § CLAUDE.md.

### 2.3 Generate `$DOCS_DIR/PROJECT-PLAN.md`

Synthesize from spec-workflow outputs. Use the template in `references/templates.md` § PROJECT-PLAN.

### 2.4 Generate `$DOCS_DIR/GIT-STRATEGY.md`

Use the template in `references/templates.md` § GIT-STRATEGY (branching model, commit conventions, workflow per spec, code review process, release management, emergency procedures, git hooks, repository hygiene).

---

## Phase 3: Generate Atomic Specifications (Iterate 3–5 Times)

### 3.1 Initial specification generation

Transform `REQUIREMENTS.md` into detailed `SPECIFICATIONS.md`. Each spec contains: User Story, Acceptance Criteria, Functional Specification (Input / Processing / Output / Database / API / Error Handling / Edge Cases), Performance Requirements, Security Requirements, Safety & Reliability, Testing Requirements, Dependencies (Requires / Required by). Template: `references/templates.md` § SPECIFICATIONS.

### 3.2 Iterative refinement (3–5 passes)

For each iteration:
1. Read current `SPECIFICATIONS.md`.
2. Challenge each spec:
   - Can this be split into smaller units?
   - Are all edge cases from `USER-JOURNEYS.md` covered?
   - Are all error conditions from `TDD-STRATEGY.md` addressed?
   - Can this be implemented in 15–30 minutes?
3. Split specs that are too complex.
4. Update dependencies after splitting.
5. Track iteration count.

### 3.3 Stop criteria

Stop iterating when:
- Specs are "ridiculously small" — single function or small set of functions.
- No further meaningful decomposition is possible.
- All edge cases from journeys are covered.
- All test scenarios from `TDD-STRATEGY.md` are mapped.

---

## Phase 4: Generate Supporting Documentation

For each artifact below, use the matching template in `references/templates.md`.

| 4.x | Document | Source data |
|---|---|---|
| 4.1 | `DEPENDENCY-GRAPH.md` | Parse `SPECIFICATIONS.md` dependencies |
| 4.2 | `PARALLEL-GROUPS.md` | Specs with identical dependency sets |
| 4.3 | `CRITICAL-PATH.md` | Specs that block the most others |
| 4.4 | `TEST-FIXTURES.md` | Extract from `TDD-STRATEGY.md` |
| 4.5 | `INTEGRATION-TESTS.md` | Cross-spec workflows from `USER-JOURNEYS.md` |
| 4.6 | `RISKS-AND-MITIGATIONS.md` | Synthesize from all spec docs |
| 4.7 | `PROJECT-PLAN.md` (v2) | Update with critical path, risks, parallel groups, quality gates |
| 4.8 | `IMPLEMENTATION-ROADMAP.md` | Step-by-step guide with checkpoints |
| 4.9 | `TDD-MASTER-DOCUMENT.md` | Consolidate all test specs |

---

## Phase 5: Generate Helper Scripts

Generate three scripts in `.claude/scripts/`. Templates in `references/scripts.md`.

| Script | Purpose |
|---|---|
| `quality-gate.sh` | Verify tests, types, lint, coverage before commit |
| `validate-planning.sh` | Confirm all 17 documents exist |
| `setup-env.sh` | Detect project type and install dependencies (manual, not auto-run) |

**Do NOT execute these scripts.** Only generate them.

---

## Phase 6: Validate All Documentation

### 6.1 Run validation

```bash
bash .claude/scripts/validate-planning.sh
```

### 6.2 Manual checklist

- [ ] All 17 documents exist (6 from spec-workflow + 11 project docs)
- [ ] Each SPEC-XXX has corresponding tests in `TDD-MASTER-DOCUMENT.md`
- [ ] Each TEST-XXX-YYY maps to a Gherkin scenario in `features/*.feature`
- [ ] All dependencies in `DEPENDENCY-GRAPH.md` resolve (no broken references)
- [ ] No circular dependencies
- [ ] Each spec has time estimate in `IMPLEMENTATION-ROADMAP.md`
- [ ] All risks have mitigations in `RISKS-AND-MITIGATIONS.md`
- [ ] Checkpoints defined in `IMPLEMENTATION-ROADMAP.md`
- [ ] Integration tests cover critical workflows from `USER-JOURNEYS.md`
- [ ] `TRACEABILITY-MATRIX.md` shows 100% coverage
- [ ] All Gherkin scenarios have corresponding test specifications

### 6.3 If validation fails

Fix issues and re-validate until all checks pass.

---

## Phase 7: Present Complete Summary (THEN HARD STOP)

After validation passes, present this summary, then **ABSOLUTELY STOP. NO MORE ACTIONS.**

```markdown
## COMPREHENSIVE DOCUMENTATION GENERATION COMPLETE

### Phase 0: Specification Workflow (6 documents)
- ✅ `.claude/docs/$BRANCH/USER-JOURNEYS.md` — [N] journeys, [N] steps
- ✅ `.claude/docs/$BRANCH/REQUIREMENTS.md` — [N] atomic EARS requirements
- ✅ `.claude/docs/$BRANCH/TDD-STRATEGY.md` — [N] test scenarios
- ✅ `.claude/docs/$BRANCH/features/*.feature` — [N] Gherkin feature files
- ✅ `.claude/docs/$BRANCH/TRACEABILITY-MATRIX.md` — 100% coverage verification
- ✅ `.claude/docs/$BRANCH/VERIFICATION-REPORT.md` — Quality assurance

### Phase 1–5: Project Documentation (11 documents + root)
- ✅ `.claude/CLAUDE.md` — Project configuration
- ✅ `.claude/docs/$BRANCH/PROJECT-PLAN.md` (v2)
- ✅ `.claude/docs/$BRANCH/SPECIFICATIONS.md` — [N] atomic specifications
- ✅ `.claude/docs/$BRANCH/RISKS-AND-MITIGATIONS.md`
- ✅ `.claude/docs/$BRANCH/IMPLEMENTATION-ROADMAP.md`
- ✅ `.claude/docs/$BRANCH/TDD-MASTER-DOCUMENT.md`
- ✅ `.claude/docs/$BRANCH/TEST-FIXTURES.md`
- ✅ `.claude/docs/$BRANCH/INTEGRATION-TESTS.md`
- ✅ `.claude/docs/$BRANCH/DEPENDENCY-GRAPH.md`
- ✅ `.claude/docs/$BRANCH/PARALLEL-GROUPS.md`
- ✅ `.claude/docs/$BRANCH/CRITICAL-PATH.md`
- ✅ `.claude/docs/$BRANCH/GIT-STRATEGY.md`

### Helper Scripts (3 files)
- ✅ `.claude/scripts/setup-env.sh`
- ✅ `.claude/scripts/quality-gate.sh`
- ✅ `.claude/scripts/validate-planning.sh`

### Statistics:
- Total Documents: 17 (6 spec-workflow + 11 project docs)
- Total Scripts: 3
- Specification Iterations: [N]
- Total Specifications: [N]
- Critical Path Specs: [N]
- Parallel Groups: [N]
- Total Test Cases: [N]
- Integration Tests: [N]
- Gherkin Scenarios: [N]
- User Journeys: [N]
- EARS Requirements: [N]
- Traceability Coverage: 100%

### Validation: ✅ PASSED

---

## ⛔ DOCUMENTATION GENERATION COMPLETE ⛔

This skill is now COMPLETE. NO further actions will be taken.

### Next Steps (manual):

**Step 1: Review the documentation**

**Step 2: Environment Setup (when ready)**
\`\`\`bash
bash .claude/scripts/setup-env.sh
\`\`\`

**Step 3: Begin Implementation (when ready)**
Follow `IMPLEMENTATION-ROADMAP.md`:
- Start with critical path specifications
- Implement in dependency order
- Run quality gates before each commit
- Follow TDD approach (tests first)
- Verify against Gherkin scenarios
```

### Forbidden after Phase 7

- ❌ Create source files (src/, tests/, config files)
- ❌ Install dependencies (npm/yarn/pnpm/cargo/pip/go)
- ❌ Run build commands
- ❌ Run test commands
- ❌ Execute ANY bash beyond `mkdir` for `.claude/`
- ❌ Begin implementation automatically
