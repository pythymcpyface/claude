---
description: macOS memory and CPU cleanup. Analyzes processes consuming high memory or CPU and terminates resource-intensive tasks.
allowed-tools: Bash, Read, AskUserQuestion
---

# Memory Cleanup Command

Run memory and CPU cleanup on macOS.

## Usage

Trigger this command when:
- System is slow or unresponsive
- Memory is exhausted
- User asks to clean up memory, free memory, clear memory

## Workflow

### Step 1: Load the Skill

Read the skill definition for full workflow:
```
Read: skills/memory-cleanup/SKILL.md
```

### Step 2: Analyze Processes

Run analysis commands to identify resource-heavy processes.

### Step 3: Present Results

Present analysis as table with checkboxes.

### Step 4: User Selection

Let user select processes to terminate.

### Step 5: Execute Cleanup

Terminate selected processes.

### Step 6: Verify

Verify memory freed.