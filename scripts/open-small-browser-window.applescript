#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open small browser window
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐

tell application "Firefox" to activate

tell application "System Events"
	tell process "Firefox"
		click menu item "New Private Window" of menu "File" of menu bar 1
	end tell
	delay .2
	tell first window of application "Firefox" to set bounds to {700, 400, 1300, 900}
end tell
