#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ff
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Find file

osascript -e 'tell application "iTerm2"
    activate
    tell current window
        create tab with default profile
        tell the current session
            write text "ff ~/dev; exit"
        end tell
    end tell
end tell'