#!/bin/bash

# IMPORTANT!
# Files with osascript doesnt seems to work well with raycast scripts
# So its better to use with Karabiner, because then you can use 'frontmost_application_if'

osascript -e 'tell application "System Events"' -e 'keystroke "1" using {command down}' -e 'keystroke "b" using {command down, option down, control down}' -e 'end tell'