#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title zendesk
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📺

tell application "Google Chrome"
	repeat with w in windows
		set i to 1
		repeat with t in tabs of w
			if URL of t starts with "https://daybright.zendesk" then
				set active tab index of w to i
				set index of w to 1
				return
			end if
			set i to i + 1
		end repeat
	end repeat
	open location "https://daybright.zendesk.com/agent"
end tell