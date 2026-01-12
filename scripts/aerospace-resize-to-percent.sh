#!/bin/bash

# Resize aerospace window to a percentage of screen width
# Usage: ./aerospace-resize-to-percent.sh 80

TARGET_PERCENT=$1

# Get screen width and current window width in a single AppleScript call
read SCREEN_WIDTH CURRENT_WIDTH < <(osascript <<'EOF'
tell application "Finder"
    set screenWidth to item 3 of (get bounds of window of desktop)
end tell
tell application "System Events"
    set activeApp to name of first application process whose frontmost is true
    tell process activeApp
        if subrole of window 1 is "AXUnknown" then
            set activeWindow to 2
        else
            set activeWindow to 1
        end if
        set windowSize to size of window activeWindow
        set windowWidth to item 1 of windowSize
    end tell
end tell
return (screenWidth as text) & " " & (windowWidth as text)
EOF
)

# Calculate and apply resize
TARGET_WIDTH=$((SCREEN_WIDTH * TARGET_PERCENT / 100))
DIFF=$((TARGET_WIDTH - CURRENT_WIDTH))

if [ "$DIFF" -gt 0 ]; then
    /opt/homebrew/bin/aerospace resize width +$DIFF
elif [ "$DIFF" -lt 0 ]; then
    /opt/homebrew/bin/aerospace resize width ${DIFF#-}
fi
