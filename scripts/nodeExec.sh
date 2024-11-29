#!/bin/bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Node exec
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🧑‍💻

# @raycast.argument1 { "type": "text", "placeholder": "code" }

# @raycast.author Tobbbe

if [[ "$1" != console.log\(* ]]; then
  node -e "console.log($1)"
else
  node -e "$1"
fi