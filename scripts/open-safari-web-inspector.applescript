#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open safari web inspector
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📺

set device_name to "Simulator - iPhone X - iOS 11.4 (15F79)"
tell application "Safari"
	activate
	delay 1
	tell application "System Events"
		click menu item "10.90.25.148" of menu 1 of menu item 4 of menu 1 of menu bar item "Utvecklare" of menu bar 1 of application process "Safari"
	end tell
end tell