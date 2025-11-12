#!/usr/bin/env bash

export PATH="$HOME/.volta/bin:$PATH"

STATE_FILE="/tmp/sketchybar_vercel_state.json"
ICON="▲"

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    osascript -e 'display notification "Vercel CLI is not installed. Run: npm i -g vercel" with title "Sketchybar Vercel Plugin"' &
    sketchybar --set "$NAME" icon="$ICON" label=""
    exit 1
fi

# Check if authenticated
if ! vercel whoami &> /dev/null 2>&1; then
    osascript -e 'display notification "Not authenticated with Vercel. Run: vercel login" with title "Sketchybar Vercel Plugin"' &
    sketchybar --set "$NAME" icon="$ICON" label=""
    exit 1
fi

# Read state file
if [ ! -f "$STATE_FILE" ]; then
    # No state file, just show icon
    sketchybar --set "$NAME" icon="$ICON" label=""
    exit 0
fi

# Parse state
PROJECT=$(jq -r '.project // empty' "$STATE_FILE" 2>/dev/null)
IS_BUILDING=$(jq -r '.is_building // false' "$STATE_FILE" 2>/dev/null)

if [ -z "$PROJECT" ] || [ "$PROJECT" = "null" ]; then
    # No project selected
    sketchybar --set "$NAME" icon="$ICON" label=""
    exit 0
fi

# If not building, don't poll
if [ "$IS_BUILDING" = "false" ]; then
    # Just display the cached status
    CACHED_LABEL=$(jq -r '.label // ""' "$STATE_FILE" 2>/dev/null)
    sketchybar --set "$NAME" icon="$ICON" label="$CACHED_LABEL"
    exit 0
fi

# Fetch latest deployment for the project
DEPLOYMENT_OUTPUT=$(vercel ls "$PROJECT" 2>&1)

if [ $? -ne 0 ]; then
    sketchybar --set "$NAME" icon="$ICON" label="No deployments"
    exit 0
fi

# Parse the first deployment row (latest)
# Format: "  Age     URL                                     Status      Environment     Duration     Username"
DEPLOYMENT_LINE=$(echo "$DEPLOYMENT_OUTPUT" | awk '/^  [0-9]+[a-z]+[[:space:]]+https/ {print; exit}')

if [ -z "$DEPLOYMENT_LINE" ]; then
    sketchybar --set "$NAME" icon="$ICON" label="No deployments"
    exit 0
fi

# Extract status (look for "● Ready", "● Error", "● Building", etc.)
if echo "$DEPLOYMENT_LINE" | grep -q "● Ready"; then
    STATE="Ready"
elif echo "$DEPLOYMENT_LINE" | grep -q "● Error"; then
    STATE="Error"
elif echo "$DEPLOYMENT_LINE" | grep -q "● Building"; then
    STATE="Building"
elif echo "$DEPLOYMENT_LINE" | grep -q "● Queued"; then
    STATE="Queued"
else
    STATE="Unknown"
fi

# Determine status icon and if still building
case "$STATE" in
    Ready)
        STATUS_ICON="✓"
        IS_BUILDING_NOW="false"
        ;;
    Error)
        STATUS_ICON="✗"
        IS_BUILDING_NOW="false"
        ;;
    Building|Queued)
        STATUS_ICON="⏳"
        IS_BUILDING_NOW="true"
        ;;
    *)
        STATUS_ICON="?"
        IS_BUILDING_NOW="false"
        ;;
esac

# Build label
LABEL="$STATUS_ICON $PROJECT"

# Update state file
jq -n \
    --arg project "$PROJECT" \
    --arg is_building "$IS_BUILDING_NOW" \
    --arg label "$LABEL" \
    '{project: $project, is_building: ($is_building == "true"), label: $label}' \
    > "$STATE_FILE"

# Update display
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
