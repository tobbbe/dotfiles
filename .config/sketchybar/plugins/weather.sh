#!/usr/bin/env bash

# Cache file for weather data
CACHE_FILE="/tmp/sketchybar_weather_cache"
CACHE_DURATION=1800  # 30 minutes

# Function to get current temperature
get_current_temperature() {
    local response=$(curl -s --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=57.7814&longitude=14.1562&hourly=temperature_2m" 2>/dev/null)
    local current_hour=$(date -u +"%Y-%m-%dT%H:00")
    
    if [ -n "$response" ] && echo "$response" | grep -q '"temperature_2m"'; then
        local temp=$(echo "$response" | jq -r --arg hour "$current_hour" '
            .hourly.time as $times | 
            .hourly.temperature_2m as $temps | 
            ($times | index($hour)) as $index | 
            if $index then $temps[$index] else null end
        ' 2>/dev/null)
        
        if [ -n "$temp" ] && [ "$temp" != "null" ]; then
            local rounded_temp=$(printf "%.0f" "$temp")
            echo "${rounded_temp}°C"
        else
            echo "Weather unavailable"
        fi
    else
        echo "Weather unavailable"
    fi
}

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    cache_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    
    if [ $((current_time - cache_time)) -lt $CACHE_DURATION ]; then
        weather=$(cat "$CACHE_FILE")
    else
        weather=$(get_current_temperature)
        echo "$weather" > "$CACHE_FILE"
    fi
else
    weather=$(get_current_temperature)
    echo "$weather" > "$CACHE_FILE"
fi

# Extract temperature and condition
if [[ "$weather" =~ ([0-9.-]+°[CF]) ]]; then
    temp="${BASH_REMATCH[1]}"
    sketchybar --set "$NAME" label="$temp"
else
    sketchybar --set "$NAME" label="N/A"
fi
