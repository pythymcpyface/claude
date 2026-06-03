# Cleanup Plan — 2026-06-03 followup

Branch: `cleanup/2026-06-03-followup` (off `session-handoff/2026-06-03`)
Source: `SESSION_HANDOFF.md` (P1/P2/P3 items)

We will work through this list in order, marking items DONE as we go. Update this file in place after each item.

---

## Status legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done
- `[s]` skipped (with reason)

---

## Step 1 — Delete shadowed commands

Skill takes precedence per Anthropic. These commands are dead weight.

- [x] Delete `commands/feature-dev.md` (573 lines) — verified byte-identical to skill body
- [x] Delete `commands/bug-fix.md` (561 lines) — verified byte-identical to skill body
- [x] Delete `commands/start-project.md` (1236 lines) — DONE in Step 3 (skill now populated)

Done in commit `d4783ec`.

---

## Step 2 — Split oversized skills (router + references)

Pattern (already used by 22 review skills):
- `SKILL.md` = ~150-line router: frontmatter, when-to-trigger, workflow phases summary, scoring, integration notes, pointers
- `references/checklists.md` = detailed checklists with search patterns
- `references/report-template.md` = output report format
- `references/patterns.md` = code/config snippets (only if applicable)

Backup before each: `cp -r skills/<name> backups/<name>-pre-split-$(date +%s)/`

- [x] `skills/feature-dev/` (575 → 86 lines, references/phases.md 440 lines) — commit `2187da0`
- [x] `skills/bug-fix/` (563 → 102 lines, references/phases.md 368 lines) — commit `2187da0`
- [x] `skills/observability-review/` (391 → 84 lines, references/{checklists.md 262, patterns.md 90}) — commit `ca3762e`
- [x] `skills/storage-cleanup/` (438 → 98 lines, references/{analysis.md 196, cleanup.md 154}) — commit `ca3762e`
- [s] `skills/spec-workflow/` (271 lines) — borderline; deferred per plan
- [s] `skills/memory-cleanup/` (252 lines) — borderline; deferred per plan

**Verify after each:** SKILL.md ≤ ~200 lines, references files reachable, frontmatter intact.

**Commit per skill:** `refactor(skills/<name>): split into router + references`

---

## Step 3 — Migrate `start-project` properly

- [x] `skills/start-project/SKILL.md` (114-line router)
- [x] `skills/start-project/references/phases.md` (330 lines — Phase 0–7 actions, stop-points, validation)
- [x] `skills/start-project/references/templates.md` (618 lines — all 11 doc templates)
- [x] `skills/start-project/references/scripts.md` (189 lines — quality-gate, validate-planning, setup-env)
- [x] Verified all 17 docs + 3 scripts referenced in skill (parity with original command)
- [x] Deleted `commands/start-project.md`

---

## Step 4 — Hook efficiency

`scripts/delegate-check.sh` already self-filters (exits 0 fast on non-matching Bash). The audit's claim of `ultra-mcp` references is stale — verified no such refs in current script.

- [s] Add `if:` matcher in settings.json (NOT NEEDED — script self-filters)
- [s] Remove ultra-mcp refs (NOT NEEDED — none present)

**Optional improvement:**
- [ ] Move `delegate-check.sh` from `scripts/` to `hooks/` for consistency (hooks live in one place). Update `settings.json` path.

---

## Step 5 — Agent improvements

- [x] `agents/code-architect.md`: added `memory: project`
- [x] `agents/code-reviewer.md`: added `memory: project`
- [x] `agents/code-simplifier.md`: added `disallowedTools: Bash`

Commit `567023a`.

---

## Step 6 — Script audit

Audit results (commit `567023a`):

- [x] `auto-heal.sh` — DELETED (476 lines, no references in hooks/skills/commands)
- [s] `quality-gate.sh` — KEEP (referenced by `feature-dev`, `bug-fix` skills, docs)
- [s] `security-gate.sh` — KEEP (referenced by `feature-dev`, `bug-fix` skills)
- [s] `tdd-gate.sh` — KEEP (referenced by `feature-dev` skill)
- [s] `integration-gate.sh` — KEEP (referenced by `INTEGRATION-TEST-TEMPLATE.md`)
- [s] `setup-auth.sh` — KEEP (manual onboarding helper, 43 lines)
- [s] `setup-env.sh` — KEEP (referenced by `start-project`, `continue-planning`)
- [s] `local-llm-usage.sh` — KEEP (wired in `settings.json` and `post-response-tokens.sh`)

---

## Step 7 — Final cleanup

- [x] `skills/learned/` confirmed gone
- [x] `commands/_aliases.md`: removed stale `/e2e` entry, kept `/qa` and `/git`
- [ ] Run a final audit: `find skills -name SKILL.md | xargs wc -l | sort -rn | head -10`

---

## Step 8 — Merge

When all P1/P2 items done:

- [ ] Squash-merge `cleanup/2026-06-03-followup` → `session-handoff/2026-06-03` → `main`
- [ ] Delete handoff branches
- [ ] Push to origin

---

## Open questions (need user input)

1. `commands/start-project.md` (1236 lines) — was content fully migrated to `skills/start-project/`? Need to diff.
2. `commands/_aliases.md` — keep or delete?
3. Are any of the `*-gate.sh` scripts invoked from inside skills (vs hooks)? If so they stay.
4. Local LLM (llama.cpp) — running or not? Determines fate of `local-llm-usage.sh`.

---

## Progress log

(Append entries here as work proceeds.)

- 2026-06-03 08:30 — Plan created on branch `cleanup/2026-06-03-followup`.
- 2026-06-03 09:10 — Step 1 done. Verified `feature-dev`/`bug-fix` skill bodies byte-identical to commands; deleted both. `start-project` deferred (skill dir empty). Commit `d4783ec`.
- 2026-06-03 09:35 — Step 2 partial: split `feature-dev` (86-line router + 440-line references) and `bug-fix` (102-line router + 368-line references). Backups in `backups/cleanup-2026-06-03/`. Commit `2187da0`.
- 2026-06-03 10:05 — Step 2 continues: split `observability-review` (84-line router + checklists 262 + patterns 90) and `storage-cleanup` (98-line router + analysis 196 + cleanup 154). Commit `ca3762e`.
- 2026-06-03 (later) — Steps 5, 6, 7 (small): agent frontmatter (memory + disallowedTools), `_aliases.md` cleanup, deleted orphaned `auto-heal.sh`. Commit `567023a`.
- 2026-06-03 (later) — Step 3 done: migrated `commands/start-project.md` (1236 lines) → `skills/start-project/{SKILL.md, references/{phases,templates,scripts}.md}` (114 + 330 + 618 + 189 = 1251 lines). Verified parity: all 17 docs + 3 scripts referenced. Deleted command. Pending commit.
