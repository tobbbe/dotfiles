#!/bin/bash
# Show a notification in sketchybar.
#
# Usage: notify.sh --text TEXT [--duration SECS] [--bg 0xAARRGGBB] [--fg 0xAARRGGBB]
#
# Options:
#   --text      Message to display (required)
#   --duration  Seconds before hiding (default: 3)
#   --bg        Bar background color in 0xAARRGGBB format (default: 0xff1a1a2e)
#   --fg        Text color in 0xAARRGGBB format (default: 0xffffffff)
#
TEXT=""
DURATION=3
BG="0xff1a1a2e"
FG="0xffffffff"

# Original bar color (transparent)
ORIGINAL_BAR_COLOR="0x00000000"

PIDFILE="/tmp/sketchybar_notify.pid"
TEXTFILE="/tmp/sketchybar_notify_text"

model_has_notch() {
  local model
  model="$(sysctl -n hw.model 2>/dev/null)"
  [[ "$model" =~ ^MacBookPro(18|19|2[0-9]), ]]
}

if model_has_notch; then
  NOTIFY_POSITION="left"
else
  NOTIFY_POSITION="center"
fi

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
  # Fresh notification — set position and bar color
  sketchybar --set notify position="$NOTIFY_POSITION"
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
  sketchybar --bar color="$ORIGINAL_BAR_COLOR"
  rm -f "$PIDFILE" "$TEXTFILE"
) &
echo $! > "$PIDFILE"
