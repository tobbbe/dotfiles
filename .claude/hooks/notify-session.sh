#!/bin/sh

payload=$(python3 -c '
import json
import os
import pathlib
import sys

data = json.load(sys.stdin)
cwd = pathlib.Path(data.get("cwd") or "").name or "unknown"
session_id = data.get("session_id") or "unknown"
message = f"Claude Code: {cwd} - {session_id} completed"
print(json.dumps(message))
')

hs -c "showNotification($payload)" >/dev/null 2>&1 < /dev/null
