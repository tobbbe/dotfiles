#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title fp
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Find project

osascript -e 'tell application "iTerm2"
    activate
    tell current window
        create tab with default profile
        tell the current session
            write text "fp; exit"
        end tell
    end tell
end tell'
