#!/bin/sh
CONFIG="$HOME/.paneru.toml"

awk '
  /^\[options\]/ { in_options=1 }
  /^\[/ && !/^\[options\]/ { in_options=0 }
  in_options && /^auto_center/ {
    if (/true/) sub(/true/, "false")
    else sub(/false/, "true")
  }
  { print }
' "$CONFIG" > "$CONFIG.tmp" && cp "$CONFIG.tmp" "$CONFIG" && rm "$CONFIG.tmp"

