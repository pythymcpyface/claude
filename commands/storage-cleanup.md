---
description: macOS disk space recovery with analysis-first approach. Analyzes caches, Docker, build artifacts, and node_modules for safe cleanup.
allowed-tools: Bash, Read, AskUserQuestion
---

# Storage Cleanup Command

Run disk space cleanup on macOS with analysis-first approach.

## Usage

Trigger this command when:
- Disk is >75% full
- User asks to clean up disk space
- User mentions "storage cleanup", "free space", "clear disk"

## Workflow

### Step 1: Load the Skill

Read the skill definition for full workflow:
```
Read: skills/storage-cleanup/SKILL.md
```

### Step 2: Analyze Storage

Run analysis commands to identify cleanup targets.

### Step 3: Present Results

Present analysis as table with checkboxes.

### Step 4: User Selection

Let user select items to clean.

### Step 5: Execute Cleanup

Only clear what user selected.

### Step 6: Verify

Verify space recovered.