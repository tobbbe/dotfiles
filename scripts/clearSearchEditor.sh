#!/bin/bash

# IMPORTANT!
# Files with osascript doesnt seems to work well with raycast scripts
# So its better to use with Karabiner, because then you can use 'frontmost_application_if'

osascript -e 'tell application "System Events"' -e 'key code 53' -e 'key code 53' -e 'keystroke "e" using {command down}' -e 'keystroke "1" using {command down}' -e 'end tell'