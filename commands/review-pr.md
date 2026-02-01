---
description: "Comprehensive PR review using specialized agents"
argument-hint: "[aspects]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task"]
---

# Comprehensive PR Review

Run a comprehensive pull request review using multiple specialized agents, each focusing on a different aspect of code quality.

**Review Aspects (optional):** "$ARGUMENTS"

## Review Workflow:

1. **Determine Review Scope**
   - Check git status to identify changed files
   - Parse arguments to see if user requested specific review aspects
   - Default: Run all applicable reviews

2. **Available Review Aspects:**

   - **tests** - Review test coverage quality and completeness
   - **errors** - Check error handling for silent failures
   - **code** - General code review for project guidelines
   - **simplify** - Simplify code for clarity and maintainability
   - **all** - Run all applicable reviews (default)

3. **Identify Changed Files**
   - Run `git diff --name-only` to see modified files
   - Check if PR already exists: `gh pr view`
   - Identify file types and what reviews apply

4. **Determine Applicable Reviews**

   Based on changes:
   - **Always applicable**: code-reviewer (general quality)
   - **If test files changed**: pr-test-analyzer
   - **If error handling changed**: silent-failure-hunter
   - **After passing review**: code-simplifier (polish and refine)

5. **Launch Review Agents**

   Launch agents sequentially for clearer feedback.

6. **Aggregate Results**

   After agents complete, summarize:
   - **Critical Issues** (must fix before merge)
   - **Important Issues** (should fix)
   - **Suggestions** (nice to have)
   - **Positive Observations** (what's good)

## Usage Examples:

**Full review (default):**
```
/review-pr
```

**Specific aspects:**
```
/review-pr tests errors
# Reviews only test coverage and error handling

/review-pr simplify
# Simplifies code after passing review
```

## Workflow Integration:

**Before committing:**
1. Write code
2. Run: `/review-pr code errors`
3. Fix critical issues
4. Commit

**Before creating PR:**
1. Stage all changes
2. Run: `/review-pr all`
3. Address all critical and important issues
4. Create PR
