#!/bin/sh
# agent-notifications.sh <title> <message>
#
# Sends a local Hammerspoon notification and, if enabled, a push notification
# via ntfy.sh to iPhone/Apple Watch.
#
# Toggle push notifications on/off with `pn` in the shell.
# On first use, `pn` will prompt for your ntfy.sh topic.
#
# Config files (managed by `pn`):
#   ~/.ntfy_topic   — ntfy.sh topic string (written once, never deleted)
#   ~/.ntfy_enabled — flag file; present = on, absent = off

title="$1"
message="$2"

if [ -f "$HOME/.ntfy_enabled" ]; then
  # Away from computer — send push notification to phone/watch
  topic=$(cat "$HOME/.ntfy_topic" 2>/dev/null)
  if [ -n "$topic" ]; then
    curl -s -o /dev/null -m 5 "https://ntfy.sh/$topic" \
      -H "Title: $title" \
      -d "$message"
  fi
else
  # At computer — show local Hammerspoon notification
  # hs_payload=$(printf '%s' "$title: $message" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
  # hs -c "showNotification($hs_payload)" >/dev/null 2>&1 < /dev/null

  # At computer — show sketchybar notification
  ~/.config/sketchybar/notify.sh --text "$title: $message" --duration 8 --bg 0xff000000 --fg 0xffaeffae
fi
