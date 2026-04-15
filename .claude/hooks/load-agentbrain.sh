#!/bin/sh

set -eu

payload=$(cat)
cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty')

if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi

sh "$HOME/dev/dotfiles/agents/agent-brain/check-agentbrain-link.sh" "$cwd"
