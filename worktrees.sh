# Worktree helpers and commands

# Shared setup for tw/tc: name windows, start tmux session, open tmux window, cd + nvim
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
  /usr/bin/python3 "$kitty_remote" launch --no-response --type=window --title "$name" tmux attach -t "$session_name" 2>/dev/null

  # cd into worktree and open nvim in the first window
  cd "$worktree_path"
  v
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

function _wt_pick_name() {
  local repo_root="$1"
  local -a animals=(wolf bear lion fox otter hawk lynx moose badger raven)
  local total=${#animals[@]}
  local start_index=$((RANDOM % total + 1))
  local offset candidate

  for ((offset = 0; offset < total; offset++)); do
    candidate=${animals[$((((start_index + offset - 1) % total) + 1))]}
    if [ ! -e "$repo_root/.worktrees/$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

# wn: create a git worktree + tmux session + open nvim
# Run from anywhere inside a git repo in a fresh kitty tab
function wn() {
  local repo_root
  repo_root=$(_wt_repo_root) || return 1

  local branch_name
  read "branch_name?New branch name (from main): "
  if [ -z "$branch_name" ]; then
    echo "No branch name provided"
    return 1
  fi

  if git -C "$repo_root" rev-parse --verify "$branch_name" &>/dev/null; then
    echo "Branch '$branch_name' already exists"
    return 1
  fi

  local base_branch
  read "base_branch?Base branch (default: main): "
  base_branch="${base_branch:-main}"
  if ! git -C "$repo_root" rev-parse --verify "$base_branch" &>/dev/null; then
    echo "Branch '$base_branch' does not exist"
    return 1
  fi

  local name
  name=$(_wt_pick_name "$repo_root")
  if [ -z "$name" ]; then
    echo "No worktree spaces available"
    return 1
  fi

  local repo_name worktree_path session_name
  repo_name=$(basename "$repo_root")
  worktree_path="$repo_root/.worktrees/$name"
  session_name="${repo_name}-wt-${name}"

  mkdir -p "$repo_root/.worktrees"

  # Ensure .worktrees/ is gitignored
  local gitignore="$repo_root/.gitignore"
  if [ -f "$gitignore" ] && ! grep -q "^\.worktrees" "$gitignore"; then
    echo ".worktrees" >>"$gitignore"
    echo "Added .worktrees to .gitignore"
  fi

  # Create worktree with a new branch off base_branch
  if ! git -C "$repo_root" worktree add "$worktree_path" -b "$branch_name" "$base_branch"; then
    echo "Failed to create worktree"
    return 1
  fi

  # Copy .env files from repo root to new worktree
  local f
  for f in "$repo_root"/.env*; do
    [[ -f "$f" ]] && cp "$f" "$worktree_path/"
  done

  echo "Created worktree '$name' for branch '$branch_name'"
  _wt_open "$name" "$worktree_path" "$session_name" "nci"
}

# wx: teardown a worktree — kill its tmux session and remove the worktree
function wx() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  # If git fails (e.g. CWD is a deleted worktree), infer main repo from path
  if [ -z "$repo_root" ] && [[ "$PWD" == */.worktrees/* ]]; then
    repo_root="${PWD%/.worktrees/*}"
  fi

  if [ -z "$repo_root" ] || ! git -C "$repo_root" rev-parse --git-dir &>/dev/null; then
    echo "Not in a git repository"
    return 1
  fi

  local selected
  selected=$(_wt_select "$repo_root" "Remove worktree: " false)

  if [ -z "$selected" ]; then
    return 0
  fi

  local main_root name repo_name session_name
  main_root=$(_wt_main_root "$repo_root")
  name=$(basename "$selected")
  repo_name=$(basename "$main_root")
  session_name="${repo_name}-wt-${name}"

  local confirm
  read "confirm?Remove worktree '$name'? [y/N] "
  if [[ "$confirm" != [yY] ]]; then
    echo "Aborted"
    return 0
  fi

  # Step 1: kill tmux session (no-op if already gone)
  tmux kill-session -t "$session_name" 2>/dev/null

  # Step 2: remove the directory
  # git worktree remove --force handles modified tracked files but refuses
  # untracked files; fall back to rm -rf after confirmation
  if [[ -d "$selected" ]]; then
    if ! git -C "$repo_root" worktree remove "$selected" --force 2>/dev/null; then
      echo "Worktree has untracked/dirty files:"
      git -C "$selected" status --short
      local force_confirm
      read "force_confirm?Delete anyway (this cannot be undone)? [y/N] "
      if [[ "$force_confirm" != [yY] ]]; then
        echo "Aborted"
        return 0
      fi
      rm -rf "$selected"
    fi
  fi

  # Step 3: prune stale git references (no-op if already clean)
  git -C "$repo_root" worktree prune

  echo "Removed worktree '$name'"
}

# wo: connect to an existing worktree (like wn but without creating)
# Run from anywhere inside a git repo in a fresh kitty tab
function wo() {
  local repo_root
  repo_root=$(_wt_repo_root) || return 1

  local selected
  selected=$(_wt_select "$repo_root" "Worktree: " false)

  if [ -z "$selected" ]; then
    return 0
  fi

  local main_root name repo_name session_name
  main_root=$(_wt_main_root "$repo_root")
  name=$(basename "$selected")
  repo_name=$(basename "$main_root")
  session_name="${repo_name}-wt-${name}"

  _wt_open "$name" "$selected" "$session_name"
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
