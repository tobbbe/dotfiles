#!/bin/bash

# Open Ghostty
open -a Ghostty

# Wait for Ghostty to become frontmost
max_attempts=10
attempt=0
while [[ "$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')" != "ghostty" ]] && [ $attempt -lt $max_attempts ]; do
  sleep 0.005
  ((attempt++))
done

# Small additional delay to ensure Ghostty is fully ready
sleep 0.02

# Send f16 key (key code 106)
osascript -e 'tell application "System Events" to key code 106'
