# Fix Plan Template

Use this template to plan the fix for a documented bug.

---

## Bug Reference

**Bug ID:** BUG-XXX
**Bug Title:** [From BUG-REPORT.md]
**Root Cause:** [Brief summary from ROOT-CAUSE.md]

---

## Fix Approach

### Minimal Change Description

[Describe the smallest possible change that will fix the root cause. Avoid refactoring or other changes - focus only on fixing this bug.]

### Why This Approach

[Explain why this approach was chosen over alternatives. Consider simplicity, risk, and maintainability.]

---

## Files to Modify

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `path/to/file.ext` | XX-YY | Edit | [specific change] |
| `path/to/file.ext` | XX-YY | Delete | [remove what] |
| `path/to/file.ext` | New | Add | [add what] |

---

## Implementation Steps

1. **[Step 1]** - [file change description]
2. **[Step 2]** - [file change description]
3. **[Step 3]** - [file change description]
4. **[Step 4]** - [file change description]

---

## Test Strategy

### Reproduction Test (Failing Before Fix)

**Test File:** `path/to/test/bug-XXX-reproduction.test.ts`

**Description:** [Test that demonstrates the bug exists]

```javascript
describe('BUG-XXX: [bug title]', () => {
  it('should [expected behavior] when [condition]', () => {
    // Arrange
    const input = [setup that triggers bug];

    // Act
    const result = functionUnderTest(input);

    // Assert
    expect(result).toBe('[expected]');
  });
});
```

**Expected Before Fix:** FAIL
**Expected After Fix:** PASS

### Regression Tests

| Test | Description | Edge Case Covered |
|------|-------------|-------------------|
| `[test name]` | [what it tests] | [edge case] |
| `[test name]` | [what it tests] | [edge case] |

---

## Risk Assessment

### What Could Break

| Area | Risk Level | Mitigation |
|------|------------|------------|
| `[component/feature]` | HIGH/MEDIUM/LOW | [how to prevent or catch] |
| `[component/feature]` | HIGH/MEDIUM/LOW | [how to prevent or catch] |

### Edge Cases to Consider

1. **[Edge case 1]** - [how to handle]
2. **[Edge case 2]** - [how to handle]
3. **[Edge case 3]** - [how to handle]

---

## Rollback Plan

### If Fix Causes Issues

1. **Detection:** [How to detect if fix causes problems]
2. **Immediate Action:** [What to do if problems are found]
3. **Revert:** [How to revert the change]

### Rollback Steps

```bash
# Rollback the fix commit
git revert <commit-hash>
git push origin <branch>

# Or rollback to previous working state
git checkout <previous-working-commit>
```

---

## Quality Gates

### Before Merging

- [ ] Reproduction test passes (was failing before)
- [ ] All regression tests pass
- [ ] Existing tests still pass (no regressions)
- [ ] Code review completed
- [ ] Quality gate passes: `.claude/scripts/quality-gate.sh`
- [ ] Security check completed (if applicable)

---

## Verification Steps

### Manual Verification

1. **[Verification 1]** - [steps to manually verify fix]
2. **[Verification 2]** - [steps to manually verify fix]
3. **[Verification 3]** - [steps to manually verify fix]

### Automated Verification

- [Unit tests]: `npm test -- [test-pattern]`
- [Integration tests]: `npm test -- integration`
- [E2E tests]: `npm test -- e2e` (if applicable)

---

## Estimation

**Estimated Implementation Time:** [X] minutes

**Complexity:** [Low/Medium/High]

**Confidence Level:** [High/Medium/Low]

---

## Notes

[Any additional context, alternative approaches considered, or concerns]

---

*End of FIX-PLAN template*
