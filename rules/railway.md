---
paths:
  - "**/railway.json"
  - "**/railway.toml"
  - "**/.railway/**"
---

# Railway Deployment

- Environment variables only via Railway dashboard or `railway variables`. Never commit `.env`.
- Database URLs come from Railway; do not hardcode.
- For deploy/database/domain workflows, see `.claude/skills/railway-{topic}/SKILL.md` if present.
- Test migrations against a Railway preview environment before promoting to production.
