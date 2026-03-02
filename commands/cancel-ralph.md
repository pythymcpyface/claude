---
description: "Cancel active Ralph Loop"
allowed-tools: ["Bash(bash $HOME/.claude/scripts/cancel-ralph-loop.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

To cancel the Ralph loop for the current project:

```!
bash "$HOME/.claude/scripts/cancel-ralph-loop.sh"
```

This will remove the project-specific ralph-loop state file and report the iteration that was cancelled.
