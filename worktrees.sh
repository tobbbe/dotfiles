# Worktree helpers and commands
#
# Decision: wt/wx worktree flow
# - wt shows an fzf picker.
# - wt picker entries are animal slots; existing canonical worktrees use the same entries.
# - Canonical worktrees live in ~/.devworktrees/<repo>/<animal> to avoid inheriting parent repo dependencies like node_modules.
# - wt/wx only manage canonical worktrees under ~/.devworktrees/<repo>/.
# - Worktree name, branch name, Kitty title, and tmux session suffix all use the same animal name, e.g. fox.
# - If a worktree is selected in the wt picker and already open, wt errors with a message.
# - Already open means any Kitty tab/window has the exact title for that worktree, e.g. fox.
# - If the selected worktree is not open, wt creates the worktree if needed.
# - Creating a missing worktree means git worktree add ~/.devworktrees/<repo>/fox -b fox main if branch fox does not exist, or git worktree add ~/.devworktrees/<repo>/fox fox if it does.
# - Existing worktrees must already be on the matching branch name. If not, wt errors instead of switching branches.
# - If the selected worktree is not open, already exists, and has a matching tmux session, wt creates the Kitty windows and connects to the existing tmux session.
# - If the selected worktree is not open and has no matching tmux session, wt creates the Kitty windows and tmux session.
# - wx tears down everything and errors first if the worktree is dirty.
# - Dirty includes untracked files.
# - wx kills the matching tmux session only after the dirty check passes.
# - wx removes the git worktree, then prunes stale worktree refs.
# - wx does not delete the branch. Branch deletion after merge stays explicit.

# Shared setup: name windows, start tmux session, open tmux window, cd + nvim
function _wt_open() {
  local name="$1" worktree_path="$2" session_name="$3" tmux_init_cmd="$4"
  local kitty_remote="/Users/tobbe/.config/kitty/kitty_remote.py"

  # Create tmux session rooted in the worktree (no-op if already exists)
  tmux new-session -d -s "$session_name" -c "$worktree_path" 2>/dev/null

  # Run optional init command inside the tmux session
  [[ -n "$tmux_init_cmd" ]] && tmux send-keys -t "$session_name" "$tmux_init_cmd" Enter

  # Name the current kitty window so the tab follows the active window title
  /usr/bin/python3 "$kitty_remote" set-window-title "$name" 2>/dev/null

  # Open a second kitty window in this tab attached to the tmux session
  /usr/bin/python3 "$kitty_remote" launch --no-response --type=window --cwd "$worktree_path" --title "$name" tmux attach -t "$session_name" 2>/dev/null

  # cd into worktree and open nvim in the first window
  cd "$worktree_path"
  v
}

function _wt_animals() {
  printf '%s\n' wolf bear lion fox otter hawk lynx moose badger raven
}

function _wt_repo_root() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_root" ]; then
    echo "Not in a git repository"
    return 1
  fi

  echo "$repo_root"
}

function _wt_main_root() {
  local repo_root="$1"
  git -C "$repo_root" worktree list --porcelain | awk '/^worktree /{print $2; exit}'
}

function _wt_repo_main_root() {
  local repo_root main_root
  repo_root=$(_wt_repo_root) || return 1
  main_root=$(_wt_main_root "$repo_root")
  if [ -z "$main_root" ]; then
    echo "Could not find main worktree"
    return 1
  fi

  echo "$main_root"
}

function _wt_select() {
  local repo_root="$1" prompt="$2" include_main="$3"
  local main_root selected

  main_root=$(_wt_main_root "$repo_root")
  if [ -z "$main_root" ]; then
    return 1
  fi

  if [ "$include_main" = "true" ]; then
    selected=$(git -C "$repo_root" worktree list --porcelain |
      awk '/^worktree /{print $2}' |
      fzf --prompt="$prompt")
  else
    selected=$(git -C "$repo_root" worktree list --porcelain |
      awk '/^worktree /{print $2}' |
      grep -v "^${main_root}$" |
      fzf --prompt="$prompt")
  fi

  echo "$selected"
}

function _wt_select_name() {
  _wt_animals | fzf --prompt="Worktree: "
}

function _wt_session_name() {
  local repo_root="$1" name="$2"
  local repo_name
  repo_name=$(basename "$repo_root")
  echo "${repo_name}-wt-${name}"
}

function _wt_worktree_base() {
  local repo_root="$1"
  local repo_name
  repo_name=$(basename "$repo_root")
  echo "$HOME/.devworktrees/$repo_name"
}

function _wt_worktree_path() {
  local repo_root="$1" name="$2"
  echo "$(_wt_worktree_base "$repo_root")/$name"
}

