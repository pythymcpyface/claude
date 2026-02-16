# Bug Report Template

Use this template to document bugs for systematic resolution.

---

## Bug ID

BUG-XXX (auto-increment per branch, e.g., BUG-001, BUG-002)

---

## Title

[Concise description of the bug - max 80 characters]

---

## Severity

| Severity | Description | Example |
|----------|-------------|---------|
| **CRITICAL** | System down, data loss, security breach | Production outage, authentication bypass |
| **HIGH** | Major feature broken, severe impact | Checkout process fails, data corruption |
| **MEDIUM** | Minor feature broken, workaround exists | UI glitch, non-critical error |
| **LOW** | Cosmetic issue, minor annoyance | Typo, spacing issue |

**Selected Severity:** [CRITICAL/HIGH/MEDIUM/LOW]

---

## Description

[Detailed description of what is wrong. Include context about when the bug occurs, who it affects, and the business impact if known.]

---

## Steps to Reproduce

[Numbered, step-by-step instructions to reproduce the bug. Be as specific as possible.]

1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4 - bug manifests here]

**Prerequisites:**
- [ ] [Any required setup, configuration, or data]
- [ ] [User role or permissions needed]
- [ ] [Specific environment or conditions]

---

## Expected Behavior

[What SHOULD happen when following the steps above. Be specific about the correct behavior.]

---

## Actual Behavior

[What ACTUALLY happens. Include error messages, incorrect output, unexpected behavior, etc.]

---

## Error Messages

[Include any error messages, stack traces, or console output]

```
[Paste error messages or stack traces here]
```

---

## Environment

| Context | Information |
|---------|-------------|
| **Environment** | [Development / Staging / Production] |
| **URL/Route** | [Where the bug occurs] |
| **Browser/Client** | [If relevant] |
| **User Role** | [If relevant] |
| **First Seen** | [Date/time when bug was discovered] |
| **Frequency** | [Always / Intermittent / Once] |

---

## Attachments

- [ ] Screenshots
- [ ] Screen recordings
- [ ] Log files
- [ ] Network traces
- [ ] Database dumps (sanitized)
- [ ] Other: [describe]

**Attachment Links:** [Add links or descriptions]

---

## Related Issues

- [ ] Linked to feature: [feature name or ticket]
- [ ] Similar bugs: [BUG-XXX]
- [ ] Related PR/commit: [PR number or commit hash]

---

## Workarounds

[Are there any known workarounds? Document them here so users can proceed while the bug is being fixed.]

---

## Notes

[Any additional context, observations, or information that might help diagnose the fix.]

---

*End of BUG-REPORT template*
