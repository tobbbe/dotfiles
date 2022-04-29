#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title js console
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 👨‍💻

tell application "Chrome"
	activate
	tell application "System Events" to keystroke "t" using {command down}
	tell application "System Events" to keystroke "j" using {option down, command down}
	delay 2
	tell application "System Events" to keystroke "l" using {control down}
	tell application "System Events" to keystroke tab
end tell