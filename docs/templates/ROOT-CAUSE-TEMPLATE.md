# Root Cause Analysis Template

Use this template to document the investigation and root cause of a bug.

---

## Bug Summary

**Bug ID:** BUG-XXX
**Bug Title:** [From BUG-REPORT.md]

[One-paragraph summary of the bug and its impact]

---

## Investigation Steps

[Document all steps taken to investigate the bug. This helps others understand the debugging process and can guide similar investigations.]

### Step 1: [Investigation Action]

**Action:** [What was done]
**Finding:** [What was discovered]
**Files Examined:**
- `[file/path:line]` - [what was looked for and found]
- `[file/path:line]` - [what was looked for and found]

### Step 2: [Investigation Action]

**Action:** [What was done]
**Finding:** [What was discovered]
**Files Examined:**
- `[file/path:line]` - [what was looked for and found]

### Step 3: [Investigation Action]

**Action:** [What was done]
**Finding:** [What was discovered]
**Files Examined:**
- `[file/path:line]` - [what was looked for and found]

[Add more steps as needed]

---

## Root Cause

### The Root Cause

[Clear, concise statement of WHY the bug occurs. Not just WHERE - focus on the underlying cause.]

### Root Cause Category

| Category | Description | Example |
|----------|-------------|---------|
| **Logic Error** | Incorrect algorithm or condition | Wrong comparison, missing edge case |
| **Data Issue** | Data shape or content problem | Null handling, type mismatch |
| **Configuration** | Wrong setting or environment | Missing config, incorrect flag |
| **Integration** | Third-party or API issue | Timeout, wrong endpoint, version mismatch |
| **Concurrency** | Race condition or timing issue | Missing lock, incorrect ordering |
| **Performance** | Resource exhaustion or inefficiency | Memory leak, N+1 query |
| **UI/UX** | Interface or interaction problem | Wrong event handler, z-index issue |

**Category:** [Select category]

---

## Code Locations

### Primary Location

**File:** `path/to/file.ext`
**Lines:** [XX-YY]
**Function/Component:** `[function_name]`

```javascript
// The problematic code
[paste the specific code causing the issue]
```

### Contributing Locations

| File | Lines | Function | Issue |
|------|-------|----------|-------|
| `path/to/file.ext` | XX-YY | `function_name` | [what contributes to bug] |
| `path/to/file.ext` | XX-YY | `function_name` | [what contributes to bug] |

---

## Why the Bug Occurs

[Detailed explanation of the mechanism that causes the bug. Include:]

1. **Trigger:** [What specific condition triggers the bug]
2. **Fault:** [What goes wrong in the code]
3. **Failure:** [How the fault manifests as the observed bug]

### Example Structure

```
1. User submits form with empty email field
   ↓
2. Validation function checks `email.length > 0` (fault: should also check for null)
   ↓
3. When email is `null`, `null.length` throws TypeError
   ↓
4. Error handler catches TypeError but shows generic "Validation failed" message
   ↓
5. User sees unhelpful error message (observed bug)
```

---

## Related Code Patterns

[Similar patterns in the codebase that may have the same issue]

### Potential Similar Bugs

| Location | Risk Level | Notes |
|----------|------------|-------|
| `path/to/file.ext:XX` | HIGH | Uses same pattern with null |
| `path/to/file.ext:XX` | MEDIUM | Similar but with different type |
| `path/to/file.ext:XX` | LOW | Uses pattern but with guards |

[Recommend reviewing these locations for similar issues]

---

## Reproduction Confirmation

**Can the bug be reproduced?** [Yes/No]

**Reproduction Test:** [Link to test file or describe reproduction test]

```javascript
// Example reproduction test
describe('BUG-XXX: [bug title]', () => {
  it('reproduces the bug when [condition]', () => {
    // Arrange
    const input = [setup that triggers bug];

    // Act
    const result = functionUnderTest(input);

    // Assert - demonstrates the bug
    expect(result).toBe('[expected behavior]');
    // This test should FAIL with the bug present
  });
});
```

---

## Prevention

### How to Prevent Similar Bugs

1. **Code Pattern:** [What pattern should be used instead]
2. **Testing:** [What test would have caught this]
3. **Review:** [What code review question would have found this]
4. **Documentation:** [What documentation needs updating]

---

## Notes

[Any additional observations, insights, or context that doesn't fit elsewhere]

---

*End of ROOT-CAUSE template*
