# Session Handoff — 2026-06-03

Branch: `session-handoff/2026-06-03`
Previous session: `session-ses_1770.md`
Last commit on `main`: `af83954 chore: remove stale docs, dedup commands/agents, add bug-fix and feature-dev skills`

---

## Context

This session worked through a comprehensive audit of `~/.claude/` against Anthropic's published best practices and three reference repos:
- `anthropics/skills` (canonical)
- `wshobson/agents` (155 skills, 191 agents, plugin marketplace)
- `wshobson/commands` (slash command patterns)

The audit produced a P0-P3 priority list. Most P0/P1 items have been completed. This document tracks what is **done** vs **remaining**.

---

## Done

### P0 — Settings safety

| Item | Status |
|------|--------|
| Remove broken `ralph-stop-hook.sh` from settings Stop hooks | DONE (no Stop hook in current settings) |
| Add `permissions.deny` rules for destructive Bash | DONE (10 deny rules: `rm -rf`, `rm -fr`, `git push --force`, `git reset --hard`, `git clean -fdx`, fork bomb, `dd if=`, `mkfs`, `chmod -R 777`) |
| Add Write/Edit deny for `.git/**`, `.env*`, `.claude/hooks/**` | DONE (6 path deny rules) |
| Untrack `settings.local.json` (contains tokens) | DONE (.gitignore + working tree removal committed) |

### P0 — Command/skill deduplication

| Item | Status |
|------|--------|
| Replace 22 review commands with thin skill wrappers (or delete) | DONE in commit `f4730d5`. Commands kept: 19. Most remaining commands are workflow/utility (commit, quality-check, git-process, review-pr, etc.). |
| Delete `agents/code-explorer.md` (redundant with built-in Explore) | DONE |
| Delete stale top-level docs (DELEGATION-GUIDE, IMPROVEMENTS-SUMMARY, SKILLS_COMMANDS_RECOMMENDATIONS) | DONE |
| Delete duplicate commands replaced by skills (memory-cleanup, observability-review, storage-cleanup) | DONE |

### P1 — Skill-splitting (router + references pattern)

22 of 32 skills now have a `references/` subdirectory. The 21 review skills that were 600-1100+ lines have been split to ~80-line routers with bundled references.

| Skill | Lines | Has references/ |
|-------|-------|-----------------|
| All 21 review skills | 76-90 | YES |
| `efficiency-review` | 163 | YES |
| `production-readiness-review` | 259 | YES |

### P1 — Path-scoped activation

`paths:` frontmatter has been added to review skills (verified on `compliance-review`: 9 path globs incl. `**/privacy/**`, `**/consent/**`, `**/gdpr/**`).

### P1 — Hooks

| Hook | Status |
|------|--------|
| `block-destructive.sh` (PreToolUse, Bash matcher) | DONE |
| `scan-ai-attribution.sh` (PreToolUse, Write/Edit) | DONE |
| `auto-format.sh` (PostToolUse, Write/Edit) | DONE |
| `user-prompt-tokens.sh`, `post-response-tokens.sh` | KEPT |

### Other consolidations done

- `opencode.json` moved to `~/.claude` as single source of truth (OPENCODE_CONFIG env var)
- `settings.local.json` merged into `settings.json`
- `skills/core/` and `skills/extended/` reference docs moved to `docs/skill-references/` (they were not skills, they were docs)
- `cgr-local` MCP fixed (was pointing at Redis kdb server; now uses code-graph-rag → Memgraph on 7689)
- `kdb-local` MCP fixed (mcp-local-rag with global DB_PATH)
- `chpwd` zsh hook sets project-aware env vars (TARGET_REPO_PATH, BASE_DIR, KNOWLEDGE_DB_PATH)

---

## Remaining

### P1 — Oversized skills still to split (router + references)

| Skill | Lines | Notes |
|-------|-------|-------|
| `feature-dev` | 575 | Newly migrated from command. Split into router + references/{phases,checklists,examples}.md |
| `bug-fix` | 563 | Newly migrated from command. Same split pattern. |
| `storage-cleanup` | 438 | Migrated from command. Split. |
| `observability-review` | 391 | Migrated from command. Split. |
| `spec-workflow` | 271 | Migrated from command. Borderline — may be acceptable as-is. |
| `memory-cleanup` | 252 | Migrated from command. Borderline. |

