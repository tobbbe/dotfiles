#!/usr/bin/env bash

SESSION=$(tmux display-message -p '#S')
WINDOW_COUNT=$(tmux list-windows -t "$SESSION" | wc -l)

if [ "$WINDOW_COUNT" -gt 1 ]; then
  # Multiple windows → join all into panes in the first window
  FIRST=$(tmux list-windows -t "$SESSION" -F '#I' | head -1)
  while [ "$(tmux list-windows -t "$SESSION" | wc -l)" -gt 1 ]; do
    NEXT=$(tmux list-windows -t "$SESSION" -F '#I' | grep -v "^${FIRST}$" | head -1)
    tmux join-pane -s "${SESSION}:${NEXT}" -t "${SESSION}:${FIRST}"
  done
else
  # Single window with panes → break each pane into its own window
  CURRENT=$(tmux display-message -p '#I')
  while [ "$(tmux list-panes -t "${SESSION}:${CURRENT}" | wc -l)" -gt 1 ]; do
    LAST=$(tmux list-panes -t "${SESSION}:${CURRENT}" -F '#P' | tail -1)
    tmux break-pane -d -s "${SESSION}:${CURRENT}.${LAST}"
  done
fi
