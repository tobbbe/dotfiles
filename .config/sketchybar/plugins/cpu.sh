#!/bin/sh

CPU_USAGE="$(top -l 1 | awk '/CPU usage/ {gsub("%", "", $7); print int(100 - $7)}')"

if [ -z "$CPU_USAGE" ]; then
  exit 0
fi

sketchybar --set "$NAME" label="c${CPU_USAGE}%"
