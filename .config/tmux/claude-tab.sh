#!/usr/bin/env bash
# Tag each tmux window whose active pane is actually running `claude`.
#
# tmux's #{pane_current_command} reports Claude's spoofed process title (its
# version, e.g. "2.1.156"), which is ambiguous — any program that titles itself
# N.N.N would look identical. So we check the REAL executable name (comm) via
# ps and set a @claude flag the tab format can read. Driven from status-interval.
tmux list-panes -a -F '#{window_id} #{pane_active} #{pane_tty}' 2>/dev/null |
  while read -r win active tty; do
    [ "$active" = 1 ] || continue
    if ps -t "${tty#/dev/}" -o comm= 2>/dev/null | grep -Eq '(^|/)claude$'; then
      tmux set-option -w -t "$win" @claude 1
    else
      tmux set-option -wu -t "$win" @claude 2>/dev/null
    fi
  done
