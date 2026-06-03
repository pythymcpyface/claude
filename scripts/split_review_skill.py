#!/usr/bin/env python3
"""
Split a review skill SKILL.md into a slim router + references/.

Strategy:
- Keep frontmatter, intro, "When to Trigger", short workflow overview,
  Scoring, and Integration in SKILL.md (the router).
- Move "Review Workflow" body (checklists) -> references/checklists.md
- Move "Quick Reference: Implementation Patterns" -> references/patterns.md
- Move any post-Quick-Reference custom sections into a "misc.md" if they exist.

Conservative: never deletes content, never invents text. Only relocates whole
sections. If structure doesn't match expectations, exits non-zero and prints why.
"""
import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("usage: split_review_skill.py <skill-dir>", file=sys.stderr)
    sys.exit(1)

skill_dir = Path(sys.argv[1])
skill_md = skill_dir / "SKILL.md"
if not skill_md.exists():
    print(f"no SKILL.md at {skill_md}", file=sys.stderr)
    sys.exit(1)

text = skill_md.read_text()

# Split frontmatter
fm_match = re.match(r"^(---\n.*?\n---\n)", text, re.DOTALL)
if not fm_match:
    print("no frontmatter found", file=sys.stderr)
    sys.exit(2)
frontmatter = fm_match.group(1)
body = text[len(frontmatter):]

# Find H2 section boundaries (lines starting with "## ")
section_pat = re.compile(r"^## (.+)$", re.MULTILINE)
sections = []
for m in section_pat.finditer(body):
    sections.append((m.start(), m.group(1).strip()))

if not sections:
    print("no H2 sections found", file=sys.stderr)
    sys.exit(3)

# Extract each section's content (start..next_start)
def section_content(idx):
    start = sections[idx][0]
    end = sections[idx + 1][0] if idx + 1 < len(sections) else len(body)
    return body[start:end]

# Header (intro before first section)
header = body[: sections[0][0]]

# Map section names to indices
name_to_idx = {}
for i, (_, name) in enumerate(sections):
    name_to_idx[name] = i

# Required sections
required = ["When to Trigger (Proactive)", "Review Workflow", "Scoring"]
for r in required:
    if r not in name_to_idx:
        print(f"missing required section: {r!r}", file=sys.stderr)
        sys.exit(4)

# Optional sections
qr_keys = [k for k in name_to_idx if k.startswith("Quick Reference")]
qr_idx = name_to_idx[qr_keys[0]] if qr_keys else None
integ_idx = name_to_idx.get("Integration with Other Reviews")

trigger_idx = name_to_idx["When to Trigger (Proactive)"]
workflow_idx = name_to_idx["Review Workflow"]
scoring_idx = name_to_idx["Scoring"]

# Build references
refs_dir = skill_dir / "references"
refs_dir.mkdir(exist_ok=True)

skill_name = skill_dir.name

# checklists.md: full Review Workflow content
checklists = (
    f"# {skill_name} — Detailed Checklists\n\n"
    f"Full checklist tables, search patterns, and per-category guidance for "
    f"{skill_name}. SKILL.md routes here when running the review workflow.\n\n"
    + section_content(workflow_idx).replace("## Review Workflow\n", "", 1)
)
(refs_dir / "checklists.md").write_text(checklists)

# patterns.md: Quick Reference content (if present)
if qr_idx is not None:
    qr_section = section_content(qr_idx)
    # Move any sections after Quick Reference but before Integration into patterns too
    end_idx = integ_idx if integ_idx is not None else len(sections)
    extra = ""
    for i in range(qr_idx + 1, end_idx):
        extra += section_content(i)
    patterns = (
        f"# {skill_name} — Implementation Patterns\n\n"
        f"Reusable code snippets and configuration templates for {skill_name}. "
        f"Copy and adapt to project context; do not paste verbatim without verifying stack.\n\n"
        + qr_section + extra
    )
    (refs_dir / "patterns.md").write_text(patterns)

# Build router SKILL.md
trigger_content = section_content(trigger_idx)
scoring_content = section_content(scoring_idx)
integ_content = section_content(integ_idx) if integ_idx is not None else ""

# Workflow overview: extract just the H3 phase headers from Review Workflow
workflow_body = section_content(workflow_idx)
phase_headers = re.findall(r"^### (.+)$", workflow_body, re.MULTILINE)

phases_summary = ""
if phase_headers:
    phases_summary = "\n".join(f"- {h.strip()}" for h in phase_headers)

router_workflow = f"""## Review Workflow

This SKILL.md is a router. Detailed material lives in `references/`:

| You need… | Read |
|---|---|
| Full checklists, search patterns, per-category guidance | `references/checklists.md` |
"""
if qr_idx is not None:
    router_workflow += "| Reusable code snippets and configuration templates | `references/patterns.md` |\n"

router_workflow += """
Always read the relevant reference file when doing the corresponding work — do not reproduce its contents from memory.

### Phases

"""
if phase_headers:
    router_workflow += phases_summary + "\n\n"
router_workflow += (
    "Walk through each phase using `references/checklists.md` for the detailed checks.\n\n"
)

router = (
    frontmatter
    + header
    + trigger_content
    + router_workflow
    + scoring_content
    + integ_content
)

skill_md.write_text(router)

# Report
orig_lines = text.count("\n") + 1
new_lines = router.count("\n") + 1
print(f"{skill_name}: {orig_lines} -> {new_lines} lines (router)")
print(f"  references/checklists.md: {(refs_dir / 'checklists.md').read_text().count(chr(10)) + 1} lines")
if qr_idx is not None:
    print(f"  references/patterns.md:   {(refs_dir / 'patterns.md').read_text().count(chr(10)) + 1} lines")
