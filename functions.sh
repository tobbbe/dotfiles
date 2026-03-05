# Start an HTTP server from a directory, optionally specifying the port
# why use -c and -p flags: https://stackoverflow.com/a/38295516/1320551
function server() {
  local port="${@:-8022}"
  echo 'https://www.npmjs.com/package/http-server'
  # sleep 2 && open "http://localhost:${port}/" &
  npx http-server -c-1 -p $port
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

function re() {
  code $(f $@ -e)
}

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

function gg() {
  local message="${@:-no message}"
  git add -A && git commit -m "${message}" && git push
}
function gam() {
  local message="${@:-no message}"
  git add -A && git commit -m "${message}"
}

# ex `getProcessByPort 8081`
function portGetProcessId() {
  lsof -n -i4TCP:$@
  printYellow "Kill with: kill (PID == processId)\n" # https://stackoverflow.com/questions/24387451/how-can-i-kill-whatever-process-is-using-port-8080-so-that-i-can-vagrant-up
}

nf() {
  cd "/Users/tobbe/Google Drive/Work/todo"
  v -c 'startinsert'
  cd -
}

function goo() {
  local message="${@:-}"
  open 'https://www.google.com/search?q='${message}
}

# ex: curlPostRe :80/post
# edit with curlEditPostData
# must use quotes around property-names in json!
function curlPostBodyFromFileRe() {
  curl -H "Content-Type: application/json" -X POST --data-binary @/Users/tobbe/Downloads/body.json $@ | jq
}

# ex: curlPost :80/post
function curlPostBodyFromFile() {
  curlEditPostData && curlPostRe $@ | jq
}

# ex: curlPostForm "param1=value1&param2=value2" :80/post
function curlPostForm() {
  curl -X POST --data-urlencode $@
}

function sumlines() {
  awk '{s+=$1} END {print s}' $@
}

function gitStatusRecursive() {
  local underline=$(tput smul)
  local qty_has_changes=0

  local show_no_changes=true
  if [[ $1 == *"-q"* ]]; then
    show_no_changes=false
  fi

  local do_git_fetch=false
  if [[ $1 == *"-f"* ]]; then
    do_git_fetch=true
  fi

  # find all .git directories
  local git_dirs=$(find . -type d -name .git -maxdepth 3)

  # remove ".git" from lines
  local dir_names=$(echo $git_dirs | sed -e "s/\.git//")

  # Create arrays to store repos with and without changes
  local no_changes_repos=()
  local has_changes_repos=()

  echo $dir_names | tr ' ' '\n' | while read line; do
    if [ -z "$line" ]; then
      continue
    fi

    if [ "$do_git_fetch" = true ]; then
      echo "git fetching ${line}"
      (cd $line && git fetch --quiet)
    fi

    local git_output=$(cd $line && git status -s)
    local git_output_length=${#git_output}

    if [[ ${#git_output_length} -gt 1 ]]; then
      has_changes_repos+=("$line")
      ((qty_has_changes++))
    elif [ "$show_no_changes" = true ]; then
      no_changes_repos+=("$line")
    fi
  done

  # Sort the arrays alphabetically, ignoring case
  IFS=$'\n' no_changes_repos=($(sort -f <<<"${no_changes_repos[*]}"))
  IFS=$'\n' has_changes_repos=($(sort -f <<<"${has_changes_repos[*]}"))

  # Display repos without changes first
  for repo in "${no_changes_repos[@]}"; do
    echo -e "\e[32m$repo\e[0m"
  done

  # Display repos with changes last
  for repo in "${has_changes_repos[@]}"; do
    echo -e "\e[31m${underline}$repo\e[0m$(printRed " - has changes")"
    # (cd $repo && git status -s)
  done

  if [ "$qty_has_changes" = "0" ]; then
    printf "\n"
    echo -e "\e[32m🎉 Everything is up to date!\e[0m"
  fi

  printf "\n"
}

function rnclearcache() {
  printRed "⚠️ Clear all the caches...\n"

  echo "🧹🧹🧹 Removing ios/build..."
  rm -rf ios/build

  echo "🧹🧹🧹 Deleting all DerivedData folders..."
  rm -rf ~/Library/Developer/Xcode/DerivedData/*

  echo "🧹🧹🧹 Running xcode clean..."
  cd ios
  xcodebuild clean
  cd -

  echo "🧹🧹🧹 Removing watchman watches..."
  watchman watch-del-all
  watchman shutdown-server

  # Using node_modules so must run after npm i
  echo "🧹🧹🧹 Cleaning android gradlew..."
  cd android && ./gradlew --no-daemon clean && cd -
}

function rnyolo() {
  echo "🧹🧹🧹 Removing node_modules..."
  rm -rf node_modules

  echo "🧹🧹🧹 Removing package-lock.json..."
  rm package-lock.json

  ## echo "🧹🧹🧹 Deintegrate CocoaPods from your project...";
  ## DANGER, removes build phases in xcode etc:  cd ios && pod deintegrate && cd -

  echo "🧹🧹🧹 Removing ios/Pods..."
  rm -rf ios/Pods

  echo "🧹🧹🧹 Removing ios/Podfile.lock..."
  rm ios/Podfile.lock

  echo "🤠🤠🤠 Running npm install..."
  npm i

  rnclearcache

  echo "🤠🤠🤠 Running pod install..."
  cd ios && pod install && cd -

  printYellow "\nDone! 🎉\n"
  printRed "🚨 Also try restart bundler with \`react-native start --reset-cache\`\n"
}

# go to finderpath: `cd $(finderpath)`
function finderpath() {
  osascript -e 'tell application "Finder" to get the POSIX path of (target of front window as alias)'
}

# function gfgo() {
# 	if [[ $@ = *" "* ]]; then
#   		echo "Release name cant contain spaces"
# 		return 1;
#   	fi
#
# 	if [ $# -eq 0 ]; then
# 		echo 'Please name release'
# 		return 1;
# 	else
# 		git flow release start $@
# 		GIT_MERGE_AUTOEDIT=no git flow release finish -m '$@' -n $@
# 		echo 'Dont forget to push!'
# 	fi;
# }

function countLetters() {
  local str="${@:-}"
  echo ${#str}
}

function minifyVideo() {
  ffmpeg -i $1 -c:v libx265 -preset fast -crf 28 -tag:v hvc1 -c:a eac3 -b:a 224k $2.mp4
}

timer() {
  start="$(($(date '+%s') + $1))"
  spin='-\|/'
  echo "Timer: $1s"
  while [ $start -ge $(date +%s) ]; do
    # time="$(( $start - $(date +%s) ))"
    # echo -ne "."
    i=$(((i + 1) % 4))
    printf "\r${spin:$i:1}"
    sleep 0.1
  done
  osascript -e 'display notification "🚨" with title "Timer"'
  say 'Timer finished!'
  osascript -e 'display notification "⏰" with title "Timer"'
  sleep 0.6
  osascript -e 'display notification "🚨" with title "Timer"'
  sleep 0.6
  osascript -e 'display notification "⏰" with title "Timer"'
  sleep 0.6
  osascript -e 'display notification "🚨" with title "Timer"'
}

function startDocker() {
  printf "Starting Docker"
  open -a Docker

  while [[ -z "$(! docker stats --no-stream 2>/dev/null)" ]]; do
    printf "."
    sleep 1
  done

  echo ""
}

function ff() {
  local dirr=$*
  local hasnav=false
  if [[ -n $dirr ]]; then
    if [[ -d $dirr ]]; then
      # if subdir exist, go there
      hasnav=true
      cd $dirr
    elif [[ ! -z $(f -e $dirr) ]]; then
      # if z find something, go there
      f "$dirr"
      hasnav=true
    fi
  fi

  local fpath=$(fzf --bind 'f2:execute-silent(code {})' --preview 'bat --style=numbers --color=always --line-range :500 {}')
  [ -z $fpath ] || code $fpath
  # [[ $hasnav ]] && cd - > /dev/null
}

# find in files
fif() {
  local dirr=$*
  local hasnav=false
  if [[ -n $dirr ]]; then
    if [[ -d $dirr ]]; then
      # if subdir exist, go there
      hasnav=true
      cd $dirr
    elif [[ ! -z $(f -e $dirr) ]]; then
      # if z find something, go there
      f "$dirr"
      hasnav=true
    fi
  fi

  selected=$(
    fzf \
      -m \
      -e \
      --ansi \
      --disabled \
      --reverse \
      --bind "ctrl-a:select-all" \
      --bind "f2:execute-silent(code {})" \
      --bind "change:reload:rg -i -l --hidden {q} || true" \
      --preview "rg -i --pretty --context 2 {q} {}" | cut -d":" -f1,2
  )

  [[ -n $selected ]] && code $selected # open multiple files in editor
  # [[ $hasnav ]] && cd - > /dev/null
}

function da() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker attach "$cid"
}

function sshproxy() {
  # create with `mkcert "*.https.localhost"`
  # CANNOT be "*.localhost". Must have subdomain before wildcard
  local-ssl-proxy --source ${2:-3010} --target ${1:-3000} --cert ~/_wildcard.https.localhost.pem --key ~/_wildcard.https.localhost-key.pem
}

function jsontocsv() {
  if [ -z "$1" ]; then
    echo "\033[0;31mNo file selected"
    return -1
  fi

  filename="$(basename -- $1)"
  outputName="${filename/json/csv}"

  jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' $1 >$outputName
}

function testIfYouHaveAccessToFns() {
  osascript -e 'display dialog ("HI!")'
}

# example: replaceInConfig API2_ORIGIN "http:\/\/"$(localip) .env.development.local
replaceInConfig() {
  local file=$3
  sed -E -i '' "/^$1=/{s/=.+/=$2/;}" "$file"
  printRed "\nDont forget to restart build job!\n\n"
}

printRed() {
  local RED='\033[1;31m'
  local NC='\033[0m'     # No Color
  printf "${RED}$1${NC}" # printf doesnt send end-of-line. So add \n after your input to skip "%"
}
printYellow() {
  local YELLOW='\033[0;33m'
  local NC='\033[0m'        # No Color
  printf "${YELLOW}$1${NC}" # printf doesnt send end-of-line. So add \n after your input to skip "%"
}

generate_random_string() {
  local length=$1
  local random_string=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1)
  echo "$random_string"
}

function setgituser {
  if [ "$#" -eq 0 ]; then
    printRed "Error: You have to pass an email address!\n"
    return 1
  else
    git config user.email "$@"
    git config user.name "Tobias Ekman"

    echo "✅ Git config set to:"
    echo "Name: $(git config user.name)"
    echo "Email: $(git config user.email)"
  fi
}

function rni() {
  if [ -z "$1" ]; then
    simulator_name="iPhone 15 Pro"
  else
    simulator_name="$1"
  fi

  if ! xcrun simctl list | grep -Fq "Booted"; then
    xcrun simctl boot "$simulator_name"
  else
    echo "🆗 "$simulator_name" simulator already booted"
  fi

  open -a Simulator

  npm start

  sleep 2
  osascript -e 'tell application "System Events" to key code 34'
}

function pi() {
  if [[ "$PWD" != */ios ]]; then
    cd ios
  fi

  pod install
  cd ..
}

foreachline() {
  # usage: doforlines <file> <command>
  local file="$1"
  shift
  while IFS= read -r line || [ -n "$line" ]; do
    "$@" "$line"
  done <"$file"
}

# usage: getwithenvvar CRON_SECRET https://url --extra-httpie-params(optional)
# example: getwithenvvar CRON_SECRET https://url -v (verbose) --follow (follow redirects)
function getwithenvvar() {
  local variable_name=$1
  local url=$2
  local current_dir=$(pwd)
  local env_file="${current_dir}/.env.local"
  local secret_value
  # Read in the target variable from the environment file
  if [ -f "$env_file" ]; then
    secret_value=$(grep -m 1 "^${variable_name}=" "$env_file" | cut -d '=' -f2-)
    # Remove surrounding double quotes only if both are present
    if [[ $secret_value == \"*\" && $secret_value == *\" ]]; then
      secret_value="${secret_value%\"}"
      secret_value="${secret_value#\"}"
    fi
  fi
  # Ensure the variable was actually found and is not empty
  if [ -z "$secret_value" ]; then
    echo "The variable '${variable_name}' was not set or is empty."
    return 1
  fi

  http $3 $4 $5 $6 -A bearer -a "$secret_value" "$url"
}

function mitm_on() {
  networksetup -setsecurewebproxystate wi-fi on
  networksetup -setwebproxystate wi-fi on

  networksetup -setwebproxy wi-fi localhost 8080
  networksetup -setsecurewebproxy wi-fi localhost 8080
}

function mitm_off() {
  networksetup -setsecurewebproxystate wi-fi off
  networksetup -setwebproxystate wi-fi off
}

function code() {
  # open current directory in vscode
  if [ $# -eq 0 ]; then
    open -a "Visual Studio Code" .
  else
    open -a "Visual Studio Code" $@
  fi
}

function t() {
  if [ -z "$1" ]; then
    # No name provided, try to attach to any existing session
    if tmux attach 2>/dev/null; then
      return 0
    fi
    # No sessions exist, create "dotfiles" in ~/dev/dotfiles/
    tmux new-session -d -s "dotfiles" -c "$HOME/dev/dotfiles/" 2>/dev/null
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "dotfiles"
    else
      tmux attach -t "dotfiles"
    fi
  else
    local session_name="$1"
    tmux new-session -d -s "$session_name" 2>/dev/null
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session_name"
    else
      tmux attach -t "$session_name"
    fi
  fi
}

function ta() {
  local cwd_name
  cwd_name="$(basename "$PWD")"
  local session_name="Tmux - ${cwd_name}"

  tmux new-session -d -s "$session_name" -c "$PWD" 2>/dev/null

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach -t "$session_name"
  fi
}

function tk() {
  if [ -z "$1" ]; then
    tmux kill-session
  else
    tmux kill-session -t "$1"
  fi
}

# Shared setup for tw/tc: rename tab, start tmux session, open tmux window, cd + nvim
function _wt_open() {
  local name="$1" worktree_path="$2" session_name="$3"

  # Create tmux session rooted in the worktree (no-op if already exists)
  tmux new-session -d -s "$session_name" -c "$worktree_path" 2>/dev/null

  # Rename the current kitty tab
  kitty @ set-tab-title "$name" 2>/dev/null

  # Open a second kitty window in this tab attached to the tmux session
  kitty @ launch --no-response --type=window tmux attach -t "$session_name" 2>/dev/null

  # cd into worktree and open nvim in the first window
  cd "$worktree_path"
  v
}

# tw: create a git worktree + tmux session + open nvim
# Run from anywhere inside a git repo in a fresh kitty tab
function tw() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_root" ]; then
    echo "Not in a git repository"
    return 1
  fi

  local name
  read "name?Worktree name: "
  if [ -z "$name" ]; then
    echo "No name provided"
    return 1
  fi

  # Early checks before creating anything
  if git -C "$repo_root" rev-parse --verify "$name" &>/dev/null; then
    echo "Branch '$name' already exists"
    return 1
  fi
  if [ -e "$repo_root/.worktrees/$name" ]; then
    echo "Worktree '$name' already exists"
    return 1
  fi

  local base_branch
  read "base_branch?Base branch (default: main): "
  base_branch="${base_branch:-main}"
  if ! git -C "$repo_root" rev-parse --verify "$base_branch" &>/dev/null; then
    echo "Branch '$base_branch' does not exist"
    return 1
  fi

  local repo_name worktree_path session_name
  repo_name=$(basename "$repo_root")
  worktree_path="$repo_root/.worktrees/$name"
  session_name="${repo_name}-wt-${name}"

  # Ensure .worktrees/ is gitignored
  local gitignore="$repo_root/.gitignore"
  if [ -f "$gitignore" ] && ! grep -q "^\.worktrees" "$gitignore"; then
    echo ".worktrees" >> "$gitignore"
    echo "Added .worktrees to .gitignore"
  fi

  # Create worktree with a new branch off base_branch
  if ! git -C "$repo_root" worktree add "$worktree_path" -b "$name" "$base_branch"; then
    echo "Failed to create worktree"
    return 1
  fi

  _wt_open "$name" "$worktree_path" "$session_name"
}

# td: teardown a worktree — kill its tmux session and remove the worktree
function td() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_root" ]; then
    echo "Not in a git repository"
    return 1
  fi

  local selected
  selected=$(git -C "$repo_root" worktree list --porcelain \
    | awk '/^worktree /{print $2}' \
    | grep -v "^${repo_root}$" \
    | fzf --prompt="Remove worktree: ")

  if [ -z "$selected" ]; then
    return 0
  fi

  local name repo_name session_name
  name=$(basename "$selected")
  repo_name=$(basename "$repo_root")
  session_name="${repo_name}-wt-${name}"

  # Kill tmux session if it exists
  tmux kill-session -t "$session_name" 2>/dev/null

  # Remove the worktree
  if ! git -C "$repo_root" worktree remove "$selected" --force; then
    echo "Failed to remove worktree"
    return 1
  fi

  echo "Removed worktree '$name'"
}

# tc: connect to an existing worktree (like tw but without creating)
# Run from anywhere inside a git repo in a fresh kitty tab
function tc() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_root" ]; then
    echo "Not in a git repository"
    return 1
  fi

  local selected
  selected=$(git -C "$repo_root" worktree list --porcelain \
    | awk '/^worktree /{print $2}' \
    | grep -v "^${repo_root}$" \
    | fzf --prompt="Worktree: ")

  if [ -z "$selected" ]; then
    return 0
  fi

  local name repo_name session_name
  name=$(basename "$selected")
  repo_name=$(basename "$repo_root")
  session_name="${repo_name}-wt-${name}"

  _wt_open "$name" "$selected" "$session_name"
}

# wr: select a worktree via fzf and run `nr` (dev script) there
# Run from anywhere inside a git repo
function wr() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_root" ]; then
    echo "Not in a git repository"
    return 1
  fi

  local selected
  selected=$(git -C "$repo_root" worktree list --porcelain | awk '/^worktree /{print $2}' | fzf --prompt="Worktree: ")

  if [ -z "$selected" ]; then
    return 0
  fi

  cd "$selected"
  nr
}

# edit/clear history in v ~/.vv_history
function vv() {
  local history_file=~/.vv_history
  local dir selected
  local history_mapping=""
  declare -A seen_paths
  local original_dir="$PWD"

  # Clean history file (remove empty lines)
  if [ -f "$history_file" ]; then
    grep -v '^$' "$history_file" >"${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
  fi

  # Build history section (last 5 unique, excluding current)
  local history_list=""
  if [ -f "$history_file" ]; then
    local count=1
    local skip_first=true
    while IFS= read -r hist_dir && [ $count -le 5 ]; do
      if [[ -z "$hist_dir" ]]; then
        continue
      fi
      if [[ "$skip_first" == true ]]; then
        skip_first=false
        continue
      fi
      if [[ -z "${seen_paths[$hist_dir]}" ]]; then
        local hist_name=$(basename "$hist_dir")
        local label="($count) $hist_name"
        history_list+="$label"$'\n'
        history_mapping+="$label|$hist_dir"$'\n'
        seen_paths["$hist_dir"]=1
        ((count++))
      fi
    done < <(tail -r "$history_file")
  fi

  # Build remaining directories (excluding those in history)
  local other_list=""
  while IFS= read -r d; do
    if [[ -n "$d" ]] && [[ -z "${seen_paths[$d]}" ]]; then
      local display_path="${d/#$HOME/~}"
      other_list+="$display_path"$'\n'
    fi
  done < <(
    find ~/dev -maxdepth 1 -type d -not -path ~/dev 2>/dev/null
    echo ~/.config/nvim
  )

  # Show in fzf (preserves order: history first, then others)
  selected=$(echo -n "${history_list}${other_list}" | fzf +m --no-sort)

  if [[ -n $selected ]]; then
    # Resolve to full path
    if [[ "$selected" == "("*") "* ]]; then
      # Look up in mapping string
      dir=$(echo "$history_mapping" | grep -F "$selected|" | cut -d'|' -f2)
      if [[ -z "$dir" ]]; then
        echo "Error: Could not resolve directory from history"
        return 1
      fi
    else
      dir="${selected/#\~/$HOME}"
    fi

    if [[ -z "$dir" ]]; then
      echo "Error: Could not resolve directory"
      return 1
    fi

    # Save to history (remove previous occurrences first)
    if [ -f "$history_file" ]; then
      grep -Fxv "$dir" "$history_file" >"${history_file}.tmp" 2>/dev/null || true
      mv "${history_file}.tmp" "$history_file"
    fi
    echo "$dir" >>"$history_file"
    cd $dir
    nvim +"lua vim.cmd('cd ' .. vim.fn.fnameescape('$dir')); require('persistence').load()"
  else
    # User cancelled (Ctrl-C), reopen nvim in current directory with persistence
    nvim +"lua vim.cmd('cd ' .. vim.fn.fnameescape('$original_dir')); require('persistence').load()"
  fi

  echo -ne "\033[1A\r\033[2K"
}

function v() {
  if [ $# -eq 0 ]; then
    nvim +"lua require(\"persistence\").load()"
  else
    nvim $@
  fi

  echo -ne "\033[1A\r\033[2K"
}

function resizeAndConvertImagesInFolder() {
  # Default values
  width=2000
  quality=90

  # Parse command line arguments
  while getopts "w:q:" opt; do
    case $opt in
    w) width=$OPTARG ;;
    q) quality=$OPTARG ;;
    *) ;;
    esac
  done

  rm -rf resized_images
  mkdir -p resized_images

  # Find all image files and process them
  find . -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | while read img; do
    # Get filename without extension
    filename=$(basename -- "$img")
    name="${filename%.*}"

    # Resize and convert to jpg with specified quality
    sips --resampleWidth $width --setProperty format jpeg --setProperty formatOptions $quality "$img" --out "resized_images/${name}.jpg"
  done

  echo "All images have been resized to width $width with quality $quality and saved to the resized_images directory"
}

function videoToGif() {
  ffmpeg -ss 00:00:26 -t 12 -i input.mp4 \
    -vf "fps=30,split[s0][s1];[s0]palettegen=max_colors=256[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" output.gif
}
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m) &&
    cd "$dir"
}
f() {
  if [[ $# -eq 0 ]]; then
    # No arguments - use find for current directory
    local file
    file="$(find . -type d \( -name .git -o -name node_modules -o -name Pods -o -name .next \) -prune -o \( -type f -o -type d \) -print 2>/dev/null | fzf --preview 'if [ -f {} ]; then bat --color=always {}; fi')"

    if [[ -n $file ]]; then
      if [[ -d $file ]]; then
        cd -- $file
      else
        nvim "$file"
      fi
    fi
  else
    # Arguments provided - use zoxide to jump
    __zoxide_z "$@"
  fi
}

s() {
  local server
  server=$(awk '/^Host / { host=$2 } /IdentityFile ~\/.ssh\/servers/ { print host }' ~/.ssh/config | fzf)
  if [[ -n $server ]]; then
    ssh $server
  fi
}
