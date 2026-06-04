#!/usr/bin/env bash

# Session switcher for kitty.
# Lists running sessions (current first, with a dot) plus any defined-but-not-
# running sessions from ~/.config/kitty/sessions, in an fzf "modal". Running
# sessions switch with goto_session <name>; not-running ones open by file path.
# Launched as an overlay (see `map cmd+b>g` in kitty.conf). Starts in fzf input.
#
# Inspired by:
# https://github.com/linkarzu/dotfiles-latest/blob/main/kitty/scripts/kitty-list-sessions.sh

set -euo pipefail

# kitty launched as a macOS .app has a minimal PATH (no Homebrew), and this
# script runs non-interactively so no profile is sourced. Make brew bins findable.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"

# Inside an overlay window KITTY_LISTEN_ON points at this instance's socket,
# so `kitty @` auto-connects to the right instance. Fall back to it explicitly.
to_arg=()
if [[ -n "${KITTY_LISTEN_ON:-}" ]]; then
  to_arg=(--to "${KITTY_LISTEN_ON}")
fi

command -v fzf >/dev/null 2>&1 || { echo "fzf not found (brew install fzf)"; sleep 2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found (brew install jq)"; sleep 2; exit 1; }
[[ -x "$kitty_bin" ]] || { echo "kitty not found at $kitty_bin"; sleep 2; exit 1; }

ls_json="$("$kitty_bin" @ "${to_arg[@]}" ls 2>/dev/null || true)"
if [[ -z "$ls_json" ]]; then
  echo "Could not talk to kitty remote control."
  sleep 2
  exit 1
fi

# Running sessions: name<TAB>current<TAB>last, most-recently-focused first.
# The focused window under the overlay still reports os_focused && tab_focused,
# so the underlying session is flagged current. The overlay window itself has a
# null session_name and is filtered out.
running_tsv="$(
  printf '%s' "$ls_json" | jq -r '
    [ .[] as $os
      | $os.tabs[] as $tab
      | $tab.windows[]?
      | select(.session_name != null and .session_name != "")
      | { name: .session_name,
          current: (($os.is_focused // false) and ($tab.is_focused // false)),
          last: (.last_focused_at // 0) }
    ]
    | group_by(.name)
    | map({ name: .[0].name,
            current: (map(.current) | any),
            last: (map(.last) | max) })
    | sort_by(-.last, .name)
    | .[]
    | [ .name, (.current|tostring), (.last|tostring) ] | @tsv
  '
)"

sessions_dir="$HOME/.config/kitty/sessions"
running_names="$(printf '%s\n' "$running_tsv" | awk -F'\t' 'NF{print $1}')"
current_session="$(printf '%s\n' "$running_tsv" | awk -F'\t' '$2=="true"{print $1; exit}')"

is_running() { printf '%s\n' "$running_names" | grep -qxF "$1"; }

# Colors for the list (needs fzf --ansi).
e=$'\033'; cur_fg="${e}[1;32m"; dim="${e}[90m"; reset="${e}[0m"

# Each menu line: name<TAB>running(0|1)<TAB>path<TAB>display
# Order: current session (with dot) first, then other running by recency,
# then defined-but-not-running sessions (alphabetical, dimmed).
build_menu() {
  local name cur f n
  if [[ -n "$current_session" ]]; then
    printf '%s\t1\t%s\t%s\n' \
      "$current_session" "$sessions_dir/$current_session.kitty-session" \
      "${cur_fg}${current_session}${reset}"
  fi
  while IFS=$'\t' read -r name cur _; do
    [[ -z "$name" || "$name" == "$current_session" ]] && continue
    printf '%s\t1\t%s\t%s\n' "$name" "$sessions_dir/$name.kitty-session" "$name"
  done <<< "$running_tsv"
  for f in "$sessions_dir"/*.kitty-session; do
    [[ -e "$f" ]] || continue
    n="$(basename "$f" .kitty-session)"
    is_running "$n" && continue
    printf '%s\t0\t%s\t%s%s%s\n' "$n" "$f" "$dim" "$n" "$reset"
  done
}

menu="$(build_menu)"
if [[ -z "$menu" ]]; then
  echo "No sessions found."
  sleep 1.5
  exit 0
fi

# Top-left, no border, no header, no info line. Current session shown first
# with a green dot; running sessions plain; not-running sessions dimmed.
selection="$(
  printf '%s\n' "$menu" | fzf \
    --ansi \
    --delimiter='\t' \
    --with-nth=4 \
    --height=60% \
    --reverse \
    --margin=0,45%,0,0 \
    --info=hidden \
    --prompt="❯ " \
    --color="prompt:#a6e3a1,pointer:#f38ba8" \
    --no-multi \
    --bind 'esc:abort' \
    || true
)"

[[ -z "$selection" ]] && exit 0

IFS=$'\t' read -r sel_name sel_running sel_path _ <<< "$selection"

# Running sessions switch by name; not-running sessions open by file path.
if [[ "$sel_running" == "1" ]]; then
  "$kitty_bin" @ "${to_arg[@]}" action goto_session "$sel_name"
else
  "$kitty_bin" @ "${to_arg[@]}" action goto_session "$sel_path"
fi
