#!/bin/bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Time
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ⏱️

# @raycast.argument1 { "type": "text", "placeholder": "timestamp" }

# @raycast.author Tobbbe

node -e "console.table(
  [
    [
      'UTC-0', new Date($1).toLocaleString('sv-SE', { timeZone: 'UTC' })
    ],
    [
      'Sweden time', new Date($1).toLocaleString('sv-SE', { timeZone: 'Europe/Stockholm' })
    ]
  ]
)"