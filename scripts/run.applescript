#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rrun script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⬛
# @raycast.argument1 { "type": "text", "placeholder": "Command", "optional": true }

cmd="$1"

echo "command: $cmd"

if [ -z "$cmd" ] ; then
    osascript -e "tell application \"iTerm\"" -e "create window with default profile" -e "end tell"
else
	osascript -e "tell application \"iTerm\"" -e "create window with default profile" -e "tell current session of current window" -e "write text \"$cmd\"" -e "end tell" -e "end tell"
fi