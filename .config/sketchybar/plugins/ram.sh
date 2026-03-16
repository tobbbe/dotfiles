#!/bin/sh

MEMORY_PRESSURE="$(memory_pressure | awk '/System-wide memory free percentage/ {gsub("%", "", $5); print int(100 - $5)}')"

if [ -z "$MEMORY_PRESSURE" ]; then
  exit 0
fi

LABEL_COLOR="0xffffffff"

if [ "$MEMORY_PRESSURE" -gt 90 ]; then
  LABEL_COLOR="0xffff8080"
fi

sketchybar --set "$NAME" label="r${MEMORY_PRESSURE}%" label.color="$LABEL_COLOR"
