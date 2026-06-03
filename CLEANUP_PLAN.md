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
- [s] Delete `commands/start-project.md` (1236 lines) — DEFERRED: `skills/start-project/` is empty; cannot delete until Step 3 migrates content

Done in commit `d4783ec`.

---

## Step 2 — Split oversized skills (router + references)

Pattern (already used by 22 review skills):
- `SKILL.md` = ~150-line router: frontmatter, when-to-trigger, workflow phases summary, scoring, integration notes, pointers
- `references/checklists.md` = detailed checklists with search patterns
- `references/report-template.md` = output report format
- `references/patterns.md` = code/config snippets (only if applicable)

Backup before each: `cp -r skills/<name> backups/<name>-pre-split-$(date +%s)/`

- [ ] `skills/feature-dev/` (575 lines)
- [ ] `skills/bug-fix/` (563 lines)
- [ ] `skills/storage-cleanup/` (438 lines)
- [ ] `skills/observability-review/` (391 lines)
- [ ] `skills/spec-workflow/` (271 lines) — borderline; defer if shape is already coherent
- [ ] `skills/memory-cleanup/` (252 lines) — borderline; defer

**Verify after each:** SKILL.md ≤ ~200 lines, references files reachable, frontmatter intact.

**Commit per skill:** `refactor(skills/<name>): split into router + references`

---

## Step 3 — Migrate `start-project` properly

If Step 1 deleted `commands/start-project.md`, the skill at `skills/start-project/SKILL.md` is the only copy. Verify:

- [ ] `skills/start-project/SKILL.md` content is current (matches command, no regression)
- [ ] If oversized, split into router + `references/{stacks,scaffolds,checklists}.md`

---

## Step 4 — Hook efficiency

`scripts/delegate-check.sh` already self-filters (exits 0 fast on non-matching Bash). The audit's claim of `ultra-mcp` references is stale — verified no such refs in current script.

- [s] Add `if:` matcher in settings.json (NOT NEEDED — script self-filters)
- [s] Remove ultra-mcp refs (NOT NEEDED — none present)

**Optional improvement:**
- [ ] Move `delegate-check.sh` from `scripts/` to `hooks/` for consistency (hooks live in one place). Update `settings.json` path.

---

## Step 5 — Agent improvements

`agents/code-architect.md` and `agents/code-reviewer.md`:
- [ ] Add `memory: project` to frontmatter for cross-session learning

`agents/code-simplifier.md` modifies code (inherited Edit/Write):
- [ ] Add `disallowedTools: Bash` OR `permissionMode: acceptEdits` to frontmatter

**Commit:** `feat(agents): add memory and guardrails`

---

## Step 6 — Script audit

Scripts in `scripts/` that are NOT referenced by any hook in `settings.json`:

- [ ] `auto-heal.sh` — wire-or-delete
- [ ] `quality-gate.sh` — wire-or-delete (or invoked from a skill?)
- [ ] `security-gate.sh` — wire-or-delete
- [ ] `tdd-gate.sh` — wire-or-delete
- [ ] `integration-gate.sh` — wire-or-delete
- [ ] `setup-auth.sh` — keep if manual onboarding script; document in CLAUDE.md
- [ ] `setup-env.sh` — same
- [ ] `local-llm-usage.sh` — delete if no local LLM running

**Commit:** `chore(scripts): remove orphaned gate/setup scripts` (or wire into hooks)

---

## Step 7 — Final cleanup

- [ ] Verify `skills/learned/` is gone
- [ ] Decide `commands/_aliases.md`: wire-or-delete
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
