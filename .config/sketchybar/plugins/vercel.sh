#!/usr/bin/env bash

STATE_FILE="/tmp/sketchybar_vercel_state.json"
ICON=""

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
DEPLOYMENT_JSON=$(vercel ls "$PROJECT" --json 2>/dev/null | jq '.[0]' 2>/dev/null)

if [ -z "$DEPLOYMENT_JSON" ] || [ "$DEPLOYMENT_JSON" = "null" ]; then
    sketchybar --set "$NAME" icon="$ICON" label="No deployments"
    exit 0
fi

# Parse deployment info
STATE=$(echo "$DEPLOYMENT_JSON" | jq -r '.state // .status // "UNKNOWN"')
# Get commit message or branch
COMMIT=$(echo "$DEPLOYMENT_JSON" | jq -r '.meta.githubCommitMessage // .meta.gitCommitMessage // ""' 2>/dev/null | head -c 40)
BRANCH=$(echo "$DEPLOYMENT_JSON" | jq -r '.meta.githubCommitRef // .meta.gitCommitRef // ""' 2>/dev/null)

# Determine status icon and if still building
case "$STATE" in
    READY|ready)
        STATUS_ICON="✓"
        IS_BUILDING_NOW="false"
        ;;
    ERROR|error|FAILED|failed)
        STATUS_ICON="✗"
        IS_BUILDING_NOW="false"
        ;;
    BUILDING|building|QUEUED|queued|INITIALIZING|initializing)
        STATUS_ICON="⏳"
        IS_BUILDING_NOW="true"
        ;;
    *)
        STATUS_ICON="?"
        IS_BUILDING_NOW="false"
        ;;
esac

# Build label with full details
LABEL="$STATUS_ICON $PROJECT"
if [ -n "$BRANCH" ]; then
    LABEL="$LABEL [$BRANCH]"
fi
if [ -n "$COMMIT" ]; then
    LABEL="$LABEL: $COMMIT"
fi

# Update state file
jq -n \
    --arg project "$PROJECT" \
    --arg is_building "$IS_BUILDING_NOW" \
    --arg label "$LABEL" \
    '{project: $project, is_building: ($is_building == "true"), label: $label}' \
    > "$STATE_FILE"

# Update display
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
