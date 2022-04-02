#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle mic
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📺

set old to (path to frontmost application as text)
activate application "Microsoft Teams"
tell application "System Events" to keystroke "m" using {shift down, command down}
activate application old

(* 
on getMicrophoneVolume()
	input volume of (get volume settings)
end getMicrophoneVolume
on disableMicrophone()
	display notification "Microphone OFF" with title "Sound input" subtitle "Disabled"
	set volume input volume 0
end disableMicrophone
on enableMicrophone()
	display notification "Microphone ON" with title "Sound input" subtitle "Enabled"
	set volume input volume 100
end enableMicrophone

if getMicrophoneVolume() is greater than 0 then
	disableMicrophone()
else
	enableMicrophone()
end if
 *)
