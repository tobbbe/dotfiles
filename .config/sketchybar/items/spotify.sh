#!/bin/bash

# Initialization
sketchybar --add item spotify left

# Config
SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
sketchybar --add event spotify_change $SPOTIFY_EVENT
# sketchybar --set spotify icon=󰝚
sketchybar --set spotify padding_left=0 \
                      label.padding_left=1
sketchybar --set spotify script="$PLUGIN_DIR/spotify.sh"
sketchybar --subscribe spotify spotify_change

# Overrides of default settings
# sketchybar --set spotify background.color=0xff121212
