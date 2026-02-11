#!/bin/bash

# Injects agentbrain project knowledge at session start.

# Read the project name from cwd in the hook's stdin JSON
PROJECT=$(cat /dev/stdin | jq -r '.cwd' | xargs basename)
FILE="$HOME/dev/agentbrain/projects/${PROJECT}.md"

if [ -f "$FILE" ]; then
  # 🚨 Keep in sync with: .config/opencode/plugin/agentbrain.mjs
  echo "# Agentbrain for current cwd"
  echo ""
  cat "$FILE"
  echo "# Available Agentbrain topics"
  ls "$HOME/dev/agentbrain/topics"
fi
