#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Status
# @raycast.mode inline

# Conditional parameters:
# @raycast.refreshTime 30s

# Optional parameters:
# @raycast.icon 🍅
# @raycast.packageName Pomodoro

# Documentation:
# @raycast.description Status of a Pomodoro timer
# @raycast.author Thomas Paul Mann
# @raycast.authorURL https://github.com/thomaspaulmann

FILENAME="pomodoro_timer_end.txt"

if [ -f "$FILENAME" ]; then
  END=$(cat $FILENAME)
  NOW=$(date +"%s")
  TIME_REMAINING_IN_MINUTES=$(( ($END - $NOW) / 60 ))

  if [ "$TIME_REMAINING_IN_MINUTES" -lt "-2" ]; then
    rm $FILENAME
    echo -e "\\033[31mTimer ended\\033[0m"
  elif [ "$TIME_REMAINING_IN_MINUTES" -lt "0" ]; then
    echo -e "\\033[31mTimer ended\\033[0m"
    say 'Take a break for fuck sake!'
    osascript -e 'display dialog "Timer ended, take a break!" with icon POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarFavoritesIcon.icns"'
    rm $FILENAME
    # osascript -e 'display alert "Pomodoro" message "Timer ended, take a break!"'
    # osascript -e 'display dialog "Timer ended, take a break!" with icon ToolbarFavoritesIcon'
    # osascript -e 'display notification "Timer ended, take a break!" with title "Pomodoro"'
  elif [ "$TIME_REMAINING_IN_MINUTES" -lt "3" ]; then
    echo -e "\\033[31m$TIME_REMAINING_IN_MINUTES minutes remaining\\033[0m"  
  elif [ "$TIME_REMAINING_IN_MINUTES" -lt "10" ]; then
    echo -e "\\033[33m$TIME_REMAINING_IN_MINUTES minutes remaining\\033[0m"  
  else
    echo -e "\\033[32m$TIME_REMAINING_IN_MINUTES minutes remaining\\033[0m"  
  fi
else 
  echo "No active timer"
fi