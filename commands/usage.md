# Usage Status
Description: Show current Z.AI quota usage and delegation recommendations
Usage: /usage

---

# Instruction

Run the usage tracking script to show current quota status:
```bash
bash ~/.claude/scripts/track-usage.sh --status
```

Then provide delegation guidance based on the output:
- If percentage >50%: "Quota healthy. Sonnet delegation available."
- If percentage 20-50%: "Quota moderate. Prefer Haiku delegation."
- If percentage <20%: "Quota low. Use Haiku only, minimize delegation."
