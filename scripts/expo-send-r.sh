#!/bin/bash

set -euo pipefail

TARGET_TTY="${1:-}"

resolve_expo_tty() {
  ps -axo pid=,tty=,command= | python3 -c '
import re
import sys

lines = [line.rstrip("\n") for line in sys.stdin if line.strip()]
best = None

patterns = [
    (re.compile(r"\bexpo\s+start\b"), 8),
    (re.compile(r"\bnpx\s+expo\b"), 7),
    (re.compile(r"@expo/cli"), 6),
    (re.compile(r"\breact-native\s+start\b"), 5),
    (re.compile(r"\bmetro\b"), 3),
    (re.compile(r"\bexpo\b"), 2),
]

for row in lines:
    parts = row.strip().split(None, 2)
    if len(parts) < 3:
        continue

    pid_raw, tty, command = parts
    if tty == "??":
        continue

    try:
        pid = int(pid_raw)
    except ValueError:
        continue

    lowered = command.lower()
    if "expo-send-r.sh" in lowered:
        continue

    score = 0
    for pattern, weight in patterns:
        if pattern.search(lowered):
            score = max(score, weight)

    if score == 0:
        continue

    candidate = (score, pid, tty)
    if best is None or candidate > best:
        best = candidate

if best is None:
    sys.exit(1)

print(best[2])
'
}

if [ -n "$TARGET_TTY" ]; then
  target_tty="${TARGET_TTY#/dev/}"
else
  target_tty="$(resolve_expo_tty || true)"
fi

if [ -z "$target_tty" ]; then
  echo "Could not find a running Expo/Metro process with a TTY."
  echo "Tip: pass a TTY explicitly, for example: ./scripts/expo-send-r.sh /dev/ttys012"
  exit 1
fi

tty_path="/dev/$target_tty"

pane_id=""
if command -v tmux >/dev/null 2>&1; then
  pane_id=$(tmux list-panes -a -F "#{pane_id} #{pane_tty}" | awk -v tty="$tty_path" '$2 == tty { print $1; exit }')
fi

if [ -n "$pane_id" ]; then
  tmux send-keys -t "$pane_id" r
  echo "Sent r to tmux pane $pane_id ($tty_path)"
  exit 0
fi

echo "Found Expo TTY $tty_path, but no tmux pane matched."
echo "Direct TTY writes only print output and cannot trigger input handlers on macOS."
echo "Run Expo inside tmux to use this script, or trigger reload from the Expo terminal window."
exit 1
