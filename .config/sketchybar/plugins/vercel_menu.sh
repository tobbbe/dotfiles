#!/usr/bin/env bash

export PATH="$HOME/.volta/bin:$PATH"

PLUGIN_DIR="$HOME/dev/dotfiles/.config/sketchybar/plugins"
CACHE_FILE="/tmp/sketchybar_vercel_projects_cache"
CACHE_DURATION=300  # 5 minutes
CONFIG_FILE="$HOME/.config/sketchybar/vercel_teams.conf"

# Function to fetch projects from all configured teams
fetch_projects() {
    local all_projects=""

    # Read teams from config file
    if [ ! -f "$CONFIG_FILE" ]; then
        # No config file, fetch from current team
        local projects_output=$(vercel project ls 2>&1)
        if [ $? -eq 0 ]; then
            all_projects=$(echo "$projects_output" | awk '/^  [a-zA-Z0-9_-]+[[:space:]]/ {print $1}' | grep -v "^Project$")
        fi
    else
        # Fetch from each configured team
        while IFS= read -r team; do
            # Skip empty lines and comments
            [[ -z "$team" || "$team" =~ ^# ]] && continue

            local projects_output=$(vercel project ls --scope "$team" 2>&1)
            if [ $? -eq 0 ]; then
                local team_projects=$(echo "$projects_output" | awk '/^  [a-zA-Z0-9_-]+[[:space:]]/ {print $1}' | grep -v "^Project$")
                if [ -n "$team_projects" ]; then
                    if [ -z "$all_projects" ]; then
                        all_projects="$team_projects"
                    else
                        all_projects="$all_projects
$team_projects"
                    fi
                fi
            fi
        done < "$CONFIG_FILE"
    fi

    echo "$all_projects"
}

# Function to display projects in popup
display_projects() {
    local projects="$1"

    # Remove existing popup items
    sketchybar --remove '/vercel\.project\..*/' 2>/dev/null
    sketchybar --remove '/vercel\.loading/' 2>/dev/null

    if [ -z "$projects" ]; then
        sketchybar --add item "vercel.loading" popup.vercel \
                   --set "vercel.loading" \
                         label="No projects found" \
                         background.drawing=on \
                         background.color=0xff1a1a1a \
                         background.corner_radius=5 \
                         background.padding_left=10 \
                         background.padding_right=10 \
                         background.height=25
    else
        # Create popup items for each project
        local index=0
        while IFS= read -r project; do
            if [ -n "$project" ]; then
                sketchybar --add item "vercel.project.$index" popup.vercel \
                           --set "vercel.project.$index" \
                                 label="$project" \
                                 click_script="$PLUGIN_DIR/vercel_select.sh '$project'" \
                                 background.drawing=on \
                                 background.color=0xff1a1a1a \
                                 background.corner_radius=5 \
                                 background.padding_left=10 \
                                 background.padding_right=10 \
                                 background.height=25
                index=$((index + 1))
            fi
        done <<< "$projects"
    fi

}

# Check if popup is currently open (do this first, it's fast)
POPUP_STATE=$(sketchybar --query vercel | jq -r '.popup.drawing')

# Check if cache exists and is fresh - use immediately without verification
if [ -f "$CACHE_FILE" ]; then
    cache_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    cache_age=$((current_time - cache_time))

    if [ $cache_age -lt $CACHE_DURATION ]; then
        # Cache is fresh, use it immediately (no need to verify vercel CLI)
        cached_projects=$(cat "$CACHE_FILE")
        display_projects "$cached_projects"

        # Toggle popup visibility
        sketchybar --set vercel popup.drawing=toggle

        # Update cache in background if getting old (over 4 minutes)
        if [ $cache_age -gt 240 ]; then
            (
                if command -v vercel &> /dev/null && vercel whoami &> /dev/null 2>&1; then
                    fetch_projects > "$CACHE_FILE"
                fi
            ) &
        fi
        exit 0
    fi
fi

# Need to fetch - now verify CLI is available
if ! command -v vercel &> /dev/null; then
    osascript -e 'display notification "Vercel CLI is not installed. Run: npm i -g vercel" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Check if authenticated
if ! vercel whoami &> /dev/null 2>&1; then
    osascript -e 'display notification "Not authenticated with Vercel. Run: vercel login" with title "Sketchybar Vercel Plugin"' &
    exit 1
fi

# Show loading indicator immediately if popup was off
if [ "$POPUP_STATE" = "off" ]; then
    sketchybar --remove '/vercel\.project\..*/' 2>/dev/null
    sketchybar --remove '/vercel\.loading/' 2>/dev/null
    sketchybar --add item "vercel.loading" popup.vercel \
               --set "vercel.loading" \
                     label="Loading projects..." \
                     background.drawing=on \
                     background.color=0xff1a1a1a \
                     background.corner_radius=5 \
                     background.padding_left=10 \
                     background.padding_right=10 \
                     background.height=25
    sketchybar --set vercel popup.drawing=on
fi

# Fetch projects in foreground (since user is waiting)
PROJECTS=$(fetch_projects)

# Cache the results
if [ -n "$PROJECTS" ]; then
    echo "$PROJECTS" > "$CACHE_FILE"
fi

# If popup was off, display projects (popup stays on)
if [ "$POPUP_STATE" = "off" ]; then
    display_projects "$PROJECTS"
else
    # Popup was on, so close it
    sketchybar --set vercel popup.drawing=off
fi
