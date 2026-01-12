#!/bin/bash

# Resize aerospace window to a percentage of screen width
# Usage: ./aerospace-resize-to-percent.sh 80

TARGET_PERCENT=$1

# Get screen dimensions
SCREEN_INFO=$(system_profiler SPDisplaysDataType | awk '/Main Display: Yes/{found=1} /Resolution/{width=$2; height=$4} /Retina/{scale=($2 == "Yes" ? 2 : 1)} /^ {8}[^ ]+/{if(found) {exit}; scale=1} END{printf "%d %d %d\n", width, height, scale}')
IS_RETINA=$(echo $SCREEN_INFO | awk '{print $3}')

if [ "$IS_RETINA" -eq 1 ]; then
    # Non-retina, use Finder bounds
    SCREEN_WIDTH=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | awk -F', ' '{print $3}')
else
    # Retina, use system_profiler
    SCREEN_WIDTH=$(echo $SCREEN_INFO | awk '{print $1}')
fi

# Get current window size using AppleScript
CURRENT_WIDTH=$(osascript <<EOF
tell application "System Events"
    set activeApp to name of first application process whose frontmost is true
    tell process activeApp
        if subrole of window 1 is "AXUnknown" then
            set activeWindow to 2
        else
            set activeWindow to 1
        end if
        set windowSize to size of window activeWindow
        return item 1 of windowSize
    end tell
end tell
EOF
)

# Calculate target width and difference
TARGET_WIDTH=$(echo "$SCREEN_WIDTH * $TARGET_PERCENT / 100" | bc)
DIFF=$(echo "$TARGET_WIDTH - $CURRENT_WIDTH" | bc)

# Round to integer
DIFF=$(printf "%.0f" $DIFF)

# Send resize command to aerospace
if [ "$DIFF" -gt 0 ]; then
    /opt/homebrew/bin/aerospace resize width +$DIFF
elif [ "$DIFF" -lt 0 ]; then
    DIFF=$(echo "$DIFF * -1" | bc)
    DIFF=$(printf "%.0f" $DIFF)
    /opt/homebrew/bin/aerospace resize width -$DIFF
fi
