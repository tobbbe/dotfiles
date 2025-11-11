#!/usr/bin/env bash

STATE_FILE="/tmp/sketchybar_vercel_state.json"
PROJECT="$1"

if [ -z "$PROJECT" ]; then
    exit 1
fi

# Save project to state file and start polling
jq -n \
    --arg project "$PROJECT" \
    '{project: $project, is_building: true, label: ""}' \
    > "$STATE_FILE"

# Close the popup
sketchybar --set vercel popup.drawing=off

# Trigger immediate update
sketchybar --trigger vercel_update