Backup before splitting: `~/.claude/backups/tier2b-20260603-081531/` already exists.

### P2 — Migrate remaining bloated commands to skills

| Command | Lines | Action |
|---------|-------|--------|
| `commands/feature-dev.md` | 573 | DELETE — `skills/feature-dev/` already exists and shadows it |
| `commands/bug-fix.md` | 561 | DELETE — `skills/bug-fix/` already exists and shadows it |
| `commands/start-project.md` | 1236 | Migrate to `skills/start-project/SKILL.md` (router) + `references/`. Then delete the command. |

### P2 — Hook efficiency

- `scripts/delegate-check.sh` fires on every Bash call. Add `if:` field or matcher pattern to fire only on test/build/lint patterns: `Bash(npm test*)`, `Bash(*pytest*)`, `Bash(*build*)`, etc.
- `delegate-check.sh` references `mcp__ultra-mcp__*` tools but ultra-mcp is not configured. Either configure it or remove those references from the script.

### P2 — Agent improvements

- Add `memory: project` to `agents/code-reviewer.md` and `agents/code-architect.md` for cross-session learning.
- Add `disallowedTools` or `permissionMode: acceptEdits` guardrails to `agents/code-simplifier.md`.

### P3 — Script audit

Wire-or-delete: `auto-heal.sh`, `quality-gate.sh`, `security-gate.sh`, `tdd-gate.sh`, `integration-gate.sh`, `setup-auth.sh`, `setup-env.sh`, `local-llm-usage.sh`. None appear in `settings.json` hooks.

### P3 — Cleanup

- `skills/learned/` was empty — verify it's gone.
- Check that `commands/_aliases.md` is actually wired or delete it.

---

## Plan for next session

Recommended order (lowest risk first):

1. **Delete shadowed commands** (5 min):
   ```bash
   rm commands/feature-dev.md commands/bug-fix.md
   ```
   Skills already exist; per Anthropic, skill wins. Verify the skills are functionally complete first.

2. **Split `feature-dev` and `bug-fix` skills** (30-60 min): backup → extract phases/checklists into `references/` → reduce SKILL.md to ~150-line router. Mirror the pattern used in review skills.

3. **Migrate `start-project.md`** (60 min): biggest single doc. Convert to `skills/start-project/SKILL.md` with `references/{stacks,scaffolds,checklists}.md`. Delete the command.

4. **Split remaining oversized skills** (30-45 min): `storage-cleanup`, `observability-review`, optionally `spec-workflow`/`memory-cleanup`.

5. **Tighten `delegate-check.sh`** (15 min): add `if:` matcher in `settings.json`, or add `case` in script that exits 0 fast for non-relevant Bash invocations.

6. **Agent memory + guardrails** (15 min): add `memory: project` and `disallowedTools` per audit.

7. **Script audit** (30 min): grep `*-gate.sh` and `setup-*.sh` references; either wire into hooks or delete.

After all P1/P2 items: merge `session-handoff/2026-06-03` → `main`, push.

---

## Open questions for the user

1. `commands/start-project.md` is 1236 lines. Should it become a skill (proper progressive disclosure) or stay as a command with the bulk extracted into reference files alongside it?
2. `commands/_aliases.md` — keep or delete?
3. Should `delegate-check.sh` be removed entirely (since ultra-mcp isn't configured) or kept and narrowed?
4. Run a final `make validate`-style sweep — is there an internal validation script, or should we add one?

---

## Key file references

- Audit findings (this session, P0-P3 list): see top of `session-ses_1770.md` (lines 9-134).
- Anthropic skill canonical reference: `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md`
- wshobson marketplace pattern: `https://github.com/wshobson/agents` (one source-of-truth `plugins/`, generated per harness).
- Backup of pre-split skills: `~/.claude/backups/tier2b-20260603-081531/`
