#!/bin/sh

eval "$(python3 -c '
import json, pathlib, sys, shlex

data = json.load(sys.stdin)
cwd = pathlib.Path(data.get("cwd") or "").name or "unknown-cwd"
reason = data.get("reason") or "completed"
print("cwd=" + shlex.quote(cwd))
print("reason=" + shlex.quote(reason))
')"

~/dev/dotfiles/scripts/agent-notifications.sh "$cwd" "$reason" &
