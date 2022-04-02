#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set window size
# @raycast.mode silent

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Preset" }
# @raycast.icon 📺

on run argv
	set preset to (item 1 of argv)

	if preset is "chrome"
		set xStartPercent to 10
		set yStartPercent to 0
		set widthPercent to 80
		set heightPercent to 100
	else if preset is "chrome-dev"
		set xStartPercent to 0
		set yStartPercent to 0
		set widthPercent to 80
		set heightPercent to 100
	else if preset is "vscode"
		set xStartPercent to 50
		set yStartPercent to 0
		set widthPercent to 50
		set heightPercent to 100
	else
		return
	end if


	#tell application "Finder"
	#set desktopBounds to bounds of window of desktop
	#end tell

	# https://stackoverflow.com/a/23452100/1320551
	set desktopBounds to words of (do shell script "system_profiler SPDisplaysDataType | awk '/Main Display: Yes/{found=1} /Resolution/{width=$2; height=$4} /Retina/{scale=($2 == \"Yes\" ? 2 : 1)} /^ {8}[^ ]+/{if(found) {exit}; scale=1} END{printf \"%d %d %d\\n\", width, height, scale}'")

	set screenWidth to item 1 of desktopBounds
	set screenHeight to item 2 of desktopBounds

	tell application "System Events"
		set activeApp to name of first application process whose frontmost is true
		tell process activeApp
			if subrole of window 1 is "AXUnknown" then
				set activeWindow to 2
			else
				set activeWindow to 1
			end if
			
			set xStartPx to screenWidth * (xStartPercent / 100)
			set yStartPx to screenHeight * (yStartPercent / 100)
			set xEndPx to screenWidth * (widthPercent / 100)
			set yEndPx to screenHeight * (heightPercent / 100)
			
			set position of window activeWindow to {xStartPx, yStartPx}
			set size of window activeWindow to {xEndPx, yEndPx}
		end tell
	end tell

end run