function _wt_select_existing_path() {
  local repo_root="$1" prompt="$2"
  local worktree_base

  worktree_base=$(_wt_worktree_base "$repo_root")
  git -C "$repo_root" worktree list --porcelain |
    awk '/^worktree /{print $2}' |
    while IFS= read -r worktree; do
      case "$worktree" in
        "$worktree_base"/*) echo "$worktree" ;;
      esac
    done |
    fzf --prompt="$prompt"
}

function _wt_copy_env_files() {
  local repo_root="$1" worktree_path="$2"
  local f

  for f in "$repo_root"/.env*; do
    [[ -f "$f" ]] && cp "$f" "$worktree_path/"
  done
}

function _wt_is_open() {
  local name="$1"
  local kitty_remote="/Users/tobbe/.config/kitty/kitty_remote.py"
  local kitty_json

  kitty_json=$(/usr/bin/python3 "$kitty_remote" ls 2>/dev/null) || return 1

  /usr/bin/python3 -c '
import json
import sys

name = sys.argv[1]
try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

for os_window in data:
    for tab in os_window.get("tabs", []):
        if tab.get("title") == name or tab.get("name") == name:
            sys.exit(0)
        for window in tab.get("windows", []):
            if window.get("title") == name:
                sys.exit(0)

sys.exit(1)
' "$name" <<<"$kitty_json"
}

function _wt_validate_branch() {
  local name="$1" worktree_path="$2"
  local branch_name

  branch_name=$(git -C "$worktree_path" branch --show-current 2>/dev/null)
  if [ "$branch_name" != "$name" ]; then
    echo "Worktree '$name' is on branch '$branch_name', expected '$name'" >&2
    return 1
  fi
}

function _wt_create_if_needed() {
  local repo_root="$1" name="$2"
  local worktree_path worktree_base

  worktree_base=$(_wt_worktree_base "$repo_root")
  worktree_path=$(_wt_worktree_path "$repo_root" "$name")

  if [ -d "$worktree_path" ] && git -C "$repo_root" worktree list --porcelain | awk '/^worktree /{print $2}' | grep -Fxq "$worktree_path"; then
    _wt_validate_branch "$name" "$worktree_path" || return 1
    echo "$worktree_path"
    return 0
  fi

  if [ -e "$worktree_path" ]; then
    echo "Worktree path exists but is not registered: $worktree_path" >&2
    return 1
  fi

  mkdir -p "$worktree_base"

  if git -C "$repo_root" rev-parse --verify "refs/heads/$name" &>/dev/null; then
    if ! git -C "$repo_root" worktree add "$worktree_path" "$name"; then
      echo "Failed to create worktree '$name'" >&2
      return 1
    fi
  else
    if ! git -C "$repo_root" rev-parse --verify "refs/heads/main" &>/dev/null; then
      echo "Branch 'main' does not exist" >&2
      return 1
    fi

    if ! git -C "$repo_root" worktree add "$worktree_path" -b "$name" main; then
      echo "Failed to create worktree '$name'" >&2
      return 1
    fi
  fi

  _wt_copy_env_files "$repo_root" "$worktree_path"
  echo "Created worktree '$name'" >&2
  echo "$worktree_path"
}

# wt: select/create a worktree + tmux session + open nvim
# Run from anywhere inside a git repo in a fresh kitty tab
function wt() {
  local repo_root
  repo_root=$(_wt_repo_main_root) || return 1

  local name
  name=$(_wt_select_name)
  if [ -z "$name" ]; then
    return 0
  fi

  if _wt_is_open "$name"; then
    echo "Worktree '$name' is already open in Kitty"
    return 1
  fi

  local worktree_path session_name
  worktree_path=$(_wt_create_if_needed "$repo_root" "$name") || return 1
  worktree_path=$(printf '%s\n' "$worktree_path" | tail -n 1)
  session_name=$(_wt_session_name "$repo_root" "$name")

  _wt_open "$name" "$worktree_path" "$session_name"
}

# wx: teardown a worktree — kill its tmux session and remove the worktree
function wx() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -z "$repo_root" ] || ! git -C "$repo_root" rev-parse --git-dir &>/dev/null; then
    echo "Not in a git repository"
    return 1
  fi

  local main_root
  main_root=$(_wt_main_root "$repo_root")
  if [ -z "$main_root" ]; then
    echo "Could not find main worktree"
    return 1
  fi
  repo_root="$main_root"

  local selected
  selected=$(_wt_select_existing_path "$repo_root" "Remove worktree: ")

  if [ -z "$selected" ]; then
    return 0
  fi

  local name session_name
  name=$(basename "$selected")
  session_name=$(_wt_session_name "$repo_root" "$name")

  if [ -n "$(git -C "$selected" status --short)" ]; then
    echo "Worktree '$name' is dirty:"
    git -C "$selected" status --short
    return 1
  fi

  local confirm
  read "confirm?Remove worktree '$name'? [y/N] "
  if [[ "$confirm" != [yY] ]]; then
    echo "Aborted"
    return 0
  fi

  # Step 1: kill tmux session (no-op if already gone)
  tmux kill-session -t "$session_name" 2>/dev/null

  # Step 2: remove the directory
  if [[ -d "$selected" ]]; then
    if ! git -C "$repo_root" worktree remove "$selected"; then
      echo "Failed to remove worktree '$name'"
      return 1
    fi
  fi

  # Step 3: prune stale git references (no-op if already clean)
  git -C "$repo_root" worktree prune

  echo "Removed worktree '$name'"
}

# wr: select a worktree via fzf and run `nr` (dev script) there
# Run from anywhere inside a git repo
function wr() {
  local repo_root
  repo_root=$(_wt_repo_root) || return 1

  local selected
  selected=$(_wt_select "$repo_root" "Worktree: " true)

  if [ -z "$selected" ]; then
    return 0
  fi

  cd "$selected"
  nr
}
