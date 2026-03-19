#!/bin/bash
# Show a centered notification in sketchybar.
#
# Usage: notify.sh --text TEXT [--duration SECS] [--bg 0xAARRGGBB] [--fg 0xAARRGGBB]
#
# Options:
#   --text      Message to display (required)
#   --duration  Seconds before hiding (default: 3)
#   --bg        Bar background color in 0xAARRGGBB format (default: 0xff1a1a2e)
#   --fg        Text color in 0xAARRGGBB format (default: 0xffffffff)
#
# Center items hidden while notification is visible: front_app

TEXT=""
DURATION=3
BG="0xff1a1a2e"
FG="0xffffffff"

# Original bar color (transparent)
ORIGINAL_BAR_COLOR="0x00000000"

# Center items to hide while notification is visible
CENTER_ITEMS=(front_app)

PIDFILE="/tmp/sketchybar_notify.pid"
TEXTFILE="/tmp/sketchybar_notify_text"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --text)     TEXT="$2";     shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --bg)       BG="$2";       shift 2 ;;
    --fg)       FG="$2";       shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$TEXT" ]]; then
  echo "Usage: notify.sh --text TEXT [--duration SECS] [--bg 0xAARRGGBB] [--fg 0xAARRGGBB]" >&2
  exit 1
fi

if [[ -f "$PIDFILE" ]]; then
  # Notification already showing — append and reset timer
  kill "$(cat "$PIDFILE")" 2>/dev/null
  current=$(cat "$TEXTFILE" 2>/dev/null)
  TEXT="${current} | ${TEXT}"
else
  # Fresh notification — hide other center items and set bar color
  for item in "${CENTER_ITEMS[@]}"; do
    sketchybar --set "$item" drawing=off
  done
  sketchybar --bar color="$BG"
fi

echo "$TEXT" > "$TEXTFILE"
sketchybar --set notify drawing=on \
                        label="$TEXT" \
                        label.color="$FG"

# Restore after duration
(
  sleep "$DURATION"
  sketchybar --set notify drawing=off
  for item in "${CENTER_ITEMS[@]}"; do
    sketchybar --set "$item" drawing=on
  done
  sketchybar --bar color="$ORIGINAL_BAR_COLOR"
  rm -f "$PIDFILE" "$TEXTFILE"
) &
echo $! > "$PIDFILE"
