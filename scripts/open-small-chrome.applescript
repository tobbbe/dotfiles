#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open small chrome window
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📺

tell application "Google Chrome" to activate

tell application "System Events"
	tell process "Google Chrome"
		click menu item "New Window" of menu "File" of menu bar 1
	end tell
end tell

tell first window of application "Google Chrome" to set bounds to {700, 400, 1300, 900}