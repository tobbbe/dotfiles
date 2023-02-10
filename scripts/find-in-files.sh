#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title fif
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Find in files

osascript -e 'tell application "iTerm2"
    activate
    tell current window
        create tab with default profile
        tell the current session
            write text "fif ~/dev; exit"
        end tell
    end tell
end tell'