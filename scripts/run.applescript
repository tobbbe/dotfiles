#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Run script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⬛
# @raycast.argument1 { "type": "text", "placeholder": "Command", "optional": true }
# @raycast.argument2 { "type": "text", "placeholder": "Kill", "optional": true }

cmd="$1"
kill="$2"

echo "command: $cmd"

if [ -z "$cmd" ] ; then
    osascript -e "tell application \"iTerm\"" -e "create window with default profile" -e "end tell"
else
	osascript -e "tell application \"iTerm\"" -e "create window with default profile" -e "tell current session of current window" -e "write text \"$cmd\"" -e "end tell" -e "end tell"
fi

# if kill is set, close the window
if [ -n "$kill" ] ; then
    osascript -e "tell application \"iTerm\"" -e "close current window" -e "end tell"
fi