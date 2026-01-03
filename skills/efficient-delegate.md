---
name: efficient-delegate
description: Delegate complex tasks to Haiku subagents for token efficiency. Auto-triggers for implementation tasks with 3+ steps.
auto-invoke-triggers:
  - "implement.*"
  - "add.*feature"
  - "refactor.*"
  - "fix.*bugs?"
  - "create.*and.*"
allowed-tools: Task, TodoWrite, AskUserQuestion
---

# Efficient Task Delegation Workflow

You are orchestrating a token-efficient workflow that:
1. Breaks down the task into tiny, atomic subtasks
2. Delegates execution to Haiku subagents (cheap/fast)
3. Verifies results with Sonnet (current model)

## Step 1: Task Analysis & Breakdown

Analyze the user's request and break it into **atomic subtasks**:
- Each subtask should be independently completable
- Subtasks should be specific and measurable
- Aim for 3-10 subtasks depending on complexity
- Categorize by type: read-only, modification, verification

Use TodoWrite to create the task breakdown for user visibility.

## Step 2: Determine Delegation Strategy

**Delegate to Haiku when:**
- Task is well-defined and straightforward
- No ambiguity in requirements
- Pattern-matching or repetitive work
- File modifications with clear specs
- Running tests/builds and reporting results

**Keep in Sonnet when:**
- Architectural decisions needed
- Ambiguous requirements
- Complex debugging requiring inference
- User preference gathering
- Final integration and verification

## Step 3: Execute with Haiku Subagents

For each delegatable subtask:

```
Use Task tool with:
- subagent_type: "general-purpose"
- model: "haiku"
- prompt: Clear, specific instructions with:
  - Exact files to modify
  - Expected outcome
  - Verification criteria
```

**Run independent subtasks in PARALLEL** using multiple Task calls in one message.

## Step 4: Verification & Integration

After Haiku completes subtasks:
1. Review all changes made
2. Check for consistency across subtasks
3. Run integration tests if applicable
4. Verify the original requirement is fully met
5. Report results to user

## Step 5: Mark Complete

Update TodoWrite to mark all subtasks as completed.

## Token Efficiency Guidelines

**Cost Comparison:**
- Haiku: ~$0.25 per 1M input tokens
- Sonnet: ~$3.00 per 1M input tokens
- Opus: ~$15.00 per 1M input tokens

**Savings Example:**
- Complex task using 50k tokens
- All Sonnet: $0.15
- Delegated (30k Haiku + 20k Sonnet): $0.0675 + $0.06 = $0.1275
- **Savings: ~15-20%** while maintaining quality

## Example Workflow

```
User: "Implement user authentication with email/password and session management"

Step 1 - Break down:
1. Create User model with email/password fields
2. Add password hashing utility
3. Create login API endpoint
4. Create session middleware
5. Add logout endpoint
6. Write tests for auth flow

Step 2 - Delegate:
- Subtasks 1,2,5,6 → Haiku (clear specs)
- Subtasks 3,4 → Sonnet (integration logic)

Step 3 - Execute:
[Spawn 2 Haiku agents in parallel for tasks 1,2]
[Wait for completion]
[Handle tasks 3,4 in Sonnet]
[Spawn 2 Haiku agents for tasks 5,6]

Step 4 - Verify:
- Check all files integrate properly
- Run test suite
- Verify auth flow works end-to-end

Step 5 - Complete & report
```

## Important Notes

- Always explain the delegation strategy to the user
- Don't over-delegate: simple tasks don't need breakdown
- Failed Haiku tasks should be retried in Sonnet
- Keep user informed of progress throughout
