#!/usr/bin/env bash

# Displays the current workspace number/letter

if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

sketchybar --set "$NAME" label="$FOCUSED_WORKSPACE"
