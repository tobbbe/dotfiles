#!/usr/bin/env bash

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    osascript -e 'display notification "Vercel CLI is not installed. Run: npm i -g vercel" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Check if authenticated
if ! vercel whoami &> /dev/null 2>&1; then
    osascript -e 'display notification "Not authenticated with Vercel. Run: vercel login" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Fetch all projects
PROJECTS_JSON=$(vercel projects ls --json 2>/dev/null)

if [ -z "$PROJECTS_JSON" ]; then
    osascript -e 'display notification "Failed to fetch Vercel projects" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Parse project names
PROJECTS=$(echo "$PROJECTS_JSON" | jq -r '.[].name' 2>/dev/null)

if [ -z "$PROJECTS" ]; then
    osascript -e 'display notification "No Vercel projects found" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Remove existing popup items
sketchybar --remove '/vercel\.project\..*/' 2>/dev/null

# Create popup items for each project
INDEX=0
while IFS= read -r project; do
    if [ -n "$project" ]; then
        sketchybar --add item "vercel.project.$INDEX" popup.vercel \
                   --set "vercel.project.$INDEX" \
                         label="$project" \
                         click_script="$PLUGIN_DIR/vercel_select.sh '$project'"
        INDEX=$((INDEX + 1))
    fi
done <<< "$PROJECTS"

# Toggle popup visibility
sketchybar --set vercel popup.drawing=toggle
