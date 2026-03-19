#!/bin/sh

message=$(python3 -c '
import json, pathlib, sys

data = json.load(sys.stdin)
cwd = pathlib.Path(data.get("cwd") or "").name or "unknown"
session_id = data.get("session_id") or "unknown"
print(f"{cwd} - {session_id} completed")
')

~/dev/dotfiles/scripts/agent-notifications.sh "Claude Code" "$message"
