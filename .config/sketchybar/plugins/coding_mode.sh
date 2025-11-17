#!/bin/sh

# This plugin displays "code" when karabiner coding mode is enabled
# The state is updated directly by karabiner when F3 is pressed

# If called with an argument, update the display
if [ -n "$1" ]; then
  if [ "$1" = "1" ]; then
    sketchybar --set "$NAME" label="code"
  else
    sketchybar --set "$NAME" label=""
  fi
fi
