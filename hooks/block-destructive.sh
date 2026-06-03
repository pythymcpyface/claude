#!/bin/bash
# PreToolUse Bash hook: block known-destructive command patterns.
# Defense in depth on top of permissions.deny in settings.json.
# Exit 2 = block. Stderr message is shown to the model.

COMMAND="$1"

# Patterns that should never run unattended.
# Use word-boundary-ish checks by anchoring on whitespace where possible.
DESTRUCTIVE_PATTERNS=(
  'rm -rf /'
  'rm -rf ~'
  'rm -rf $HOME'
  'rm -rf *'
  'rm -fr /'
  'rm -fr ~'
  'rm -fr *'
  'git push --force'
  'git push -f '
  'git push --force-with-lease'
  'git reset --hard'
  'git clean -fdx'
  'git clean -fdX'
  'mkfs'
  'dd if='
  ':(){ :|:& };:'
  'chmod -R 777'
  'chmod 777 -R'
  '> /dev/sda'
  'shutdown'
  'reboot'
  'halt'
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "BLOCKED: command matches destructive pattern: '$pattern'" >&2
    echo "If this is genuinely intended, run it manually outside the agent." >&2
    exit 2
  fi
done

exit 0
