# Autonomous Development Guide

Complete guide for autonomous TDD development using Claude Code and Ralph Loop.

---

## Quick Start

```bash
# 1. Start Claude Code with autonomous permissions
claude --dangerously-skip-permissions

# 2. Navigate to your project and start
cd /path/to/project
claude

# 3. Load the autonomous flow and start planning
"Read .claude/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md and execute Phase 1"
```

---

## The Process Overview

```
Planning Phase (Opus, 3-5 breakdown iterations)
│
├─ Requirements Gathering → User input, domain exploration
├─ Project Plan v1 → Architecture, tech stack, timeline
├─ Specification Breakdown → Break down until atomic (3-5 passes)
├─ Risks & Mitigations → Clinical, technical, operational risks
├─ Project Plan v2 → Updated with risks and contingencies
├─ Junior-Developer Roadmap → Step-by-step implementation guide
├─ Final Specification Review → One more breakdown pass
└─ TDD Master Document → Every test case for every spec
│
▼
Ralph Loop Implementation (autonomous TDD execution)
```

---

## Complete Example: Notes API

Follow along with the notes-app project example.

### Step 1: Start Claude Code

```bash
cd ~/Documents/nodeprojects/claude/notes-app
claude --dangerously-skip-permissions
```

### Step 2: Copy the Planning Flow

```bash
# Copy autonomous flow to your project
cp ~/.claude/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md .claude/docs/
```

### Step 3: Start Planning - Phase 1

In Claude Code:

```
Read .claude/docs/AUTONOMOUS-DEVELOPMENT-FLOW.md

Execute Phase 1 for a notes API with these requirements:
- Lightweight REST API
- Node.js, TypeScript, Fastify framework
- In-memory data storage
- CRUD operations for notes
- Title (required, max 200 chars), content (optional, max 5000 chars)
- Output <promise>PHASE_1_COMPLETE</promise> when ready
```

Claude will gather requirements, explore the domain, and create the initial PROJECT-PLAN.md.

### Step 4: Continue Through Planning Phases

After Phase 1 completes, continue:

```
Continue with Phase 2 (already done as part of Phase 1)
Then execute Phase 3: First pass specification breakdown
```

Keep prompting Claude through each phase:

```
Continue to Phase 3: Second pass atomic specification breakdown
Continue to Phase 3: Third pass junior-developer clarity check
Continue to Phase 3: Fourth/fifth pass - question everything
```

```
Execute Phase 4: Create Risks & Mitigations document
```

```
Execute Phase 5: Update Project Plan to v2 with risks
```

```
Execute Phase 6: Create Junior-Developer Roadmap
```

```
Execute Phase 7: Final specification review pass
```

```
Execute Phase 8: Create TDD Master Document
```

### Step 5: Start Ralph Loop Implementation

Once all planning is complete:

```
/ralph-loop "
You are implementing a notes API using strict TDD.

# MANDATORY READING
1. .claude/docs/PROJECT-PLAN.md
2. .claude/docs/SPECIFICATIONS.md
3. .claude/docs/RISKS-AND-MITIGATIONS.md
4. .claude/docs/IMPLEMENTATION-ROADMAP.md
5. .claude/docs/TDD-MASTER-DOCUMENT.md

# STRICT TDD
For each specification:
1. Read specification and tests from TDD-MASTER-DOCUMENT.md
2. Write failing tests
3. Run: npm test (verify red)
4. Implement minimal code to pass
5. Run: npm test (verify green)
6. Update PROGRESS.md
7. git commit -m \"feat(spec-XXX): [title]\"

Output <promise>NOTES_API_COMPLETE</promise> when all specs implemented and tests pass.
" --max-iterations 100
```

---

## Claude Code Commands Reference

| Command | Purpose |
|---------|---------|
| `/ralph-loop "PROMPT" --max-iterations N` | Start autonomous loop |
| `/cancel-ralph` | Cancel active loop |
| `/review-pr` | Comprehensive PR review |
| `/commit` | Create commit with auto-generated message |
| `/usage` | Check token usage (Z.AI quota) |

---

## Monitoring Progress

While Ralph Loop runs, monitor in separate terminals:

```bash
# Watch progress
watch -n 2 cat .claude/docs/PROGRESS.md

# Check iteration count
head -10 .claude/ralph-loop.local.md

# Watch git history
watch -n 2 "git log --oneline -5"

# Run tests
watch -n 2 "npm test"
```

---

## Project Structure After Setup

```
notes-app/
├── .claude/
│   ├── settings.local.json          # Autonomous permissions + hooks
│   ├── hooks/
│   │   └── ralph-stop-hook.sh       # Stop hook for loop
│   └── docs/
│       ├── AUTONOMOUS-DEVELOPMENT-FLOW.md
│       ├── PROJECT-PLAN.md
│       ├── SPECIFICATIONS.md
│       ├── RISKS-AND-MITIGATIONS.md
│       ├── IMPLEMENTATION-ROADMAP.md
│       ├── TDD-MASTER-DOCUMENT.md
│       └── PROGRESS.md
├── src/
├── tests/
└── package.json
```

---

## Key Points

1. **Always use `--dangerously-skip-permissions`** flag when starting Claude Code
2. **Planning is done BEFORE Ralph Loop** - don't skip the planning phases
3. **Use Opus for planning** - highest quality for specifications
4. **Specifications must be atomic** - junior developers implement independently
5. **TDD is strict** - tests first, code after, never skip
6. **Clinical safety context** - even for non-hospital projects, treat it as critical

---

## Troubleshooting

### Ralph Loop doesn't start

Check stop hook is configured in `.claude/settings.local.json`:
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/ralph-stop-hook.sh"
      }]
    }]
  }
}
```

### Permissions still being asked

Ensure you started Claude with:
```bash
claude --dangerously-skip-permissions
```

Not a setting in a file - it's a command-line flag.

### Loop stops unexpectedly

Check iteration count:
```bash
grep '^iteration:' .claude/ralph-loop.local.md
```

Check max_iterations wasn't reached.

### Tests keep failing

Use `/review-pr code tests errors` to identify issues.

---

## Summary

1. **Start**: `claude --dangerously-skip-permissions`
2. **Plan**: Execute phases 1-8 using Opus
3. **Implement**: Start Ralph Loop with TDD prompt
4. **Monitor**: Watch PROGRESS.md and git log
5. **Complete**: Ralph Loop outputs completion promise
